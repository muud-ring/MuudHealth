import 'package:flutter/material.dart';

class TrendsTab extends StatelessWidget {
  const TrendsTab({super.key});

  static const Color kPurple = Color(0xFF5B288E);
  static const Color kGreyText = Color(0xFF898384);
  static const Color kLightPurple = Color(0xFFC9B7E6); // icon tint like figma

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Column(
            children: [
              _SearchBar(onChanged: (_) {}, onTapSearch: () {}),

              // main empty content
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 4),
                        const _EmptyTrendsIcon(),
                        const SizedBox(height: 18),

                        const Text(
                          "No Data",
                          style: TextStyle(
                            color: kPurple,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),

                        Text(
                          "Your trends will show up here.",
                          style: TextStyle(
                            color: kGreyText.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 28),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              // Match your app routing if needed
                              // Navigator.pushNamed(context, '/journal');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPurple,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: const Text(
                              "Start Journaling",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ----------------------------- SEARCH BAR ----------------------------- */

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged, required this.onTapSearch});

  final ValueChanged<String> onChanged;
  final VoidCallback onTapSearch;

  static const Color kPurple = Color(0xFF5B288E);
  static const Color kHint = Color(0xFFB7B1B3);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kPurple.withOpacity(0.55), width: 2),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              cursorColor: kPurple,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Search...",
                hintStyle: TextStyle(
                  color: kHint,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onTapSearch,
            icon: Icon(
              Icons.search,
              color: kPurple.withOpacity(0.55),
              size: 26,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}

/* ---------------------------- EMPTY ICON ----------------------------- */

class _EmptyTrendsIcon extends StatelessWidget {
  const _EmptyTrendsIcon();

  static const Color kLightPurple = Color(0xFFC9B7E6);

  @override
  Widget build(BuildContext context) {
    // Icon composition to resemble the figma (database + search)
    return SizedBox(
      width: 86,
      height: 86,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.storage_rounded,
            size: 64,
            color: kLightPurple.withOpacity(0.75),
          ),
          Positioned(
            right: 6,
            bottom: 16,
            child: Icon(
              Icons.search_rounded,
              size: 34,
              color: kLightPurple.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }
}
