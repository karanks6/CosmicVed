import 'dart:async';
import '../database/daos/user_profile_dao.dart';
import '../models/user_profile.dart';
import '../core/result/result.dart';

/// Repository for user profile operations
class ProfileRepository {
  final UserProfileDao _dao;

  ProfileRepository({UserProfileDao? dao})
      : _dao = dao ?? UserProfileDao();

  Future<Result<List<UserProfile>>> getAllProfiles() async {
    try {
      final maps = await _dao.getAll();
      return Success(maps.map(UserProfile.fromMap).toList());
    } catch (e) {
      return Failure(DatabaseFailure('Failed to load profiles: $e'));
    }
  }

  Future<Result<UserProfile?>> getActiveProfile() async {
    try {
      final map = await _dao.getActive();
      return Success(map != null ? UserProfile.fromMap(map) : null);
    } catch (e) {
      return Failure(DatabaseFailure('Failed to get active profile: $e'));
    }
  }

  Future<Result<int>> createProfile(UserProfile profile) async {
    try {
      final id = await _dao.insert(profile.toMap());
      return Success(id);
    } catch (e) {
      return Failure(DatabaseFailure('Failed to create profile: $e'));
    }
  }

  Future<Result<void>> updateProfile(UserProfile profile) async {
    try {
      if (profile.id == null) {
        return const Failure(ValidationFailure('Profile ID is required for update'));
      }
      await _dao.update(profile.id!, profile.toMap());
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseFailure('Failed to update profile: $e'));
    }
  }

  Future<Result<void>> setActiveProfile(int id) async {
    try {
      await _dao.setActive(id);
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseFailure('Failed to set active profile: $e'));
    }
  }

  Future<Result<void>> archiveProfile(int id) async {
    try {
      await _dao.archive(id);
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseFailure('Failed to archive profile: $e'));
    }
  }

  Future<Result<void>> deleteProfile(int id) async {
    try {
      await _dao.delete(id);
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseFailure('Failed to delete profile: $e'));
    }
  }

  Future<Result<int>> getProfileCount() async {
    try {
      return Success(await _dao.count());
    } catch (e) {
      return Failure(DatabaseFailure('$e'));
    }
  }
}
