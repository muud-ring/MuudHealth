import 'package:flutter/material.dart';
import '../data/people_models.dart';

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

class _ManagePersonBody extends StatelessWidget {
  final Person person;

  const _ManagePersonBody({required this.person});

  static const Color kPurple = Color(0xFF5B288E);
  static const Color kGreyText = Color(0xFF898384);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFE6E6E6),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 14),

            Text(
              person.name,
              style: const TextStyle(
                color: kPurple,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),

            _SheetRow(
              text: "Add to Inner Circle",
              onTap: () {
                // TODO: API call
                Navigator.pop(context);
              },
            ),
            _SheetRow(
              text: "Add to Connections",
              onTap: () {
                // TODO: API call
                Navigator.pop(context);
              },
            ),
            _SheetRow(
              text: "Remove",
              danger: true,
              onTap: () {
                // TODO: API call
                Navigator.pop(context);
              },
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kPurple),
                  shape: const StadiumBorder(),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: kPurple, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool danger;

  const _SheetRow({
    required this.text,
    required this.onTap,
    this.danger = false,
  });

  static const Color kPurple = Color(0xFF5B288E);
  static const Color kGreyText = Color(0xFF898384);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        text,
        style: TextStyle(
          color: danger ? Colors.redAccent : kPurple,
          fontWeight: FontWeight.w900,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: danger ? Colors.redAccent : kGreyText,
      ),
      onTap: onTap,
    );
  }
}
