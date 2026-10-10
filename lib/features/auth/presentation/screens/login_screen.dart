import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/router/routes.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/validators.dart';
import 'package:expense_tracker/core/widgets/app_button.dart';
import 'package:expense_tracker/core/widgets/app_scaffold.dart';
import 'package:expense_tracker/core/widgets/app_text_field.dart';
import 'package:expense_tracker/features/auth/presentation/providers/login_controller.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/auth_form_layout.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/password_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// Email + password sign-in. On success the router redirect leaves this screen.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref.read(loginControllerProvider.notifier).signIn(email: _email.text, password: _password.text);
  }

  Future<void> _resendConfirmation() async {
    final result = await ref.read(loginControllerProvider.notifier).resendConfirmation(_email.text);
    if (!mounted) return;
    context.showSnack(
      result.isSuccess
          ? context.l10n.authConfirmationResent
          : errorMessageOf(result.failureOrNull!, context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    ref.listen(loginControllerProvider, (previous, next) {
      switch (next) {
        case AsyncError(
          error: AuthFailure(reason: AuthFailureReason.emailNotConfirmed) && final error,
        ):
          context.showSnack(
            error.toL10n(context),
            actionLabel: l10n.authResendConfirmation,
            onAction: _resendConfirmation,
          );
        case AsyncError(:final error):
          context.showSnack(errorMessageOf(error, context));
        case AsyncData() when previous?.isLoading ?? false:
          // Lets password managers offer to save the credentials.
          TextInput.finishAutofillContext();
        default:
          break;
      }
    });
    final isLoading = ref.watch(loginControllerProvider).isLoading;

    return AppScaffold(
      title: l10n.authLoginTitle,
      body: AutofillGroup(
        child: Form(
          key: _formKey,
          child: AuthFormLayout(
            children: [
              Text(
                l10n.authLoginSubtitle,
                style: context.text.bodyLarge?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const Gap(AppSpacing.lg),
              AppTextField(
                label: l10n.authEmailLabel,
                controller: _email,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                enabled: !isLoading,
                validator: (value) => Validators.email(value)?.toL10n(context),
              ),
              const Gap(AppSpacing.md),
              PasswordField(
                label: l10n.authPasswordLabel,
                controller: _password,
                textInputAction: TextInputAction.done,
                enabled: !isLoading,
                onSubmitted: (_) => _submit(),
                validator: (value) => Validators.required(value)?.toL10n(context),
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: AppButton.text(
                  label: l10n.authLoginForgotPassword,
                  onPressed: isLoading
                      ? null
                      : () => context.pushNamed(Routes.forgotPassword, extra: _email.text.trim()),
                ),
              ),
              const Gap(AppSpacing.md),
              AppButton.primary(
                label: l10n.authLoginSubmit,
                onPressed: _submit,
                isLoading: isLoading,
                isExpanded: true,
              ),
              const Gap(AppSpacing.sm),
              AppButton.text(
                label: l10n.authLoginGoToSignUp,
                onPressed: isLoading ? null : () => context.pushNamed(Routes.signUp),
                isExpanded: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
