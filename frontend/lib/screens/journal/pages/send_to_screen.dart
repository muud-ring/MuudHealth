// MUUD Health — Send To Screen
// Visibility selection and recipient picker for journal posts
// © Muud Health — Armin Hoes, MD

import 'dart:io';
import 'package:flutter/material.dart';
import '../../../services/journal_api.dart';
import '../../../theme/app_theme.dart';

class SendToScreen extends StatefulWidget {
  final File imageFile;
  final String? audioPath;
  final String caption;

  const SendToScreen({
    super.key,
    required this.imageFile,
    required this.caption,
    this.audioPath,
  });

  @override
  State<SendToScreen> createState() => _SendToScreenState();
}

class _SendToScreenState extends State<SendToScreen> {
  final _searchCtrl = TextEditingController();

  final List<_Person> _all = const [
    _Person(id: "1", name: "Shaila", username: "@shaila"),
    _Person(id: "2", name: "Jacob", username: "@jacob"),
    _Person(id: "3", name: "Maya", username: "@maya"),
    _Person(id: "4", name: "Noah", username: "@noah"),
    _Person(id: "5", name: "Ava", username: "@ava"),
  ];

  String _visibility = "Public";
  final Set<String> _selectedIds = {};
  bool _posting = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_Person> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _all;
    return _all.where((p) =>
        p.name.toLowerCase().contains(q) || p.username.toLowerCase().contains(q)).toList();
  }

  bool get _needsRecipients => _visibility != "Public";
  bool get _canPost => !_needsRecipients || _selectedIds.isNotEmpty;

  void _openVisibilitySheet() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: MuudColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _VisibilitySheet(current: _visibility),
    );
    if (picked == null) return;
    setState(() {
      _visibility = picked;
      if (_visibility == "Public") _selectedIds.clear();
    });
  }

  void _togglePerson(String id) {
    setState(() {
      if (_selectedIds.contains(id)) { _selectedIds.remove(id); } else { _selectedIds.add(id); }
    });
  }

  String _guessImageContentType(File f) {
    final p = f.path.toLowerCase();
    if (p.endsWith(".png")) return "image/png";
    if (p.endsWith(".webp")) return "image/webp";
    return "image/jpeg";
  }

  String _guessAudioContentType(String path) {
    final p = path.toLowerCase();
    if (p.endsWith(".aac")) return "audio/aac";
    if (p.endsWith(".mp3")) return "audio/mpeg";
    return "audio/mp4";
  }

  Future<void> _post() async {
    if (_posting || !_canPost) return;
    setState(() => _posting = true);

    try {
      final imgType = _guessImageContentType(widget.imageFile);
      final imgPresign = await JournalApi.presign(contentType: imgType, kind: "journalImage");
      final imgUploadUrl = (imgPresign["uploadUrl"] ?? "").toString();
      final imgKey = (imgPresign["key"] ?? "").toString();
      await JournalApi.uploadToS3(uploadUrl: imgUploadUrl, file: widget.imageFile, contentType: imgType);

      String? audioKey;
      if (widget.audioPath != null) {
        final audioFile = File(widget.audioPath!);
        final audioType = _guessAudioContentType(widget.audioPath!);
        final audPresign = await JournalApi.presign(contentType: audioType, kind: "journalAudio");
        final audUploadUrl = (audPresign["uploadUrl"] ?? "").toString();
        audioKey = (audPresign["key"] ?? "").toString();
        await JournalApi.uploadToS3(uploadUrl: audUploadUrl, file: audioFile, contentType: audioType);
      }

      final visibilityBackend = _visibility == "Public"
          ? "public"
          : _visibility == "Connections" ? "connections" : "innerCircle";

      final recipientSubs = _needsRecipients ? _selectedIds.toList() : <String>[];

      await JournalApi.createPost(
        caption: widget.caption,
        mediaKeys: [imgKey],
        audioKey: audioKey,
        visibility: visibilityBackend,
        recipientSubs: recipientSubs,
      );

      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Posted")));
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Post failed"),
          content: Text(e.toString().replaceFirst("Exception: ", "")),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
        ),
      );
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;

    return Scaffold(
      backgroundColor: MuudColors.white,
      appBar: AppBar(
        backgroundColor: MuudColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: MuudColors.purple),
        title: Text("Send to", style: MuudTypography.titleMedium.copyWith(color: MuudColors.purple)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(MuudSpacing.base, MuudSpacing.sm, MuudSpacing.base, MuudSpacing.sm),
            child: Row(
              children: [
                Text("Visibility:", style: MuudTypography.caption.copyWith(color: MuudColors.greyText)),
                const SizedBox(width: MuudSpacing.sm),
                GestureDetector(
                  onTap: _openVisibilitySheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: MuudSpacing.md, vertical: MuudSpacing.sm),
                    decoration: BoxDecoration(
                      borderRadius: MuudRadius.pillAll,
                      border: Border.all(color: MuudColors.divider),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_visibility, style: MuudTypography.label.copyWith(color: MuudColors.purple, fontWeight: FontWeight.w900)),
                        const SizedBox(width: MuudSpacing.sm),
                        const Icon(Icons.keyboard_arrow_down, color: MuudColors.purple),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_needsRecipients)
            Padding(
              padding: const EdgeInsets.fromLTRB(MuudSpacing.base, 0, MuudSpacing.base, MuudSpacing.sm),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: MuudRadius.mdAll),
                ),
              ),
            ),

          Expanded(
            child: _needsRecipients
                ? ListView.separated(
                    padding: const EdgeInsets.fromLTRB(MuudSpacing.base, MuudSpacing.xs, MuudSpacing.base, 90),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(height: MuudSpacing.lg),
                    itemBuilder: (_, i) {
                      final p = list[i];
                      final selected = _selectedIds.contains(p.id);
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: MuudColors.lightPurple.withValues(alpha: 0.5),
                          child: Text(
                            p.name.isNotEmpty ? p.name[0] : "?",
                            style: MuudTypography.label.copyWith(color: MuudColors.purple, fontWeight: FontWeight.w900),
                          ),
                        ),
                        title: Text(p.name, style: MuudTypography.label.copyWith(color: MuudColors.purple, fontWeight: FontWeight.w900)),
                        subtitle: Text(p.username, style: MuudTypography.caption.copyWith(color: MuudColors.greyText)),
                        trailing: Checkbox(value: selected, onChanged: (_) => _togglePerson(p.id), activeColor: MuudColors.purple),
                        onTap: () => _togglePerson(p.id),
                      );
                    },
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(MuudSpacing.xl),
                      child: Text(
                        "Public post — no recipients needed.",
                        style: MuudTypography.bodySmall.copyWith(color: MuudColors.greyText),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      bottomSheet: Container(
        color: MuudColors.white,
        padding: const EdgeInsets.fromLTRB(MuudSpacing.base, MuudSpacing.sm, MuudSpacing.base, MuudSpacing.lg),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _canPost ? MuudColors.purple : MuudColors.purple.withValues(alpha: 0.4),
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            onPressed: (_canPost && !_posting) ? _post : null,
            child: _posting
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.6, color: MuudColors.white))
                : Text(
                    _needsRecipients ? "Send to" : "Post",
                    style: MuudTypography.button.copyWith(color: MuudColors.white),
                  ),
          ),
        ),
      ),
    );
  }
}

