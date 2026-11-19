import 'package:brainiacs_flutter/core/audio/audio_controller_provider.dart';
import 'package:brainiacs_flutter/core/storage/local_storage_provider.dart';
import 'package:brainiacs_flutter/l10n/generated/app_localizations.dart';
import 'package:brainiacs_flutter/shared/widgets/pause_menu_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('audio switches do not dismiss pause menu or change action', (
    tester,
  ) async {
    final storage = LocalStorageService.memory();
    final container = ProviderContainer(
      overrides: [
        localStorageProvider.overrideWithValue(storage),
      ],
    );
    addTearDown(container.dispose);

    PauseMenuAction? result;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      result = await PauseMenuDialog.show(
                        context,
                        isPracticeMode: false,
                      );
                    },
                    child: const Text('Open'),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Paused'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);

    final switches = find.byType(Switch);
    expect(switches, findsNWidgets(2));

    await tester.tap(switches.first);
    await tester.pumpAndSettle();
    expect(find.text('Paused'), findsOneWidget);
    expect(result, isNull);
    expect(container.read(audioControllerProvider).bgmEnabled, isFalse);

    await tester.tap(switches.at(1));
    await tester.pumpAndSettle();
    expect(find.text('Paused'), findsOneWidget);
    expect(result, isNull);
    expect(container.read(audioControllerProvider).sfxEnabled, isFalse);

    await tester.tap(find.text('Resume'));
    await tester.pumpAndSettle();
    expect(result, PauseMenuAction.resume);
  });

  testWidgets('pause and settings share the same audio state', (tester) async {
    final storage = LocalStorageService.memory();
    final container = ProviderContainer(
      overrides: [
        localStorageProvider.overrideWithValue(storage),
      ],
    );
    addTearDown(container.dispose);

    await container.read(audioControllerProvider.notifier).setSfxEnabled(false);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      PauseMenuDialog.show(context, isPracticeMode: true);
                    },
                    child: const Text('Open'),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
    expect(switches[0].value, isTrue);
    expect(switches[1].value, isFalse);
  });
}
