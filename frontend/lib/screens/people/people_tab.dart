import 'package:flutter/material.dart';

import 'models/people_models.dart';
import 'widgets/section_header.dart';
import 'widgets/inner_circle_orbit.dart';
import 'widgets/connection_card.dart';
import 'widgets/suggested_friend_tile.dart';

class PeopleTab extends StatefulWidget {
  const PeopleTab({super.key});

  @override
  State<PeopleTab> createState() => _PeopleTabState();
}

class _PeopleTabState extends State<PeopleTab> {
  static const Color kPurple = Color(0xFF5B288E);

  // UI state
  bool _showAllConnections = false;

  // TEMP UI DATA (later we replace with API)
  late final List<InnerCircleMember> _innerCircleMembers;
  late final List<ConnectionItem> _connections;
  late final List<SuggestedFriend> _suggested;

  @override
  void initState() {
    super.initState();

    _innerCircleMembers = const [
      InnerCircleMember(name: "A", avatarUrl: "", ringColor: Color(0xFF6A5AE0)),
      InnerCircleMember(name: "B", avatarUrl: "", ringColor: Color(0xFF30D5C8)),
      InnerCircleMember(name: "C", avatarUrl: "", ringColor: Color(0xFF7C3AED)),
      InnerCircleMember(name: "D", avatarUrl: "", ringColor: Color(0xFF60A5FA)),
      InnerCircleMember(name: "E", avatarUrl: "", ringColor: Color(0xFFF59E0B)),
      InnerCircleMember(name: "F", avatarUrl: "", ringColor: Color(0xFFEF4444)),
    ];

    _connections = const [
      ConnectionItem(
        name: "Kathleen",
        lastSeen: "3 days ago",
        moodLabel: "Sad",
        cardColor: Color(0xFFECE0FF),
        moodBorderColor: Color(0xFF8B5CF6),
        avatarUrl: "",
      ),
      ConnectionItem(
        name: "Lily M.",
        lastSeen: "2 weeks ago",
        moodLabel: "Surprised",
        cardColor: Color(0xFFFFE4D6),
        moodBorderColor: Color(0xFFFB7185),
        avatarUrl: "",
      ),
      ConnectionItem(
        name: "Jacob S.",
        lastSeen: "1 month ago",
        moodLabel: "Disappointed",
        cardColor: Color(0xFFE0F3E3),
        moodBorderColor: Color(0xFF22C55E),
        avatarUrl: "",
      ),
      ConnectionItem(
        name: "Sean L.",
        lastSeen: "1 month ago",
        moodLabel: "Embarrassed",
        cardColor: Color(0xFFE5E9FF),
        moodBorderColor: Color(0xFF3B82F6),
        avatarUrl: "",
      ),
    ];

    _suggested = const [
      SuggestedFriend(
        name: "James Carter",
        handle: "@james",
        avatarUrl: "",
        ringColor: Color(0xFF6A5AE0),
      ),
      SuggestedFriend(
        name: "Henry C.",
        handle: "@henry",
        avatarUrl: "",
        ringColor: Color(0xFF30D5C8),
      ),
      SuggestedFriend(
        name: "Sean K.",
        handle: "@seank",
        avatarUrl: "",
        ringColor: Color(0xFF22C55E),
      ),
      SuggestedFriend(
        name: "Arya Singh",
        handle: "@arya",
        avatarUrl: "",
        ringColor: Color(0xFFF472B6),
      ),
      SuggestedFriend(
        name: "Mia",
        handle: "@mia",
        avatarUrl: "",
        ringColor: Color(0xFF7C3AED),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final visibleConnections = _showAllConnections
        ? _connections
        : _connections.take(4).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Inner Circle
          SectionHeader(
            title: "Inner Circle",
            onAction: () => _openPlaceholder(context, "Inner Circle - See All"),
          ),
          const SizedBox(height: 14),
          InnerCircleOrbit(
            centerAvatarUrl: "", // later: current user profile avatar
            members: _innerCircleMembers,
            onTapCenter: () =>
                _openPlaceholder(context, "Your profile (center)"),
            onTapMember: (m) =>
                _openPlaceholder(context, "Inner circle member: ${m.name}"),
          ),

          const SizedBox(height: 28),

          // Connections
          SectionHeader(
            title: "Connections",
            onAction: () => _openPlaceholder(context, "Connections - See All"),
          ),
          const SizedBox(height: 12),

          ...visibleConnections.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ConnectionCard(
                item: c,
                onTap: () =>
                    _openPlaceholder(context, "Open connection: ${c.name}"),
                onMenu: () => _showConnectionMenu(c),
              ),
            ),
          ),

          const SizedBox(height: 6),

          Center(
            child: SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kPurple, width: 1.4),
                  shape: const StadiumBorder(),
                ),
                onPressed: () {
                  setState(() => _showAllConnections = !_showAllConnections);
                },
                child: Text(
                  _showAllConnections ? "Show less" : "Show more",
                  style: const TextStyle(
                    color: kPurple,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 26),

          // Suggested Friends
          SectionHeader(
            title: "Suggested Friends",
            onAction: () =>
                _openPlaceholder(context, "Suggested Friends - See All"),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 118,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) => SuggestedFriendTile(
                friend: _suggested[i],
                onTap: () => _openPlaceholder(
                  context,
                  "Suggested friend: ${_suggested[i].name}",
                ),
              ),
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemCount: _suggested.length,
            ),
          ),
        ],
      ),
    );
  }

  void _showConnectionMenu(ConnectionItem c) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text("View ${c.name}"),
                onTap: () {
                  Navigator.pop(context);
                  _openPlaceholder(context, "View profile: ${c.name}");
                },
              ),
              ListTile(
                leading: const Icon(Icons.star_outline),
                title: const Text("Toggle Inner Circle"),
                onTap: () {
                  Navigator.pop(context);
                  _openPlaceholder(
                    context,
                    "Toggle inner circle for ${c.name}",
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text("Remove Connection"),
                onTap: () {
                  Navigator.pop(context);
                  _openPlaceholder(context, "Remove connection: ${c.name}");
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _openPlaceholder(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _PlaceholderScreen(title: title)),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  static const Color kPurple = Color(0xFF5B288E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), foregroundColor: kPurple),
      body: const Center(
        child: Text("Next screen will be built after this page."),
      ),
    );
  }
}