/* ── Visibility Sheet ──────────────────────────────────────────────── */

class _VisibilitySheet extends StatelessWidget {
  final String current;
  const _VisibilitySheet({required this.current});

  @override
  Widget build(BuildContext context) {
    final options = const ["Public", "Inner Circle", "Connections"];

    return Padding(
      padding: const EdgeInsets.fromLTRB(MuudSpacing.base, MuudSpacing.base, MuudSpacing.base, MuudSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Choose who your post is visible to",
            style: MuudTypography.label.copyWith(color: MuudColors.purple, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: MuudSpacing.md),
          ...options.map((o) {
            final selected = o == current;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(o, style: MuudTypography.label.copyWith(color: MuudColors.purple, fontWeight: FontWeight.w800)),
              subtitle: Text(
                o == "Public" ? "Anyone can see this post."
                    : o == "Inner Circle" ? "Only your inner circle can see."
                    : "Only your connections can see.",
                style: MuudTypography.caption.copyWith(color: MuudColors.greyText),
              ),
              trailing: selected
                  ? const Icon(Icons.check_circle, color: MuudColors.purple)
                  : Icon(Icons.circle_outlined, color: MuudColors.purple.withValues(alpha: 0.4)),
              onTap: () => Navigator.pop(context, o),
            );
          }),
          const SizedBox(height: MuudSpacing.xs),
        ],
      ),
    );
  }
}

class _Person {
  final String id;
  final String name;
  final String username;
  const _Person({required this.id, required this.name, required this.username});
}
