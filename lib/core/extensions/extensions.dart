import 'package:flutter/material.dart';

/// DateTime extensions for Vedic astrology calculations
extension CosmicDateExt on DateTime {
  /// Julian Day Number (JDN) — fundamental for all astronomical calculations
  double get julianDay {
    int y = year;
    int m = month;
    final d = day + (hour + minute / 60.0 + second / 3600.0) / 24.0;

    if (m <= 2) {
      y -= 1;
      m += 12;
    }

    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();

    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        d +
        b -
        1524.5;
  }

  /// Julian Centuries from J2000.0
  double get julianCenturies => (julianDay - 2451545.0) / 36525.0;

  /// Local Sidereal Time in degrees (requires longitude in degrees)
  double localSiderealTime(double longitudeDegrees) {
    final t = julianCenturies;
    // Greenwich Mean Sidereal Time in degrees
    double gmst = 280.46061837 +
        360.98564736629 * (julianDay - 2451545.0) +
        0.000387933 * t * t -
        t * t * t / 38710000.0;
    gmst = gmst % 360.0;
    if (gmst < 0) gmst += 360.0;
    double lst = (gmst + longitudeDegrees) % 360.0;
    if (lst < 0) lst += 360.0;
    return lst;
  }

  /// Format as Indian date display
  String get indianDisplay {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '$day ${months[month - 1]} $year';
  }

  /// Format as time string HH:mm
  String get timeDisplay =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  /// Day of week for Vedic calculations (0 = Sunday, Ravivara)
  int get vedicDayOfWeek => weekday % 7; // Flutter weekday: Mon=1..Sun=7

  /// Check if this date has DST offset (simplified — use timezone package in production)
  bool get isPossiblyDST => month >= 3 && month <= 10;

  /// Get UTC offset from timezone name (basic lookup; full version uses timezone package)
  static DateTime fromBirthInput({
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minute,
    required double utcOffsetHours,
  }) {
    return DateTime.utc(year, month, day, hour, minute)
        .subtract(Duration(minutes: (utcOffsetHours * 60).round()));
  }
}

/// String extensions for numerology and general utility
extension CosmicStringExt on String {
  /// Strip all non-alphabetic characters and uppercase for Chaldean lookup
  String get forNumerology =>
      toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');

  /// Capitalize first letter of each word
  String get titleCase => split(' ')
      .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');

  /// Normalize city name for lookup
  String get normalizedCity =>
      trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  /// Truncate with ellipsis
  String truncate(int maxLength) =>
      length > maxLength ? '${substring(0, maxLength)}...' : this;

  /// Check if valid birth time format HH:mm
  bool get isValidTime {
    final parts = split(':');
    if (parts.length != 2) return false;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    return h != null && m != null && h >= 0 && h < 24 && m >= 0 && m < 60;
  }

  /// Get first name (for display)
  String get firstName => trim().split(' ').first;
}

/// int extensions for numerology
extension CosmicIntExt on int {
  /// Reduce to single digit (Chaldean doesn't reduce 11, 22, 33)
  int get chaldeanReduce {
    if (this == 11 || this == 22 || this == 33) return this;
    if (this < 10) return this;
    int sum = 0;
    int n = this;
    while (n > 0) {
      sum += n % 10;
      n ~/= 10;
    }
    return sum.chaldeanReduce;
  }

  /// Get digit sum (for Pythagorean/basic reduction)
  int get digitSum {
    int sum = 0;
    int n = abs();
    while (n > 0) {
      sum += n % 10;
      n ~/= 10;
    }
    return sum;
  }

  /// Ordinal string (1st, 2nd, etc.)
  String get ordinal {
    if (this >= 11 && this <= 13) return '${this}th';
    return switch (this % 10) {
      1 => '${this}st',
      2 => '${this}nd',
      3 => '${this}rd',
      _ => '${this}th',
    };
  }
}

/// Double extensions for astronomical calculations
extension CosmicDoubleExt on double {
  /// Normalize angle to 0–360
  double get normalize360 {
    double d = this % 360.0;
    return d < 0 ? d + 360.0 : d;
  }

  /// Convert degrees to radians
  double get toRad => this * 3.141592653589793 / 180.0;

  /// Convert radians to degrees
  double get toDeg => this * 180.0 / 3.141592653589793;

  /// Zodiac sign index (0-based Aries) from longitude
  int get rashiIndex => (normalize360 / 30).floor() % 12;

  /// Degrees within current rashi
  double get rashiDegrees => normalize360 % 30;

  /// Format as degrees°minutes'seconds"
  String get dmsString {
    final d = floor();
    final mFrac = (this - d) * 60;
    final m = mFrac.floor();
    final s = ((mFrac - m) * 60).round();
    return "$d°$m'${s}\"";
  }
}

/// BuildContext shorthand extensions
extension CosmicContextExt on BuildContext {
  ThemeData get theme => Theme.of(this);
  bool get isDark => theme.brightness == Brightness.dark;
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  bool get isSmallScreen => screenWidth < 600;
  bool get isMediumScreen => screenWidth >= 600 && screenWidth < 1200;
  bool get isLargeScreen => screenWidth >= 1200;
}
