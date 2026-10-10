import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/router/routes.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/validators.dart';
import 'package:expense_tracker/core/widgets/app_button.dart';
import 'package:expense_tracker/core/widgets/app_scaffold.dart';
import 'package:expense_tracker/core/widgets/app_text_field.dart';
import 'package:expense_tracker/core/widgets/empty_state.dart';
import 'package:expense_tracker/features/auth/presentation/providers/forgot_password_controller.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/auth_form_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// Requests a password-reset email. Setting the new password from the link is M1.13.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail});

  /// Pre-fills the field, e.g. with what was typed on the login screen.
  final String? initialEmail;

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.initialEmail);

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref.read(forgotPasswordControllerProvider.notifier).sendReset(email: _email.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    ref.listen(forgotPasswordControllerProvider, (_, next) {
      if (next case AsyncError(:final error)) {
        context.showSnack(errorMessageOf(error, context));
      }
    });
    final state = ref.watch(forgotPasswordControllerProvider);

    return AppScaffold(
      title: l10n.authForgotPasswordTitle,
      body: switch (state) {
        AsyncData(value: final sentTo?) => EmptyState(
          icon: Icons.mark_email_read_outlined,
          title: l10n.authForgotPasswordSentTitle,
          message: l10n.authForgotPasswordSentMessage(sentTo),
          actionLabel: l10n.authForgotPasswordBackToLogin,
          onAction: () => context.goNamed(Routes.login),
        ),
        _ => Form(
          key: _formKey,
          child: AuthFormLayout(
            children: [
              Text(
                l10n.authForgotPasswordSubtitle,
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
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.email],
                enabled: !state.isLoading,
                onSubmitted: (_) => _submit(),
                validator: (value) => Validators.email(value)?.toL10n(context),
              ),
              const Gap(AppSpacing.lg),
              AppButton.primary(
                label: l10n.authForgotPasswordSubmit,
                onPressed: _submit,
                isLoading: state.isLoading,
                isExpanded: true,
              ),
            ],
          ),
        ),
      },
    );
  }
}
