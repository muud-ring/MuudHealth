import 'package:flutter/material.dart';

import 'data/people_dummy_data.dart';
import 'widgets/section_title.dart';
import 'widgets/inner_circle_ring.dart';
import 'widgets/person_tile.dart';
import 'widgets/suggested_avatar.dart';
import 'widgets/primary_button.dart';
import 'sheets/manage_person_sheet.dart';

class PeopleTab extends StatelessWidget {
  const PeopleTab({super.key});

  static const Color kPurple = Color(0xFF5B288E);
  static const Color kGreyText = Color(0xFF898384);

  @override
  Widget build(BuildContext context) {
    final hasPeople = PeopleDummyData.hasPeople;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Inner Circle
          SectionTitle(
            title: "Inner Circle",
            trailingText: "See All",
            onTapTrailing: () {
              Navigator.pushNamed(context, '/people/inner-circle');
            },
          ),
          const SizedBox(height: 12),

          InnerCircleRing(
            isEmpty: !hasPeople,
            people: hasPeople ? PeopleDummyData.innerCircle : const [],
            onTapAddFriends: () {
              Navigator.pushNamed(context, '/people/suggestions');
            },
          ),

          const SizedBox(height: 18),

          // Empty helper (kept for completeness, but demo is locked to filled)
          if (!hasPeople) ...[
            const SizedBox(height: 14),
            const Text(
              "No Inner Circle",
              style: TextStyle(
                color: kPurple,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Add friends to your inner circle\nto keep up with their muuds.",
              style: TextStyle(
                color: kGreyText,
                fontSize: 13.5,
                height: 1.25,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            PrimaryButton(
              text: "Add Friends",
              onTap: () => Navigator.pushNamed(context, '/people/suggestions'),
            ),
            const SizedBox(height: 26),
          ] else ...[
            const SizedBox(height: 18),
          ],

          // --- Connections preview
          SectionTitle(
            title: "Connections",
            trailingText: "See All",
            onTapTrailing: () {
              Navigator.pushNamed(context, '/people/connections');
            },
          ),
          const SizedBox(height: 14),

          if (!hasPeople) ...[
            Center(
              child: Column(
                children: const [
                  Icon(
                    Icons.group_outlined,
                    size: 44,
                    color: Color(0xFFD7CDE3),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "No Connections",
                    style: TextStyle(
                      color: kPurple,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Add friends to connect and\nshare your muuds.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kGreyText,
                      fontSize: 13.5,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            PrimaryButton(
              text: "Add Friends",
              onTap: () => Navigator.pushNamed(context, '/people/suggestions'),
            ),
          ] else ...[
            ...PeopleDummyData.connections
                .take(3)
                .map(
                  (p) => PersonTile(
                    person: p,
                    onTap: () =>
                        Navigator.pushNamed(context, '/people/profile'),
                    onTapMenu: () => ManagePersonSheet.open(context, person: p),
                  ),
                ),
          ],

          const SizedBox(height: 26),

          // --- Suggested friends row
          SectionTitle(
            title: "Suggested Friends",
            trailingText: "See All",
            onTapTrailing: () {
              Navigator.pushNamed(context, '/people/suggestions');
            },
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 104,
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: PeopleDummyData.suggestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, i) {
                final person = PeopleDummyData.suggestions[i];
                return SuggestedAvatar(
                  person: person,
                  onTap: () => Navigator.pushNamed(context, '/people/profile'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
