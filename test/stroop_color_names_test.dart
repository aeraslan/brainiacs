import 'package:brainiacs_flutter/features/visual/domain/stroop_palette.dart';
import 'package:brainiacs_flutter/features/visual/presentation/stroop_color_names.dart';
import 'package:brainiacs_flutter/l10n/generated/app_localizations_en.dart';
import 'package:brainiacs_flutter/l10n/generated/app_localizations_tr.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all Stroop ids resolve in English and Turkish', () {
    final en = AppLocalizationsEn();
    final tr = AppLocalizationsTr();

    for (final color in StroopPalette.all) {
      final enName = stroopColorName(color.id, en);
      final trName = stroopColorName(color.id, tr);
      expect(enName, isNotEmpty);
      expect(trName, isNotEmpty);
      expect(enName, isNot(equals(trName)));
    }

    expect(stroopColorName('red', tr), 'Kırmızı');
    expect(stroopColorName('blue', tr), 'Mavi');
    expect(stroopColorName('green', tr), 'Yeşil');
    expect(stroopColorName('yellow', tr), 'Sarı');
    expect(stroopColorName('pink', tr), 'Pembe');
    expect(stroopColorName('purple', tr), 'Mor');
  });
}
