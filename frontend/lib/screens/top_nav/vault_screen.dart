import 'package:flutter/material.dart';
import '../journal/pages/creator_tool_screen.dart';
import '../../services/vault_api.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  static const Color kPurple = Color(0xFF5B288E);
  static const Color kGrey = Color(0xFF898384);

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  bool loading = true;
  String? error;

  // from backend /vault/landing
  List<Map<String, dynamic>> sections = [];

  // UI state (chips)
  String selectedChip = "All";

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final data = await VaultApi.landing();
      if (!mounted) return;
      setState(() => sections = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => error = e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  int get _totalSavedCount {
    int sum = 0;
    for (final s in sections) {
      final c = s["count"];
      if (c is int) sum += c;
    }
    return sum;
  }

  void _openCreatorTool() {
    Navigator.of(
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
          icon: const Icon(Icons.arrow_back, color: VaultScreen.kPurple),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Vault",
          style: TextStyle(
            color: VaultScreen.kPurple,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: RefreshIndicator(onRefresh: _load, child: _body()),
    );
  }

  Widget _body() {
    if (loading) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (error != null) {
      return ListView(
        padding: const EdgeInsets.all(18),
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
              backgroundColor: VaultScreen.kPurple,
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
      );
    }

    // ✅ Figma empty state
    if (_totalSavedCount == 0) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
        children: [
          _searchAndFilterRow(),
          const SizedBox(height: 12),
          _categoryChips(),
          const SizedBox(height: 26),

          _emptyPostsCard(),
          const SizedBox(height: 28),

          _recommendationsSection(),
          const SizedBox(height: 26),

          _suggestedFriendsSection(),
          const SizedBox(height: 26),

          _communityTrendsSection(),
          const SizedBox(height: 26),

          _savedContentTypesSection(),
        ],
      );
    }

    // ✅ If items exist, we can keep a simple “sections list” for now.
    // Next steps will implement the exact Figma filled layout with big card + 2 small cards per section.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
      children: [
        _searchAndFilterRow(),
        const SizedBox(height: 12),
        _categoryChips(),
        const SizedBox(height: 18),
        ...sections.map((s) => _SectionCard(section: s)).toList(),
      ],
    );
  }

  // ---------- UI blocks (Figma) ----------

  Widget _searchAndFilterRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE7E1EF)),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: VaultScreen.kGrey),
                SizedBox(width: 10),
                Text(
                  "Search",
                  style: TextStyle(
                    color: VaultScreen.kGrey,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 52,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE7E1EF)),
          ),
          child: IconButton(
            onPressed: () {
              // Next step: open Filter screen like Figma
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Filter screen coming next")),
              );
            },
            icon: const Icon(Icons.tune, color: VaultScreen.kPurple),
          ),
        ),
      ],
    );
  }

  Widget _categoryChips() {
    final chips = ["All", "Family", "Friends", "Holidays"];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final label = chips[i];
          final selected = selectedChip == label;

          return InkWell(
            onTap: () => setState(() => selectedChip = label),
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? VaultScreen.kPurple : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: VaultScreen.kPurple),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : VaultScreen.kPurple,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _emptyPostsCard() {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Icon(
          Icons.description_outlined,
          size: 72,
          color: Color(0xFFD7CDE3),
        ),
        const SizedBox(height: 14),
        const Text(
          "Empty Posts",
          style: TextStyle(
            color: VaultScreen.kPurple,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "Your posts will show up here.",
          style: TextStyle(
            color: VaultScreen.kGrey,
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          height: 52,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _openCreatorTool,
            style: ElevatedButton.styleFrom(
              backgroundColor: VaultScreen.kPurple,
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
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: VaultScreen.kPurple,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("$title - See All coming next")),
            );
          },
          child: const Text(
            "See All",
            style: TextStyle(
              color: VaultScreen.kPurple,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _recommendationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("Recommendations"),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _miniTile(
                icon: Icons.self_improvement,
                label: "Meditation",
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _miniTile(icon: Icons.restaurant, label: "Cooking"),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _miniTile(icon: Icons.directions_run, label: "Exercise"),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _miniTile(icon: Icons.menu_book, label: "Reading"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _miniTile({required IconData icon, required String label}) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E1EF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: VaultScreen.kPurple),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: VaultScreen.kPurple,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _suggestedFriendsSection() {
    // Placeholder UI like Figma; later we’ll wire People suggestions
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("Suggested Friends"),
        const SizedBox(height: 10),
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, i) {
              return SizedBox(
                width: 64,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Color(0xFFF2EEF6),
                      child: Icon(
                        Icons.person,
                        color: VaultScreen.kGrey,
                        size: 20,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Name",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: VaultScreen.kPurple,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "@user",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: VaultScreen.kGrey,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _communityTrendsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("Community Trends"),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE7E1EF)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFF2EEF6),
                child: Icon(Icons.group, color: VaultScreen.kGrey),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Your friends sent 8 supportive reactions after your low mood entry.",
                  style: TextStyle(
                    color: VaultScreen.kPurple,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _savedContentTypesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("Saved Content Types"),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _contentTypeCard(title: "Journal")),
            const SizedBox(width: 12),
            Expanded(child: _contentTypeCard(title: "Photo")),
          ],
        ),
      ],
    );
  }

  Widget _contentTypeCard({required String title}) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F3FA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7E1EF)),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: VaultScreen.kPurple,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// Used when vault has content (basic section list for now)
class _SectionCard extends StatelessWidget {
  final Map<String, dynamic> section;
  const _SectionCard({required this.section});

  static const Color kPurple = Color(0xFF5B288E);
  static const Color kGrey = Color(0xFF898384);

  @override
  Widget build(BuildContext context) {
    final title = (section["title"] ?? "").toString();
    final count = (section["count"] ?? 0) as int;
    final preview = (section["preview"] as List?) ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
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
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: kPurple,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                "$count",
                style: const TextStyle(
                  color: kGrey,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 86,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: preview.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final p = preview[i] as Map<String, dynamic>;
                final imageUrl = (p["imageUrl"] ?? "").toString();

                return ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 86,
                    color: const Color(0xFFF2EEF6),
                    child: imageUrl.isEmpty
                        ? const Icon(Icons.image, color: kGrey)
                        : Image.network(imageUrl, fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
