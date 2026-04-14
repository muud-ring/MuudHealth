// MUUD Health — Edit Journal Screen
// Caption editing for journal posts
// © Muud Health — Armin Hoes, MD

import 'package:flutter/material.dart';
import '../../../services/journal_api.dart';
import '../../../theme/app_theme.dart';

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
    setState(() { _saving = true; _error = null; });

    try {
      await JournalApi.updatePost(
        postId: widget.postId,
        caption: _captionCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
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
        title: Text(
          "Edit Journal",
          style: MuudTypography.titleMedium.copyWith(color: MuudColors.purple),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: MuudColors.purple),
                  )
                : Text(
                    "Save",
                    style: MuudTypography.label.copyWith(
                      color: MuudColors.purple,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(MuudSpacing.base, MuudSpacing.md, MuudSpacing.base, MuudSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(MuudSpacing.md),
                decoration: BoxDecoration(
                  color: MuudColors.error.withValues(alpha: 0.08),
                  borderRadius: MuudRadius.mdAll,
                  border: Border.all(color: MuudColors.error.withValues(alpha: 0.25)),
                ),
                child: Text(
                  _error!,
                  style: MuudTypography.bodySmall.copyWith(color: MuudColors.error),
                ),
              ),
              const SizedBox(height: MuudSpacing.md),
            ],
            Text(
              "Caption",
              style: MuudTypography.label.copyWith(color: MuudColors.purple, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: MuudSpacing.sm),
            TextField(
              controller: _captionCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Update your caption… #hashtags",
                border: OutlineInputBorder(borderRadius: MuudRadius.mdAll),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
