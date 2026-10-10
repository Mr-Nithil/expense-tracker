import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/router/routes.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/validators.dart';
import 'package:expense_tracker/core/widgets/app_button.dart';
import 'package:expense_tracker/core/widgets/app_scaffold.dart';
import 'package:expense_tracker/core/widgets/app_text_field.dart';
import 'package:expense_tracker/features/auth/domain/entities/sign_up_outcome.dart';
import 'package:expense_tracker/features/auth/presentation/providers/sign_up_controller.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/auth_form_layout.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/password_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// Account creation: optional name, email, password + confirmation.
///
/// When a session is created the router redirect leaves this screen. When email confirmation is
/// required, it shows a message and returns to login.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref
        .read(signUpControllerProvider.notifier)
        .signUp(email: _email.text, password: _password.text, displayName: _name.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    ref.listen(signUpControllerProvider, (previous, next) {
      switch (next) {
        case AsyncError(:final error):
          context.showSnack(errorMessageOf(error, context));
        case AsyncData(value: SignUpOutcome.emailConfirmationRequired):
          context.showSnack(l10n.authSignUpConfirmEmailSent);
          context.goNamed(Routes.login);
        case AsyncData(value: SignUpOutcome.signedIn):
          // Lets password managers offer to save the new credentials.
          TextInput.finishAutofillContext();
        default:
          break;
      }
    });
    final isLoading = ref.watch(signUpControllerProvider).isLoading;

    return AppScaffold(
      title: l10n.authSignUpTitle,
      body: AutofillGroup(
        child: Form(
          key: _formKey,
          child: AuthFormLayout(
            children: [
              Text(
                l10n.authSignUpSubtitle,
                style: context.text.bodyLarge?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const Gap(AppSpacing.lg),
              AppTextField(
                label: l10n.authDisplayNameLabel,
                controller: _name,
                prefixIcon: Icons.person_outline,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                inputFormatters: [
                  LengthLimitingTextInputFormatter(Validators.maxDisplayNameLength),
                ],
                enabled: !isLoading,
              ),
              const Gap(AppSpacing.md),
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
                label: l10n.authSignUpSubmit,
                onPressed: _submit,
                isLoading: isLoading,
                isExpanded: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
