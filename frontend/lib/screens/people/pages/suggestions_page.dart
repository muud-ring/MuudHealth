// MUUD Health — Suggestions Page
// Discover and connect with suggested friends
// © Muud Health — Armin Hoes, MD

import 'dart:async';
import 'package:flutter/material.dart';

import '../../../services/people_api.dart';
import '../../../theme/app_theme.dart';
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

  bool _looksLikeUuid(String v) => RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  ).hasMatch(v.trim());

  String _tintForSub(String sub) {
    const options = ["purple", "orange", "green", "blue", "pink", "yellow"];
    final code = sub.codeUnits.fold<int>(0, (a, b) => a + b);
    return options[code % options.length];
  }

  String _shortSub(String sub) =>
      sub.isEmpty ? "user" : (sub.length > 8 ? sub.substring(0, 8) : sub);

  Person _personFromProfile(Map<String, dynamic> raw) {
    final sub = (raw['sub'] ?? '').toString().trim();
    final rawUsername = (raw['username'] ?? '').toString().trim();
    final username = _looksLikeUuid(rawUsername) ? "" : rawUsername;
    final name = (raw['name'] ?? '').toString().trim();
    final location = (raw['location'] ?? '').toString().trim();

    final displayName = name.isNotEmpty
        ? name
        : (username.isNotEmpty ? username : "User ${_shortSub(sub)}");

    return Person(
      id: sub,
      name: displayName,
      handle: username.isNotEmpty ? '@$username' : '',
      avatarUrl: (raw['avatarUrl'] ?? '').toString(),
      location: location,
      lastActive: "",
      moodChip: "",
      tint: _tintForSub(sub.isEmpty ? displayName : sub),
    );
  }

  Future<void> _load() async {
    setState(() { loading = true; error = null; });

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
      setState(() { suggestions = mapped; loading = false; });
    } catch (e) {
      final msg = e.toString();
      setState(() {
        loading = false;
        error = msg.contains('401') || msg.toLowerCase().contains('unauthorized')
            ? "Session expired. Please log in again."
            : msg.replaceFirst('Exception: ', '');
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() => q = value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _load());
  }

  Future<void> _sendRequest(Person p) async {
    if (p.id.isEmpty) return;
    try {
      await PeopleApi.sendRequest(sub: p.id);
      PeopleEvents.notifyReload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Request sent to ${p.name}"), duration: const Duration(seconds: 2)),
      );
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
      backgroundColor: MuudColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44, height: 5,
                decoration: BoxDecoration(
                  color: MuudColors.divider,
                  borderRadius: MuudRadius.pillAll,
                ),
              ),
              const SizedBox(height: MuudSpacing.md),
              ListTile(
                leading: const Icon(Icons.person_add_alt_1, color: MuudColors.purple),
                title: Text("Send request", style: MuudTypography.label.copyWith(fontWeight: FontWeight.w800)),
                onTap: () async {
                  Navigator.pop(context);
                  await _sendRequest(p);
                },
              ),
              const SizedBox(height: MuudSpacing.xs),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MuudColors.white,
      appBar: AppBar(
        backgroundColor: MuudColors.white,
        elevation: 0,
        title: Text(
          "Suggested Friends",
          style: MuudTypography.titleMedium.copyWith(color: MuudColors.purple),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          children: [
            PeopleSearchField(hint: "Search...", onChanged: _onSearchChanged),
            const SizedBox(height: MuudSpacing.base),

            if (loading)
              const Expanded(
                child: Center(child: CircularProgressIndicator(color: MuudColors.purple)),
              )
            else if (error != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 44, color: MuudColors.purple),
                      const SizedBox(height: MuudSpacing.sm),
                      Text(error!, textAlign: TextAlign.center,
                        style: MuudTypography.caption.copyWith(color: MuudColors.greyText)),
                      const SizedBox(height: MuudSpacing.md),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MuudColors.purple, elevation: 0, shape: const StadiumBorder(),
                        ),
                        onPressed: _load,
                        child: Text("Retry", style: MuudTypography.button.copyWith(color: MuudColors.white)),
                      ),
                    ],
                  ),
                ),
              )
            else if (suggestions.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    "No suggestions right now.",
                    style: MuudTypography.bodySmall.copyWith(color: MuudColors.greyText),
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  color: MuudColors.purple,
                  onRefresh: _load,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: suggestions.length,
                    itemBuilder: (context, i) {
                      final p = suggestions[i];
                      return PersonTile(
                        person: p,
                        onTap: () {},
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
