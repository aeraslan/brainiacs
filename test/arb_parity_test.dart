import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('English and Turkish ARB files share keys and placeholders', () {
    final enFile = File('lib/l10n/app_en.arb');
    final trFile = File('lib/l10n/app_tr.arb');
    expect(enFile.existsSync(), isTrue);
    expect(trFile.existsSync(), isTrue);

    final en = jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;
    final tr = jsonDecode(trFile.readAsStringSync()) as Map<String, dynamic>;

    final enKeys = en.keys.where((k) => !k.startsWith('@')).toSet();
    final trKeys = tr.keys.where((k) => !k.startsWith('@')).toSet();

    expect(trKeys, enKeys);

    for (final key in enKeys) {
      if (key == '@@locale') {
        continue;
      }
      final enMeta = en['@$key'];
      final trMeta = tr['@$key'];
      if (enMeta is Map || trMeta is Map) {
        final enPlaceholders = enMeta is Map
            ? (enMeta['placeholders'] as Map?)?.keys.toSet() ?? <Object?>{}
            : <Object?>{};
        final trPlaceholders = trMeta is Map
            ? (trMeta['placeholders'] as Map?)?.keys.toSet() ?? <Object?>{}
            : <Object?>{};
        expect(
          trPlaceholders,
          enPlaceholders,
          reason: 'Placeholder mismatch for $key',
        );
      }
    }
  });
}
