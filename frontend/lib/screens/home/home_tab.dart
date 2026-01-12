import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../services/user_api.dart';
import '../../services/token_storage.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  static const Color kPurple = Color(0xFF5B288E);
  static const Color kGreyText = Color(0xFF898384);

  String _displayName = "there";
  String _location = "";
  String? _avatarUrl;

  bool _loading = true;
  bool _avatarLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  bool _looksLikeUuid(String v) {
    final s = v.trim();
    if (s.isEmpty) return false;
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(s);
  }

  String _pickDisplayNameFromClaims(Map<String, dynamic> c) {
    String s(dynamic v) => (v ?? '').toString().trim();

    final preferred = s(c['preferred_username']);
    final cognitoUsername = s(c['cognito:username']);
    final username = s(c['username']);
    final name = s(c['name']);
    final email = s(c['email']);
    final sub = s(c['sub']);

    final candidates = <String>[
      preferred,
      cognitoUsername,
      username,
      name,
      email,
    ];

    for (final v in candidates) {
      if (v.isNotEmpty && !_looksLikeUuid(v)) return v;
    }
    return sub.isNotEmpty ? sub : "there";
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 1) name from token
      final idToken = await TokenStorage.getIdToken();
      if (idToken != null && idToken.isNotEmpty) {
        final claims = JwtDecoder.decode(idToken);
        final nameFromToken = _pickDisplayNameFromClaims(claims);

        if (mounted) {
          setState(() {
            _displayName = nameFromToken;
          });
        }
      }

      // 2) location from backend
      try {
        final me = await UserApi.getMe();
        final location = (me['location'] ?? '').toString().trim();
        if (mounted) setState(() => _location = location);
      } catch (_) {}

      // 3) avatar
      await _loadAvatar();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
      onRefresh: _loadAll,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Good Morning $_displayName!",
              style: const TextStyle(
                fontSize: 28,
                height: 1.1,
                fontWeight: FontWeight.w800,
                color: kPurple,
              ),
            ),
            const SizedBox(height: 18),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

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
                        if (updated == true) await _loadAll();
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
                    _displayName,
                    style: const TextStyle(
                      color: kPurple,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _location.isNotEmpty ? _location : " ",
                    style: const TextStyle(
                      color: kGreyText,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: CircularProgressIndicator(),
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
