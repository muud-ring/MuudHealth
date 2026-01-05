import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'preview_screen.dart';

class CreatorToolScreen extends StatefulWidget {
  const CreatorToolScreen({super.key});

  @override
  State<CreatorToolScreen> createState() => _CreatorToolScreenState();
}

class _CreatorToolScreenState extends State<CreatorToolScreen> {
  static const Color kPurple = Color(0xFF5B288E);

  final _picker = ImagePicker();
  final _recorder = AudioRecorder();

  File? _imageFile;
  String? _audioPath;

  bool _recording = false;
  String? _error;

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _error = null);
    try {
      final x = await _picker.pickImage(
        source: source,
        imageQuality: 92,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (x == null) return;

      setState(() => _imageFile = File(x.path));
    } catch (e) {
      setState(() => _error = "Failed to get image: $e");
    }
  }

  Future<String> _newAudioPath() async {
    final dir = await getTemporaryDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    return "${dir.path}/muud_voice_$ts.m4a";
  }

  Future<void> _toggleRecord() async {
    setState(() => _error = null);

    try {
      if (_recording) {
        final path = await _recorder.stop();
        setState(() {
          _recording = false;
          _audioPath = path ?? _audioPath;
        });
        return;
      }

      final ok = await _recorder.hasPermission();
      if (!ok) {
        setState(() => _error = "Microphone permission denied.");
        return;
      }

      final path = await _newAudioPath();
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      setState(() {
        _recording = true;
        _audioPath = null; // overwrite any old one
      });
    } catch (e) {
      setState(() => _error = "Audio recording failed: $e");
    }
  }

  void _goNext() {
    if (_imageFile == null) {
      setState(() => _error = "Add a photo to continue.");
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            PreviewScreen(imageFile: _imageFile!, audioPath: _audioPath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Main canvas
            Positioned.fill(
              child: _imageFile == null
                  ? const Center(
                      child: Text(
                        "Add a photo (camera or gallery)",
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : Image.file(_imageFile!, fit: BoxFit.cover),
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
                    onTap: _goNext,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Text(
                        "Next",
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

            // Error banner
            if (_error != null)
              Positioned(
                left: 16,
                right: 16,
                top: 64,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.4)),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),

            // Bottom bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 18,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _pill(label: "Public"),
                    const SizedBox(width: 10),

                    // ✅ Camera
                    _circleIcon(
                      icon: Icons.photo_camera_outlined,
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                    const SizedBox(width: 10),

                    // ✅ Gallery
                    _circleIcon(
                      icon: Icons.photo_library_outlined,
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),
                    const SizedBox(width: 10),

                    // Mic
                    _circleIcon(
                      icon: _recording ? Icons.stop : Icons.mic_none,
                      onTap: _toggleRecord,
                      active: _recording,
                    ),

                    const Spacer(),
                    _sendToButton(label: "Next", onTap: _goNext),
                  ],
                ),
              ),
            ),

            // Tiny status text
            if (_audioPath != null && !_recording)
              Positioned(
                left: 16,
                bottom: 86,
                child: Text(
                  "Voice note ready",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (_recording)
              Positioned(
                left: 16,
                bottom: 86,
                child: Text(
                  "Recording… tap stop",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w800,
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

  Widget _circleIcon({
    required IconData icon,
    required VoidCallback onTap,
    bool active = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: active ? kPurple : Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _sendToButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: kPurple,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
