import 'package:flutter/material.dart';
import '../services/token_storage.dart';

// Screens (content-only)
import '../screens/home/home_tab.dart';
import '../screens/trends/trends_tab.dart';
import '../screens/journal/journal_tab.dart';
import '../screens/people/people_tab.dart';
import '../screens/explore/explore_tab.dart';

import '../screens/top_nav/settings_screen.dart';
import '../screens/top_nav/notifications_screen.dart'; // ✅ NEW
import '../screens/chat/pages/conversations_page.dart';

// People events (to refresh badge)
import '../screens/people/state/people_events.dart'; // ✅ NEW
import '../services/people_api.dart'; // ✅ NEW (to fetch requests count)

// Journal Tab
import '../screens/journal/pages/creator_tool_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const Color kPurple = Color(0xFF5B288E);

  int _selectedIndex = 0;

  // ✅ forces PeopleTab to rebuild when user taps People
  int _peopleReloadTick = 0;

  // ✅ badge count for bell
  int _requestCount = 0;

  @override
  void initState() {
    super.initState();

    // Load initial badge count
    _refreshRequestCount();

    // Whenever PeopleEvents says "reload", refresh badge too
    PeopleEvents.reload.addListener(_onPeopleReloadSignal);
  }

  void _onPeopleReloadSignal() {
    _refreshRequestCount();
  }

  @override
  void dispose() {
    PeopleEvents.reload.removeListener(_onPeopleReloadSignal);
    super.dispose();
  }

  Future<void> _refreshRequestCount() async {
    try {
      final list = await PeopleApi.fetchRequests();
      if (!mounted) return;
      setState(() => _requestCount = list.length);
    } catch (_) {
      // if token expired or API fails, don't crash UI
      if (!mounted) return;
      setState(() => _requestCount = 0);
    }
  }

  Future<void> _logout() async {
    await TokenStorage.clearTokens();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  void _onNavTap(int index) {
    // ✅ "+" should open Creator Tool instead of switching tabs
    if (index == 2) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const CreatorToolScreen()));
      return;
    }

    setState(() {
      _selectedIndex = index;
      if (index == 3) {
        _peopleReloadTick++;
        _refreshRequestCount(); // ✅ update badge when you open People
      }
    });
  }

  String _titleForIndex(int index) {
    switch (index) {
      case 0:
        return "Home";
      case 1:
        return "Trends";
      case 2:
        return "Journal";
      case 3:
        return "People";
      case 4:
        return "Explore";
      default:
        return "";
    }
  }

  List<Widget> _rightActionsForIndex() {
    // ✅ bell should exist only on People page (as you already designed)
    if (_selectedIndex == 3) {
      return [
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/chat/conversations');
          },
          icon: const Icon(Icons.chat_bubble_outline, color: kPurple),
        ),

        // ✅ Bell with badge + opens NotificationsScreen
        IconButton(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            );

            // ✅ after coming back, refresh badge (accept/decline changes count)
            _refreshRequestCount();
          },
          icon: _BellWithBadge(count: _requestCount),
        ),
      ];
    }

    // Default (Home/Trends/Explore): chat + logout
    return [
      IconButton(
        onPressed: () {
          Navigator.pushNamed(context, '/chat/conversations');
        },
        icon: const Icon(Icons.chat_bubble_outline, color: kPurple),
      ),
      IconButton(
        onPressed: _logout,
        icon: const Icon(Icons.logout, color: kPurple),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          bottom: false,
          child: _TopBar(
            title: _titleForIndex(_selectedIndex),
            rightActions: _rightActionsForIndex(),
            onTapLeft1: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
            onTapLeft2: () {
              Navigator.of(context).pushNamed('/vault');
            },
          ),
        ),
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const HomeTab(),
          const TrendsTab(),
          const JournalTab(),

          // ✅ key changes each time you tap People → rebuild + re-fetch with latest token
          PeopleTab(key: ValueKey("people_$_peopleReloadTick")),

          const ExploreTab(),
        ],
      ),

      bottomNavigationBar: _BottomNav(
        selectedIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

/* ----------------------------- TOP BAR UI ----------------------------- */

class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onTapLeft1;
  final VoidCallback onTapLeft2;
  final List<Widget> rightActions;

  const _TopBar({
    required this.title,
    required this.onTapLeft1,
    required this.onTapLeft2,
    required this.rightActions,
  });

  static const Color kPurple = Color(0xFF5B288E);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      child: Row(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onTapLeft1,
                icon: const Icon(Icons.settings_outlined, color: kPurple),
              ),
              IconButton(
                onPressed: onTapLeft2,
                icon: const Icon(Icons.lock_outline, color: kPurple),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: kPurple,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Row(children: rightActions),
        ],
      ),
    );
  }
}

/* -------------------------- BELL WITH BADGE --------------------------- */

class _BellWithBadge extends StatelessWidget {
  final int count;
  const _BellWithBadge({required this.count});

  static const Color kPurple = Color(0xFF5B288E);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications_none, color: kPurple),

        if (count > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Center(
                child: Text(
                  count > 99 ? "99+" : "$count",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/* ---------------------------- BOTTOM NAV ------------------------------ */

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.selectedIndex, required this.onTap});

  static const Color kPurple = Color(0xFF5B288E);
  static const Color kGreyText = Color(0xFF898384);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kPurple,
        unselectedItemColor: kGreyText,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: "Trends",
          ),
          BottomNavigationBarItem(icon: _PlusIcon(), label: ""),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            label: "People",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Explore"),
        ],
      ),
    );
  }
}

class _PlusIcon extends StatelessWidget {
  const _PlusIcon();
  static const Color kPurple = Color(0xFF5B288E);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: kPurple,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.add, color: Colors.white, size: 26),
    );
  }
}
