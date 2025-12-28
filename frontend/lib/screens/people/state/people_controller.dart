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
      print("❌ People loadAll error: $e"); // ✅ ADD THIS
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
      final id = (raw['id'] ?? raw['_id'] ?? '').toString();
      final name =
          (raw['name'] ??
                  raw['fullName'] ??
                  raw['displayName'] ??
                  raw['username'] ??
                  'Unknown')
              .toString();
      final handle = (raw['handle'] ?? raw['username'] ?? '').toString();
      final avatarUrl =
          (raw['avatarUrl'] ?? raw['avatar'] ?? raw['photoUrl'] ?? '')
              .toString();
      final location = (raw['location'] ?? raw['city'] ?? '').toString();
      final lastActive = (raw['lastActive'] ?? raw['lastSeen'] ?? '')
          .toString();
      final mood = (raw['mood'] ?? raw['moodChip'] ?? '').toString();

      return Person(
        id: id.isEmpty ? name : id,
        name: name,
        handle: handle.isEmpty
            ? ""
            : (handle.startsWith('@') ? handle : '@$handle'),
        avatarUrl: avatarUrl,
        location: location,
        lastActive: lastActive,
        moodChip: mood,
        tint: _tintForId(id.isEmpty ? name : id),
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
      final requestId = (raw['id'] ?? raw['_id'] ?? raw['requestId'] ?? '')
          .toString();
      final personRaw = raw['person'] ?? raw['fromUser'] ?? raw['user'] ?? raw;

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
