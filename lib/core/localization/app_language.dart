/// Persisted language preference for Brainiacs.
enum AppLanguage {
  system,
  en,
  tr;

  String get storageValue => name;

  /// Invalid or missing values resolve to [system].
  static AppLanguage fromStorage(Object? raw) {
    if (raw is! String || raw.isEmpty) {
      return AppLanguage.system;
    }
    for (final value in AppLanguage.values) {
      if (value.storageValue == raw) {
        return value;
      }
    }
    return AppLanguage.system;
  }
}
