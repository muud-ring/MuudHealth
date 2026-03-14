import 'package:flutter/material.dart';
import '../data/people_models.dart';
import '../pages/chat_page.dart';

class ProfilePage extends StatelessWidget {
  static const Color kPurple = Color(0xFF5B288E);
  final Person person;

  const ProfilePage({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    final title = person.handle.isNotEmpty ? person.handle : person.name;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPurple),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(color: kPurple, fontWeight: FontWeight.w800),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F0F8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: const Color(0xFFE7E1F3),
                    child: Text(
                      (person.name.isNotEmpty ? person.name[0] : "?")
                          .toUpperCase(),
                      style: const TextStyle(
                        color: kPurple,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    person.name,
                    style: const TextStyle(
                      color: kPurple,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (person.handle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      person.handle,
                      style: const TextStyle(
                        color: Color(0xFF898384),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  if (person.location.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      person.location,
                      style: const TextStyle(
                        color: Color(0xFF898384),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPurple,
                        elevation: 0,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatPage(
                              otherSub: person.id, // person.id = sub
                              title: title,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "Message",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Demo placeholder posts (optional)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Posts",
                style: TextStyle(
                  color: kPurple,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _postCard("Yoga class was amazing today!", "2h ago"),
            _postCard("Feeling a bit low but going for a walk.", "1d ago"),
            _postCard("Meditation streak: 7 days ✅", "3d ago"),
          ],
        ),
      ),
    );
  }

  Widget _postCard(String text, String time) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(color: kPurple, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            time,
            style: const TextStyle(
              color: Color(0xFF898384),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
