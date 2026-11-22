import 'package:brainiacs_flutter/core/session/game_session_state.dart';
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

  Future<void> openPause(
    WidgetTester tester, {
    required Locale locale,
    required PauseOrigin origin,
    required int manualPauseNumber,
    required int pendingPenaltySeconds,
  }) async {
    final storage = LocalStorageService.memory();
    final container = ProviderContainer(
      overrides: [
        localStorageProvider.overrideWithValue(storage),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      PauseMenuDialog.show(
                        context,
                        isPracticeMode: false,
                        pauseOrigin: origin,
                        manualPauseNumber: manualPauseNumber,
                        pendingPenaltySeconds: pendingPenaltySeconds,
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
  }

  testWidgets('English first pause shows free message', (tester) async {
    await openPause(
      tester,
      locale: const Locale('en'),
      origin: PauseOrigin.manual,
      manualPauseNumber: 1,
      pendingPenaltySeconds: 0,
    );
    expect(find.text('First pause is free. No time penalty.'), findsOneWidget);
  });

  testWidgets('English second pause shows 3-second cost', (tester) async {
    await openPause(
      tester,
      locale: const Locale('en'),
      origin: PauseOrigin.manual,
      manualPauseNumber: 2,
      pendingPenaltySeconds: 3,
    );
    expect(
      find.text(
        'Resuming costs 3 seconds. Each additional pause costs 1 more second.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('English automatic pause shows free automatic message', (
    tester,
  ) async {
    await openPause(
      tester,
      locale: const Locale('en'),
      origin: PauseOrigin.automatic,
      manualPauseNumber: 0,
      pendingPenaltySeconds: 0,
    );
    expect(
      find.text('Game paused automatically. No time penalty.'),
      findsOneWidget,
    );
  });

  testWidgets('Turkish first pause shows free message', (tester) async {
    await openPause(
      tester,
      locale: const Locale('tr'),
      origin: PauseOrigin.manual,
      manualPauseNumber: 1,
      pendingPenaltySeconds: 0,
    );
    expect(
      find.text('İlk duraklatma ücretsiz. Süre cezası yok.'),
      findsOneWidget,
    );
  });

  testWidgets('Turkish automatic pause shows free automatic message', (
    tester,
  ) async {
    await openPause(
      tester,
      locale: const Locale('tr'),
      origin: PauseOrigin.automatic,
      manualPauseNumber: 0,
      pendingPenaltySeconds: 0,
    );
    expect(
      find.text('Oyun otomatik duraklatıldı. Süre cezası yok.'),
      findsOneWidget,
    );
  });

  testWidgets('barrier tap does not dismiss pause menu', (tester) async {
    await openPause(
      tester,
      locale: const Locale('en'),
      origin: PauseOrigin.manual,
      manualPauseNumber: 1,
      pendingPenaltySeconds: 0,
    );
    expect(find.text('Paused'), findsOneWidget);

    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
    expect(find.text('Paused'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
  });
}
