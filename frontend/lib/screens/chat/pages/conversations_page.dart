// MUUD Health — Conversations Page
// Inbox with real-time Socket.IO updates
// Signal Pathway: Learn layer (shared experiences)
// © Muud Health — Armin Hoes, MD

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/chat_provider.dart';
import '../../../router/route_names.dart';
import '../../../services/chat_api.dart';
import '../../../services/chat_socket.dart';
import '../../../theme/app_theme.dart';
import '../data/conversation_models.dart';
import '../state/chat_badge.dart';

class ConversationsPage extends ConsumerStatefulWidget {
  const ConversationsPage({super.key});

  @override
  ConsumerState<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends ConsumerState<ConversationsPage> {
  bool loading = true;
  bool _socketReady = false;
  String? error;
  String q = "";

  List<ConversationItem> all = [];

  dynamic _socket;

  @override
  void initState() {
    super.initState();
    _load();
    _initSocket();
    ChatBadge.refresh();
  }

  /* ── Data ─────────────────────────────────────────────────────────── */

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

  /* ── Socket ───────────────────────────────────────────────────────── */

  Future<void> _initSocket() async {
    try {
      final socket = await ChatSocket.instance.connect();
      _socket = socket;

      socket.off('inboxUpdate');
      socket.off('connect');
      socket.off('disconnect');

      socket.on('inboxUpdate', (_) {
        _load();
        ChatBadge.refresh();
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

  /* ── UI ───────────────────────────────────────────────────────────── */

  @override
  Widget build(BuildContext context) {
    final filtered = all.where((c) {
      final name = c.name.toLowerCase();
      final handle = c.username.toLowerCase();
      final query = q.toLowerCase();
      return name.contains(query) || handle.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: MuudColors.white,
      appBar: AppBar(
        backgroundColor: MuudColors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Go back',
          icon: const Icon(Icons.arrow_back, color: MuudColors.purple),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Messages",
          style: MuudTypography.titleMedium.copyWith(color: MuudColors.purple),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: MuudSpacing.md),
            child: Icon(
              Icons.circle,
              size: 10,
              color: _socketReady ? Colors.green : MuudColors.greyText,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          MuudSpacing.lg, MuudSpacing.sm, MuudSpacing.lg, MuudSpacing.lg,
        ),
        child: Column(
          children: [
            // Search bar
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: MuudSpacing.md),
              decoration: BoxDecoration(
                border: Border.all(
                  color: MuudColors.purple.withValues(alpha: 0.5),
                  width: 1.2,
                ),
                borderRadius: MuudRadius.mdAll,
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: MuudColors.purple),
                  const SizedBox(width: MuudSpacing.sm),
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

            const SizedBox(height: MuudSpacing.md),

            if (loading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: MuudColors.purple),
                ),
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
                        onPressed: () async {
                          await _load();
                          ChatBadge.refresh();
                        },
                        child: Text(
                          "Retry",
                          style: MuudTypography.button.copyWith(color: MuudColors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (filtered.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    "No conversations yet.",
                    style: MuudTypography.bodySmall.copyWith(color: MuudColors.greyText),
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  color: MuudColors.purple,
                  onRefresh: () async {
                    await _load();
                    ChatBadge.refresh();
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: MuudSpacing.lg),
                    itemBuilder: (context, i) {
                      final c = filtered[i];
                      final displayTitle = c.username.isNotEmpty
                          ? '@${c.username}'
                          : c.name;

                      return _ConversationRow(
                        item: c,
                        onTap: () async {
                          await context.push(Routes.chatConversation(c.otherSub));
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

/* ── Conversation Row ──────────────────────────────────────────────── */

class _ConversationRow extends StatelessWidget {
  final ConversationItem item;
  final VoidCallback onTap;

  const _ConversationRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: MuudRadius.mdAll,
      child: Row(
        children: [
          _Avatar(url: item.avatarUrl, label: item.name),
          const SizedBox(width: MuudSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: MuudTypography.label.copyWith(
                    color: MuudColors.purple,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: MuudSpacing.xxs),
                Text(
                  item.lastMessage.isEmpty ? " " : item.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: MuudTypography.bodySmall.copyWith(color: MuudColors.greyText),
                ),
              ],
            ),
          ),
          const SizedBox(width: MuudSpacing.sm),

          if (item.lastMessage.isNotEmpty)
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: MuudColors.purple,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

/* ── Avatar ─────────────────────────────────────────────────────────── */

class _Avatar extends StatelessWidget {
  final String url;
  final String label;

  const _Avatar({required this.url, required this.label});

  @override
  Widget build(BuildContext context) {
    if (url.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _placeholder(),
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
        color: MuudColors.lightPurple.withValues(alpha: 0.5),
        border: Border.all(color: MuudColors.purple, width: 2),
      ),
      child: Center(
        child: Text(
          letter,
          style: MuudTypography.heading.copyWith(
            color: MuudColors.purple,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
