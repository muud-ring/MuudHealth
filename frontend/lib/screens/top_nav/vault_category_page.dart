// MUUD Health — Vault Category Page
// Paginated vault items by category
// © Muud Health — Armin Hoes, MD

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../services/vault_api.dart';
import '../../theme/app_theme.dart';

class VaultCategoryPage extends StatefulWidget {
  final String categoryKey;
  final String categoryTitle;
  final String? fromIso;
  final String? toIso;

  const VaultCategoryPage({
    super.key,
    required this.categoryKey,
    required this.categoryTitle,
    this.fromIso,
    this.toIso,
  });

  @override
  State<VaultCategoryPage> createState() => _VaultCategoryPageState();
}

class _VaultCategoryPageState extends State<VaultCategoryPage> {
  bool loading = true;
  bool loadingMore = false;
  String? error;

  final List<_VaultPost> posts = [];
  int _page = 1;
  bool _hasMore = true;
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadFirst();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) _loadMore();
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadFirst() async {
    setState(() { loading = true; error = null; posts.clear(); _page = 1; _hasMore = true; });

    try {
      final decoded = await VaultApi.getItems(category: widget.categoryKey, limit: 20, page: 1);
      final items = (decoded["items"] as List?) ?? [];
      final mapped = items.cast<Map<String, dynamic>>().map((m) => _VaultPost.fromMap(m)).toList();

      if (!mounted) return;
      setState(() {
        posts.addAll(mapped);
        _hasMore = mapped.length >= 20;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => error = e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (loading || loadingMore || !_hasMore) return;
    setState(() => loadingMore = true);

    try {
      final nextPage = _page + 1;
      final decoded = await VaultApi.getItems(category: widget.categoryKey, limit: 20, page: nextPage);
      final items = (decoded["items"] as List?) ?? [];
      final mapped = items.cast<Map<String, dynamic>>().map((m) => _VaultPost.fromMap(m)).toList();
      if (!mounted) return;
      setState(() {
        posts.addAll(mapped);
        _page = nextPage;
        _hasMore = mapped.length >= 20;
      });
    } catch (_) {} finally {
      if (mounted) setState(() => loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MuudColors.white,
      appBar: AppBar(
        backgroundColor: MuudColors.white,
        surfaceTintColor: MuudColors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Go back',
          icon: const Icon(Icons.arrow_back, color: MuudColors.purple),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(widget.categoryTitle, style: MuudTypography.titleMedium.copyWith(color: MuudColors.purple)),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: MuudColors.purple))
          : (error != null)
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(MuudSpacing.lg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(error!, textAlign: TextAlign.center, style: MuudTypography.bodyMedium.copyWith(color: MuudColors.error)),
                        const SizedBox(height: MuudSpacing.md),
                        ElevatedButton(
                          onPressed: _loadFirst,
                          style: ElevatedButton.styleFrom(backgroundColor: MuudColors.purple, shape: const StadiumBorder(), elevation: 0),
                          child: Text("Retry", style: MuudTypography.button.copyWith(color: MuudColors.white)),
                        ),
                      ],
                    ),
                  ),
                )
              : (posts.isEmpty)
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(MuudSpacing.lg),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bookmark_border, size: 58, color: MuudColors.lightPurple),
                            const SizedBox(height: MuudSpacing.md),
                            Text("Nothing saved here yet", style: MuudTypography.titleMedium.copyWith(color: MuudColors.purple)),
                            const SizedBox(height: MuudSpacing.xs),
                            Text("Save a journal to see it in this category.", textAlign: TextAlign.center, style: MuudTypography.bodySmall.copyWith(color: MuudColors.greyText)),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      color: MuudColors.purple,
                      onRefresh: _loadFirst,
                      child: ListView.separated(
                        controller: _scroll,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(MuudSpacing.base, MuudSpacing.md, MuudSpacing.base, MuudSpacing.xl),
                        itemCount: posts.length + (loadingMore ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: MuudSpacing.md),
                        itemBuilder: (_, i) {
                          if (i >= posts.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: MuudSpacing.sm),
                              child: Center(child: CircularProgressIndicator(color: MuudColors.purple)),
                            );
                          }
                          final p = posts[i];
                          return Container(
                            decoration: BoxDecoration(
                              color: MuudColors.white,
                              borderRadius: MuudRadius.lgAll,
                              border: Border.all(color: MuudColors.divider),
                              boxShadow: MuudShadows.card,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  child: AspectRatio(
                                    aspectRatio: 1.1,
                                    child: (p.imageUrl == null || p.imageUrl!.isEmpty)
                                        ? Container(color: MuudColors.lightPurple.withValues(alpha: 0.3), child: const Center(child: Icon(Icons.image_not_supported, color: MuudColors.greyText)))
                                        : CachedNetworkImage(imageUrl: p.imageUrl!, fit: BoxFit.cover),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(MuudSpacing.md),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (p.caption.isNotEmpty) ...[
                                        Text(p.caption, style: MuudTypography.bodyMedium.copyWith(color: MuudColors.purple, fontWeight: FontWeight.w900)),
                                        const SizedBox(height: MuudSpacing.sm),
                                      ],
                                      Row(
                                        children: [
                                          Text(_formatTime(p.createdAt), style: MuudTypography.caption.copyWith(color: MuudColors.greyText)),
                                          const Spacer(),
                                          Text(p.visibilityLabel, style: MuudTypography.caption.copyWith(color: MuudColors.greyText)),
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
                    ),
    );
  }

  String _formatTime(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }
}

class _VaultPost {
  final String postId;
  final String caption;
  final String? imageUrl;
  final String visibility;
  final DateTime createdAt;

  _VaultPost({required this.postId, required this.caption, required this.imageUrl, required this.visibility, required this.createdAt});

  String get visibilityLabel {
    if (visibility == "innerCircle") return "Inner Circle";
    if (visibility == "connections") return "Connections";
    return "Public";
  }

  factory _VaultPost.fromMap(Map<String, dynamic> m) {
    final post = (m["post"] as Map?)?.cast<String, dynamic>() ?? {};
    return _VaultPost(
      postId: (post["id"] ?? "").toString(),
      caption: (post["caption"] ?? "").toString(),
      imageUrl: post["imageUrl"]?.toString(),
      visibility: (post["visibility"] ?? "public").toString(),
      createdAt: DateTime.tryParse((post["createdAt"] ?? "").toString()) ?? DateTime.now(),
    );
  }
}
