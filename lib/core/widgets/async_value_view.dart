import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/widgets/error_view.dart';
import 'package:expense_tracker/core/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Renders an [AsyncValue] with the standard [LoadingView] / [ErrorView]. Use instead of
/// repeating `.when(...)` in screens.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;

  /// Replaces the default [LoadingView] (e.g. with a skeleton).
  final Widget Function()? loading;

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: loading ?? () => const LoadingView(),
      error: (error, _) => ErrorView(message: errorMessageOf(error, context), onRetry: onRetry),
    );
  }
}
