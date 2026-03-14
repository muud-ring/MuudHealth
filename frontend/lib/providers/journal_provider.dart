import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/journal_feed_api.dart';

class JournalState {
  final List<Map<String, dynamic>> posts;
  final bool isLoading;
  final String? error;

  const JournalState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
  });

  JournalState copyWith({
    List<Map<String, dynamic>>? posts,
    bool? isLoading,
    String? error,
  }) {
    return JournalState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class JournalNotifier extends StateNotifier<JournalState> {
  JournalNotifier() : super(const JournalState());

  Future<void> loadPosts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final posts = await JournalFeedApi.getMyPosts();
      state = state.copyWith(posts: posts, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final journalProvider = StateNotifierProvider<JournalNotifier, JournalState>((ref) {
  return JournalNotifier();
});
