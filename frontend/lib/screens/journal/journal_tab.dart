import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../services/journal_feed_api.dart';
import '../../services/vault_api.dart';

class JournalTab extends StatefulWidget {
  const JournalTab({super.key});

  @override
  State<JournalTab> createState() => _JournalTabState();
}

class _JournalTabState extends State<JournalTab> {
  static const Color kPurple = Color(0xFF5B288E);
  static const Color kGrey = Color(0xFF898384);

  bool loading = true;
  String? error;

  List<_JournalPost> posts = [];

  final _player = AudioPlayer();
  String? _playingPostId;
  bool _playing = false;

  static const List<Map<String, String>> _vaultCategories = [
    {"key": "family", "label": "Family"},
    {"key": "friends", "label": "Friends"},
    {"key": "events", "label": "Events"},
    {"key": "holidays", "label": "Holidays"},
    {"key": "work", "label": "Work"},
    {"key": "school", "label": "School"},
    {"key": "other", "label": "Other"},
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final raw = await JournalFeedApi.getMyPosts();
      final mapped = raw.map((m) => _JournalPost.fromMap(m)).toList();
      if (!mounted) return;
      setState(() => posts = mapped);
    } catch (e) {
      if (!mounted) return;
      setState(() => error = e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _toggleAudio(_JournalPost p) async {
    if (p.audioUrl == null || p.audioUrl!.isEmpty) return;

    if (_playingPostId == p.id && _playing) {
      await _player.stop();
      setState(() {
        _playing = false;
        _playingPostId = null;
      });
      return;
    }

    await _player.stop();
    await _player.play(UrlSource(p.audioUrl!));

    setState(() {
      _playing = true;
      _playingPostId = p.id;
    });

    _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _playing = false;
        _playingPostId = null;
      });
    });
  }

  Future<void> _openSaveToVaultSheet(_JournalPost p) async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => _VaultCategorySheet(
        categories: _vaultCategories,
        purple: kPurple,
        grey: kGrey,
      ),
    );

    if (chosen == null) return;

    try {
      await VaultApi.savePostToVault(postId: p.id, category: chosen);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Saved to Vault")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _load,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPurple,
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                child: const Text(
                  "Retry",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (posts.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
          children: const [
            Icon(Icons.edit_note, size: 64, color: Color(0xFFD7CDE3)),
            SizedBox(height: 14),
            Text(
              "No journal entries yet",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kPurple,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: posts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, i) {
          final p = posts[i];
          final isThisPlaying = _playing && _playingPostId == p.id;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.1,
                    child: p.imageUrl == null || p.imageUrl!.isEmpty
                        ? Container(
                            color: const Color(0xFFF2EEF6),
                            child: const Icon(Icons.image, color: kGrey),
                          )
                        : Image.network(p.imageUrl!, fit: BoxFit.cover),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (p.caption.isNotEmpty)
                        Text(
                          p.caption,
                          style: const TextStyle(
                            color: kPurple,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      const SizedBox(height: 10),
                      if (p.audioUrl != null && p.audioUrl!.isNotEmpty)
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => _toggleAudio(p),
                              icon: Icon(
                                isThisPlaying
                                    ? Icons.pause_circle
                                    : Icons.play_circle,
                                color: kPurple,
                                size: 34,
                              ),
                            ),
                            const Text("Voice note"),
                          ],
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            _formatTime(p.createdAt),
                            style: const TextStyle(
                              color: kGrey,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => _openSaveToVaultSheet(p),
                            icon: const Icon(
                              Icons.bookmark_border,
                              color: kPurple,
                            ),
                          ),
                          Text(
                            p.visibilityLabel,
                            style: const TextStyle(
                              color: kGrey,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }
}

class _JournalPost {
  final String id;
  final String caption;
  final String? imageUrl;
  final String? audioUrl;
  final String visibility;
  final DateTime createdAt;

  _JournalPost({
    required this.id,
    required this.caption,
    required this.imageUrl,
    required this.audioUrl,
    required this.visibility,
    required this.createdAt,
  });

  String get visibilityLabel {
    if (visibility == "innerCircle") return "Inner Circle";
    if (visibility == "connections") return "Connections";
    return "Public";
  }

  factory _JournalPost.fromMap(Map<String, dynamic> m) {
    return _JournalPost(
      id: m["id"].toString(),
      caption: (m["caption"] ?? "").toString(),
      imageUrl: m["imageUrl"]?.toString(),
      audioUrl: m["audioUrl"]?.toString(),
      visibility: m["visibility"].toString(),
      createdAt: DateTime.parse(m["createdAt"]),
    );
  }
}

class _VaultCategorySheet extends StatefulWidget {
  final List<Map<String, String>> categories;
  final Color purple;
  final Color grey;

  const _VaultCategorySheet({
    required this.categories,
    required this.purple,
    required this.grey,
  });

  @override
  State<_VaultCategorySheet> createState() => _VaultCategorySheetState();
}

class _VaultCategorySheetState extends State<_VaultCategorySheet> {
  String selected = "other";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Save to Vault",
            style: TextStyle(
              color: widget.purple,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: widget.categories.map((c) {
              final key = c["key"]!;
              final label = c["label"]!;
              final selectedNow = selected == key;

              return ChoiceChip(
                label: Text(label),
                selected: selectedNow,
                selectedColor: widget.purple,
                labelStyle: TextStyle(
                  color: selectedNow ? Colors.white : widget.purple,
                  fontWeight: FontWeight.w800,
                ),
                onSelected: (_) => setState(() => selected = key),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, selected),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.purple,
              shape: const StadiumBorder(),
            ),
            child: const Text(
              "Save",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
