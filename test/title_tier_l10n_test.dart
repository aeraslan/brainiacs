import 'package:brainiacs_flutter/core/rank/title_tier.dart';
import 'package:brainiacs_flutter/core/rank/title_tier_l10n.dart';
import 'package:brainiacs_flutter/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppLocalizations en;
  late AppLocalizations tr;

  setUpAll(() async {
    en = await AppLocalizations.delegate.load(const Locale('en'));
    tr = await AppLocalizations.delegate.load(const Locale('tr'));
  });

  test('every tier has unique non-empty English name and description', () {
    final names = <String>{};
    final descriptions = <String>{};
    for (final tier in TitleTier.values) {
      final name = tier.localizedName(en);
      final description = tier.localizedDescription(en);
      expect(name, isNotEmpty);
      expect(description, isNotEmpty);
      expect(names.add(name), isTrue, reason: 'duplicate EN name: $name');
      expect(
        descriptions.add(description),
        isTrue,
        reason: 'duplicate EN description: $description',
      );
    }
    expect(names, hasLength(8));
    expect(descriptions, hasLength(8));
  });

  test('every tier has unique non-empty Turkish name and description', () {
    final names = <String>{};
    final descriptions = <String>{};
    for (final tier in TitleTier.values) {
      final name = tier.localizedName(tr);
      final description = tier.localizedDescription(tr);
      expect(name, isNotEmpty);
      expect(description, isNotEmpty);
      expect(names.add(name), isTrue, reason: 'duplicate TR name: $name');
      expect(
        descriptions.add(description),
        isTrue,
        reason: 'duplicate TR description: $description',
      );
    }
    expect(names, hasLength(8));
    expect(descriptions, hasLength(8));
  });

  test('spot-checks exact approved English strings', () {
    expect(TitleTier.dormantMind.localizedName(en), 'Single Brain Cell');
    expect(
      TitleTier.dormantMind.localizedDescription(en),
      'One brain cell. Zero backup plans.',
    );
    expect(TitleTier.quantumBrain.localizedName(en), 'Galaxy Brain');
    expect(TitleTier.brainiac.localizedName(en), 'Certified Brainiac');
    expect(
      TitleTier.brainiac.localizedDescription(en),
      "AI asks YOU the questions now. We're slightly concerned.",
    );
  });

  test('spot-checks exact approved Turkish strings', () {
    expect(TitleTier.dormantMind.localizedName(tr), 'Tek Hücreli Yaşam Formu');
    expect(TitleTier.analyticMind.localizedName(tr), 'Annesinin Dahisi');
    expect(
      TitleTier.analyticMind.localizedDescription(tr),
      'Aile WhatsApp grubunun bilim danışmanı.',
    );
    expect(TitleTier.brainiac.localizedName(tr), 'Brainiac');
    expect(
      TitleTier.brainiac.localizedDescription(tr),
      'Yapay zekâ sana soru soruyor. Biz de biraz korkuyoruz.',
    );
  });

  test('language switch changes display text but not tier identity', () {
    for (final tier in TitleTier.values) {
      final index = tier.index;
      expect(tier.localizedName(en), isNot(equals(tier.localizedName(tr))));
      expect(tier.index, index);
      expect(TitleTier.values[index], tier);
    }
  });
}
