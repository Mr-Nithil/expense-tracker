import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/auth/data/auth_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'confirm_password_controller.g.dart';

/// Checks the account password of the signed-in user without signing out (PIN recovery, M7.7).
/// The auth feature's entry point for other features (ARCHITECTURE §3).
@Riverpod(keepAlive: true)
class ConfirmPasswordController extends _$ConfirmPasswordController {
  @override
  void build() {}

  /// The signed-in account's email, or `null`.
  String? get email => ref.read(authRepositoryProvider).currentUser?.email;

  Future<Result<void>> confirm(String password) =>
      ref.read(authRepositoryProvider).confirmPassword(password);
}
