// MUUD Health — Profile Page
// User profile view with posts and message CTA
// © Muud Health — Armin Hoes, MD

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../router/route_names.dart';
import '../../../theme/app_theme.dart';
import '../data/people_models.dart';

class ProfilePage extends StatelessWidget {
  final Person person;

  const ProfilePage({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    final title = person.handle.isNotEmpty ? person.handle : person.name;

    return Scaffold(
      backgroundColor: MuudColors.white,
      appBar: AppBar(
        backgroundColor: MuudColors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Go back',
          icon: const Icon(Icons.arrow_back, color: MuudColors.purple),
          onPressed: () => context.pop(),
        ),
        title: Text(
          title,
          style: MuudTypography.titleMedium.copyWith(color: MuudColors.purple),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          children: [
            // Profile card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(MuudSpacing.base),
              decoration: BoxDecoration(
                color: MuudColors.purple.withValues(alpha: 0.04),
                borderRadius: MuudRadius.lgAll,
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: MuudColors.lightPurple.withValues(alpha: 0.5),
                    child: Text(
                      (person.name.isNotEmpty ? person.name[0] : "?")
                          .toUpperCase(),
                      style: MuudTypography.heading.copyWith(
                        color: MuudColors.purple,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: MuudSpacing.sm),
                  Text(
                    person.name,
                    style: MuudTypography.titleMedium.copyWith(
                      color: MuudColors.purple,
                    ),
                  ),
                  if (person.handle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      person.handle,
                      style: MuudTypography.caption.copyWith(
                        color: MuudColors.greyText,
                      ),
                    ),
                  ],
                  if (person.location.isNotEmpty) ...[
                    const SizedBox(height: MuudSpacing.xs),
                    Text(
                      person.location,
                      style: MuudTypography.caption.copyWith(
                        color: MuudColors.greyText,
                      ),
                    ),
                  ],
                  const SizedBox(height: MuudSpacing.md),
                  SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MuudColors.purple,
                        elevation: 0,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () {
                        context.push(
                          Routes.chatConversation(person.id),
                        );
                      },
                      child: Text(
                        "Message",
                        style: MuudTypography.button.copyWith(
                          color: MuudColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: MuudSpacing.base),

            // Posts section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Posts",
                style: MuudTypography.titleMedium.copyWith(
                  color: MuudColors.purple,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: MuudSpacing.sm),
            _postCard("Yoga class was amazing today!", "2h ago"),
            _postCard("Feeling a bit low but going for a walk.", "1d ago"),
            _postCard("Meditation streak: 7 days", "3d ago"),
          ],
        ),
      ),
    );
  }

  Widget _postCard(String text, String time) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: MuudSpacing.sm),
      padding: const EdgeInsets.all(MuudSpacing.md),
      decoration: BoxDecoration(
        color: MuudColors.white,
        borderRadius: MuudRadius.mdAll,
        boxShadow: MuudShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: MuudTypography.bodyMedium.copyWith(
              color: MuudColors.purple,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: MuudSpacing.xs),
          Text(
            time,
            style: MuudTypography.caption.copyWith(
              color: MuudColors.greyText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
