import 'package:flutter/material.dart';
import '../../services/user_api.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  static const Color kPurple = Color(0xFF5B288E);
  static const Color kGreyText = Color(0xFF898384);

  final String firstName = "Alex";
  final String location = "Los Angeles, CA";

  String? _avatarUrl;
  bool _avatarLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    setState(() => _avatarLoading = true);
    try {
      final url = await UserApi.getAvatarUrl();
      if (!mounted) return;
      setState(() => _avatarUrl = url);
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _avatarLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarWidget = _buildAvatar();

    return RefreshIndicator(
      onRefresh: _loadAvatar,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Good Morning $firstName!",
              style: const TextStyle(
                fontSize: 28,
                height: 1.1,
                fontWeight: FontWeight.w800,
                color: kPurple,
              ),
            ),
            const SizedBox(height: 18),

            // Profile card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () async {
                        final updated = await Navigator.pushNamed(
                          context,
                          '/edit-profile',
                        );
                        if (updated == true) {
                          await _loadAvatar();
                        }
                      },
                      child: const Text(
                        "Edit",
                        style: TextStyle(
                          color: kPurple,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  avatarWidget,
                  const SizedBox(height: 12),
                  Text(
                    firstName,
                    style: const TextStyle(
                      color: kPurple,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location,
                    style: const TextStyle(
                      color: kGreyText,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 34),

            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.storage_outlined,
                    size: 48,
                    color: Color(0xFFD7CDE3),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "No Data",
                    style: TextStyle(
                      color: kPurple,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Your trends will show up here.",
                    style: const TextStyle(
                      color: kGreyText,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPurple,
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                onPressed: () {},
                child: const Text(
                  "Start Journaling",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (_avatarLoading) {
      return const SizedBox(
        width: 98,
        height: 98,
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          _avatarUrl!,
          width: 98,
          height: 98,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholderAvatar(),
        ),
      );
    }

    return _placeholderAvatar();
  }

  Widget _placeholderAvatar() {
    return Container(
      width: 98,
      height: 98,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFEFEFEF),
      ),
      child: const Icon(Icons.person, size: 48, color: Color(0xFFBDBDBD)),
    );
  }
}
