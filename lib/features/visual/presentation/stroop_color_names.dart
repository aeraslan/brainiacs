import '../../../l10n/generated/app_localizations.dart';

/// Resolves a Stroop color [id] to a localized display name.
String stroopColorName(String id, AppLocalizations l10n) {
  return switch (id) {
    'red' => l10n.colorClashRed,
    'blue' => l10n.colorClashBlue,
    'green' => l10n.colorClashGreen,
    'yellow' => l10n.colorClashYellow,
    'pink' => l10n.colorClashPink,
    'purple' => l10n.colorClashPurple,
    _ => l10n.colorClashRed,
  };
}
