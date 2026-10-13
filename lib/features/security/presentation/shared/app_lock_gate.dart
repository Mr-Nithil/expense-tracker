import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/features/security/presentation/providers/app_lock_controller.dart';
import 'package:expense_tracker/features/security/presentation/screens/lock_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Covers the whole app with the [LockScreen] while it is locked (M7.5). Wraps the router's
/// output in `App`'s `builder`.
///
/// The app underneath stays mounted (tabs, scroll positions and open sheets survive) but gets no
/// taps, focus, animations or screen-reader access. While the settings load it shows an empty
/// cover, so nothing flashes. Android back never reaches the hidden pages: it closes the lock
/// screen's own sheet, or leaves the app.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();

  bool get _covered =>
      ref.read(sessionProvider) != null &&
      ref.read(appLockControllerProvider) != AppLockStatus.unlocked;

  @override
  void initState() {
    super.initState();
    // Registered before the router's back button dispatcher, so it is asked first.
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async {
    if (!_covered) return false;
    if (await _navigatorKey.currentState?.maybePop() ?? false) return true;
    await SystemNavigator.pop();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = ref.watch(sessionProvider) != null;
    final status = ref.watch(appLockControllerProvider);
    final covered = signedIn && status != AppLockStatus.unlocked;

    // Always the same shape, so locking never rebuilds (and resets) the app underneath.
    return Stack(
      fit: StackFit.expand,
      children: [
        ExcludeSemantics(
          excluding: covered,
          child: ExcludeFocus(
            excluding: covered,
            child: TickerMode(enabled: !covered, child: widget.child),
          ),
        ),
        if (!covered)
          const SizedBox.shrink()
        else if (status == AppLockStatus.checking)
          ColoredBox(color: Theme.of(context).colorScheme.surface)
        else
          // Its own navigator, so the lock screen's sheets and dialogs work above the app.
          HeroControllerScope.none(
            child: Navigator(
              key: _navigatorKey,
              onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => const LockScreen()),
            ),
          ),
      ],
    );
  }
}
