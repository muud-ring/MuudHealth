// MUUD Health — Inner Circle Page
// Displays the user's closest connections (innerCircle tier)
// © Muud Health — Armin Hoes, MD

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../services/people_api.dart';
import '../../../router/route_names.dart';
import '../../../theme/app_theme.dart';
import '../data/people_models.dart';
import '../widgets/search_field.dart';
import '../widgets/person_tile.dart';
import '../sheets/manage_person_sheet.dart';
import '../state/people_events.dart';

class InnerCirclePage extends StatefulWidget {
  const InnerCirclePage({super.key});

  @override
  State<InnerCirclePage> createState() => _InnerCirclePageState();
}

class _InnerCirclePageState extends State<InnerCirclePage> {
  String q = "";
  bool loading = true;
  String? error;
  List<Person> all = [];

  @override
  void initState() {
    super.initState();
    PeopleEvents.reload.addListener(_onExternalReload);
    _load();
  }

  void _onExternalReload() => _load();

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
      final sub = (raw['sub'] ?? '').toString();
      final username = (raw['username'] ?? '').toString();
      final name = (raw['name'] ?? '').toString();
      final location = (raw['location'] ?? '').toString();

      return Person(
        id: sub,
        name: name.isNotEmpty ? name : username,
        handle: username.isEmpty ? "" : '@$username',
        avatarUrl: (raw['avatarUrl'] ?? '').toString(),
        location: location,
        lastActive: "",
        moodChip: "",
        tint: _tintForId(sub),
      );
    }
    return const Person(
      id: "", name: "Unknown", handle: "", avatarUrl: "",
      location: "", lastActive: "", moodChip: "", tint: "grey",
    );
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() { loading = true; error = null; });

    try {
      final res = await PeopleApi.fetchInnerCircle();
      final list = res.map(_personFromJson).where((p) => p.id.isNotEmpty).toList();
      if (!mounted) return;
      setState(() { all = list; loading = false; });
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
      backgroundColor: MuudColors.white,
      appBar: AppBar(
        backgroundColor: MuudColors.white,
        elevation: 0,
        title: Text(
          "Inner Circle",
          style: MuudTypography.titleMedium.copyWith(color: MuudColors.purple),
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
                      Text(
                        error!,
                        textAlign: TextAlign.center,
                        style: MuudTypography.caption.copyWith(color: MuudColors.greyText),
                      ),
                      const SizedBox(height: MuudSpacing.md),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MuudColors.purple,
                          elevation: 0,
                          shape: const StadiumBorder(),
                        ),
                        onPressed: _load,
                        child: Text("Retry", style: MuudTypography.button.copyWith(color: MuudColors.white)),
                      ),
                    ],
                  ),
                ),
              )
            else if (filtered.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    "No Inner Circle people yet.",
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
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final p = filtered[i];
                      return PersonTile(
                        person: p,
                        onTap: () => context.push(Routes.profile(p.id)),
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
