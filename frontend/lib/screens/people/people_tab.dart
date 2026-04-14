// MUUD Health — People Tab
// Social graph: inner circle, connections, suggestions
// Signal Pathway: Learn + Grow layers
// © Muud Health — Armin Hoes, MD

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/token_storage.dart';
import '../../router/route_names.dart';
import '../../theme/app_theme.dart';
import 'state/people_controller.dart';
import 'widgets/section_title.dart';
import 'widgets/inner_circle_ring.dart';
import 'widgets/person_tile.dart';
import 'widgets/suggested_avatar.dart';
import 'widgets/primary_button.dart';
import 'sheets/manage_person_sheet.dart';
import 'state/people_events.dart';

class PeopleTab extends ConsumerStatefulWidget {
  const PeopleTab({super.key});

  @override
  ConsumerState<PeopleTab> createState() => _PeopleTabState();
}

class _PeopleTabState extends ConsumerState<PeopleTab> {
  final PeopleController controller = PeopleController();

  @override
  void initState() {
    super.initState();
    controller.addListener(_onUpdate);
    PeopleEvents.reload.addListener(_onExternalReload);
    controller.loadAll();
  }

  void _onExternalReload() => controller.loadAll();
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
    context.go(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    if (controller.loading) {
      return const Center(
        child: CircularProgressIndicator(color: MuudColors.purple),
      );
    }

    if (controller.error != null) {
      final isExpired =
          controller.error!.toLowerCase().contains("session expired");

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(MuudSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 44, color: MuudColors.purple),
              const SizedBox(height: MuudSpacing.sm),
              Text(
                "Could not load People",
                style: MuudTypography.titleMedium.copyWith(
                  color: MuudColors.purple,
                ),
              ),
              const SizedBox(height: MuudSpacing.xs),
              Text(
                controller.error!,
                textAlign: TextAlign.center,
                style: MuudTypography.caption.copyWith(
                  color: MuudColors.greyText,
                ),
              ),
              const SizedBox(height: MuudSpacing.md),
              SizedBox(
                width: 180,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MuudColors.purple,
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
                    style: MuudTypography.button.copyWith(color: MuudColors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final suggestions = controller.suggestions;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: MuudSpacing.sm),

            // Inner Circle
            SectionTitle(
              title: "Inner Circle",
              trailingText: "See All",
              onTapTrailing: () => context.push(Routes.innerCircle),
            ),
            const SizedBox(height: MuudSpacing.md),
            InnerCircleRing(
              isEmpty: controller.innerCircle.isEmpty,
              people: controller.innerCircle,
              centerPerson: controller.me,
              onTapAddFriends: () => context.push(Routes.suggestions),
              onTapPerson: (p) => context.push(Routes.profile(p.id)),
            ),

            const SizedBox(height: MuudSpacing.xl),

            // Connections
            SectionTitle(
              title: "Connections",
              trailingText: "See All",
              onTapTrailing: () => context.push(Routes.connections),
            ),
            const SizedBox(height: MuudSpacing.md),

            if (controller.connections.isEmpty) ...[
              const SizedBox(height: MuudSpacing.sm),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.group_outlined,
                      size: 44,
                      color: MuudColors.lightPurple.withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: MuudSpacing.sm),
                    Text(
                      "No Connections",
                      style: MuudTypography.titleMedium.copyWith(
                        color: MuudColors.purple,
                      ),
                    ),
                    const SizedBox(height: MuudSpacing.xs),
                    Text(
                      "Your connections will show up here.",
                      textAlign: TextAlign.center,
                      style: MuudTypography.bodySmall.copyWith(
                        color: MuudColors.greyText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: MuudSpacing.md),
              PrimaryButton(
                text: "Add friends",
                onTap: () => context.push(Routes.suggestions),
              ),
            ] else ...[
              ...controller.connections.take(4).map(
                (p) => PersonTile(
                  person: p,
                  onTap: () => context.push(Routes.profile(p.id)),
                  onTapMenu: () =>
                      ManagePersonSheet.open(context, person: p),
                ),
              ),
              const SizedBox(height: MuudSpacing.sm),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: MuudColors.purple, width: 1.5),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () => context.push(Routes.connections),
                  child: Text(
                    "Show more",
                    style: MuudTypography.button.copyWith(
                      color: MuudColors.purple,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: MuudSpacing.xl),

            // Suggested Friends
            SectionTitle(
              title: "Suggested Friends",
              trailingText: "See All",
              onTapTrailing: () => context.push(Routes.suggestions),
            ),
            const SizedBox(height: MuudSpacing.md),

            if (suggestions.isEmpty)
              Text(
                "No suggestions right now.",
                style: MuudTypography.bodySmall.copyWith(
                  color: MuudColors.greyText,
                ),
              )
            else
              SizedBox(
                height: 112,
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: suggestions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: MuudSpacing.md),
                  itemBuilder: (context, i) {
                    final person = suggestions[i];
                    return SuggestedAvatar(
                      person: person,
                      onTap: () => context.push(Routes.profile(person.id)),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
