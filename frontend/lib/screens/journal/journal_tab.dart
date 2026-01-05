import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../services/journal_feed_api.dart';

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

    // if same post playing -> stop
    if (_playingPostId == p.id && _playing) {
      await _player.stop();
      setState(() {
        _playing = false;
        _playingPostId = null;
      });
      return;
    }

    // stop anything else
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
          children: [
            const Icon(Icons.edit_note, size: 64, color: Color(0xFFD7CDE3)),
            const SizedBox(height: 14),
            const Text(
              "No journal entries yet",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kPurple,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Tap the + button to create your first journal post.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kGrey,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  // + button is in bottom nav; we just inform user
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Tap the + button to post")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPurple,
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                child: const Text(
                  "Create a journal",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
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
                // image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.1,
                    child: (p.imageUrl == null || p.imageUrl!.isEmpty)
                        ? Container(
                            color: const Color(0xFFF2EEF6),
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: kGrey,
                              ),
                            ),
                          )
                        : Image.network(p.imageUrl!, fit: BoxFit.cover),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // caption
                      if (p.caption.isNotEmpty)
                        Text(
                          p.caption,
                          style: const TextStyle(
                            color: kPurple,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                      if (p.caption.isNotEmpty) const SizedBox(height: 10),

                      // audio
                      if (p.audioUrl != null && p.audioUrl!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE7E1EF)),
                          ),
                          child: Row(
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
                              const SizedBox(width: 6),
                              const Expanded(
                                child: Text(
                                  "Voice note",
                                  style: TextStyle(
                                    color: kPurple,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 10),

                      // meta row
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
    // simple format for now; we’ll polish later
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return "$y-$m-$d  $hh:$mm";
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
      id: (m["id"] ?? "").toString(),
      caption: (m["caption"] ?? "").toString(),
      imageUrl: m["imageUrl"]?.toString(),
      audioUrl: m["audioUrl"]?.toString(),
      visibility: (m["visibility"] ?? "public").toString(),
      createdAt:
          DateTime.tryParse((m["createdAt"] ?? "").toString()) ??
          DateTime.now(),
    );
  }
}
