// MUUD Health — Chat Page
// Real-time messaging with Socket.IO
// Signal Pathway: Learn layer (shared experiences)
// © Muud Health — Armin Hoes, MD

import 'package:flutter/material.dart';

import '../../../services/chat_api.dart';
import '../../../services/chat_socket.dart';
import '../../../theme/app_theme.dart';
import '../../chat/state/chat_badge.dart';

class ChatPage extends StatefulWidget {
  final String otherSub;
  final String title;

  const ChatPage({super.key, required this.otherSub, required this.title});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool loading = true;
  String? error;
  String? conversationId;
  final TextEditingController _text = TextEditingController();
  final List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() { loading = true; error = null; });

    try {
      final convoRes = await ChatApi.getOrCreateConversation(
        otherSub: widget.otherSub,
      );
      final convo = (convoRes['conversation'] as Map).cast<String, dynamic>();
      conversationId = convo['_id'].toString();

      final list = await ChatApi.fetchMessages(conversationId: conversationId!);
      messages..clear()..addAll(list);
      ChatBadge.refresh();

      final socket = await ChatSocket.instance.connect();
      socket.emit("joinConversation", conversationId);
      socket.off("newMessage");
      socket.on("newMessage", (data) {
        if (!mounted) return;
        if (data is Map && data['conversationId']?.toString() == conversationId) {
          setState(() => messages.add(data.cast<String, dynamic>()));
        }
      });

      if (mounted) setState(() => loading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
          error = e.toString().replaceFirst("Exception: ", "");
        });
      }
    }
  }

  @override
  void dispose() {
    try {
      final s = ChatSocket.instance.socket;
      if (conversationId != null) s?.emit("leaveConversation", conversationId);
      s?.off("newMessage");
    } catch (_) {}
    _text.dispose();
    super.dispose();
    ChatBadge.refresh();
  }

  Future<void> _send() async {
    final text = _text.text.trim();
    if (text.isEmpty || conversationId == null) return;
    _text.clear();

    try {
      await ChatApi.sendMessage(conversationId: conversationId!, text: text);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MuudColors.white,
      appBar: AppBar(
        backgroundColor: MuudColors.white,
        elevation: 0,
        title: Text(
          widget.title,
          style: MuudTypography.titleMedium.copyWith(color: MuudColors.purple),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: MuudColors.purple))
          : (error != null)
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(MuudSpacing.lg),
                    child: Text(
                      error!,
                      textAlign: TextAlign.center,
                      style: MuudTypography.bodySmall.copyWith(color: MuudColors.greyText),
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Messages list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                        itemCount: messages.length,
                        itemBuilder: (_, i) {
                          final m = messages[i];
                          final text = (m['text'] ?? '').toString();
                          final fromSub = (m['fromSub'] ?? '').toString();
                          final mine = fromSub != widget.otherSub;

                          return Align(
                            alignment: mine
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: MuudSpacing.sm),
                              padding: const EdgeInsets.symmetric(
                                horizontal: MuudSpacing.md,
                                vertical: MuudSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: mine
                                    ? MuudColors.purple
                                    : MuudColors.purple.withValues(alpha: 0.08),
                                borderRadius: MuudRadius.mdAll,
                              ),
                              child: Text(
                                text,
                                style: MuudTypography.bodyMedium.copyWith(
                                  color: mine ? MuudColors.white : MuudColors.purple,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Input bar
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _text,
                                decoration: InputDecoration(
                                  hintText: "Message...",
                                  border: OutlineInputBorder(
                                    borderRadius: MuudRadius.mdAll,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: MuudSpacing.sm),
                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MuudColors.purple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: MuudRadius.mdAll,
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: _send,
                                child: const Icon(Icons.send, color: MuudColors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
