// MUUD Health — GoRouter Configuration
// Central Signal Router for app navigation
// © Muud Health — Armin Hoes, MD

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import 'route_names.dart';

// ── Screens ──────────────────────────────────────────────────────────────
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/otp_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/verify_reset_code_screen.dart';
import '../screens/reset_password_screen.dart';
import '../screens/edit_profile_screen.dart';

import '../screens/onboarding/onboarding_page_01.dart';
import '../screens/onboarding/onboarding_page_02.dart';
import '../screens/onboarding/onboarding_page_03.dart';
import '../screens/onboarding/onboarding_page_04.dart';
import '../screens/onboarding/onboarding_page_05.dart';
import '../screens/onboarding/onboarding_page_06.dart';
import '../screens/onboarding/onboarding_page_07.dart';
import '../screens/onboarding/onboarding_page_08.dart';

import '../screens/home/home_tab.dart';
import '../screens/trends/trends_tab.dart';
import '../screens/people/people_tab.dart';
import '../screens/explore/explore_tab.dart';

import '../screens/journal/pages/creator_tool_screen.dart';
import '../screens/journal/pages/edit_journal_screen.dart';
import '../screens/journal/pages/preview_screen.dart';
import '../screens/journal/pages/send_to_screen.dart';

import '../screens/people/pages/inner_circle_page.dart';
import '../screens/people/pages/connections_page.dart';
import '../screens/people/pages/suggestions_page.dart';
import '../screens/people/pages/profile_page.dart';
import '../screens/people/pages/chat_page.dart';
import '../screens/people/data/people_models.dart';

import '../screens/chat/pages/conversations_page.dart';

import '../screens/top_nav/vault_screen.dart';
import '../screens/top_nav/vault_category_page.dart';
import '../screens/top_nav/vault_filter_page.dart';
import '../screens/top_nav/settings_screen.dart';
import '../screens/top_nav/notifications_screen.dart';

import '../screens/ring/ring_screen.dart';
import '../screens/clinic/clinic_screen.dart';
import '../screens/academy/academy_screen.dart';

import '../shell/app_shell.dart';

// ── Navigator Keys ───────────────────────────────────────────────────────
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// ── Router Provider ──────────────────────────────────────────────────────
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.home,
    debugLogDiagnostics: false,

    // ── Redirect Logic ─────────────────────────────────────────────────
    redirect: (context, state) {
      final status = authState.status;
      final location = state.matchedLocation;

      final isAuthRoute = location == Routes.login ||
          location == Routes.signup ||
          location == Routes.otp ||
          location == Routes.forgot ||
          location == Routes.verifyReset ||
          location == Routes.resetPassword;

      final isOnboardingRoute = location.startsWith(Routes.onboardingBase);

      // Still loading — stay put
      if (status == AuthStatus.unknown) return null;

      // Not authenticated — force login (unless already on auth route)
      if (status == AuthStatus.unauthenticated) {
        return isAuthRoute ? null : Routes.login;
      }

      // Needs onboarding — force onboarding (unless already there)
      if (status == AuthStatus.onboarding) {
        return isOnboardingRoute ? null : Routes.onboarding('01');
      }

      // Authenticated — redirect away from auth/onboarding routes
      if (status == AuthStatus.authenticated) {
        if (isAuthRoute || isOnboardingRoute) return Routes.home;
      }

      return null;
    },

    // ── Routes ─────────────────────────────────────────────────────────
    routes: [
      // ── Auth (no shell) ────────────────────────────────────────────
      GoRoute(
        path: Routes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.signup,
        builder: (_, __) => const SignupScreen(),
      ),
      GoRoute(
        path: Routes.otp,
        builder: (_, __) => const OtpScreen(),
      ),
      GoRoute(
        path: Routes.forgot,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: Routes.verifyReset,
        builder: (_, __) => const VerifyResetCodeScreen(),
      ),
      GoRoute(
        path: Routes.resetPassword,
        builder: (_, __) => const ResetPasswordScreen(),
      ),

      // ── Onboarding (no shell) ──────────────────────────────────────
      GoRoute(
        path: '${Routes.onboardingBase}/:step',
        builder: (_, state) {
          final step = state.pathParameters['step'] ?? '01';
          return _onboardingPage(step);
        },
      ),

      // ── Main App Shell (bottom nav) ────────────────────────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (_, __, child) => AppShellGoRouter(child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            pageBuilder: (_, __) => const NoTransitionPage(child: HomeTab()),
          ),
          GoRoute(
            path: Routes.trends,
            pageBuilder: (_, __) => const NoTransitionPage(child: TrendsTab()),
          ),
          GoRoute(
            path: Routes.people,
            pageBuilder: (_, __) => const NoTransitionPage(child: PeopleTab()),
          ),
          GoRoute(
            path: Routes.explore,
            pageBuilder: (_, __) => const NoTransitionPage(child: ExploreTab()),
          ),
        ],
      ),

      // ── Journal / Creator (fullscreen over shell) ──────────────────
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.journalCreate,
        builder: (_, __) => const CreatorToolScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.journalEdit,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return EditJournalScreen(
            postId: extra['postId'] as String? ?? '',
            initialCaption: extra['initialCaption'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.journalPreview,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return PreviewScreen(
            imageFile: extra['imageFile'] as dynamic,
            audioPath: extra['audioPath'] as String?,
            initialVisibility: extra['initialVisibility'] as String? ?? 'Public',
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.journalSend,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return SendToScreen(
            imageFile: extra['imageFile'] as dynamic,
            caption: extra['caption'] as String? ?? '',
            audioPath: extra['audioPath'] as String?,
          );
        },
      ),

      // ── People Sub-routes ──────────────────────────────────────────
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.innerCircle,
        builder: (_, __) => const InnerCirclePage(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.connections,
        builder: (_, __) => const ConnectionsPage(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.suggestions,
        builder: (_, __) => const SuggestionsPage(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '${Routes.profileBase}/:sub',
        builder: (_, state) {
          final sub = state.pathParameters['sub'] ?? '';
          // ProfilePage expects a Person object. When navigating by sub,
          // a minimal placeholder is created; the screen should fetch full
          // profile data from the API using this sub.
          return _ProfileBySubWrapper(sub: sub);
        },
      ),

      // ── Chat ───────────────────────────────────────────────────────
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.chat,
        builder: (_, __) => const ConversationsPage(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '${Routes.chat}/:conversationId',
        builder: (_, state) {
          final conversationId = state.pathParameters['conversationId'] ?? '';
          // ChatPage uses otherSub for conversation lookup. When navigating
          // by conversationId, we treat it as the other user's sub.
          return ChatPage(otherSub: conversationId, title: '');
        },
      ),

      // ── Vault ──────────────────────────────────────────────────────
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.vault,
        builder: (_, __) => const VaultScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/vault/category/:category',
        builder: (_, state) {
          final category = state.pathParameters['category'] ?? '';
          return VaultCategoryPage(
            categoryKey: category,
            categoryTitle: category[0].toUpperCase() + category.substring(1),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.vaultFilter,
        builder: (_, __) => const VaultFilterPage(),
      ),

      // ── Settings / Profile ─────────────────────────────────────────
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.settings,
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.editProfile,
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.notifications,
        builder: (_, __) => const NotificationsScreen(),
      ),

      // ── Ring ──────────────────────────────────────────────────────
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.ringSetup,
        builder: (_, __) => const RingScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.ringStatus,
        builder: (_, __) => const RingScreen(),
      ),

      // ── Clinic (Phase 4 stub) ─────────────────────────────────────
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.clinic,
        builder: (_, __) => const ClinicScreen(),
      ),

      // ── Academy (Phase 4 stub) ────────────────────────────────────
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.academy,
        builder: (_, __) => const AcademyScreen(),
      ),
    ],

    errorBuilder: (_, __) => const Scaffold(
      body: Center(child: Text('Page not found')),
    ),
  );
});

