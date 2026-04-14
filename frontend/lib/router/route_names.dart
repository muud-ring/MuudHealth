// MUUD Health — Route Path Constants
// © Muud Health — Armin Hoes, MD

/// Centralized route path constants for type-safe navigation.
/// All paths correspond to GoRouter route definitions in app_router.dart.
class Routes {
  Routes._();

  // ── Auth ────────────────────────────────────────────────────────────────
  static const String login         = '/login';
  static const String signup        = '/signup';
  static const String otp           = '/otp';
  static const String forgot        = '/forgot';
  static const String verifyReset   = '/reset';
  static const String resetPassword = '/reset-password';

  // ── Onboarding ─────────────────────────────────────────────────────────
  static String onboarding(String step) => '/onboarding/$step';
  static const String onboardingBase = '/onboarding';

  // ── Shell Tabs ─────────────────────────────────────────────────────────
  static const String home    = '/home';
  static const String trends  = '/trends';
  static const String people  = '/people';
  static const String explore = '/explore';

  // ── Journal / Creator ──────────────────────────────────────────────────
  static const String journalCreate  = '/journal/create';
  static const String journalEdit    = '/journal/edit';
  static const String journalPreview = '/journal/preview';
  static const String journalSend    = '/journal/send';

  // ── People Sub-routes ──────────────────────────────────────────────────
  static const String innerCircle       = '/people/inner-circle';
  static const String connections       = '/people/connections';
  static const String suggestions       = '/people/suggestions';
  static String profile(String sub) => '/people/profile/$sub';
  static const String profileBase       = '/people/profile';

  // ── Chat ───────────────────────────────────────────────────────────────
  static const String chat              = '/chat';
  static String chatConversation(String id) => '/chat/$id';

  // ── Vault ──────────────────────────────────────────────────────────────
  static const String vault             = '/vault';
  static String vaultCategory(String cat) => '/vault/category/$cat';
  static const String vaultFilter       = '/vault/filter';

  // ── Settings / Profile ─────────────────────────────────────────────────
  static const String settings     = '/settings';
  static const String editProfile  = '/edit-profile';
  static const String notifications = '/notifications';

  // ── Ring ────────────────────────────────────────────────────────────────
  static const String ringSetup    = '/ring/setup';
  static const String ringStatus   = '/ring/status';

  // ── Clinic (stub) ──────────────────────────────────────────────────────
  static const String clinic       = '/clinic';

  // ── Academy (stub) ─────────────────────────────────────────────────────
  static const String academy      = '/academy';
}
