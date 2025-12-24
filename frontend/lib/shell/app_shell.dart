import 'package:flutter/material.dart';
import '../services/token_storage.dart';

// ✅ People sheets
import '../screens/people/sheets/requests_sheet.dart';

// Screens (content-only)
import '../screens/home/home_tab.dart';
import '../screens/trends/trends_tab.dart';
import '../screens/journal/journal_tab.dart';
import '../screens/people/people_tab.dart';
import '../screens/explore/explore_tab.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const Color kPurple = Color(0xFF5B288E);

  int _selectedIndex = 0;

  Future<void> _logout() async {
    await TokenStorage.clearTokens();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  void _onNavTap(int index) {
    // ✅ "+" goes to Journal (index 2)
    setState(() => _selectedIndex = index);
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
    // People: chat + bell (bell opens requests sheet)
    if (_selectedIndex == 3) {
      return [
        IconButton(
          onPressed: () {
            // TODO: messages route later
          },
          icon: const Icon(Icons.chat_bubble_outline, color: kPurple),
        ),
        IconButton(
          onPressed: () {
            RequestsSheet.open(context);
          },
          icon: const Icon(Icons.notifications_none, color: kPurple),
        ),
      ];
    }

    // Default: chat + logout
    return [
      IconButton(
        onPressed: () {
          // TODO: messages route later
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
              // TODO: settings
            },
            onTapLeft2: () {
              // TODO: vault/lock
            },
          ),
        ),
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          HomeTab(),
          TrendsTab(),
          JournalTab(),
          PeopleTab(),
          ExploreTab(),
        ],
      ),

      bottomNavigationBar: _BottomNav(
        selectedIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

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
