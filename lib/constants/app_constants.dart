/// Application-wide constants
abstract final class AppConstants {
  static const String appName = 'CosmicVed';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Your Cosmic Companion';

  // Database
  static const String dbName = 'cosmicved.db';
  static const String geonamesDbName = 'geonames.db';
  static const int dbVersion = 1;

  // Hive boxes
  static const String settingsBox = 'cosmic_settings';
  static const String cacheBox = 'cosmic_cache';
  static const String userBox = 'cosmic_user';

  // Settings keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyActiveProfileId = 'active_profile_id';
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyBiometricEnabled = 'biometric_enabled';
  static const String keyPinEnabled = 'pin_enabled';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyDefaultChartStyle = 'default_chart_style';
  static const String keyLanguage = 'language';

  // Secure storage keys
  static const String keyEncryptedPin = 'encrypted_pin';
  static const String keyDbEncryptionKey = 'db_encryption_key';

  // Timing
  static const Duration cacheExpiry = Duration(hours: 24);
  static const Duration weeklyExpiry = Duration(days: 7);
  static const Duration monthlyExpiry = Duration(days: 30);

  // Pagination
  static const int defaultPageSize = 20;

  // Chart styles
  static const String chartNorthIndian = 'north_indian';
  static const String chartSouthIndian = 'south_indian';
  static const String chartEastIndian = 'east_indian';

  // Report types
  static const String reportKundali = 'kundali';
  static const String reportNumerology = 'numerology';
  static const String reportCompatibility = 'compatibility';
  static const String reportDaily = 'daily';
  static const String reportMonthly = 'monthly';
  static const String reportYearly = 'yearly';

  // Numerology result types
  static const String numLifePath = 'life_path';
  static const String numDestiny = 'destiny';
  static const String numName = 'name_number';

  // Compatibility types
  static const String compatMarriage = 'marriage';
  static const String compatFriendship = 'friendship';
  static const String compatBusiness = 'business';

  // Disclaimer
  static const String numerologyDisclaimer =
      'These insights are based on traditional Chaldean Numerology interpretations '
      'and are provided for educational and spiritual guidance purposes only. '
      'They do not constitute professional advice of any kind.';

  static const String astrologyDisclaimer =
      'These readings are based on authentic Vedic astrological traditions '
      'and are intended for spiritual and educational purposes only. '
      'They should not replace professional medical, legal, or financial advice.';

  static const String healthDisclaimer =
      'Health insights presented here are based on traditional numerological '
      'wellness philosophy and are NOT medical advice. Always consult a '
      'qualified healthcare professional for medical concerns.';
}
