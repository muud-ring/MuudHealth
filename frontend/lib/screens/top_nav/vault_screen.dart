// MUUD Health — Vault Screen
// Private content vault with category sections
// Signal Pathway: Learn layer (saved experiences)
// © Muud Health — Armin Hoes, MD

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/route_names.dart';
import '../../services/vault_api.dart';
import '../../theme/app_theme.dart';
import '../journal/pages/creator_tool_screen.dart';
import 'vault_category_page.dart';
import 'vault_filter_page.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  bool _loading = true;
  String? _error;

  List<_VaultSection> _sections = [];
  String _selectedChip = "All";
  String _search = "";
  Map<String, dynamic>? _activeFilter;

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
    setState(() { _loading = true; _error = null; });

    try {
      final raw = await VaultApi.getLanding(chip: _selectedChip, search: _search);
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
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreatorToolScreen()),
    );
  }

  Future<void> _openFilter() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const VaultFilterPage()),
    );
    if (!mounted) return;
    if (result is Map) {
      setState(() => _activeFilter = Map<String, dynamic>.from(result));
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
      backgroundColor: MuudColors.white,
      appBar: AppBar(
        backgroundColor: MuudColors.white,
        surfaceTintColor: MuudColors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Go back',
          icon: const Icon(Icons.arrow_back_ios_new, color: MuudColors.purple, size: 20),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text("Vault", style: MuudTypography.titleMedium.copyWith(color: MuudColors.purple)),
      ),
      body: RefreshIndicator(
        color: MuudColors.purple,
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(MuudSpacing.base, MuudSpacing.xs, MuudSpacing.base, MuudSpacing.xxl),
          children: [
            _buildTopRow(),
            const SizedBox(height: MuudSpacing.md),
            _buildChips(),
            const SizedBox(height: MuudSpacing.lg),

            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: MuudSpacing.xxl),
                child: Center(child: CircularProgressIndicator(color: MuudColors.purple)),
              )
            else if (_error != null)
              _buildError()
            else if (!_hasAnySaved)
              _buildEmptyState()
            else
              ..._buildSections(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: MuudSpacing.md),
            decoration: BoxDecoration(
              color: MuudColors.white,
              borderRadius: MuudRadius.mdAll,
              border: Border.all(color: MuudColors.divider, width: 1.2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: "Search",
                      hintStyle: MuudTypography.bodySmall.copyWith(color: MuudColors.greyText),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                const Icon(Icons.search, color: MuudColors.greyText, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(width: MuudSpacing.sm),
        Container(
          width: 50, height: 44,
          decoration: BoxDecoration(
            color: MuudColors.white,
            borderRadius: MuudRadius.mdAll,
            border: Border.all(color: MuudColors.divider, width: 1.2),
          ),
          child: IconButton(
            onPressed: _openFilter,
            icon: const Icon(Icons.tune, color: MuudColors.purple),
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
            padding: const EdgeInsets.only(right: MuudSpacing.sm),
            child: GestureDetector(
              onTap: () => _setChip(c),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: MuudSpacing.md, vertical: MuudSpacing.sm),
                decoration: BoxDecoration(
                  color: selected ? MuudColors.purple : MuudColors.white,
                  borderRadius: MuudRadius.pillAll,
                  border: Border.all(color: MuudColors.purple, width: 1.4),
                ),
                child: Text(
                  c,
                  style: MuudTypography.caption.copyWith(
                    color: selected ? MuudColors.white : MuudColors.purple,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildSections() {
    return _sections.where((s) => s.count > 0).map((s) {
      return Padding(
        padding: const EdgeInsets.only(bottom: MuudSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: s.title, onSeeAll: () => _openCategory(s)),
            const SizedBox(height: MuudSpacing.md),
            _SectionBody(section: s, onTapAny: () => _openCategory(s)),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.only(top: MuudSpacing.lg),
      child: Column(
        children: [
          Text(
            _error ?? "Something went wrong",
            textAlign: TextAlign.center,
            style: MuudTypography.bodyMedium.copyWith(color: MuudColors.error, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: MuudSpacing.md),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _load,
              style: ElevatedButton.styleFrom(backgroundColor: MuudColors.purple, shape: const StadiumBorder(), elevation: 0),
              child: Text("Retry", style: MuudTypography.button.copyWith(color: MuudColors.white)),
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
        const Icon(Icons.description_outlined, size: 68, color: MuudColors.lightPurple),
        const SizedBox(height: MuudSpacing.md),
        Text("Empty Posts", style: MuudTypography.heading.copyWith(color: MuudColors.purple, fontSize: 22)),
        const SizedBox(height: MuudSpacing.sm),
        Text("Your posts will show up here.", style: MuudTypography.bodySmall.copyWith(color: MuudColors.greyText)),
        const SizedBox(height: MuudSpacing.lg),
        SizedBox(
          width: double.infinity, height: 54,
          child: ElevatedButton(
            onPressed: _openCreatorTool,
            style: ElevatedButton.styleFrom(backgroundColor: MuudColors.purple, shape: const StadiumBorder(), elevation: 0),
            child: Text("Start Journaling", style: MuudTypography.button.copyWith(color: MuudColors.white)),
          ),
        ),
        const SizedBox(height: MuudSpacing.lg),
      ],
    );
  }
}

/* ── UI Components ─────────────────────────────────────────────────── */

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: MuudTypography.heading.copyWith(color: MuudColors.purple, fontSize: 22)),
        const Spacer(),
        GestureDetector(
          onTap: onSeeAll,
          child: Text("See All", style: MuudTypography.label.copyWith(color: MuudColors.purple)),
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
    if (items.isEmpty) return _EmptySectionCard(onTap: onTapAny);

    final first = items[0];
    final second = items.length > 1 ? items[1] : null;
    final third = items.length > 2 ? items[2] : null;

    return Column(
      children: [
        _BigCard(item: first, sectionCount: section.count, onTap: onTapAny),
        if (second != null || third != null) ...[
          const SizedBox(height: MuudSpacing.md),
          Row(
            children: [
              Expanded(child: second == null ? const SizedBox.shrink() : _SmallCard(item: second, sectionCount: section.count, onTap: onTapAny)),
              if (third != null) ...[
                const SizedBox(width: MuudSpacing.md),
                Expanded(child: _SmallCard(item: third, sectionCount: section.count, onTap: onTapAny)),
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(MuudSpacing.md),
        decoration: BoxDecoration(
          color: MuudColors.white,
          borderRadius: MuudRadius.lgAll,
          border: Border.all(color: MuudColors.divider),
        ),
        child: Text("No previews yet", style: MuudTypography.bodySmall.copyWith(color: MuudColors.greyText)),
      ),
    );
  }
}

class _BigCard extends StatelessWidget {
  final _VaultPreview item;
  final int sectionCount;
  final VoidCallback onTap;
  const _BigCard({required this.item, required this.sectionCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final extra = sectionCount > 1 ? sectionCount - 1 : 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: MuudColors.white,
          borderRadius: MuudRadius.lgAll,
          border: Border.all(color: MuudColors.divider),
          boxShadow: MuudShadows.card,
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 150, width: double.infinity,
                child: (item.imageUrl == null || item.imageUrl!.isEmpty)
                    ? Container(color: MuudColors.lightPurple.withValues(alpha: 0.3))
                    : CachedNetworkImage(imageUrl: item.imageUrl!, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(MuudSpacing.md, MuudSpacing.md, MuudSpacing.md, MuudSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${item.authorName} · ${item.authorUsername}".trim(),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: MuudTypography.label.copyWith(color: MuudColors.purple, fontWeight: FontWeight.w900),
                        ),
                        if (item.authorLocation.isNotEmpty) ...[
                          const SizedBox(height: MuudSpacing.xxs),
                          Text(item.authorLocation, style: MuudTypography.caption.copyWith(color: MuudColors.greyText)),
                        ],
                        if (item.caption.isNotEmpty) ...[
                          const SizedBox(height: MuudSpacing.xs),
                          Text(item.caption, maxLines: 2, overflow: TextOverflow.ellipsis, style: MuudTypography.bodySmall.copyWith(color: MuudColors.greyText)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: MuudSpacing.sm),
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: MuudColors.lightPurple.withValues(alpha: 0.5),
                        backgroundImage: (item.authorAvatarUrl != null && item.authorAvatarUrl!.isNotEmpty)
                            ? NetworkImage(item.authorAvatarUrl!) : null,
                        child: (item.authorAvatarUrl == null || item.authorAvatarUrl!.isEmpty)
                            ? const Icon(Icons.person, size: 16, color: MuudColors.greyText) : null,
                      ),
                      if (extra > 0) ...[
                        const SizedBox(height: MuudSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: MuudSpacing.sm, vertical: MuudSpacing.xxs),
                          decoration: BoxDecoration(
                            color: MuudColors.lightPurple.withValues(alpha: 0.3),
                            borderRadius: MuudRadius.pillAll,
                            border: Border.all(color: MuudColors.divider),
                          ),
                          child: Text("+$extra", style: MuudTypography.caption.copyWith(color: MuudColors.greyText, fontSize: 11)),
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
  const _SmallCard({required this.item, required this.sectionCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 216,
        decoration: BoxDecoration(
          color: MuudColors.white,
          borderRadius: MuudRadius.lgAll,
          border: Border.all(color: MuudColors.divider),
          boxShadow: MuudShadows.card,
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 110, width: double.infinity,
                child: (item.imageUrl == null || item.imageUrl!.isEmpty)
                    ? Container(color: MuudColors.lightPurple.withValues(alpha: 0.3))
                    : CachedNetworkImage(imageUrl: item.imageUrl!, fit: BoxFit.cover),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(MuudSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${item.authorName} · ${item.authorUsername}".trim(),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: MuudTypography.caption.copyWith(color: MuudColors.purple, fontWeight: FontWeight.w900),
                    ),
                    if (item.authorLocation.isNotEmpty) ...[
                      const SizedBox(height: MuudSpacing.xxs),
                      Text(item.authorLocation, maxLines: 1, overflow: TextOverflow.ellipsis, style: MuudTypography.caption.copyWith(color: MuudColors.greyText)),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: MuudColors.lightPurple.withValues(alpha: 0.5),
                          backgroundImage: (item.authorAvatarUrl != null && item.authorAvatarUrl!.isNotEmpty) ? NetworkImage(item.authorAvatarUrl!) : null,
                          child: (item.authorAvatarUrl == null || item.authorAvatarUrl!.isEmpty) ? const Icon(Icons.person, size: 14, color: MuudColors.greyText) : null,
                        ),
                        const Spacer(),
                        const Icon(Icons.chevron_right, color: MuudColors.greyText),
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

/* ── Models ─────────────────────────────────────────────────────────── */

class _VaultSection {
  final String keyName;
  final String title;
  final int count;
  final List<_VaultPreview> preview;

  _VaultSection({required this.keyName, required this.title, required this.count, required this.preview});

  factory _VaultSection.fromMap(Map<String, dynamic> m) {
    final pv = ((m["preview"] as List?) ?? []).cast<Map<String, dynamic>>();
    return _VaultSection(
      keyName: (m["key"] ?? "").toString(),
      title: (m["title"] ?? "").toString(),
      count: (m["count"] is int) ? (m["count"] as int) : int.tryParse("${m["count"]}") ?? 0,
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

  _VaultPreview({required this.imageUrl, required this.caption, required this.authorName, required this.authorUsername, required this.authorLocation, required this.authorAvatarUrl});

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
