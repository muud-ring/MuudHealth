import 'package:flutter/material.dart';

import '../../../services/chat_api.dart';
import '../../../services/chat_socket.dart';

import '../../people/pages/chat_page.dart';
import '../data/conversation_models.dart';
import '../state/chat_badge.dart';
import 'package:muud_health_app/theme/app_theme.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  static const AppTheme.purple = AppTheme.purple;
  static const AppTheme.greyText = AppTheme.greyText;

  bool loading = true;
  bool _socketReady = false;
  String? error;
  String q = "";

  List<ConversationItem> all = [];

  // keep a reference so we can .off() in dispose
  dynamic _socket; // io.Socket (dynamic avoids import issues)

  @override
  void initState() {
    super.initState();
    _load();
    _initSocket();

    // ✅ when user opens Messages screen, refresh badge once
    ChatBadge.refresh();
  }

  /* -------------------------------------------------------------------------- */
  /*                               DATA LOAD                                    */
  /* -------------------------------------------------------------------------- */

  Future<void> _load() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final res = await ChatApi.fetchConversations();
      all = res.map((e) => ConversationItem.fromJson(e)).toList();

      if (!mounted) return;
      setState(() => loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = e.toString().replaceFirst("Exception: ", "");
      });
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                             SOCKET (INBOX)                                 */
  /* -------------------------------------------------------------------------- */

  Future<void> _initSocket() async {
    try {
      final socket = await ChatSocket.instance.connect();
      _socket = socket;

      // remove old listeners (safe)
      socket.off('inboxUpdate');
      socket.off('connect');
      socket.off('disconnect');

      // fired when backend emits inboxUpdate
      socket.on('inboxUpdate', (_) {
        _load();
        ChatBadge.refresh(); // ✅ keep badge in sync too
      });

      socket.on('connect', (_) {
        if (mounted) setState(() => _socketReady = true);
      });

      socket.on('disconnect', (_) {
        if (mounted) setState(() => _socketReady = false);
      });

      if (mounted) setState(() => _socketReady = socket.connected == true);
    } catch (_) {
      if (mounted) setState(() => _socketReady = false);
    }
  }

  @override
  void dispose() {
    try {
      _socket?.off('inboxUpdate');
      _socket?.off('connect');
      _socket?.off('disconnect');
    } catch (_) {}
    super.dispose();
  }

  /* -------------------------------------------------------------------------- */
  /*                                   UI                                       */
  /* -------------------------------------------------------------------------- */

  @override
  Widget build(BuildContext context) {
    final filtered = all.where((c) {
      final name = c.name.toLowerCase();
      final handle = c.username.toLowerCase();
      final query = q.toLowerCase();
      return name.contains(query) || handle.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppTheme.purple),
        title: const Text(
          "Messages",
          style: TextStyle(color: AppTheme.purple, fontWeight: FontWeight.w900),
        ),
        actions: [
          // tiny indicator for socket (optional)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              Icons.circle,
              size: 10,
              color: _socketReady ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        child: Column(
          children: [
            // Search
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.purple.withOpacity(0.5), width: 1.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppTheme.purple),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => q = v),
                      decoration: const InputDecoration(
                        hintText: "Search...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            if (loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (error != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 40, color: AppTheme.purple),
                      const SizedBox(height: 10),
                      Text(
                        error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.greyText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.purple,
                          elevation: 0,
                          shape: const StadiumBorder(),
                        ),
                        onPressed: () async {
                          await _load();
                          ChatBadge.refresh();
                        },
                        child: const Text(
                          "Retry",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (filtered.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    "No conversations yet.",
                    style: TextStyle(color: AppTheme.greyText, fontWeight: FontWeight.w600),
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _load();
                    ChatBadge.refresh();
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 18),
                    itemBuilder: (context, i) {
                      final c = filtered[i];

                      // ✅ always try username first for title
                      final displayTitle = c.username.isNotEmpty
                          ? '@${c.username}'
                          : c.name;

                      return _ConversationRow(
                        item: c,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatPage(
                                otherSub: c.otherSub,
                                title: displayTitle,
                              ),
                            ),
                          );

                          // ✅ after returning from chat, refresh badge
                          ChatBadge.refresh();
                        },
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

class _ConversationRow extends StatelessWidget {
  final ConversationItem item;
  final VoidCallback onTap;

  const _ConversationRow({required this.item, required this.onTap});

  static const AppTheme.purple = AppTheme.purple;
  static const AppTheme.greyText = AppTheme.greyText;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          _Avatar(url: item.avatarUrl, label: item.name),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.lastMessage.isEmpty ? " " : item.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.greyText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Keep your existing small dot behavior (does NOT depend on unreadCount)
          if (item.lastMessage.isNotEmpty)
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppTheme.purple,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String url;
  final String label;

  const _Avatar({required this.url, required this.label});

  static const AppTheme.purple = AppTheme.purple;

  @override
  Widget build(BuildContext context) {
    if (url.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          url,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    final letter = label.isNotEmpty ? label.trim()[0].toUpperCase() : "?";

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.purple, width: 2),
      ),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
            color: AppTheme.purple,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
