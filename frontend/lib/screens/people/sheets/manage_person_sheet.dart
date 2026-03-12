import 'package:flutter/material.dart';

import '../../../services/people_api.dart';
import '../data/people_models.dart';
import '../state/people_events.dart';
import '../pages/chat_page.dart';

class ManagePersonSheet {
  static Future<void> open(
    BuildContext context, {
    required Person person,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
  static const Color kPurple = Color(0xFF5B288E);
  bool working = false;

  Future<void> _setTier(String tier) async {
    if (working) return;
    setState(() => working = true);

    try {
      await PeopleApi.updateTier(sub: widget.person.id, tier: tier);

      // ✅ Tell ALL People screens to reload (PeopleTab, ConnectionsPage, InnerCirclePage)
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
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFE7E1F3),
                  child: Text(
                    (p.name.isNotEmpty ? p.name[0] : "?").toUpperCase(),
                    style: const TextStyle(
                      color: kPurple,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: const TextStyle(
                          color: kPurple,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p.handle,
                        style: const TextStyle(
                          color: Color(0xFF898384),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(),

            ListTile(
              enabled: !working,
              leading: const Icon(Icons.chat_bubble_outline, color: kPurple),
              title: const Text(
                "Message",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              onTap: working
                  ? null
                  : () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            otherSub: p.id,
                            title: p.handle.isNotEmpty ? p.handle : p.name,
                          ),
                        ),
                      );
                    },
            ),

            ListTile(
              enabled: !working,
              leading: const Icon(Icons.group_outlined, color: kPurple),
              title: const Text(
                "Move to Connections",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              onTap: working ? null : () => _setTier("connection"),
            ),

            ListTile(
              enabled: !working,
              leading: const Icon(Icons.star_outline, color: kPurple),
              title: const Text(
                "Move to Inner Circle",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              onTap: working ? null : () => _setTier("inner_circle"),
            ),

            ListTile(
              enabled: !working,
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                "Remove",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.red,
                ),
              ),
              onTap: working ? null : _remove,
            ),

            const SizedBox(height: 10),

            if (working)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
