import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/currencies.dart';
import 'package:expense_tracker/core/widgets/app_button.dart';
import 'package:expense_tracker/core/widgets/app_scaffold.dart';
import 'package:expense_tracker/features/profile/presentation/providers/onboarding_controller.dart';
import 'package:expense_tracker/features/profile/presentation/widgets/currency_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// First-run setup: pick the one currency used for every amount. The router's onboarding gate
/// leaves this screen once it is saved.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  String? _suggested;
  String? _selected;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The device region, not the app's UI locale (which is always English for now).
    _suggested ??= Currencies.forLocale(View.of(context).platformDispatcher.locale.toString());
    _selected ??= _suggested;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    ref.listen(onboardingControllerProvider, (_, next) {
      if (next case AsyncError(:final error)) {
        context.showSnack(errorMessageOf(error, context));
      }
    });
    final isLoading = ref.watch(onboardingControllerProvider).isLoading;

    final suggested = _suggested!;
    final selected = _selected!;
    // The suggested currency first, so the pre-selection is always visible.
    final codes = [suggested, ...Currencies.supported.where((code) => code != suggested)];

    return AppScaffold(
      title: l10n.onboardingTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Text(
              l10n.onboardingSubtitle,
              style: context.text.bodyLarge?.copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: codes.length,
              itemBuilder: (context, index) {
                final code = codes[index];
                return CurrencyTile(
                  currencyCode: code,
                  selected: code == selected,
                  suggested: code == suggested,
                  onTap: isLoading ? null : () => setState(() => _selected = code),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: AppButton.primary(
              label: l10n.onboardingContinue,
              onPressed: () => ref.read(onboardingControllerProvider.notifier).confirm(selected),
              isLoading: isLoading,
              isExpanded: true,
            ),
          ),
        ],
      ),
    );
  }
}
