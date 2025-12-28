import 'dart:async';
import 'package:flutter/material.dart';

import '../../../services/people_api.dart';
import '../data/people_models.dart';
import '../widgets/search_field.dart';
import '../widgets/person_tile.dart';
import '../state/people_events.dart';

class SuggestionsPage extends StatefulWidget {
  const SuggestionsPage({super.key});

  @override
  State<SuggestionsPage> createState() => _SuggestionsPageState();
}

class _SuggestionsPageState extends State<SuggestionsPage> {
  static const Color kPurple = Color(0xFF5B288E);
  static const Color kGreyText = Color(0xFF898384);

  bool loading = true;
  String? error;

  String q = "";
  Timer? _debounce;

  List<Person> suggestions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  String _tintForSub(String sub) {
    const options = ["purple", "orange", "green", "blue", "pink", "yellow"];
    final code = sub.codeUnits.fold<int>(0, (a, b) => a + b);
    return options[code % options.length];
  }

  Person _personFromProfile(Map<String, dynamic> raw) {
    final sub = (raw['sub'] ?? '').toString();

    final rawUsername = (raw['username'] ?? '').toString().trim();
    final handle = rawUsername.isEmpty
        ? ""
        : (rawUsername.startsWith('@') ? rawUsername : '@$rawUsername');

    // ✅ Suggestions: show ONLY usernames (fallback to short sub)
    final display = handle.isNotEmpty
        ? handle
        : (sub.isNotEmpty ? '@${sub.substring(0, 8)}' : '@user');

    final location = (raw['location'] ?? '').toString();
    final avatarKey = (raw['avatarKey'] ?? '').toString();

    return Person(
      id: sub, // keep sub always
      name: display, // ✅ put username here so PersonTile shows it
      handle: "", // optional: keep empty so you don't show it twice
      avatarUrl: "", // later: convert avatarKey -> signed url
      location: location,
      lastActive: "",
      moodChip: "",
      tint: _tintForSub(sub.isEmpty ? display : sub),
    );
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final list = await PeopleApi.fetchSuggestions(q: q, limit: 50);

      final mapped = <Person>[];
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          mapped.add(_personFromProfile(item));
        } else if (item is Map) {
          mapped.add(_personFromProfile(item.cast<String, dynamic>()));
        }
      }

      setState(() {
        suggestions = mapped;
        loading = false;
      });
    } catch (e) {
      final msg = e.toString();
      setState(() {
        loading = false;
        error = msg.contains('401') || msg.contains('Unauthorized')
            ? "Session expired. Please log in again."
            : msg.replaceFirst('Exception: ', '');
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() => q = value);

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _load();
    });
  }

  Future<void> _sendRequest(Person p) async {
    final sub = p.id; // we stored sub in id
    if (sub.isEmpty) return;

    try {
      await PeopleApi.sendRequest(sub: sub);

      PeopleEvents.notifyReload();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Request sent to ${p.name}"),
          duration: const Duration(seconds: 2),
        ),
      );

      // refresh list to hide requested user (backend excludes pending)
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _openMenu(Person p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
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

                ListTile(
                  leading: const Icon(Icons.person_add_alt_1, color: kPurple),
                  title: const Text(
                    "Send request",
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _sendRequest(p);
                  },
                ),

                const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Suggested Friends",
          style: TextStyle(color: kPurple, fontWeight: FontWeight.w800),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          children: [
            PeopleSearchField(hint: "Search...", onChanged: _onSearchChanged),
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
            else if (suggestions.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    "No suggestions right now.",
                    style: TextStyle(
                      color: kGreyText,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: suggestions.length,
                    itemBuilder: (context, i) {
                      final p = suggestions[i];
                      return PersonTile(
                        person: p,
                        onTap: () {}, // keep safe for demo
                        onTapMenu: () => _openMenu(p),
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
