import 'package:drift/drift.dart';
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/tables/profiles.dart';

part 'profiles_dao.g.dart';

/// The user's profile row (`id = user_id`). Queries only; rules live in the repository.
@DriftAccessor(tables: [Profiles])
class ProfilesDao extends DatabaseAccessor<AppDatabase> with _$ProfilesDaoMixin {
  ProfilesDao(super.attachedDatabase);

  SimpleSelectStatement<$ProfilesTable, ProfileRow> _byUser(String userId) =>
      select(profiles)..where((t) => t.id.equals(userId) & t.deletedAt.isNull());

  Stream<ProfileRow?> watchProfile(String userId) => _byUser(userId).watchSingleOrNull();

  Future<ProfileRow?> getProfile(String userId) => _byUser(userId).getSingleOrNull();

  Future<void> insertProfile(ProfilesCompanion row) => into(profiles).insert(row);

  /// Returns the number of updated rows (0 when the profile doesn't exist).
  Future<int> updateProfile(String userId, ProfilesCompanion changes) =>
      (update(profiles)..where((t) => t.id.equals(userId))).write(changes);
}
