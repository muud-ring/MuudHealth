// MUUD Health — Chat API Service
// Real-time messaging via REST + Socket.IO
// © Muud Health — Armin Hoes, MD

import 'api_client.dart';

class ChatApi {
  ChatApi._();

  /// Fetch total unread message count (for badge)
  static Future<int> fetchUnreadCount() async {
    final res = await ApiClient.get('/api/v1/chat/unread-count');
    final data = ApiClient.handleResponse(res);
    final unread = data['unread'];
    if (unread is int) return unread;
    if (unread is String) return int.tryParse(unread) ?? 0;
    return 0;
  }

  /// Fetch all conversations
  static Future<List<Map<String, dynamic>>> fetchConversations() async {
    final res = await ApiClient.get('/api/v1/chat/conversations');
    final data = ApiClient.handleResponse(res);
    final list = (data['conversations'] as List?) ?? [];
    return list.map((e) => (e as Map).cast<String, dynamic>()).toList();
  }

  /// Fetch inbox view (conversations + previews)
  static Future<Map<String, dynamic>> fetchInbox() async {
    final res = await ApiClient.get('/api/v1/chat/inbox');
    return ApiClient.handleResponse(res);
  }

  /// Get or create a conversation with another user
  static Future<Map<String, dynamic>> getOrCreateConversation({
    required String otherSub,
  }) async {
    final res = await ApiClient.get('/api/v1/chat/conversation/$otherSub');
    return ApiClient.handleResponse(res);
  }

  /// Fetch messages for a conversation
  static Future<List<Map<String, dynamic>>> fetchMessages({
    required String conversationId,
    int page = 1,
    int limit = 50,
  }) async {
    final res = await ApiClient.get(
      '/api/v1/chat/messages/$conversationId?page=$page&limit=$limit',
    );
    final data = ApiClient.handleResponse(res);
    final list = (data['messages'] as List?) ?? [];
    return list.map((e) => (e as Map).cast<String, dynamic>()).toList();
  }

  /// Send a message
  static Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String text,
    String? mediaUrl,
  }) async {
    final res = await ApiClient.post(
      '/api/v1/chat/messages/$conversationId',
      body: {
        'text': text,
        if (mediaUrl != null) 'mediaUrl': mediaUrl,
      },
    );
    final data = ApiClient.handleResponse(res);
    return (data['message'] as Map?)?.cast<String, dynamic>() ?? data;
  }
}
