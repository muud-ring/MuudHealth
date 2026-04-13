import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/people_provider.dart';
import '../router/route_names.dart';

// Screens (content-only)
import '../screens/home/home_tab.dart';
import '../screens/trends/trends_tab.dart';
import '../screens/journal/journal_tab.dart';
import '../screens/people/people_tab.dart';
import '../screens/explore/explore_tab.dart';

import '../screens/top_nav/settings_screen.dart';
import '../screens/top_nav/notifications_screen.dart';

// People events (to refresh badge)
import '../screens/people/state/people_events.dart';

// Chat badge (still uses ValueNotifier for Socket.IO real-time)
import '../screens/chat/state/chat_badge.dart';

// Journal Tab
import '../screens/journal/pages/creator_tool_screen.dart';
import '../theme/app_theme.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _selectedIndex = 0;
  int _peopleReloadTick = 0;

  @override
  void initState() {
    super.initState();

    // Load people data (includes requests for badge count)
    ref.read(peopleProvider.notifier).loadAll();

    // Whenever PeopleEvents says "reload", refresh via provider
    PeopleEvents.reload.addListener(_onPeopleReloadSignal);

    // Start chat badge socket + initial unread fetch
    ChatBadge.start();
  }

  void _onPeopleReloadSignal() {
    ref.read(peopleProvider.notifier).loadAll();
  }

  @override
  void dispose() {
    PeopleEvents.reload.removeListener(_onPeopleReloadSignal);
    ChatBadge.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    ChatBadge.reset();
    await ref.read(authProvider.notifier).logout();
    if (!mounted) return;
    context.go(Routes.login);
  }

  void _onNavTap(int index) {
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
        ref.read(peopleProvider.notifier).loadAll();
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
    final requestCount = ref.watch(peopleProvider).requests.length;

    if (_selectedIndex == 3) {
      return [
        IconButton(
          tooltip: 'Messages',
          onPressed: () => context.push(Routes.chat),
          icon: const _MessageWithBadge(),
        ),
        IconButton(
          tooltip: 'Notifications',
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            );
            ref.read(peopleProvider.notifier).loadAll();
          },
          icon: _BellWithBadge(count: requestCount),
        ),
      ];
    }

    return [
      IconButton(
        tooltip: 'Messages',
        onPressed: () => context.push(Routes.chat),
        icon: const _MessageWithBadge(),
      ),
      IconButton(
        tooltip: 'Log out',
        onPressed: _logout,
        icon: const Icon(Icons.logout, color: MuudColors.purple),
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
            onTapLeft1: () => context.push(Routes.settings),
            onTapLeft2: () => context.push(Routes.vault),
          ),
        ),
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const HomeTab(),
          const TrendsTab(),
          const JournalTab(),
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
                icon: const Icon(Icons.settings_outlined, color: MuudColors.purple),
              ),
              IconButton(
                onPressed: onTapLeft2,
                icon: const Icon(Icons.lock_outline, color: MuudColors.purple),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: MuudColors.purple,
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

/* -------------------------- MESSAGE WITH BADGE --------------------------- */

class _MessageWithBadge extends StatelessWidget {
  const _MessageWithBadge();
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: ChatBadge.unread,
      builder: (context, count, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.chat_bubble_outline, color: MuudColors.purple),
            if (count > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
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
      },
    );
  }
}

/* -------------------------- BELL WITH BADGE --------------------------- */

class _BellWithBadge extends StatelessWidget {
  final int count;
  const _BellWithBadge({required this.count});
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications_none, color: MuudColors.purple),
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
        selectedItemColor: MuudColors.purple,
        unselectedItemColor: MuudColors.greyText,
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
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: MuudColors.purple,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.add, color: Colors.white, size: 26),
    );
  }
}
