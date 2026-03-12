import 'package:flutter/foundation.dart';
import '../../../services/chat_api.dart';
import '../../../services/chat_socket.dart';

class ChatBadge {
  ChatBadge._();

  static final ValueNotifier<int> unread = ValueNotifier<int>(0);

  static dynamic _socket;
  static bool _started = false;

  static Future<void> start() async {
    if (_started) return;
    _started = true;

    // ✅ IMPORTANT: reset immediately so stale badge never shows
    unread.value = 0;

    // ✅ then fetch real value
    await refresh();

    try {
      final socket = await ChatSocket.instance.connect();
      _socket = socket;

      // keep clean
      socket.off('inboxUpdate');
      socket.off('newMessage');

      // whenever inbox updates, refresh unread count
      socket.on('inboxUpdate', (_) async {
        await refresh();
      });

      // (optional) if server emits newMessage to user room, refresh too
      socket.on('newMessage', (_) async {
        await refresh();
      });
    } catch (_) {
      // ignore socket errors (badge will still update on refresh calls)
    }
  }

  static Future<void> refresh() async {
    try {
      final n = await ChatApi.fetchUnreadCount();
      unread.value = n;
    } catch (_) {
      unread.value = 0;
    }
  }

  static void reset() {
    unread.value = 0;
  }

  static void dispose() {
    try {
      _socket?.off('inboxUpdate');
      _socket?.off('newMessage');
    } catch (_) {}
    _started = false;
  }
}
