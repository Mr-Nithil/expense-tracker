import 'package:drift/drift.dart';
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/daos/profiles_dao.dart';
import 'package:expense_tracker/core/db/tables/sync_columns.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/logging/app_logger.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/currencies.dart';
import 'package:expense_tracker/features/profile/data/mappers.dart';
import 'package:expense_tracker/features/profile/domain/entities/profile.dart';
import 'package:expense_tracker/features/profile/domain/profile_repository.dart';

/// [ProfileRepository] backed by the local `profiles` table.
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({required this.dao, required this.clock, required this.session});

  final ProfilesDao dao;
  final Clock clock;
  final Session session;

  static const currencyField = 'currencyCode';

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
        return Result.success(saved!.toEntity());
      });
    } on StateError catch (_) {
      return const Result.failure(AuthFailure('setCurrency: no session'));
    } catch (error, stackTrace) {
      AppLogger.error('setCurrency failed', error, stackTrace);
      return Result.failure(StorageFailure('setCurrency: $error'));
    }
  }
}
