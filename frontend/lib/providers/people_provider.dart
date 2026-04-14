import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/people_api.dart';

class PeopleState {
  final List<dynamic> connections;
  final List<dynamic> innerCircle;
  final List<dynamic> suggestions;
  final List<dynamic> requests;
  final bool isLoading;
  final String? error;

  const PeopleState({
    this.connections = const [],
    this.innerCircle = const [],
    this.suggestions = const [],
    this.requests = const [],
    this.isLoading = false,
    this.error,
  });

  PeopleState copyWith({
    List<dynamic>? connections,
    List<dynamic>? innerCircle,
    List<dynamic>? suggestions,
    List<dynamic>? requests,
    bool? isLoading,
    String? error,
  }) {
    return PeopleState(
      connections: connections ?? this.connections,
      innerCircle: innerCircle ?? this.innerCircle,
      suggestions: suggestions ?? this.suggestions,
      requests: requests ?? this.requests,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PeopleNotifier extends StateNotifier<PeopleState> {
  PeopleNotifier() : super(const PeopleState());

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        PeopleApi.fetchConnections(),
        PeopleApi.fetchInnerCircle(),
        PeopleApi.fetchSuggestions(),
        PeopleApi.fetchRequests(),
      ]);
      state = state.copyWith(
        connections: results[0],
        innerCircle: results[1],
        suggestions: results[2],
        requests: results[3],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> sendRequest(String sub) async {
    await PeopleApi.sendRequest(sub: sub);
    await loadAll();
  }

  Future<void> acceptRequest(String requestId) async {
    await PeopleApi.acceptRequest(requestId: requestId);
    await loadAll();
  }

  Future<void> declineRequest(String requestId) async {
    await PeopleApi.declineRequest(requestId: requestId);
    await loadAll();
  }

  Future<void> removeConnection(String sub) async {
    await PeopleApi.removeConnection(sub: sub);
    await loadAll();
  }

  Future<void> updateTier(String sub, String tier) async {
    await PeopleApi.updateTier(sub: sub, tier: tier);
    await loadAll();
  }
}

final peopleProvider = StateNotifierProvider<PeopleNotifier, PeopleState>((ref) {
  return PeopleNotifier();
});
