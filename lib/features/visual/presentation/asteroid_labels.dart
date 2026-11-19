import '../../../l10n/generated/app_localizations.dart';
import '../domain/asteroid.dart';

/// Resolves the on-sprite label for an [Asteroid] in the active locale.
String asteroidDisplayText(Asteroid asteroid, AppLocalizations l10n) {
  final letter = asteroid.letterLabel;
  if (letter != null) {
    return letter;
  }
  if (!asteroid.showsNumberWord) {
    return '${asteroid.value}';
  }
  final word = asteroidNumberWord(asteroid.value, l10n);
  if (word.length > AsteroidField.maxNumberWordLength) {
    return '${asteroid.value}';
  }
  return word;
}

bool asteroidNeedsOrientationHint(String displayText) {
  const ambiguous = {'6', '9', 'Z', 'N', 'C', 'U'};
  return ambiguous.contains(displayText);
}

String asteroidNumberWord(int value, AppLocalizations l10n) {
  return switch (value) {
    1 => l10n.asteroidOne,
    2 => l10n.asteroidTwo,
    3 => l10n.asteroidThree,
    4 => l10n.asteroidFour,
    5 => l10n.asteroidFive,
    6 => l10n.asteroidSix,
    7 => l10n.asteroidSeven,
    8 => l10n.asteroidEight,
    9 => l10n.asteroidNine,
    10 => l10n.asteroidTen,
    11 => l10n.asteroidEleven,
    12 => l10n.asteroidTwelve,
    13 => l10n.asteroidThirteen,
    14 => l10n.asteroidFourteen,
    15 => l10n.asteroidFifteen,
    16 => l10n.asteroidSixteen,
    17 => l10n.asteroidSeventeen,
    18 => l10n.asteroidEighteen,
    19 => l10n.asteroidNineteen,
    20 => l10n.asteroidTwenty,
    _ => '$value',
  };
}
