import 'package:flutter/material.dart';
import '../../../services/chat_api.dart';
import '../../../services/chat_socket.dart';

class ChatPage extends StatefulWidget {
  final String otherSub;
  final String title;

  const ChatPage({super.key, required this.otherSub, required this.title});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static const Color kPurple = Color(0xFF5B288E);
  static const Color kGrey = Color(0xFF898384);

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
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final convoRes = await ChatApi.getOrCreateConversation(
        otherSub: widget.otherSub,
      );
      final convo = (convoRes['conversation'] as Map).cast<String, dynamic>();
      conversationId = convo['_id'].toString();

      final list = await ChatApi.fetchMessages(conversationId: conversationId!);
      messages
        ..clear()
        ..addAll(list);

      // connect socket
      final socket = await ChatSocket.instance.connect();
      socket.emit("joinConversation", conversationId);

      socket.off("newMessage"); // avoid duplicate listeners
      socket.on("newMessage", (data) {
        if (!mounted) return;
        if (data is Map &&
            data['conversationId']?.toString() == conversationId) {
          setState(() {
            messages.add((data as Map).cast<String, dynamic>());
          });
        }
      });

      if (mounted) {
        setState(() => loading = false);
      }
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
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _text.text.trim();
    if (text.isEmpty || conversationId == null) return;

    _text.clear();

    try {
      final msg = await ChatApi.sendMessage(
        conversationId: conversationId!,
        text: text,
      );

      // REST returns message too; we can optimistically add
      if (mounted) {
        setState(() => messages.add(msg));
      }
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(color: kPurple, fontWeight: FontWeight.w800),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : (error != null)
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: kGrey),
                ),
              ),
            )
          : Column(
              children: [
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
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: mine ? kPurple : const Color(0xFFEFEAF6),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            text,
                            style: TextStyle(
                              color: mine ? Colors.white : kPurple,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
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
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _send,
                            child: const Icon(Icons.send, color: Colors.white),
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
