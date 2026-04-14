import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/chat_api.dart';

class ChatState {
  final List<Map<String, dynamic>> conversations;
  final int unreadCount;
  final bool isLoading;

  const ChatState({
    this.conversations = const [],
    this.unreadCount = 0,
    this.isLoading = false,
  });

  ChatState copyWith({
    List<Map<String, dynamic>>? conversations,
    int? unreadCount,
    bool? isLoading,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(const ChatState());

  Future<void> loadConversations() async {
    state = state.copyWith(isLoading: true);
    try {
      final convos = await ChatApi.fetchConversations();
      final unread = await ChatApi.fetchUnreadCount();
      state = state.copyWith(
        conversations: convos,
        unreadCount: unread,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void updateUnreadCount(int count) {
    state = state.copyWith(unreadCount: count);
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});
