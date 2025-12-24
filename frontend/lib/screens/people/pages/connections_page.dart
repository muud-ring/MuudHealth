import 'package:flutter/material.dart';

import '../data/people_dummy_data.dart';
import '../widgets/search_field.dart';
import '../widgets/person_tile.dart';
import '../sheets/manage_person_sheet.dart';

class ConnectionsPage extends StatefulWidget {
  const ConnectionsPage({super.key});

  @override
  State<ConnectionsPage> createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<ConnectionsPage> {
  String q = "";

  @override
  Widget build(BuildContext context) {
    final list = PeopleDummyData.connections
        .where((p) => p.name.toLowerCase().contains(q.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Connections",
          style: TextStyle(
            color: Color(0xFF5B288E),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          children: [
            PeopleSearchField(
              hint: "Search...",
              onChanged: (v) => setState(() => q = v),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final p = list[i];
                  return PersonTile(
                    person: p,
                    onTap: () =>
                        Navigator.pushNamed(context, '/people/profile'),
                    onTapMenu: () => ManagePersonSheet.open(context, person: p),
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
