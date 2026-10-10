import 'package:uuid/uuid.dart';

/// Generates record IDs on the device, so records can be created offline.
abstract final class IdGenerator {
  static const _uuid = Uuid();

  /// Namespace for [deterministic] IDs. Never change it: existing IDs depend on it.
  static const _namespace = '0f6b1c2e-5d3a-4e8f-9b7a-2c4d6e8f0a1b';

  /// A random UUID v4. Use for every new record.
  static String newId() => _uuid.v4();

  /// A UUID v5 derived from [parts], identical on every device.
  ///
  /// Use for records that must be unique per key across devices (e.g. one budget per
  /// user/month/category), so offline creation on two devices converges on one row.
  static String deterministic(List<String> parts) => _uuid.v5(_namespace, parts.join('|'));
}
