import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clock.g.dart';

/// Source of the current time. Inject it instead of calling `DateTime.now()` so tests can
/// control time.
abstract interface class Clock {
  DateTime now();
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

/// A clock frozen at [current]. Call [advance] to move it forward. For tests.
class FixedClock implements Clock {
  FixedClock(this.current);

  DateTime current;

  @override
  DateTime now() => current;

  void advance(Duration duration) => current = current.add(duration);
}

@Riverpod(keepAlive: true)
Clock clock(Ref ref) => const SystemClock();
