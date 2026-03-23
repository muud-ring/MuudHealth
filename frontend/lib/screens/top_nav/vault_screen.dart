import 'package:flutter/material.dart';

import '../../services/vault_api.dart';
import '../journal/pages/creator_tool_screen.dart';
import 'vault_category_page.dart';
import 'vault_filter_page.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  // Figma-ish tokens
  static const Color kPurple = Color(0xFF5B288E);
  static const Color kGrey = Color(0xFF898384);
  static const Color kBorder = Color(0xFFE7E1EF);

  final TextEditingController _searchCtrl = TextEditingController();

  bool _loading = true;
  String? _error;

  List<_VaultSection> _sections = [];

  String _selectedChip = "All";
  String _search = "";

  Map<String, dynamic>? _activeFilter; // UI only for now

  @override
  void initState() {
    super.initState();
    _load();

    _searchCtrl.addListener(() {
      final v = _searchCtrl.text.trim();
      if (v == _search) return;
      setState(() => _search = v);
      _load();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final raw = await VaultApi.getLanding(
        chip: _selectedChip,
        search: _search,
      );
      final mapped = raw.map((m) => _VaultSection.fromMap(m)).toList();

      if (!mounted) return;
      setState(() => _sections = mapped);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _setChip(String chip) {
    if (_selectedChip == chip) return;
    setState(() => _selectedChip = chip);
    _load();
  }

  bool get _hasAnySaved => _sections.any((s) => s.count > 0);

  Future<void> _openCreatorTool() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CreatorToolScreen()));
  }

  Future<void> _openFilter() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const VaultFilterPage()));
    if (!mounted) return;

    if (result is Map) {
      setState(() => _activeFilter = Map<String, dynamic>.from(result));
      // filter wiring later
    }
  }

  void _openCategory(_VaultSection s) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VaultCategoryPage(
          categoryKey: s.keyName,
          categoryTitle: s.title,
          fromIso: _activeFilter?["from"]?.toString(),
          toIso: _activeFilter?["to"]?.toString(),
        ),
      ),
    );
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
          icon: const Icon(Icons.arrow_back_ios_new, color: kPurple, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Vault",
          style: TextStyle(
            color: kPurple,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 26),
          children: [
            _buildTopRow(),
            const SizedBox(height: 12),
            _buildChips(),
            const SizedBox(height: 18),

            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 26),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              _buildError()
            else if (!_hasAnySaved)
              _buildEmptyState()
            else
              ..._buildSectionsLikeFigma(),
          ],
        ),
      ),
    );
  }

  // Search + filter button (matches figma)
  Widget _buildTopRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kBorder, width: 1.2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      hintText: "Search",
                      hintStyle: TextStyle(
                        color: Color(0xFFB7B0B8),
                        fontWeight: FontWeight.w600,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                const Icon(Icons.search, color: kGrey, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 50,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kBorder, width: 1.2),
          ),
          child: IconButton(
            onPressed: _openFilter,
            icon: const Icon(Icons.tune, color: kPurple),
          ),
        ),
      ],
    );
  }

  Widget _buildChips() {
    final chips = <String>["All", "Family", "Friends", "Holidays"];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips.map((c) {
          final selected = _selectedChip == c;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => _setChip(c),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: selected ? kPurple : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: kPurple, width: 1.4),
                ),
                child: Text(
                  c,
                  style: TextStyle(
                    color: selected ? Colors.white : kPurple,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildSectionsLikeFigma() {
    final nonEmpty = _sections.where((s) => s.count > 0).toList();

    return nonEmpty.map((s) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: s.title, onSeeAll: () => _openCategory(s)),
            const SizedBox(height: 12),
            _SectionBody(section: s, onTapAny: () => _openCategory(s)),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Text(
            _error ?? "Something went wrong",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ElevatedButton(
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
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Icon(
          Icons.description_outlined,
          size: 68,
          color: Color(0xFFD7CDE3),
        ),
        const SizedBox(height: 14),
        const Text(
          "Empty Posts",
          style: TextStyle(
            color: kPurple,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Your posts will show up here.",
          style: TextStyle(
            color: kGrey,
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _openCreatorTool,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPurple,
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            child: const Text(
              "Start Journaling",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}

/// ---------- UI pieces (no dummy) ----------

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

  static const Color kPurple = Color(0xFF5B288E);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: kPurple,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onSeeAll,
          child: const Text(
            "See All",
            style: TextStyle(color: kPurple, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _SectionBody extends StatelessWidget {
  final _VaultSection section;
  final VoidCallback onTapAny;

  const _SectionBody({required this.section, required this.onTapAny});

  @override
  Widget build(BuildContext context) {
    final items = section.preview;

    // We do NOT add fake items. Only show what we have.
    if (items.isEmpty) {
      return _EmptySectionCard(onTap: onTapAny);
    }

    // Figma pattern: big card + 2 small cards (if available)
    final first = items[0];
    final second = items.length > 1 ? items[1] : null;
    final third = items.length > 2 ? items[2] : null;

    return Column(
      children: [
        _BigCard(item: first, sectionCount: section.count, onTap: onTapAny),
        if (second != null || third != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: second == null
                    ? const SizedBox.shrink()
                    : _SmallCard(
                        item: second,
                        sectionCount: section.count,
                        onTap: onTapAny,
                      ),
              ),
              if (third != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _SmallCard(
                    item: third,
                    sectionCount: section.count,
                    onTap: onTapAny,
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _EmptySectionCard extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptySectionCard({required this.onTap});

  static const Color kBorder = Color(0xFFE7E1EF);
  static const Color kGrey = Color(0xFF898384);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder),
        ),
        child: const Text(
          "No previews yet",
          style: TextStyle(color: kGrey, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _BigCard extends StatelessWidget {
  final _VaultPreview item;
  final int sectionCount;
  final VoidCallback onTap;

  const _BigCard({
    required this.item,
    required this.sectionCount,
    required this.onTap,
  });

  static const Color kPurple = Color(0xFF5B288E);
  static const Color kGrey = Color(0xFF898384);
  static const Color kBorder = Color(0xFFE7E1EF);

  @override
  Widget build(BuildContext context) {
    // show “+N” only if it’s REAL (count from backend)
    final extra = sectionCount > 1 ? sectionCount - 1 : 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: (item.imageUrl == null || item.imageUrl!.isEmpty)
                    ? Container(color: const Color(0xFFF2EEF6))
                    : Image.network(item.imageUrl!, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${item.authorName} · ${item.authorUsername}".trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: kPurple,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (item.authorLocation.isNotEmpty)
                          Text(
                            item.authorLocation,
                            style: const TextStyle(
                              color: kGrey,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        const SizedBox(height: 6),
                        if (item.caption.isNotEmpty)
                          Text(
                            item.caption,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: kGrey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // right side: avatar + "+N" (only if real)
                  Column(
                    children: [
                      if (item.authorAvatarUrl != null &&
                          item.authorAvatarUrl!.isNotEmpty)
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: const Color(0xFFEFEAF6),
                          backgroundImage: NetworkImage(item.authorAvatarUrl!),
                        )
                      else
                        const CircleAvatar(
                          radius: 14,
                          backgroundColor: Color(0xFFEFEAF6),
                          child: Icon(Icons.person, size: 16, color: kGrey),
                        ),
                      if (extra > 0) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2EEF6),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: kBorder),
                          ),
                          child: Text(
                            "+$extra",
                            style: const TextStyle(
                              color: kGrey,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallCard extends StatelessWidget {
  final _VaultPreview item;
  final int sectionCount;
  final VoidCallback onTap;

  const _SmallCard({
    required this.item,
    required this.sectionCount,
    required this.onTap,
  });

  static const Color kPurple = Color(0xFF5B288E);
  static const Color kGrey = Color(0xFF898384);
  static const Color kBorder = Color(0xFFE7E1EF);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 216,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: SizedBox(
                height: 110,
                width: double.infinity,
                child: (item.imageUrl == null || item.imageUrl!.isEmpty)
                    ? Container(color: const Color(0xFFF2EEF6))
                    : Image.network(item.imageUrl!, fit: BoxFit.cover),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${item.authorName} · ${item.authorUsername}".trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: kPurple,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (item.authorLocation.isNotEmpty)
                      Text(
                        item.authorLocation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: kGrey,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    const Spacer(),
                    Row(
                      children: [
                        if (item.authorAvatarUrl != null &&
                            item.authorAvatarUrl!.isNotEmpty)
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: const Color(0xFFEFEAF6),
                            backgroundImage: NetworkImage(
                              item.authorAvatarUrl!,
                            ),
                          )
                        else
                          const CircleAvatar(
                            radius: 12,
                            backgroundColor: Color(0xFFEFEAF6),
                            child: Icon(Icons.person, size: 14, color: kGrey),
                          ),
                        const Spacer(),
                        const Icon(Icons.chevron_right, color: kGrey),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------- Models ----------

class _VaultSection {
  final String keyName;
  final String title;
  final int count;
  final List<_VaultPreview> preview;

  _VaultSection({
    required this.keyName,
    required this.title,
    required this.count,
    required this.preview,
  });

  factory _VaultSection.fromMap(Map<String, dynamic> m) {
    final pv = ((m["preview"] as List?) ?? []).cast<Map<String, dynamic>>();
    return _VaultSection(
      keyName: (m["key"] ?? "").toString(),
      title: (m["title"] ?? "").toString(),
      count: (m["count"] is int)
          ? (m["count"] as int)
          : int.tryParse("${m["count"]}") ?? 0,
      preview: pv.map((x) => _VaultPreview.fromMap(x)).toList(),
    );
  }
}

class _VaultPreview {
  final String? imageUrl;
  final String caption;

  final String authorName;
  final String authorUsername;
  final String authorLocation;
  final String? authorAvatarUrl;

  _VaultPreview({
    required this.imageUrl,
    required this.caption,
    required this.authorName,
    required this.authorUsername,
    required this.authorLocation,
    required this.authorAvatarUrl,
  });

  factory _VaultPreview.fromMap(Map<String, dynamic> m) {
    final a = (m["author"] as Map?)?.cast<String, dynamic>() ?? {};
    final name = (a["name"] ?? "").toString().trim();
    final username = (a["username"] ?? "").toString().trim();

    return _VaultPreview(
      imageUrl: m["imageUrl"]?.toString(),
      caption: (m["caption"] ?? "").toString(),
      authorName: name.isEmpty ? "User" : name,
      authorUsername: username.isEmpty ? "" : "@$username",
      authorLocation: (a["location"] ?? "").toString(),
      authorAvatarUrl: a["avatarUrl"]?.toString(),
    );
  }
}
