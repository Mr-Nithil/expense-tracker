import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/utils/validators.dart';

/// Field rules for categories. Used by the repository (authoritative) and the form (M2.4).
abstract final class CategoryValidator {
  /// Matches the `categories.name` check constraint (Drift and Postgres).
  static const maxNameLength = 50;

  static const nameField = 'name';
  static const iconField = 'icon';
  static const colorField = 'color';
  static const typeField = 'type';

  /// `ValidationFailure.message` reasons, shared by the repository and the form.
  static const nameRequired = 'nameRequired';
  static const nameTooLong = 'nameTooLong';
  static const iconRequired = 'iconRequired';
  static const invalidColor = 'invalidColor';
  static const duplicateName = 'duplicateName';
  static const typeLockedByTransactions = 'typeLockedByTransactions';

  static const _maxColor = 0xFFFFFFFF;

  /// The first problem found, or `null` when valid. [name] is checked after trimming.
  static ValidationFailure? validate({
    required String name,
    required String icon,
    required int color,
  }) {
    final trimmed = name.trim();
    if (Validators.required(trimmed) != null) {
      return const ValidationFailure(nameRequired, field: nameField);
    }
    if (trimmed.length > maxNameLength) {
      return const ValidationFailure(nameTooLong, field: nameField);
    }
    if (icon.trim().isEmpty) {
      return const ValidationFailure(iconRequired, field: iconField);
    }
    if (color < 0 || color > _maxColor) {
      return const ValidationFailure(invalidColor, field: colorField);
    }
    return null;
  }
}
