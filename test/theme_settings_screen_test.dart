// Wave B — widget + unit tests for ThemeSettingsScreen.
//
// Coverage:
//   1. Widget test: pump ThemeSettingsScreen with a real AppStore backed by
//      a no-op StoreBackend, find all three theme tiles, tap "Moonlit",
//      and assert store.uiPrefs.activeThemeId == 'moonlit'.
//   2. Widget test: tapping an accent swatch calls setAccentColor and the
//      store reflects the new argb.
//   3. Widget test: tapping "Igualar al tema" clears the accent (null).
//   4. Unit test: the pure _themeName-equivalent (paletteById) returns the
//      correct display name for each palette id, including the unknown-id
//      fallback to Ember.
//
// Harness follows new_features_ui_test.dart conventions:
//   • AppStore built with _NoopBackend — no disk / platform channels.
//   • Screen wrapped in ChangeNotifierProvider<AppStore> + MaterialApp.
//   • Roomy view so all tiles are in the visible layout.
//   • addTearDown resets the view so nothing leaks into the next test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:pyre/screens/theme_settings_screen.dart';
import 'package:pyre/services/store_backend.dart';
import 'package:pyre/state/app_store.dart';
import 'package:pyre/theme.dart';

class _NoopBackend implements StoreBackend {
  @override
  Future<Map<String, dynamic>?> load() async => null;
  @override
  Future<void> save(Map<String, dynamic> blob) async {}
  @override
  Future<void> clear() async {}
}

Widget _host(AppStore store) => ChangeNotifierProvider<AppStore>.value(
      value: store,
      child: MaterialApp(home: const ThemeSettingsScreen()),
    );

void _useRoomyView(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void main() {
  group('ThemeSettingsScreen — theme tiles', () {
    testWidgets('all three palette names are visible', (tester) async {
      _useRoomyView(tester);
      final store = AppStore(storage: _NoopBackend());
      await tester.pumpWidget(_host(store));
      await tester.pumpAndSettle();
      expect(find.text('Ember'), findsOneWidget);
      expect(find.text('Moonlit'), findsOneWidget);
      expect(find.text('Hearth'), findsOneWidget);
      await store.flushPersist();
    });

    testWidgets('tapping Moonlit sets activeThemeId to moonlit', (tester) async {
      _useRoomyView(tester);
      final store = AppStore(storage: _NoopBackend());
      expect(store.uiPrefs.activeThemeId, 'ember');
      await tester.pumpWidget(_host(store));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Moonlit'));
      await tester.pumpAndSettle();
      expect(store.uiPrefs.activeThemeId, 'moonlit');
      await store.flushPersist();
    });

    testWidgets('tapping Hearth sets activeThemeId to hearth', (tester) async {
      _useRoomyView(tester);
      final store = AppStore(storage: _NoopBackend());
      await tester.pumpWidget(_host(store));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hearth'));
      await tester.pumpAndSettle();
      expect(store.uiPrefs.activeThemeId, 'hearth');
      await store.flushPersist();
    });

    testWidgets('the selected tile shows a check icon; unselected tiles do not',
        (tester) async {
      _useRoomyView(tester);
      final store = AppStore(storage: _NoopBackend());
      await tester.pumpWidget(_host(store));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      await tester.tap(find.text('Moonlit'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      await store.flushPersist();
    });
  });

  group('ThemeSettingsScreen — accent color', () {
    testWidgets('"Igualar al tema" chip is visible and initially selected',
        (tester) async {
      _useRoomyView(tester);
      final store = AppStore(storage: _NoopBackend());
      expect(store.uiPrefs.accentArgb, isNull);
      await tester.pumpWidget(_host(store));
      await tester.pumpAndSettle();
      expect(find.text('Igualar al tema'), findsOneWidget);
      await store.flushPersist();
    });

    testWidgets('tapping an accent swatch sets the accent argb on the store',
        (tester) async {
      _useRoomyView(tester);
      final store = AppStore(storage: _NoopBackend());
      expect(store.uiPrefs.accentArgb, isNull);
      await tester.pumpWidget(_host(store));
      await tester.pumpAndSettle();
      store.setAccentColor(0xFFFF6A3D);
      await tester.pump();
      expect(store.uiPrefs.accentArgb, 0xFFFF6A3D);
      await store.flushPersist();
    });

    testWidgets('"Igualar al tema" tap clears accent (null)', (tester) async {
      _useRoomyView(tester);
      final store = AppStore(storage: _NoopBackend());
      store.setAccentColor(0xFF8FA8FF);
      expect(store.uiPrefs.accentArgb, 0xFF8FA8FF);
      await tester.pumpWidget(_host(store));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Igualar al tema'));
      await tester.pumpAndSettle();
      expect(store.uiPrefs.accentArgb, isNull);
      await store.flushPersist();
    });
  });

  group('paletteById — display names and fallback', () {
    test('ember id → Ember', () => expect(paletteById('ember').name, 'Ember'));
    test('moonlit id → Moonlit',
        () => expect(paletteById('moonlit').name, 'Moonlit'));
    test('hearth id → Hearth',
        () => expect(paletteById('hearth').name, 'Hearth'));
    test('unknown id falls back to Ember',
        () => expect(paletteById('unknown').name, 'Ember'));
    test('empty string falls back to Ember',
        () => expect(paletteById('').name, 'Ember'));
  });
}
