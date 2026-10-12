import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations.dart';
import 'package:expense_tracker/core/l10n/l10n_lookup.dart';
import 'package:expense_tracker/core/l10n/locale_controller.dart';
import 'package:expense_tracker/core/widgets/section_header.dart';
import 'package:expense_tracker/features/profile/presentation/providers/locale_setter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Language": the app language (saved on the profile, so it follows the user to other devices)
/// or the device language. Each language is named in itself, so it can be found from any language.
class SettingsLanguageTile extends ConsumerWidget {
  const SettingsLanguageTile({super.key});

  /// `null` = the device language.
  static const _options = <Locale?>[null, ...AppLocalizations.supportedLocales];

  Future<void> _choose(BuildContext context, WidgetRef ref, Locale? current) async {
    final l10n = context.l10n;
    final device = View.of(context).platformDispatcher.locale;
    final deviceLanguage = appLocalizationsFor(null, device: device);

    // A record, so choosing the device language (null) differs from dismissing the dialog.
    final choice = await showDialog<(Locale?,)>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.settingsLanguageChoose),
        children: [
          for (final option in _options)
            ListTile(
              title: _LanguageName(option),
              subtitle: option == null
                  ? Text(
                      deviceLanguage.languageNativeName,
                      locale: Locale(deviceLanguage.localeName),
                    )
                  : null,
              trailing: option == current ? const Icon(Icons.check) : null,
              selected: option == current,
              onTap: () => Navigator.of(context).pop((option,)),
            ),
        ],
      ),
    );
    if (choice == null || choice.$1 == current || !context.mounted) return;

    final result = await ref.read(localeSetterProvider.notifier).setLocale(choice.$1);
    if (!context.mounted) return;
    if (result case Failure(:final failure)) context.showSnack(failure.toL10n(context));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current = ref.watch(localeControllerProvider).value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.settingsLanguageLabel),
        ListTile(
          leading: const Icon(Icons.translate),
          title: _LanguageName(current),
          trailing: const Icon(Icons.arrow_drop_down),
          onTap: () => _choose(context, ref, current),
        ),
      ],
    );
  }
}

/// [locale]'s name written in that language, or "Device language" (in the app's language).
class _LanguageName extends StatelessWidget {
  const _LanguageName(this.locale);

  final Locale? locale;

  @override
  Widget build(BuildContext context) => switch (locale) {
    null => Text(context.l10n.settingsLanguageDevice),
    final locale => Text(lookupAppLocalizations(locale).languageNativeName, locale: locale),
  };
}
