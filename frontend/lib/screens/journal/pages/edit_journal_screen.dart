import 'package:flutter/material.dart';
import '../../../services/journal_api.dart';
import 'package:muud_health_app/theme/app_theme.dart';

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
      Navigator.pop(context, true); // ✅ tells Home to reload
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.purple),
        title: const Text(
          "Edit Journal",
          style: TextStyle(color: AppTheme.purple, fontWeight: FontWeight.w900),
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
                      color: AppTheme.purple,
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
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.25)),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (_error != null) const SizedBox(height: 12),
            const Text(
              "Caption",
              style: TextStyle(color: AppTheme.purple, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _captionCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Update your caption… #hashtags",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
