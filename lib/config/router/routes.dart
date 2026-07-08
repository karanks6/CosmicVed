/// Route constants for GoRouter
abstract final class AppRoutes {
  // ─── Root ──────────────────────────────────────────────────────────────────
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const welcome = '/welcome';
  static const profileSetup = '/profile-setup';

  // ─── Main Shell ───────────────────────────────────────────────────────────
  static const shell = '/shell';
  static const dashboard = '/dashboard';
  static const kundali = '/kundali';
  static const numerology = '/numerology';
  static const compatibility = '/compatibility';
  static const panchang = '/panchang';

  // ─── Nested ───────────────────────────────────────────────────────────────
  static const lifePath = '/numerology/life-path';
  static const destinyNumber = '/numerology/destiny';
  static const nameNumber = '/numerology/name-number';

  static const marriage = '/compatibility/marriage';
  static const friendship = '/compatibility/friendship';
  static const business = '/compatibility/business';

  static const kundaliDetail = '/kundali/detail';

  // ─── Features ─────────────────────────────────────────────────────────────
  static const profiles = '/profiles';
  static const addProfile = '/profiles/add';
  static const editProfile = '/profiles/edit';

  static const settings = '/settings';
  static const remedies = '/remedies';
  static const health = '/health';
  static const education = '/education';
  static const reports = '/reports';
  static const horoscope = '/horoscope';
  static const zodiacTraits = '/zodiac-traits';
}
