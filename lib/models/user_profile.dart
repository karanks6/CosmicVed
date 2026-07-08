import 'dart:convert';

/// User profile model — fully serializable to/from SQLite
class UserProfile {
  final int? id;
  final String name;
  final String gender; // 'male' | 'female' | 'other'
  final DateTime dateOfBirth;
  final String timeOfBirth; // HH:mm
  final String birthCity;
  final String birthCountry;
  final double latitude;
  final double longitude;
  final String timezoneId;
  final int utcOffsetMinutes;
  final int avatarIndex;
  final bool isActive;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    this.id,
    required this.name,
    required this.gender,
    required this.dateOfBirth,
    required this.timeOfBirth,
    required this.birthCity,
    required this.birthCountry,
    required this.latitude,
    required this.longitude,
    required this.timezoneId,
    required this.utcOffsetMinutes,
    this.avatarIndex = 0,
    this.isActive = false,
    this.isArchived = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as int?,
      name: map['name'] as String,
      gender: map['gender'] as String,
      dateOfBirth: DateTime.parse(map['date_of_birth'] as String),
      timeOfBirth: map['time_of_birth'] as String,
      birthCity: map['birth_city'] as String,
      birthCountry: map['birth_country'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      timezoneId: map['timezone_id'] as String,
      utcOffsetMinutes: (map['utc_offset_minutes'] as int?) ?? 0,
      avatarIndex: (map['avatar_index'] as int?) ?? 0,
      isActive: (map['is_active'] as int?) == 1,
      isArchived: (map['is_archived'] as int?) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'gender': gender,
      'date_of_birth': '${dateOfBirth.year}-${dateOfBirth.month.toString().padLeft(2,'0')}-${dateOfBirth.day.toString().padLeft(2,'0')}',
      'time_of_birth': timeOfBirth,
      'birth_city': birthCity,
      'birth_country': birthCountry,
      'latitude': latitude,
      'longitude': longitude,
      'timezone_id': timezoneId,
      'utc_offset_minutes': utcOffsetMinutes,
      'avatar_index': avatarIndex,
      'is_active': isActive ? 1 : 0,
      'is_archived': isArchived ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    int? id,
    String? name,
    String? gender,
    DateTime? dateOfBirth,
    String? timeOfBirth,
    String? birthCity,
    String? birthCountry,
    double? latitude,
    double? longitude,
    String? timezoneId,
    int? utcOffsetMinutes,
    int? avatarIndex,
    bool? isActive,
    bool? isArchived,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      timeOfBirth: timeOfBirth ?? this.timeOfBirth,
      birthCity: birthCity ?? this.birthCity,
      birthCountry: birthCountry ?? this.birthCountry,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timezoneId: timezoneId ?? this.timezoneId,
      utcOffsetMinutes: utcOffsetMinutes ?? this.utcOffsetMinutes,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      isActive: isActive ?? this.isActive,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Full name initials for avatar fallback
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Birth datetime in local timezone (approximation — full version uses timezone package)
  DateTime get birthDateTimeLocal {
    final parts = timeOfBirth.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    return DateTime(
      dateOfBirth.year,
      dateOfBirth.month,
      dateOfBirth.day,
      h,
      m,
    );
  }

  /// UTC birth datetime
  DateTime get birthDateTimeUtc {
    return birthDateTimeLocal.subtract(
      Duration(minutes: utcOffsetMinutes),
    );
  }

  int get ageInYears {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  @override
  String toString() => 'UserProfile($id: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UserProfile && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
