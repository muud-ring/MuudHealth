import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../services/user_api.dart';
import '../../services/token_storage.dart';
import '../../theme/app_theme.dart';
import 'widgets/daily_greeting_card.dart';
import 'widgets/quick_stats_row.dart';
import 'widgets/signal_pathway_card.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
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
            // Greeting card (context-aware, replaces static text)
            DailyGreetingCard(displayName: _displayName),

            const SizedBox(height: MuudSpacing.base),

            // Error banner
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: MuudSpacing.md),
                child: Container(
                  padding: const EdgeInsets.all(MuudSpacing.md),
                  decoration: BoxDecoration(
                    color: MuudColors.error.withValues(alpha: 0.08),
                    borderRadius: MuudRadius.mdAll,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: MuudColors.error, size: 18),
                      const SizedBox(width: MuudSpacing.sm),
                      Expanded(
                        child: Text(
                          _error!,
                          style: MuudTypography.bodySmall.copyWith(
                            color: MuudColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Quick stats row (biometric snapshot)
            const QuickStatsRow(
              heartRate: null, // Populated when ring data available
              steps: null,
              sleepMinutes: null,
              stressLevel: null,
            ),

            const SizedBox(height: MuudSpacing.base),

            // Profile card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
              decoration: BoxDecoration(
                color: MuudColors.white,
                borderRadius: MuudRadius.lgAll,
                boxShadow: MuudShadows.card,
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () async {
                        final updated = await context.push<bool>(
                          '/edit-profile',
                        );
                        if (updated == true) await _loadAll();
                      },
                      child: Text(
                        "Edit",
                        style: MuudTypography.label.copyWith(
                          color: MuudColors.purple,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  avatarWidget,
                  const SizedBox(height: 12),
                  Text(
                    _displayName,
                    style: MuudTypography.titleMedium.copyWith(
                      color: MuudColors.purple,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _location.isNotEmpty ? _location : " ",
                    style: MuudTypography.caption.copyWith(
                      color: MuudColors.greyText,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: MuudSpacing.base),

            // Signal Pathway progress card
            const SignalPathwayCard(
              signalProgress: 0.0, // Will be computed from ring data
              insightProgress: 0.0,
              actionProgress: 0.0,
              learnProgress: 0.0,
              growProgress: 0.0,
            ),

            const SizedBox(height: MuudSpacing.lg),

            // Start Journaling CTA
            SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: MuudColors.purple,
                  disabledBackgroundColor: MuudColors.purple.withValues(alpha: 0.35),
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                child: Text(
                  "Start Journaling",
                  style: MuudTypography.button.copyWith(
                    color: MuudColors.white,
                  ),
                ),
              ),
            ),

            // Loading indicator
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: MuudSpacing.base),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: MuudColors.purple,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: MuudSpacing.xxl),
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
        child: CachedNetworkImage(
          imageUrl: _avatarUrl!,
          width: 98,
          height: 98,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _placeholderAvatar(),
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
