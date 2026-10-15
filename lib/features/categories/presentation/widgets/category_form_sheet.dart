import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/validators.dart';
import 'package:expense_tracker/core/widgets/app_bottom_sheet.dart';
import 'package:expense_tracker/core/widgets/app_button.dart';
import 'package:expense_tracker/core/widgets/app_text_field.dart';
import 'package:expense_tracker/core/widgets/category_icon.dart';
import 'package:expense_tracker/core/widgets/confirm_dialog.dart';
import 'package:expense_tracker/core/widgets/section_header.dart';
import 'package:expense_tracker/core/widgets/segmented_pill.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/domain/services/category_palette.dart';
import 'package:expense_tracker/features/categories/domain/services/category_validator.dart';
import 'package:expense_tracker/features/categories/presentation/category_type_l10n.dart';
import 'package:expense_tracker/features/categories/presentation/providers/category_form_controller.dart';
import 'package:expense_tracker/features/categories/presentation/shared/category_color_picker.dart';
import 'package:expense_tracker/features/categories/presentation/shared/category_icon_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Add or edit a category: name, type, icon and color. When editing, it can also archive the
/// category (with confirmation). Closes itself once saved or archived.
///
/// Errors show inside the sheet (a snackbar would sit behind it).
class CategoryFormSheet extends ConsumerStatefulWidget {
  const CategoryFormSheet({super.key, this.category, this.initialType = CategoryType.expense});

  /// The category to edit, or `null` to add one.
  final Category? category;

  /// Type of a new category (ignored when editing).
  final CategoryType initialType;

  static Future<void> show(
    BuildContext context, {
    Category? category,
    CategoryType initialType = CategoryType.expense,
  }) => AppBottomSheet.show<void>(
    context,
    title: category == null
        ? context.l10n.categoryFormNewTitle
        : context.l10n.categoryFormEditTitle,
    child: CategoryFormSheet(category: category, initialType: initialType),
  );

  @override
  ConsumerState<CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends ConsumerState<CategoryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.category?.name);
  late CategoryType _type = widget.category?.type ?? widget.initialType;
  late String _icon = widget.category?.icon ?? CategoryIcon.keys.first;
  late int _color = widget.category?.color ?? CategoryPalette.colors.first;
  String? _nameError;
  String? _formError;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    setState(() => _nameError = _formError = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref
        .read(categoryFormControllerProvider.notifier)
        .save(existing: widget.category, name: _name.text, icon: _icon, color: _color, type: _type);
  }

  Future<void> _archive(Category category) async {
    final l10n = context.l10n;
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.categoryArchiveConfirmTitle(category.name),
      message: l10n.categoryArchiveConfirmMessage,
      confirmLabel: l10n.categoryFormArchive,
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;
    setState(() => _nameError = _formError = null);
    await ref.read(categoryFormControllerProvider.notifier).archive(category);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final editing = widget.category;

    ref.listen(categoryFormControllerProvider, (previous, next) {
      switch (next) {
        case AsyncError(error: ValidationFailure(message: CategoryValidator.duplicateName)):
          setState(() => _nameError = l10n.errorCategoryNameTaken);
        case AsyncError(
          error: ValidationFailure(message: CategoryValidator.typeLockedByTransactions),
        ):
          setState(() => _formError = l10n.errorCategoryTypeLocked);
        case AsyncError(:final error):
          setState(() => _formError = errorMessageOf(error, context));
        case AsyncData() when previous?.isLoading ?? false:
          Navigator.of(context).pop();
        default:
          break;
      }
    });
    final isSaving = ref.watch(categoryFormControllerProvider).isLoading;
    final formError = _formError;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CategoryIcon(iconKey: _icon, color: _color),
              const Gap(AppSpacing.md),
              Expanded(
                child: AppTextField(
                  label: l10n.categoryFormNameLabel,
                  controller: _name,
                  errorText: _nameError,
                  enabled: !isSaving,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(CategoryValidator.maxNameLength),
                  ],
                  onChanged: (_) {
                    if (_nameError != null) setState(() => _nameError = null);
                  },
                  validator: (value) => Validators.required(value)?.toL10n(context),
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.md),
          SectionHeader(title: l10n.categoryFormTypeLabel),
          SegmentedPill<CategoryType>(
            options: [
              for (final type in CategoryType.values)
                SegmentedPillOption(value: type, label: type.label(context)),
            ],
            selected: _type,
            onChanged: isSaving ? null : (type) => setState(() => _type = type),
          ),
          const Gap(AppSpacing.md),
          SectionHeader(title: l10n.categoryFormIconLabel),
          CategoryIconPicker(
            selected: _icon,
            color: _color,
            onChanged: isSaving ? null : (icon) => setState(() => _icon = icon),
          ),
          const Gap(AppSpacing.md),
          SectionHeader(title: l10n.categoryFormColorLabel),
          CategoryColorPicker(
            selected: _color,
            onChanged: isSaving ? null : (color) => setState(() => _color = color),
          ),
          const Gap(AppSpacing.lg),
          if (formError != null) ...[
            Text(
              formError,
              style: context.text.bodyMedium?.copyWith(color: context.colorScheme.error),
            ),
            const Gap(AppSpacing.sm),
          ],
          AppButton.primary(
            label: l10n.commonSave,
            onPressed: _submit,
            isLoading: isSaving,
            isExpanded: true,
          ),
          if (editing != null) ...[
            const Gap(AppSpacing.sm),
            AppButton.text(
              label: l10n.categoryFormArchive,
              icon: Icons.archive_outlined,
              onPressed: isSaving ? null : () => _archive(editing),
              isExpanded: true,
            ),
          ],
        ],
      ),
    );
  }
}
