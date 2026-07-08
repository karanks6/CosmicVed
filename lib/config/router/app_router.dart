import 'package:go_router/go_router.dart';
import 'routes.dart';
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/welcome_screen.dart';
import '../../features/onboarding/screens/profile_setup_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/kundali/screens/kundali_screen.dart';
import '../../features/numerology/screens/numerology_home_screen.dart';
import '../../features/numerology/screens/life_path_screen.dart';
import '../../features/numerology/screens/destiny_screen.dart';
import '../../features/compatibility/screens/compatibility_home_screen.dart';
import '../../features/panchang/screens/panchang_screen.dart';
import '../../features/profiles/screens/profiles_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/remedies/screens/remedies_screen.dart';
import '../../features/health/screens/health_insights_screen.dart';
import '../../features/education/screens/education_home_screen.dart';
import '../../features/horoscope/screens/horoscope_screen.dart';
import '../../features/horoscope/screens/zodiac_traits_screen.dart';
import '../../widgets/main_shell.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: false,
  routes: [
    // ── Splash & Onboarding ──────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.welcome,
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.profileSetup,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ProfileSetupScreen(isFirstProfile: extra?['first'] == true);
      },
    ),

    // ── Profile Management ───────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.profiles,
      builder: (context, state) => const ProfilesScreen(),
    ),
    GoRoute(
      path: AppRoutes.addProfile,
      builder: (context, state) => const ProfileSetupScreen(isFirstProfile: false),
    ),

    // ── Main Shell with Bottom Navigation ────────────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        // Dashboard
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.dashboard,
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        // Kundali
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.kundali,
              builder: (context, state) => const KundaliScreen(),
            ),
          ],
        ),
        // Numerology
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.numerology,
              builder: (context, state) => const NumerologyHomeScreen(),
              routes: [
                GoRoute(
                  path: 'life-path',
                  builder: (context, state) => const LifePathScreen(),
                ),
                GoRoute(
                  path: 'destiny',
                  builder: (context, state) => const DestinyScreen(),
                ),
                GoRoute(
                  path: 'name-number',
                  builder: (context, state) => const NameNumberScreen(),
                ),
              ],
            ),
          ],
        ),
        // Compatibility
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.compatibility,
              builder: (context, state) => const CompatibilityHomeScreen(),
            ),
          ],
        ),
        // Panchang
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.panchang,
              builder: (context, state) => const PanchangScreen(),
            ),
          ],
        ),
      ],
    ),

    // ── Settings & Other ─────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.remedies,
      builder: (context, state) => const RemediesScreen(),
    ),
    GoRoute(
      path: AppRoutes.health,
      builder: (context, state) => const HealthInsightsScreen(),
    ),
    GoRoute(
      path: AppRoutes.education,
      builder: (context, state) => const EducationHomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.horoscope,
      builder: (context, state) => const HoroscopeScreen(),
    ),
    GoRoute(
      path: AppRoutes.zodiacTraits,
      builder: (context, state) => const ZodiacTraitsScreen(),
    ),
  ],
);