// ── Onboarding Page Resolver ─────────────────────────────────────────────
Widget _onboardingPage(String step) {
  switch (step) {
    case '01': return const OnboardingPage01();
    case '02': return const OnboardingPage02();
    case '03': return const OnboardingPage03();
    case '04': return const OnboardingPage04();
    case '05': return const OnboardingPage05();
    case '06': return const OnboardingPage06();
    case '07': return const OnboardingPage07();
    case '08': return const OnboardingPage08();
    default:   return const OnboardingPage01();
  }
}

// ── Profile Wrapper (sub → Person lookup) ───────────────────────────────
// ProfilePage expects a Person model. This wrapper accepts a sub string
// from the route param, constructs a minimal Person, and delegates.
// The ProfilePage itself should hydrate the full profile from API.
class _ProfileBySubWrapper extends StatelessWidget {
  final String sub;
  const _ProfileBySubWrapper({required this.sub});

  @override
  Widget build(BuildContext context) {
    // Create a placeholder Person with the sub as identifier.
    // ProfilePage will fetch full data from UserApi.
    final placeholder = Person(
      id: sub,
      name: '',
      handle: '',
      avatarUrl: '',
      location: '',
      lastActive: '',
      moodChip: '',
      tint: 'purple',
    );
    return ProfilePage(person: placeholder);
  }
}

// ── GoRouter-compatible AppShell ─────────────────────────────────────────
// This wraps the child from ShellRoute, providing the bottom nav bar.
// The existing AppShell uses IndexedStack — this version receives
// the child widget from GoRouter instead.
class AppShellGoRouter extends StatelessWidget {
  final Widget child;
  const AppShellGoRouter({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Determine current tab index from location
    final location = GoRouterState.of(context).matchedLocation;
    final index = _indexForLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: _GoRouterBottomNav(
        currentIndex: index,
        onTap: (i) => _onNavTap(context, i),
      ),
    );
  }

  static int _indexForLocation(String location) {
    if (location.startsWith(Routes.trends)) return 1;
    if (location.startsWith(Routes.people)) return 3;
    if (location.startsWith(Routes.explore)) return 4;
    return 0; // home
  }

  static void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go(Routes.home); break;
      case 1: context.go(Routes.trends); break;
      case 2: context.push(Routes.journalCreate); break; // FAB — push, not go
      case 3: context.go(Routes.people); break;
      case 4: context.go(Routes.explore); break;
    }
  }
}

class _GoRouterBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _GoRouterBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex > 2 ? currentIndex - 1 : currentIndex, // Skip index 2 (FAB)
        onTap: (i) {
          // Remap: 0=Home, 1=Trends, 2=FAB(journal), 3→2=People, 4→3=Explore
          if (i >= 2) {
            onTap(i + 1);
          } else {
            onTap(i);
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Trends'),
          BottomNavigationBarItem(
            icon: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 26),
            ),
            label: '',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.group_outlined), label: 'People'),
          const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
        ],
      ),
    );
  }
}
