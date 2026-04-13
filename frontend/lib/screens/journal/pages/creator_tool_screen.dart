// MUUD Health — Creator Tool Screen
// Camera, gallery, and voice note capture
// Signal Pathway: Signal layer (content creation)
// © Muud Health — Armin Hoes, MD

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../theme/app_theme.dart';
import 'preview_screen.dart';

class CreatorToolScreen extends StatefulWidget {
  const CreatorToolScreen({super.key});

  @override
  State<CreatorToolScreen> createState() => _CreatorToolScreenState();
}

class _CreatorToolScreenState extends State<CreatorToolScreen> {
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
        setState(() { _recording = false; _audioPath = path ?? _audioPath; });
        return;
      }

      final ok = await _recorder.hasPermission();
      if (!ok) {
        setState(() => _error = "Microphone permission denied.");
        return;
      }

      final path = await _newAudioPath();
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000, sampleRate: 44100),
        path: path,
      );
      setState(() { _recording = true; _audioPath = null; });
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
        builder: (_) => PreviewScreen(imageFile: _imageFile!, audioPath: _audioPath),
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
                  ? Center(
                      child: Text(
                        "Add a photo (camera or gallery)",
                        style: MuudTypography.bodyMedium.copyWith(color: Colors.white70),
                      ),
                    )
                  : Image.file(_imageFile!, fit: BoxFit.cover),
            ),

            // Top bar
            Positioned(
              top: MuudSpacing.sm, left: MuudSpacing.sm, right: MuudSpacing.sm,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: _goNext,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: MuudSpacing.sm, vertical: MuudSpacing.sm),
                      child: Text("Next", style: MuudTypography.label.copyWith(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),

            // Error banner
            if (_error != null)
              Positioned(
                left: MuudSpacing.base, right: MuudSpacing.base, top: 64,
                child: Container(
                  padding: const EdgeInsets.all(MuudSpacing.sm),
                  decoration: BoxDecoration(
                    color: MuudColors.error.withValues(alpha: 0.2),
                    borderRadius: MuudRadius.mdAll,
                    border: Border.all(color: MuudColors.error.withValues(alpha: 0.4)),
                  ),
                  child: Text(_error!, style: MuudTypography.bodySmall.copyWith(color: Colors.white)),
                ),
              ),

            // Bottom bar
            Positioned(
              left: 0, right: 0, bottom: MuudSpacing.lg,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: MuudSpacing.base),
                child: Row(
                  children: [
                    _pill(label: "Public"),
                    const SizedBox(width: MuudSpacing.sm),
                    _circleIcon(icon: Icons.photo_camera_outlined, onTap: () => _pickImage(ImageSource.camera)),
                    const SizedBox(width: MuudSpacing.sm),
                    _circleIcon(icon: Icons.photo_library_outlined, onTap: () => _pickImage(ImageSource.gallery)),
                    const SizedBox(width: MuudSpacing.sm),
                    _circleIcon(icon: _recording ? Icons.stop : Icons.mic_none, onTap: _toggleRecord, active: _recording),
                    const Spacer(),
                    _sendToButton(label: "Next", onTap: _goNext),
                  ],
                ),
              ),
            ),

            if (_audioPath != null && !_recording)
              Positioned(
                left: MuudSpacing.base, bottom: 86,
                child: Text("Voice note ready", style: MuudTypography.label.copyWith(color: Colors.white.withValues(alpha: 0.8))),
              ),
            if (_recording)
              Positioned(
                left: MuudSpacing.base, bottom: 86,
                child: Text("Recording… tap stop", style: MuudTypography.label.copyWith(color: Colors.white.withValues(alpha: 0.9))),
              ),
          ],
        ),
      ),
    );
  }

  Widget _pill({required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: MuudSpacing.base, vertical: MuudSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: MuudRadius.pillAll,
      ),
      child: Text(label, style: MuudTypography.label.copyWith(color: Colors.white)),
    );
  }

  Widget _circleIcon({required IconData icon, required VoidCallback onTap, bool active = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: active ? MuudColors.purple : Colors.white.withValues(alpha: 0.15),
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
        padding: const EdgeInsets.symmetric(horizontal: MuudSpacing.lg, vertical: MuudSpacing.md),
        decoration: BoxDecoration(
          color: MuudColors.purple,
          borderRadius: MuudRadius.pillAll,
        ),
        child: Text(label, style: MuudTypography.button.copyWith(color: MuudColors.white)),
      ),
    );
  }
}
