import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/validators.dart';
import 'package:expense_tracker/core/widgets/app_button.dart';
import 'package:expense_tracker/core/widgets/app_scaffold.dart';
import 'package:expense_tracker/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:expense_tracker/features/auth/presentation/providers/reset_password_controller.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/auth_form_layout.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/password_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Opened from a password-reset link (`AuthStatus.passwordRecovery`). The router keeps the user
/// here until the new password is saved or they cancel (sign out).
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref.read(resetPasswordControllerProvider.notifier).save(_password.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    ref.listen(resetPasswordControllerProvider, (_, next) {
      if (next case AsyncError(:final error)) {
        context.showSnack(errorMessageOf(error, context));
      }
    });
    final isLoading = ref.watch(resetPasswordControllerProvider).isLoading;
    final email = ref.watch(authStateProvider).value?.user?.email ?? '';

    return AppScaffold(
      title: l10n.authResetPasswordTitle,
      body: AutofillGroup(
        child: Form(
          key: _formKey,
          child: AuthFormLayout(
            children: [
              Text(
                l10n.authResetPasswordSubtitle(email),
                style: context.text.bodyLarge?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const Gap(AppSpacing.lg),
              PasswordField(
                label: l10n.authNewPasswordLabel,
                controller: _password,
                hint: l10n.authPasswordHint(Validators.minPasswordLength),
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                enabled: !isLoading,
                validator: (value) => Validators.password(value)?.toL10n(context),
              ),
              const Gap(AppSpacing.md),
              PasswordField(
                label: l10n.authConfirmPasswordLabel,
                controller: _confirmPassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                enabled: !isLoading,
                onSubmitted: (_) => _submit(),
                validator: (value) =>
                    Validators.passwordConfirmation(_password.text, value)?.toL10n(context),
              ),
              const Gap(AppSpacing.lg),
              AppButton.primary(
                label: l10n.authResetPasswordSubmit,
                onPressed: _submit,
                isLoading: isLoading,
                isExpanded: true,
              ),
              const Gap(AppSpacing.sm),
              AppButton.text(
                label: l10n.authResetPasswordCancel,
                onPressed: isLoading
                    ? null
                    : () => ref.read(resetPasswordControllerProvider.notifier).cancel(),
                isExpanded: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
