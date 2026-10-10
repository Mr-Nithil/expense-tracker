import 'package:expense_tracker/core/widgets/loading_view.dart';
import 'package:flutter/material.dart';

/// Shown while the session is restored. Built out in M1.3.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: LoadingView());
  }
}
