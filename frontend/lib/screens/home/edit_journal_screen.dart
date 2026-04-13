import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/journal_api.dart';
import '../../theme/app_theme.dart';

class EditJournalScreen extends StatefulWidget {
  final String postId;
  final String initialCaption;

  const EditJournalScreen({
    super.key,
    required this.postId,
    required this.initialCaption,
  });

  @override
  State<EditJournalScreen> createState() => _EditJournalScreenState();
}

class _EditJournalScreenState extends State<EditJournalScreen> {
  late final TextEditingController _captionCtrl;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _captionCtrl = TextEditingController(text: widget.initialCaption);
  }

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await JournalApi.updatePost(
        postId: widget.postId,
        caption: _captionCtrl.text.trim(),
      );

      if (!mounted) return;
      context.pop(true); // ✅ tells Home to reload feed
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MuudColors.white,
      appBar: AppBar(
        backgroundColor: MuudColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: MuudColors.purple),
        title: const Text(
          "Edit Journal",
          style: TextStyle(color: MuudColors.purple, fontWeight: FontWeight.w900),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    "Save",
                    style: TextStyle(
                      color: MuudColors.purple,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: MuudColors.error.withValues(alpha:0.08),
                  borderRadius: MuudRadius.mdAll,
                  border: Border.all(color: MuudColors.error.withValues(alpha:0.25)),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: MuudColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (_error != null) const SizedBox(height: 12),

            const Text(
              "Caption",
              style: TextStyle(color: MuudColors.purple, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _captionCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Update your caption… #hashtags",
                border: OutlineInputBorder(
                  borderRadius: MuudRadius.mdAll,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
