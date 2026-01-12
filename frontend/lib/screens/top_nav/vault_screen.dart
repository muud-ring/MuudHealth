import 'package:flutter/material.dart';

import '../../services/vault_api.dart';
import '../journal/pages/creator_tool_screen.dart';
import 'vault_category_page.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  static const Color kPurple = Color(0xFF5B288E);
  static const Color kGrey = Color(0xFF898384);
  static const Color kBorder = Color(0xFFE7E1EF);

  final TextEditingController _searchCtrl = TextEditingController();

  bool _loading = true;
  String? _error;

  // landing sections from backend
  List<_VaultSection> _allSections = [];
  List<_VaultSection> _sections = []; // filtered view shown on UI

  // UI state
  String _selectedChip = "All";
  String _search = "";

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(() {
      final v = _searchCtrl.text.trim();
      if (v == _search) return;
      setState(() => _search = v);
      _load(); // MVP: client-side filter, still ok to reload
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
      setState(() {
        _allSections = mapped;
        _sections =
            mapped; // because your backend is currently returning filtered already
      });
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

  bool get _hasAnySaved {
    // If any section has count > 0 => vault not empty
    for (final s in _allSections) {
      if (s.count > 0) return true;
    }
    return false;
  }

  Future<void> _openCreatorTool() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CreatorToolScreen()));
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
        title: const Text(
          "Vault",
          style: TextStyle(
            color: kPurple,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
          children: [
            _buildTopRow(),
            const SizedBox(height: 12),
            _buildChips(),
            const SizedBox(height: 16),

            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 22),
                child: Center(child: CircularProgressIndicator()),
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
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F3FA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: kGrey, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      hintText: "Search your Vault",
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                if (_searchCtrl.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      FocusScope.of(context).unfocus();
                    },
                    child: const Icon(Icons.close, color: kGrey, size: 18),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Filter icon (we'll hook to filter screen next step)
        Container(
          width: 46,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kBorder),
          ),
          child: IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Filter screen next ✅")),
              );
            },
            icon: const Icon(Icons.tune, color: kPurple),
          ),
        ),
      ],
    );
  }

  Widget _buildChips() {
    final chips = <String>[
      "All",
      "Family",
      "Friends",
      "Events",
      "Holidays",
      "Work",
      "School",
      "Other",
    ];

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
                  border: Border.all(color: kPurple),
                ),
                child: Text(
                  c,
                  style: TextStyle(
                    color: selected ? Colors.white : kPurple,
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
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
    // matches your figma empty state vibe
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

        const SizedBox(height: 26),
        _buildRecommendations(),
        const SizedBox(height: 18),
        _buildSuggestedFriendsPlaceholder(),
        const SizedBox(height: 18),
        _buildSavedContentTypesPlaceholder(),
      ],
    );
  }

  Widget _buildRecommendations() {
    return _SectionShell(
      title: "Recommendations",
      action: "See All",
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(
                child: _MiniPill(
                  icon: Icons.self_improvement,
                  text: "Meditation",
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _MiniPill(icon: Icons.restaurant, text: "Cooking"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Expanded(
                child: _MiniPill(icon: Icons.directions_run, text: "Exercise"),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _MiniPill(icon: Icons.menu_book, text: "Reading"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedFriendsPlaceholder() {
    return _SectionShell(
      title: "Suggested Friends",
      action: "See All",
      child: SizedBox(
        height: 78,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 6,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, __) {
            return Column(
              children: const [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0xFFEFEAF6),
                  child: Icon(Icons.person, color: kGrey),
                ),
                SizedBox(height: 6),
                SizedBox(
                  width: 52,
                  child: Text(
                    "Name",
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kPurple,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSavedContentTypesPlaceholder() {
    return _SectionShell(
      title: "Saved Content Types",
      action: "See All",
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 82,
              decoration: BoxDecoration(
                color: const Color(0xFFF6F3FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBorder),
              ),
              child: const Center(
                child: Text(
                  "Journal",
                  style: TextStyle(color: kPurple, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 82,
              decoration: BoxDecoration(
                color: const Color(0xFFF6F3FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBorder),
              ),
              child: const Center(
                child: Text(
                  "Photo",
                  style: TextStyle(color: kPurple, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSections() {
    // Show only non-empty sections (like curated memory space)
    final nonEmpty = _sections.where((s) => s.count > 0).toList();

    return nonEmpty.map((s) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => VaultCategoryPage(
                  categoryKey: s.keyName,
                  categoryTitle: s.title,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      s.title,
                      style: const TextStyle(
                        color: kPurple,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "${s.count}",
                      style: const TextStyle(
                        color: kGrey,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (s.preview.isEmpty)
                  const Text(
                    "No previews yet",
                    style: TextStyle(color: kGrey, fontWeight: FontWeight.w600),
                  )
                else
                  SizedBox(
                    height: 56,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: s.preview.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, i) {
                        final p = s.preview[i];
                        return _PreviewThumb(imageUrl: p.imageUrl);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}

/// Models

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

  _VaultPreview({required this.imageUrl});

  factory _VaultPreview.fromMap(Map<String, dynamic> m) {
    return _VaultPreview(imageUrl: m["imageUrl"]?.toString());
  }
}

/// UI Helpers

class _SectionShell extends StatelessWidget {
  final String title;
  final String action;
  final Widget child;

  const _SectionShell({
    required this.title,
    required this.action,
    required this.child,
  });

  static const Color kPurple = Color(0xFF5B288E);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: kPurple,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            Text(
              action,
              style: const TextStyle(
                color: kPurple,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _MiniPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniPill({required this.icon, required this.text});

  static const Color kPurple = Color(0xFF5B288E);
  static const Color kBorder = Color(0xFFE7E1EF);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: kPurple, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(color: kPurple, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _PreviewThumb extends StatelessWidget {
  final String? imageUrl;
  const _PreviewThumb({required this.imageUrl});

  static const Color kBorder = Color(0xFFE7E1EF);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 72,
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(color: kBorder),
          borderRadius: BorderRadius.circular(14),
        ),
        child: (imageUrl == null || imageUrl!.isEmpty)
            ? Container(color: const Color(0xFFF6F3FA))
            : Image.network(imageUrl!, fit: BoxFit.cover),
      ),
    );
  }
}
