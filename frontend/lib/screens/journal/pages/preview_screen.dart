import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

import 'send_to_screen.dart';

class PreviewScreen extends StatefulWidget {
  final File imageFile;
  final String? audioPath;
  final String initialVisibility; // Public | Inner Circle | Connections

  const PreviewScreen({
    super.key,
    required this.imageFile,
    this.audioPath,
    this.initialVisibility = "Public",
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  static const Color kPurple = Color(0xFF5B288E);

  final _captionCtrl = TextEditingController();
  final _player = AudioPlayer();

  bool _playing = false;

  File? _workingImage;

  // ✅ overlays
  final ScreenshotController _shot = ScreenshotController();
  final List<_TextOverlay> _texts = [];
  int? _selectedTextId;

  String _visibility = "Public";

  @override
  void initState() {
    super.initState();
    _workingImage = widget.imageFile;
    _visibility = widget.initialVisibility;
  }

  @override
  void dispose() {
    _captionCtrl.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (widget.audioPath == null) return;

    if (_playing) {
      await _player.stop();
      setState(() => _playing = false);
      return;
    }

    await _player.play(DeviceFileSource(widget.audioPath!));
    setState(() => _playing = true);

    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playing = false);
    });
  }

  void _cycleVisibility() {
    setState(() {
      if (_visibility == "Public") {
        _visibility = "Inner Circle";
      } else if (_visibility == "Inner Circle") {
        _visibility = "Connections";
      } else {
        _visibility = "Public";
      }
    });
  }

  Future<void> _crop() async {
    final img = _workingImage;
    if (img == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: img.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Crop'),
      ],
    );

    if (cropped == null) return;

    setState(() {
      _workingImage = File(cropped.path);
    });
  }

  Future<void> _addText() async {
    final txt = await _askText();
    if (txt == null || txt.trim().isEmpty) return;

    setState(() {
      _texts.add(
        _TextOverlay(
          id: DateTime.now().millisecondsSinceEpoch,
          text: txt.trim(),
          dx: 0.5,
          dy: 0.5,
          fontSize: 28,
        ),
      );
      _selectedTextId = _texts.last.id;
    });
  }

  Future<String?> _askText() async {
    final c = TextEditingController();
    final out = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add text"),
        content: TextField(
          controller: c,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Type something…"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, c.text),
            child: const Text("Add"),
          ),
        ],
      ),
    );
    c.dispose();
    return out;
  }

  void _deleteSelectedText() {
    final id = _selectedTextId;
    if (id == null) return;
    setState(() {
      _texts.removeWhere((t) => t.id == id);
      _selectedTextId = null;
    });
  }

  Future<File> _renderEditedImageToFile() async {
    // capture the image+overlay stack as bytes
    final Uint8List? bytes = await _shot.capture(
      pixelRatio: 2.5,
      delay: const Duration(milliseconds: 50),
    );

    if (bytes == null) return _workingImage ?? widget.imageFile;

    final dir = await getTemporaryDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final f = File("${dir.path}/muud_edited_$ts.png");
    await f.writeAsBytes(bytes);
    return f;
  }

  Future<void> _goSend() async {
    final base = _workingImage ?? widget.imageFile;

    // If there are overlays, bake them into the image
    File finalImg = base;
    if (_texts.isNotEmpty) {
      finalImg = await _renderEditedImageToFile();
    }

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SendToScreen(
          imageFile: finalImg,
          audioPath: widget.audioPath,
          caption: _captionCtrl.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasAudio = widget.audioPath != null;
    final img = _workingImage ?? widget.imageFile;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // ✅ editable canvas
            Positioned.fill(
              child: Screenshot(
                controller: _shot,
                child: _Canvas(
                  imageFile: img,
                  texts: _texts,
                  selectedId: _selectedTextId,
                  onTapText: (id) => setState(() => _selectedTextId = id),
                  onMoveText: (id, dx, dy) {
                    setState(() {
                      final i = _texts.indexWhere((t) => t.id == id);
                      if (i >= 0) {
                        _texts[i] = _texts[i].copyWith(dx: dx, dy: dy);
                      }
                    });
                  },
                ),
              ),
            ),

            // Top bar
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: _goSend,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Text(
                        "Send",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom bar (crop + text + mic preview)
            Positioned(
              left: 0,
              right: 0,
              bottom: 18,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _cycleVisibility,
                      child: _pill(label: _visibility),
                    ),
                    const SizedBox(width: 10),

                    _circleIcon(icon: Icons.crop, onTap: _crop),
                    const SizedBox(width: 10),

                    _circleIcon(icon: Icons.text_fields, onTap: _addText),
                    const SizedBox(width: 10),

                    if (_selectedTextId != null)
                      _circleIcon(
                        icon: Icons.delete_outline,
                        onTap: _deleteSelectedText,
                      ),

                    const Spacer(),

                    if (hasAudio)
                      GestureDetector(
                        onTap: _togglePlay,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _playing ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                "Voice",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Caption chip centered (like your figma overlay text area)
            Positioned(
              left: 20,
              right: 20,
              bottom: 86,
              child: TextField(
                controller: _captionCtrl,
                maxLines: 1,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
                decoration: InputDecoration(
                  hintText: "#happy, #ootd, #healing",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.25),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.25),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.15),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill({required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _circleIcon({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _Canvas extends StatelessWidget {
  final File imageFile;
  final List<_TextOverlay> texts;
  final int? selectedId;
  final void Function(int id) onTapText;
  final void Function(int id, double dx, double dy) onMoveText;

  const _Canvas({
    required this.imageFile,
    required this.texts,
    required this.selectedId,
    required this.onTapText,
    required this.onMoveText,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final w = c.maxWidth;
        final h = c.maxHeight;

        return Stack(
          fit: StackFit.expand,
          children: [
            Image.file(imageFile, fit: BoxFit.cover),

            // overlays
            ...texts.map((t) {
              final left = (t.dx.clamp(0.0, 1.0)) * (w - 10);
              final top = (t.dy.clamp(0.0, 1.0)) * (h - 10);
              final selected = t.id == selectedId;

              return Positioned(
                left: left,
                top: top,
                child: GestureDetector(
                  onTap: () => onTapText(t.id),
                  onPanUpdate: (d) {
                    final ndx = ((left + d.delta.dx) / (w - 10)).clamp(
                      0.0,
                      1.0,
                    );
                    final ndy = ((top + d.delta.dy) / (h - 10)).clamp(0.0, 1.0);
                    onMoveText(t.id, ndx, ndy);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: selected
                        ? BoxDecoration(
                            color: Colors.black.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                            ),
                          )
                        : null,
                    child: Text(
                      t.text,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: t.fontSize,
                        fontWeight: FontWeight.w900,
                        shadows: const [
                          Shadow(blurRadius: 8, offset: Offset(0, 2)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _TextOverlay {
  final int id;
  final String text;
  final double dx; // 0..1
  final double dy; // 0..1
  final double fontSize;

  const _TextOverlay({
    required this.id,
    required this.text,
    required this.dx,
    required this.dy,
    required this.fontSize,
  });

  _TextOverlay copyWith({
    String? text,
    double? dx,
    double? dy,
    double? fontSize,
  }) {
    return _TextOverlay(
      id: id,
      text: text ?? this.text,
      dx: dx ?? this.dx,
      dy: dy ?? this.dy,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}
