import 'package:flutter/material.dart';

import '../../../services/people_api.dart';
import '../data/people_models.dart';
import '../widgets/search_field.dart';
import '../widgets/person_tile.dart';
import '../sheets/manage_person_sheet.dart';
import '../pages/profile_page.dart';
import '../state/people_events.dart';

class ConnectionsPage extends StatefulWidget {
  const ConnectionsPage({super.key});

  @override
  State<ConnectionsPage> createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<ConnectionsPage> {
  static const Color kPurple = Color(0xFF5B288E);
  static const Color kGreyText = Color(0xFF898384);

  String q = "";
  bool loading = true;
  String? error;

  List<Person> all = [];

  @override
  void initState() {
    super.initState();

    // ✅ IMPORTANT: reload this page when actions happen (move tier / remove / etc.)
    PeopleEvents.reload.addListener(_onExternalReload);

    _load();
  }

  void _onExternalReload() {
    // ✅ triggers after "Move to Inner Circle" or "Move to Connections"
    _load();
  }

  @override
  void dispose() {
    PeopleEvents.reload.removeListener(_onExternalReload);
    super.dispose();
  }

  String _tintForId(String id) {
    const options = ["purple", "orange", "green", "blue", "pink", "yellow"];
    final code = id.codeUnits.fold<int>(0, (a, b) => a + b);
    return options[code % options.length];
  }

  Person _personFromJson(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final sub = (raw['sub'] ?? '').toString(); // ✅ MUST be sub
      final username = (raw['username'] ?? '').toString();
      final name = (raw['name'] ?? '').toString();
      final location = (raw['location'] ?? '').toString();

      return Person(
        id: sub, // ✅ store sub here
        name: name.isNotEmpty ? name : username,
        handle: username.isEmpty ? "" : '@$username',
        avatarUrl: (raw['avatarUrl'] ?? '').toString(), // safe
        location: location,
        lastActive: "",
        moodChip: "",
        tint: _tintForId(sub),
      );
    }

    return const Person(
      id: "",
      name: "Unknown",
      handle: "",
      avatarUrl: "",
      location: "",
      lastActive: "",
      moodChip: "",
      tint: "grey",
    );
  }

  Future<void> _load() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final res = await PeopleApi.fetchConnections();
      final list = res
          .map(_personFromJson)
          .where((p) => p.id.isNotEmpty)
          .toList();

      if (!mounted) return;
      setState(() {
        all = list;
        loading = false;
      });
    } catch (e) {
      final msg = e.toString();
      if (!mounted) return;

      setState(() {
        loading = false;
        error = msg.contains('401') || msg.contains('Unauthorized')
            ? "Session expired. Please log in again."
            : msg.replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = all
        .where((p) => p.name.toLowerCase().contains(q.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Connections",
          style: TextStyle(color: kPurple, fontWeight: FontWeight.w800),
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

            if (loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (error != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 44, color: kPurple),
                      const SizedBox(height: 8),
                      Text(
                        error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: kGreyText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPurple,
                          elevation: 0,
                          shape: const StadiumBorder(),
                        ),
                        onPressed: _load,
                        child: const Text(
                          "Retry",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final p = filtered[i];
                      return PersonTile(
                        person: p,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfilePage(person: p),
                            ),
                          );
                        },
                        onTapMenu: () =>
                            ManagePersonSheet.open(context, person: p),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
