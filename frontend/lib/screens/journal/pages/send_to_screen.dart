import 'dart:io';
import 'package:flutter/material.dart';
import '../../../services/journal_api.dart';
import 'package:muud_health_app/theme/app_theme.dart';

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

  // Step 3: dummy data (Step 4 will wire real connections)
  final List<_Person> _all = const [
    _Person(id: "1", name: "Shaila", username: "@shaila"),
    _Person(id: "2", name: "Jacob", username: "@jacob"),
    _Person(id: "3", name: "Maya", username: "@maya"),
    _Person(id: "4", name: "Noah", username: "@noah"),
    _Person(id: "5", name: "Ava", username: "@ava"),
  ];

  String _visibility = "Public"; // Public | Inner Circle | Connections
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
    return _all.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.username.toLowerCase().contains(q);
    }).toList();
  }

  bool get _needsRecipients => _visibility != "Public";
  bool get _canPost => !_needsRecipients || _selectedIds.isNotEmpty;

  void _openVisibilitySheet() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _VisibilitySheet(current: _visibility),
    );

    if (picked == null) return;

    setState(() {
      _visibility = picked;

      // if switching back to Public, clear recipients selection
      if (_visibility == "Public") _selectedIds.clear();
    });
  }

  void _togglePerson(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
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
    // record package typically produces .m4a
    return "audio/mp4";
  }

  Future<void> _post() async {
    if (_posting || !_canPost) return;

    setState(() => _posting = true);

    try {
      // 1) Presign + upload image
      final imgType = _guessImageContentType(widget.imageFile);

      final imgPresign = await JournalApi.presign(
        contentType: imgType,
        kind: "journalImage",
      );

      final imgUploadUrl = (imgPresign["uploadUrl"] ?? "").toString();
      final imgKey = (imgPresign["key"] ?? "").toString();

      await JournalApi.uploadToS3(
        uploadUrl: imgUploadUrl,
        file: widget.imageFile,
        contentType: imgType,
      );

      // 2) Presign + upload audio (optional)
      String? audioKey;
      if (widget.audioPath != null) {
        final audioFile = File(widget.audioPath!);
        final audioType = _guessAudioContentType(widget.audioPath!);

        final audPresign = await JournalApi.presign(
          contentType: audioType,
          kind: "journalAudio",
        );

        final audUploadUrl = (audPresign["uploadUrl"] ?? "").toString();
        audioKey = (audPresign["key"] ?? "").toString();

        await JournalApi.uploadToS3(
          uploadUrl: audUploadUrl,
          file: audioFile,
          contentType: audioType,
        );
      }

      // 3) Create post (DB record)
      final visibilityBackend = _visibility == "Public"
          ? "public"
          : _visibility == "Connections"
          ? "connections"
          : "innerCircle";

      // NOTE: currently dummy IDs; step 5 we’ll replace with real connection subs.
      final recipientSubs = _needsRecipients
          ? _selectedIds.toList()
          : <String>[];

      await JournalApi.createPost(
        caption: widget.caption,
        mediaKeys: [imgKey],
        audioKey: audioKey,
        visibility: visibilityBackend,
        recipientSubs: recipientSubs,
      );

      if (!mounted) return;

      // Close SendTo -> Preview -> Creator
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Posted ✅")));
    } catch (e) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Post failed"),
          content: Text(e.toString().replaceFirst("Exception: ", "")),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.purple),
        title: const Text(
          "Send to",
          style: TextStyle(color: AppTheme.purple, fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          // Visibility selector
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: Row(
              children: [
                const Text(
                  "Visibility:",
                  style: TextStyle(color: AppTheme.greyText, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _openVisibilitySheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE7E1EF)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _visibility,
                          style: const TextStyle(
                            color: AppTheme.purple,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.keyboard_arrow_down, color: AppTheme.purple),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search (only if not public)
          if (_needsRecipients)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

          // List
          Expanded(
            child: _needsRecipients
                ? ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 90),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(height: 18),
                    itemBuilder: (_, i) {
                      final p = list[i];
                      final selected = _selectedIds.contains(p.id);
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFEFEFEF),
                          child: Text(
                            p.name.isNotEmpty ? p.name[0] : "?",
                            style: const TextStyle(
                              color: AppTheme.purple,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        title: Text(
                          p.name,
                          style: const TextStyle(
                            color: AppTheme.purple,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        subtitle: Text(
                          p.username,
                          style: const TextStyle(
                            color: AppTheme.greyText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: Checkbox(
                          value: selected,
                          onChanged: (_) => _togglePerson(p.id),
                          activeColor: AppTheme.purple,
                        ),
                        onTap: () => _togglePerson(p.id),
                      );
                    },
                  )
                : const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        "Public post — no recipients needed.",
                        style: TextStyle(
                          color: AppTheme.greyText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),

      // Bottom Post button
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _canPost ? AppTheme.purple : const Color(0xFFB9A9C9),
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            onPressed: (_canPost && !_posting) ? _post : null,
            child: _posting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.6,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    _needsRecipients ? "Send to" : "Post",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _VisibilitySheet extends StatelessWidget {
  final String current;
  const _VisibilitySheet({required this.current});
  @override
  Widget build(BuildContext context) {
    final options = const ["Public", "Inner Circle", "Connections"];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Choose who your post is visible to",
            style: TextStyle(
              color: AppTheme.purple,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ...options.map((o) {
            final selected = o == current;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                o,
                style: const TextStyle(
                  color: AppTheme.purple,
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(
                o == "Public"
                    ? "Anyone can see this post."
                    : o == "Inner Circle"
                    ? "Only your inner circle can see."
                    : "Only your connections can see.",
                style: const TextStyle(
                  color: AppTheme.greyText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: selected
                  ? const Icon(Icons.check_circle, color: AppTheme.purple)
                  : const Icon(Icons.circle_outlined, color: Color(0xFFB8A9C9)),
              onTap: () => Navigator.pop(context, o),
            );
          }).toList(),
          const SizedBox(height: 6),
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
