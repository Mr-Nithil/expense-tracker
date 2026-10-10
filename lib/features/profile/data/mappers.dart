import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/features/profile/domain/entities/profile.dart';

extension ProfileRowMapper on ProfileRow {
  Profile toEntity() => Profile(id: id, displayName: displayName, currencyCode: currencyCode);
}
