import 'package:flutter/material.dart';

import '../../people/data/people_models.dart';
import '../../../services/people_api.dart';

class PeopleController extends ChangeNotifier {
  bool loading = false;
  String? error;

  Person? me; // ✅ NEW: current user

  List<Person> connections = [];
  List<Person> innerCircle = [];
  List<Person> suggestions = [];
  List<ConnectionRequest> requests = [];

  Future<void> loadAll() async {
    print("🔄 PeopleController.loadAll() called");
    loading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        PeopleApi.fetchMe(), // Map
        PeopleApi.fetchConnections(), // List
        PeopleApi.fetchInnerCircle(), // List
        PeopleApi.fetchSuggestions(), // List
        PeopleApi.fetchRequests(), // List
      ]);

      // ✅ Explicit casting (THIS fixes your error)
      final meMap = results[0] as Map<String, dynamic>;
      final connectionsRaw = results[1] as List<dynamic>;
      final innerCircleRaw = results[2] as List<dynamic>;
      final suggestionsRaw = results[3] as List<dynamic>;
      final requestsRaw = results[4] as List<dynamic>;

      me = _personFromJson(meMap['me']);

      connections = connectionsRaw.map(_personFromJson).toList();
      innerCircle = innerCircleRaw.map(_personFromJson).toList();
      suggestions = suggestionsRaw.map(_personFromJson).toList();
      requests = requestsRaw.map(_requestFromJson).toList();

      loading = false;
      notifyListeners();
    } catch (e) {
      print("❌ People loadAll error: $e");
      loading = false;

      final msg = e.toString();
      if (msg.contains('401') || msg.contains('Unauthorized')) {
        error = "Session expired. Please log in again.";
      } else {
        error = msg;
      }

      notifyListeners();
    }
  }

  // ---------- Mapping helpers ----------

  Person _personFromJson(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      // ✅ IMPORTANT: backend returns `sub`, not `_id`
      final sub = (raw['sub'] ?? '').toString();

      final username = (raw['username'] ?? '').toString();
      final name = (raw['name'] ?? '').toString();
      final avatarUrl = (raw['avatarUrl'] ?? '').toString();
      final location = (raw['location'] ?? '').toString();

      final displayName = name.isNotEmpty
          ? name
          : (username.isNotEmpty ? username : "Unknown");

      return Person(
        id: sub, // ✅ store sub everywhere
        name: displayName,
        handle: username.isEmpty ? "" : '@$username',
        avatarUrl: avatarUrl,
        location: location,
        lastActive: "",
        moodChip: "",
        tint: _tintForId(sub.isEmpty ? displayName : sub),
      );
    }

    return const Person(
      id: "unknown",
      name: "Unknown",
      handle: "",
      avatarUrl: "",
      location: "",
      lastActive: "",
      moodChip: "",
      tint: "grey",
    );
  }

  ConnectionRequest _requestFromJson(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final requestId = (raw['_id'] ?? raw['id'] ?? raw['requestId'] ?? '')
          .toString();
      final personRaw = raw['fromUser'] ?? raw['person'] ?? raw;

      return ConnectionRequest(
        id: requestId.isEmpty
            ? "req_${DateTime.now().millisecondsSinceEpoch}"
            : requestId,
        person: _personFromJson(personRaw),
      );
    }

    return ConnectionRequest(
      id: "req_unknown",
      person: const Person(
        id: "unknown",
        name: "Unknown",
        handle: "",
        avatarUrl: "",
        location: "",
        lastActive: "",
        moodChip: "",
        tint: "grey",
      ),
    );
  }

  String _tintForId(String id) {
    const options = ["purple", "orange", "green", "blue", "pink", "yellow"];
    final code = id.codeUnits.fold<int>(0, (a, b) => a + b);
    return options[code % options.length];
  }
}
