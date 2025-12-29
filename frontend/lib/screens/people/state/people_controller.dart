import 'package:flutter/material.dart';

import '../../people/data/people_models.dart';
import '../../../services/people_api.dart';

class PeopleController extends ChangeNotifier {
  bool loading = false;
  String? error;

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
        PeopleApi.fetchConnections(),
        PeopleApi.fetchInnerCircle(),
        PeopleApi.fetchSuggestions(),
        PeopleApi.fetchRequests(),
      ]);

      connections = results[0].map(_personFromJson).toList();
      innerCircle = results[1].map(_personFromJson).toList();
      suggestions = results[2].map(_personFromJson).toList();
      requests = results[3].map(_requestFromJson).toList();

      loading = false;
      notifyListeners();
    } catch (e) {
      print("❌ People loadAll error: $e");
      loading = false;

      final msg = e.toString();
      if (msg.contains('401') || msg.contains('Unauthorized')) {
        error = "Session expired. Please log in again.";
      } else {
        error = msg.replaceFirst('Exception: ', '');
      }

      notifyListeners();
    }
  }

  // ---------- Mapping helpers ----------

  Person _personFromJson(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      // ✅ IMPORTANT: our backend uses "sub" as the identity for all People actions
      final sub = (raw['sub'] ?? '').toString();

      final username = (raw['username'] ?? '').toString();
      final name = (raw['name'] ?? '').toString();

      final location = (raw['location'] ?? '').toString();

      // backend currently returns avatarKey, not avatarUrl (so this is often empty)
      final avatarUrl =
          (raw['avatarUrl'] ?? raw['avatar'] ?? raw['photoUrl'] ?? '')
              .toString();

      return Person(
        id: sub, // ✅ always SUB (never name / _id)
        name: name.isNotEmpty
            ? name
            : (username.isNotEmpty ? username : "Unknown"),
        handle: username.isEmpty ? "" : '@$username',
        avatarUrl: avatarUrl,
        location: location,
        lastActive: "",
        moodChip: "",
        tint: _tintForId(sub),
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

      // our backend returns fromUser in requests list
      final personRaw = raw['fromUser'] ?? raw['person'] ?? raw['user'] ?? raw;

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
