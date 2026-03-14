import 'package:flutter/material.dart';
import '../../services/vault_api.dart';

class VaultCategoryPage extends StatefulWidget {
  final String categoryKey; // friends | family | holidays | etc
  final String categoryTitle; // Friends | Family | ...
  final String? fromIso; // ISO
  final String? toIso; // ISO

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
  static const Color kPurple = Color(0xFF5B288E);
  static const Color kGrey = Color(0xFF898384);
  static const Color kBorder = Color(0xFFE7E1EF);

  bool loading = true;
  bool loadingMore = false;
  String? error;

  final List<_VaultPost> posts = [];
  String? nextCursor; // ISO cursor from backend

  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadFirst();

    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadFirst() async {
    setState(() {
      loading = true;
      error = null;
      posts.clear();
      nextCursor = null;
    });

    try {
      final decoded = await VaultApi.getItems(
        category: widget.categoryKey,
        limit: 20,
        cursor: null,
        from: widget.fromIso,
        to: widget.toIso,
      );

      final items = (decoded["items"] as List?) ?? [];
      final cursor = decoded["nextCursor"]?.toString();

      final mapped = items
          .cast<Map<String, dynamic>>()
          .map((m) => _VaultPost.fromMap(m))
          .toList();

      if (!mounted) return;
      setState(() {
        posts.addAll(mapped);
        nextCursor = (cursor != null && cursor.isNotEmpty) ? cursor : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => error = e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (loading || loadingMore) return;
    if (nextCursor == null || nextCursor!.isEmpty) return;

    setState(() => loadingMore = true);

    try {
      final decoded = await VaultApi.getItems(
        category: widget.categoryKey,
        limit: 20,
        cursor: nextCursor,
        from: widget.fromIso,
        to: widget.toIso,
      );

      final items = (decoded["items"] as List?) ?? [];
      final cursor = decoded["nextCursor"]?.toString();

      final mapped = items
          .cast<Map<String, dynamic>>()
          .map((m) => _VaultPost.fromMap(m))
          .toList();

      if (!mounted) return;
      setState(() {
        posts.addAll(mapped);
        nextCursor = (cursor != null && cursor.isNotEmpty) ? cursor : null;
      });
    } catch (_) {
      // ignore paging errors for MVP
    } finally {
      if (mounted) setState(() => loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPurple),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          widget.categoryTitle,
          style: const TextStyle(
            color: kPurple,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : (error != null)
          ? Center(
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
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadFirst,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPurple,
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Retry",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : (posts.isEmpty)
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      size: 58,
                      color: Color(0xFFD7CDE3),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Nothing saved here yet",
                      style: TextStyle(
                        color: kPurple,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Save a journal to see it in this category.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: kGrey,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadFirst,
              child: ListView.separated(
                controller: _scroll,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: posts.length + (loadingMore ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (_, i) {
                  if (i >= posts.length) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 10),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final p = posts[i];

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: kBorder),
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
                              if (p.caption.isNotEmpty)
                                Text(
                                  p.caption,
                                  style: const TextStyle(
                                    color: kPurple,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              if (p.caption.isNotEmpty)
                                const SizedBox(height: 10),
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
            ),
    );
  }

  String _formatTime(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return "$y-$m-$d  $hh:$mm";
  }
}

// Parses backend shape: { vault: {...}, post: {...} }
class _VaultPost {
  final String postId;
  final String caption;
  final String? imageUrl;
  final String visibility;
  final DateTime createdAt;

  _VaultPost({
    required this.postId,
    required this.caption,
    required this.imageUrl,
    required this.visibility,
    required this.createdAt,
  });

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
      createdAt:
          DateTime.tryParse((post["createdAt"] ?? "").toString()) ??
          DateTime.now(),
    );
  }
}
