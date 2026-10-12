/// Hashes that are the same on every run and device (unlike `String.hashCode`), for ids that
/// must not change, e.g. notification ids derived from row ids.
abstract final class StableHash {
  /// 32-bit FNV-1a over the UTF-16 code units of [value].
  static int fnv1a(String value) {
    var hash = 0x811c9dc5;
    for (final unit in value.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0xFFFFFFFF;
    }
    return hash;
  }
}
