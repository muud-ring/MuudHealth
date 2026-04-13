// MUUD Health — Journal Tab
// User's journal feed with audio playback and vault saving
// Signal Pathway: Signal layer (personal expression)
// © Muud Health — Armin Hoes, MD

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/journal_provider.dart';
import '../../services/vault_api.dart';
import '../../theme/app_theme.dart';

class JournalTab extends ConsumerStatefulWidget {
  const JournalTab({super.key});

  @override
  ConsumerState<JournalTab> createState() => _JournalTabState();
}

class _JournalTabState extends ConsumerState<JournalTab> {

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
    // Use Riverpod provider for data loading instead of local setState
    ref.read(journalProvider.notifier).loadPosts();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio(_JournalPost p) async {
    if (p.audioUrl == null || p.audioUrl!.isEmpty) return;

    if (_playingPostId == p.id && _playing) {
      await _player.stop();
      setState(() { _playing = false; _playingPostId = null; });
      return;
    }

    await _player.stop();
    await _player.play(UrlSource(p.audioUrl!));

    setState(() { _playing = true; _playingPostId = p.id; });

    _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() { _playing = false; _playingPostId = null; });
    });
  }

  Future<void> _openSaveToVaultSheet(_JournalPost p) async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: MuudColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => const _VaultCategorySheet(),
    );

    if (chosen == null) return;

    try {
      await VaultApi.save(sourceId: p.id, category: chosen);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saved to Vault")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Riverpod-driven state: watch provider instead of local setState
    final journalState = ref.watch(journalProvider);
    final posts = journalState.posts.map((m) => _JournalPost.fromMap(m)).toList();
    final loading = journalState.isLoading;
    final error = journalState.error;

    if (loading && posts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: MuudColors.purple),
      );
    }

    if (error != null && posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(MuudSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                error,
                textAlign: TextAlign.center,
                style: MuudTypography.bodyMedium.copyWith(
                  color: MuudColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: MuudSpacing.md),
              ElevatedButton(
                onPressed: () => ref.read(journalProvider.notifier).loadPosts(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MuudColors.purple,
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                child: Text("Retry", style: MuudTypography.button.copyWith(color: MuudColors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (posts.isEmpty) {
      return RefreshIndicator(
        color: MuudColors.purple,
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(MuudSpacing.lg, 50, MuudSpacing.lg, MuudSpacing.xl),
          children: [
            const Icon(Icons.edit_note, size: 64, color: MuudColors.lightPurple),
            const SizedBox(height: MuudSpacing.md),
            Text(
              "No journal entries yet",
              textAlign: TextAlign.center,
              style: MuudTypography.titleMedium.copyWith(color: MuudColors.purple),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: MuudColors.purple,
      onRefresh: _load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(MuudSpacing.base, MuudSpacing.md, MuudSpacing.base, MuudSpacing.xl),
        itemCount: posts.length,
        separatorBuilder: (_, __) => const SizedBox(height: MuudSpacing.md),
        itemBuilder: (_, i) {
          final p = posts[i];
          final isThisPlaying = _playing && _playingPostId == p.id;

          return Container(
            decoration: BoxDecoration(
              color: MuudColors.white,
              borderRadius: MuudRadius.lgAll,
              boxShadow: MuudShadows.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 1.1,
                    child: p.imageUrl == null || p.imageUrl!.isEmpty
                        ? Container(
                            color: MuudColors.lightPurple.withValues(alpha: 0.3),
                            child: const Icon(Icons.image, color: MuudColors.greyText),
                          )
                        : CachedNetworkImage(imageUrl: p.imageUrl!, fit: BoxFit.cover),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(MuudSpacing.md, MuudSpacing.md, MuudSpacing.md, MuudSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (p.caption.isNotEmpty)
                        Text(
                          p.caption,
                          style: MuudTypography.bodyMedium.copyWith(
                            color: MuudColors.purple,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      const SizedBox(height: MuudSpacing.sm),
                      if (p.audioUrl != null && p.audioUrl!.isNotEmpty)
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => _toggleAudio(p),
                              icon: Icon(
                                isThisPlaying ? Icons.pause_circle : Icons.play_circle,
                                color: MuudColors.purple,
                                size: 34,
                              ),
                            ),
                            Text("Voice note", style: MuudTypography.caption),
                          ],
                        ),
                      const SizedBox(height: MuudSpacing.sm),
                      Row(
                        children: [
                          Text(
                            _formatTime(p.createdAt),
                            style: MuudTypography.caption.copyWith(color: MuudColors.greyText),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => _openSaveToVaultSheet(p),
                            icon: const Icon(Icons.bookmark_border, color: MuudColors.purple),
                          ),
                          Text(
                            p.visibilityLabel,
                            style: MuudTypography.caption.copyWith(color: MuudColors.greyText),
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

/* ── Models ─────────────────────────────────────────────────────────── */

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

/* ── Vault Category Sheet ──────────────────────────────────────────── */

class _VaultCategorySheet extends StatefulWidget {
  const _VaultCategorySheet();

  @override
  State<_VaultCategorySheet> createState() => _VaultCategorySheetState();
}

class _VaultCategorySheetState extends State<_VaultCategorySheet> {
  String selected = "other";

  static const List<Map<String, String>> _categories = [
    {"key": "family", "label": "Family"},
    {"key": "friends", "label": "Friends"},
    {"key": "events", "label": "Events"},
    {"key": "holidays", "label": "Holidays"},
    {"key": "work", "label": "Work"},
    {"key": "school", "label": "School"},
    {"key": "other", "label": "Other"},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(MuudSpacing.base),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Save to Vault",
            style: MuudTypography.titleMedium.copyWith(color: MuudColors.purple),
          ),
          const SizedBox(height: MuudSpacing.md),
          Wrap(
            spacing: MuudSpacing.sm,
            runSpacing: MuudSpacing.sm,
            children: _categories.map((c) {
              final key = c["key"]!;
              final label = c["label"]!;
              final selectedNow = selected == key;

              return ChoiceChip(
                label: Text(label),
                selected: selectedNow,
                selectedColor: MuudColors.purple,
                labelStyle: TextStyle(
                  color: selectedNow ? MuudColors.white : MuudColors.purple,
                  fontWeight: FontWeight.w800,
                ),
                onSelected: (_) => setState(() => selected = key),
              );
            }).toList(),
          ),
          const SizedBox(height: MuudSpacing.lg),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, selected),
            style: ElevatedButton.styleFrom(
              backgroundColor: MuudColors.purple,
              shape: const StadiumBorder(),
            ),
            child: Text(
              "Save",
              style: MuudTypography.button.copyWith(color: MuudColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
