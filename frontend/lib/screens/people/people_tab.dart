import 'package:flutter/material.dart';

import '../../services/token_storage.dart';

import 'state/people_controller.dart';
import 'widgets/section_title.dart';
import 'widgets/inner_circle_ring.dart';
import 'widgets/person_tile.dart';
import 'widgets/suggested_avatar.dart';
import 'widgets/primary_button.dart';
import 'sheets/manage_person_sheet.dart';

import 'state/people_events.dart';

class PeopleTab extends StatefulWidget {
  const PeopleTab({super.key});

  @override
  State<PeopleTab> createState() => _PeopleTabState();
}

class _PeopleTabState extends State<PeopleTab> {
  static const Color kPurple = Color(0xFF5B288E);
  static const Color kGreyText = Color(0xFF898384);

  final PeopleController controller = PeopleController();

  @override
  void initState() {
    super.initState();
    controller.addListener(_onUpdate);

    // ✅ reload when any People action happens elsewhere
    PeopleEvents.reload.addListener(_onExternalReload);

    controller.loadAll();
  }

  void _onExternalReload() {
    controller.loadAll();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    PeopleEvents.reload.removeListener(_onExternalReload);
    controller.removeListener(_onUpdate);
    controller.dispose();
    super.dispose();
  }

  Future<void> _forceLogout() async {
    await TokenStorage.clearTokens();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final hasPeople =
        controller.innerCircle.isNotEmpty || controller.connections.isNotEmpty;

    // --- Loading
    if (controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // --- Error
    if (controller.error != null) {
      final isExpired = controller.error!.toLowerCase().contains(
        "session expired",
      );

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 44, color: kPurple),
              const SizedBox(height: 10),
              const Text(
                "Could not load People",
                style: TextStyle(
                  color: kPurple,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                controller.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: kGreyText,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: 180,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPurple,
                    elevation: 0,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () async {
                    if (isExpired) {
                      await _forceLogout();
                      return;
                    }
                    controller.loadAll();
                  },
                  child: Text(
                    isExpired ? "Login" : "Retry",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final suggestions = controller.suggestions;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Manual refresh row (guaranteed)
          Row(
            children: [
              const Text(
                "People",
                style: TextStyle(
                  color: kPurple,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: controller.loadAll,
                icon: const Icon(Icons.refresh, color: kPurple),
                label: const Text(
                  "Refresh",
                  style: TextStyle(color: kPurple, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

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
            isEmpty: controller.innerCircle.isEmpty,
            people: controller.innerCircle,
            onTapAddFriends: () {
              Navigator.pushNamed(context, '/people/suggestions');
            },
          ),

          const SizedBox(height: 18),

          // Empty helper
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

          if (controller.connections.isEmpty) ...[
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
            ...controller.connections
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

          if (suggestions.isEmpty)
            const Text(
              "No suggestions right now.",
              style: TextStyle(
                color: kGreyText,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            SizedBox(
              height: 104,
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: suggestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, i) {
                  final person = suggestions[i];
                  return SuggestedAvatar(
                    person: person,
                    onTap: () =>
                        Navigator.pushNamed(context, '/people/profile'),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
