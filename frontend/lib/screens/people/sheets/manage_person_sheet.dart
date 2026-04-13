// MUUD Health — Manage Person Sheet
// Bottom sheet for connection management actions
// © Muud Health — Armin Hoes, MD

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../router/route_names.dart';
import '../../../services/people_api.dart';
import '../../../theme/app_theme.dart';
import '../data/people_models.dart';
import '../state/people_events.dart';

class ManagePersonSheet {
  static Future<void> open(
    BuildContext context, {
    required Person person,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: MuudColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _ManagePersonBody(person: person),
    );
  }
}

class _ManagePersonBody extends StatefulWidget {
  final Person person;
  const _ManagePersonBody({required this.person});

  @override
  State<_ManagePersonBody> createState() => _ManagePersonBodyState();
}

class _ManagePersonBodyState extends State<_ManagePersonBody> {
  bool working = false;

  Future<void> _setTier(String tier) async {
    if (working) return;
    setState(() => working = true);

    try {
      await PeopleApi.updateTier(sub: widget.person.id, tier: tier);
      PeopleEvents.notifyReload();

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tier == "inner_circle"
                ? "Moved to Inner Circle"
                : "Moved to Connections",
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => working = false);
    }
  }

  Future<void> _remove() async {
    if (working) return;
    setState(() => working = true);

    try {
      await PeopleApi.removeConnection(sub: widget.person.id);
      PeopleEvents.notifyReload();

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Removed connection"),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.person;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          MuudSpacing.lg, MuudSpacing.md, MuudSpacing.lg, MuudSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: MuudColors.divider,
                borderRadius: MuudRadius.pillAll,
              ),
            ),
            const SizedBox(height: MuudSpacing.md),

            // Person header
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: MuudColors.lightPurple.withValues(alpha: 0.5),
                  child: Text(
                    (p.name.isNotEmpty ? p.name[0] : "?").toUpperCase(),
                    style: MuudTypography.label.copyWith(
                      color: MuudColors.purple,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: MuudSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: MuudTypography.label.copyWith(
                          color: MuudColors.purple,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (p.handle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          p.handle,
                          style: MuudTypography.caption.copyWith(
                            color: MuudColors.greyText,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: MuudSpacing.md),
            const Divider(color: MuudColors.divider),

            // Message action
            ListTile(
              enabled: !working,
              leading: const Icon(Icons.chat_bubble_outline, color: MuudColors.purple),
              title: Text(
                "Message",
                style: MuudTypography.label.copyWith(fontWeight: FontWeight.w800),
              ),
              onTap: working
                  ? null
                  : () {
                      Navigator.pop(context);
                      context.push(Routes.chatConversation(p.id));
                    },
            ),

            // Move to Connections
            ListTile(
              enabled: !working,
              leading: const Icon(Icons.group_outlined, color: MuudColors.purple),
              title: Text(
                "Move to Connections",
                style: MuudTypography.label.copyWith(fontWeight: FontWeight.w800),
              ),
              onTap: working ? null : () => _setTier("connection"),
            ),

            // Move to Inner Circle
            ListTile(
              enabled: !working,
              leading: const Icon(Icons.star_outline, color: MuudColors.purple),
              title: Text(
                "Move to Inner Circle",
                style: MuudTypography.label.copyWith(fontWeight: FontWeight.w800),
              ),
              onTap: working ? null : () => _setTier("inner_circle"),
            ),

            // Remove
            ListTile(
              enabled: !working,
              leading: Icon(Icons.delete_outline, color: MuudColors.error),
              title: Text(
                "Remove",
                style: MuudTypography.label.copyWith(
                  fontWeight: FontWeight.w800,
                  color: MuudColors.error,
                ),
              ),
              onTap: working ? null : _remove,
            ),

            const SizedBox(height: MuudSpacing.sm),

            if (working)
              Padding(
                padding: const EdgeInsets.only(bottom: MuudSpacing.sm),
                child: SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: MuudColors.purple,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
