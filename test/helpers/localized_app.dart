import 'package:brainiacs_flutter/core/storage/local_storage_provider.dart';
import 'package:brainiacs_flutter/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

/// Test harness with gen_l10n delegates and optional locale override.
Widget localizedTestApp({
  required Widget home,
  Locale locale = const Locale('en'),
  List<Override> overrides = const [],
  Size? size,
}) {
  Widget app = ProviderScope(
    overrides: [
      localStorageProvider.overrideWithValue(LocalStorageService.memory()),
      ...overrides,
    ],
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: home,
    ),
  );

  if (size != null) {
    app = MediaQuery(
      data: MediaQueryData(size: size),
      child: app,
    );
  }
  return app;
}
