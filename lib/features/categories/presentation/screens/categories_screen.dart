import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/widgets/app_scaffold.dart';
import 'package:expense_tracker/core/widgets/async_value_view.dart';
import 'package:expense_tracker/core/widgets/empty_state.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/category_type_l10n.dart';
import 'package:expense_tracker/features/categories/presentation/providers/categories_providers.dart';
import 'package:expense_tracker/features/categories/presentation/widgets/category_form_sheet.dart';
import 'package:expense_tracker/features/categories/presentation/widgets/category_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The user's categories, one tab per type. The FAB adds one of the current tab's type; tapping
/// a row edits it. Archive (M2.5) hooks in here.
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: CategoryType.values.length,
      // Builder: the FAB needs a context below the tab controller.
      child: Builder(
        builder: (context) => AppScaffold(
          title: context.l10n.categoriesTitle,
          bottom: TabBar(
            tabs: [for (final type in CategoryType.values) Tab(text: type.label(context))],
          ),
          floatingActionButton: FloatingActionButton(
            tooltip: context.l10n.categoriesAdd,
            onPressed: () => CategoryFormSheet.show(
              context,
              initialType: CategoryType.values[DefaultTabController.of(context).index],
            ),
            child: const Icon(Icons.add),
          ),
          body: TabBarView(
            children: [for (final type in CategoryType.values) _CategoryList(type: type)],
          ),
        ),
      ),
    );
  }
}

class _CategoryList extends ConsumerWidget {
  const _CategoryList({required this.type});

  final CategoryType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return AsyncValueView(
      value: ref.watch(categoriesProvider(type)),
      onRetry: () => ref.invalidate(categoriesProvider(type)),
      data: (categories) => categories.isEmpty
          ? EmptyState(
              icon: Icons.category_outlined,
              title: l10n.categoriesEmptyTitle,
              message: l10n.categoriesEmptyMessage,
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              itemCount: categories.length,
              itemBuilder: (context, index) => CategoryTile(
                category: categories[index],
                onTap: () => CategoryFormSheet.show(context, category: categories[index]),
              ),
            ),
    );
  }
}
