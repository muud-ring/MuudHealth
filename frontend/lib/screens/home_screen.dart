import 'package:flutter/material.dart';
import '../services/token_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color kPurple = Color(0xFF5B288E);
  static const Color kGreyText = Color(0xFF898384);

  int _selectedIndex = 0;

  // Temporary placeholders until we wire real profile/user data
  final String firstName = "Alex";
  final String location = "Los Angeles, CA";

  Future<void> _logout() async {
    await TokenStorage.clearTokens();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);

    // If you already have routes/screens for these, you can navigate here.
    // Keeping it simple for now.
    switch (index) {
      case 0:
        // Home (stay)
        break;
      case 1:
        // Navigator.pushReplacementNamed(context, '/trends');
        break;
      case 2:
        // Plus action (journal create)
        // Navigator.pushNamed(context, '/journal/create');
        break;
      case 3:
        // Navigator.pushReplacementNamed(context, '/people');
        break;
      case 4:
        // Navigator.pushReplacementNamed(context, '/explore');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ---------- Body ----------
      body: SafeArea(
        child: Column(
          children: [
            // Top row (Settings, Vault) (Home title) (Chat, Logout)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              child: Row(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          // Navigator.pushNamed(context, '/settings');
                        },
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: kPurple,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // Navigator.pushNamed(context, '/vault');
                        },
                        icon: const Icon(Icons.lock_outline, color: kPurple),
                      ),
                    ],
                  ),

                  const Spacer(),

                  const Text(
                    "Home",
                    style: TextStyle(
                      color: kPurple,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const Spacer(),

                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          // Navigator.pushNamed(context, '/messages');
                        },
                        icon: const Icon(
                          Icons.chat_bubble_outline,
                          color: kPurple,
                        ),
                      ),

                      // Replacing bell with logout (as you asked)
                      IconButton(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout, color: kPurple),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    Text(
                      "Good Morning $firstName!",
                      style: const TextStyle(
                        fontSize: 28,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                        color: kPurple,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Profile card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
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
                        children: [
                          // Edit (top right)
                          Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: () {
                                // Navigator.pushNamed(context, '/edit-profile');
                              },
                              child: const Text(
                                "Edit",
                                style: TextStyle(
                                  color: kPurple,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Avatar
                          Container(
                            width: 98,
                            height: 98,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFEFEFEF),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 48,
                              color: Color(0xFFBDBDBD),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            firstName,
                            style: const TextStyle(
                              color: kPurple,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            location,
                            style: const TextStyle(
                              color: kGreyText,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 34),

                    // Empty state icon + text
                    Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.storage_outlined,
                            size: 48,
                            color: Color(0xFFD7CDE3),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "No Data",
                            style: TextStyle(
                              color: kPurple,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Your trends will show up here.",
                            style: TextStyle(
                              color: kGreyText.withOpacity(0.9),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    // Start Journaling button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPurple,
                          shape: const StadiumBorder(),
                          elevation: 0,
                        ),
                        onPressed: () {
                          // Navigator.pushNamed(context, '/journal');
                        },
                        child: const Text(
                          "Start Journaling",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ---------- Bottom Nav ----------
      bottomNavigationBar: _BottomNav(
        selectedIndex: _selectedIndex,
        onTap: _onNavTap,
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
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
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
        boxShadow: [
          BoxShadow(
            color: kPurple.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(Icons.add, color: Colors.white, size: 26),
    );
  }
}
