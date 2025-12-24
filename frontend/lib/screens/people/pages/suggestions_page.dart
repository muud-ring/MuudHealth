import 'package:flutter/material.dart';

import '../data/people_dummy_data.dart';
import '../widgets/search_field.dart';
import '../widgets/person_tile.dart';

class SuggestionsPage extends StatefulWidget {
  const SuggestionsPage({super.key});

  @override
  State<SuggestionsPage> createState() => _SuggestionsPageState();
}

class _SuggestionsPageState extends State<SuggestionsPage> {
  String q = "";

  @override
  Widget build(BuildContext context) {
    final list = PeopleDummyData.suggestions
        .where((p) => p.name.toLowerCase().contains(q.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Suggested Friends",
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
                    onTapMenu: () {
                      // later: send request
                    },
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
