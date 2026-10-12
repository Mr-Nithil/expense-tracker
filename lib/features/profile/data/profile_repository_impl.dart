import 'package:drift/drift.dart';
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/daos/profiles_dao.dart';
import 'package:expense_tracker/core/db/tables/sync_columns.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations.dart';
import 'package:expense_tracker/core/logging/app_logger.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/sync/sync_trigger.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/currencies.dart';
import 'package:expense_tracker/features/profile/data/mappers.dart';
import 'package:expense_tracker/features/profile/domain/entities/profile.dart';
import 'package:expense_tracker/features/profile/domain/profile_repository.dart';

/// [ProfileRepository] backed by the local `profiles` table.
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required this.dao,
    required this.clock,
    required this.session,
    required this.syncTrigger,
  });

  final ProfilesDao dao;
  final Clock clock;
  final Session session;
  final SyncTrigger syncTrigger;

  static const currencyField = 'currencyCode';
  static const localeField = 'locale';

  @override
  Stream<Profile?> watchProfile() {
    final userId = session.currentUser?.userId;
    if (userId == null) return Stream.value(null);
    return dao.watchProfile(userId).map((row) => row?.toEntity());
  }

  @override
  Future<Result<Profile>> setCurrency(String currencyCode) async {
    if (!Currencies.isSupported(currencyCode)) {
      return const Result.failure(ValidationFailure('unsupportedCurrency', field: currencyField));
    }

    try {
      final user = session.requireUser();
      return await dao.transaction(() async {
        final existing = await dao.getProfile(user.userId);
        if (existing?.currencyCode != null) {
          // The currency is read-only after onboarding (one currency per user).
          return const Result<Profile>.failure(
            ValidationFailure('currencyAlreadySet', field: currencyField),
          );
        }

        final now = clock.now().toUtc();
        if (existing == null) {
          // No local row yet (it has not been pulled). Carry the display name so a later push
          // does not blank the server value.
          await dao.insertProfile(
            ProfilesCompanion.insert(
              id: user.userId,
              userId: user.userId,
              createdAt: now,
              updatedAt: now,
              displayName: Value(user.displayName),
              currencyCode: Value(currencyCode),
              syncStatus: const Value(SyncStatus.pending),
            ),
          );
        } else {
          await dao.updateProfile(
            user.userId,
            ProfilesCompanion(
              currencyCode: Value(currencyCode),
              updatedAt: Value(now),
              syncStatus: const Value(SyncStatus.pending),
            ),
          );
        }

        final saved = await dao.getProfile(user.userId);
        syncTrigger.requestSync();
        return Result.success(saved!.toEntity());
      });
    } on StateError catch (_) {
      return const Result.failure(AuthFailure('setCurrency: no session'));
    } catch (error, stackTrace) {
      AppLogger.error('setCurrency failed', error, stackTrace);
      return Result.failure(StorageFailure('setCurrency: $error'));
    }
  }

  @override
  Future<Result<Profile>> setThemeMode(AppThemeMode mode) => _savePreference(
    'setThemeMode',
    isUnchanged: (row) => row.themeMode == mode.dbValue,
    change: ProfilesCompanion(themeMode: Value(mode.dbValue)),
  );

  @override
  Future<Result<Profile>> setLocale(String? languageCode) async {
    if (languageCode != null &&
        !AppLocalizations.supportedLocales.any((l) => l.languageCode == languageCode)) {
      return const Result.failure(ValidationFailure('unsupportedLocale', field: localeField));
    }
    return _savePreference(
      'setLocale',
      isUnchanged: (row) => row.locale == languageCode,
      change: ProfilesCompanion(locale: Value(languageCode)),
    );
  }

  /// Writes a synced preference column ([change]) unless [isUnchanged]. Without a local row yet
  /// (not pulled), first creates it, carrying the display name like [setCurrency].
  Future<Result<Profile>> _savePreference(
    String operation, {
    required bool Function(ProfileRow row) isUnchanged,
    required ProfilesCompanion change,
  }) async {
    try {
      final user = session.requireUser();
      return await dao.transaction(() async {
        final existing = await dao.getProfile(user.userId);
        if (existing != null && isUnchanged(existing)) {
          return Result.success(existing.toEntity());
        }

        final now = clock.now().toUtc();
        if (existing == null) {
          await dao.insertProfile(
            ProfilesCompanion.insert(
              id: user.userId,
              userId: user.userId,
              createdAt: now,
              updatedAt: now,
              displayName: Value(user.displayName),
            ),
          );
        }
        await dao.updateProfile(
          user.userId,
          change.copyWith(updatedAt: Value(now), syncStatus: const Value(SyncStatus.pending)),
        );

        final saved = await dao.getProfile(user.userId);
        syncTrigger.requestSync();
        return Result.success(saved!.toEntity());
      });
    } on StateError catch (_) {
      return Result.failure(AuthFailure('$operation: no session'));
    } catch (error, stackTrace) {
      AppLogger.error('$operation failed', error, stackTrace);
      return Result.failure(StorageFailure('$operation: $error'));
    }
  }
}
