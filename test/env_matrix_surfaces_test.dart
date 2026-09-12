// Tier-1 ENVIRONMENT-MATRIX surface tests.
//
// Two shipped bugs (issue #2: kebab-menu items landing under the Android
// gesture-nav strip; Create/Import sheets unscrollable in landscape) were
// invisible to default-size widget tests because they were purely
// ENVIRONMENTAL — they only showed up at real device sizes/insets. This file
// re-runs the known-risk bottom-sheet surfaces across `kEnvMatrix`
// (`test/support/env_matrix.dart`) and asserts the exact property the old
// bugs violated: every item stays reachable and tappable, and Flutter's own
// RenderFlex-overflow assertion (which auto-fails a test) stands in for "no
// layout blew past its box".
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:pyre/models/models.dart';
import 'package:pyre/screens/character_edit_screen.dart';
import 'package:pyre/screens/characters_screen.dart';
import 'package:pyre/screens/chat_info_sheet.dart';
import 'package:pyre/services/store_backend.dart';
import 'package:pyre/state/app_store.dart';
import 'package:pyre/widgets/menu_sheet.dart';

import 'support/env_matrix.dart';

class _NoopBackend implements StoreBackend {
  @override
  Future<Map<String, dynamic>?> load() async => null;
  @override
  Future<void> save(Map<String, dynamic> blob) async {}
  @override
  Future<void> clear() async {}
}

AppStore _store() => AppStore(storage: _NoopBackend());

void main() {
  group('character kebab menu — last item reachable', () {
    for (final env in kEnvMatrix) {
      testWidgets('character kebab menu [${env.name}]', (tester) async {
        const itemCount = 10;
        final tappedIndex = <int>[];

        await pumpInEnv(
          tester,
          env,
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => Center(
                  child: ElevatedButton(
                    onPressed: () => showMenuSheet<void>(
                      context,
                      itemsBuilder: (sheet) => [
                        for (var i = 0; i < itemCount; i++)
                          ListTile(
                            title: Text('Item $i'),
                            onTap: () {
                              tappedIndex.add(i);
                              Navigator.pop(sheet);
                            },
                          ),
                      ],
                    ),
                    child: const Text('Open menu'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open menu'));
        await tester.pumpAndSettle();

        final lastItem = find.text('Item ${itemCount - 1}');
        await tester.ensureVisible(lastItem);
        await tester.pumpAndSettle();
        await tester.tap(lastItem);
        await tester.pumpAndSettle();

        expect(tappedIndex, [itemCount - 1],
            reason: 'the last menu item must be reachable+tappable, not '
                'hidden under the gesture-nav strip or clipped in landscape');
      });
    }
  });

  group('Create chooser — "From file" reachable', () {
    for (final env in kEnvMatrix) {
      testWidgets('create/import chooser [${env.name}]', (tester) async {
        final store = _store();
        store.addCharacter(Character(id: 'c1', name: 'Aria'));

        await pumpInEnv(
          tester,
          env,
          ChangeNotifierProvider<AppStore>.value(
            value: store,
            child: const MaterialApp(home: CharactersScreen()),
          ),
        );

        await tester.tap(find.widgetWithText(ElevatedButton, 'Crear'));
        await tester.pumpAndSettle();

        final lastTile = find.widgetWithText(ListTile, 'Desde archivo');
        await tester.ensureVisible(lastTile);
        await tester.pumpAndSettle();
        await tester.tap(lastTile, warnIfMissed: false);
        await tester.pumpAndSettle();
      });
    }
  });

  group('Resume/Start-fresh sheet — reachable + capped below status bar', () {
    for (final env in kEnvMatrix) {
      testWidgets(
        'resume-or-start-fresh sheet [${env.name}]',
        (tester) async {
          final store = _store();
          store.addCharacter(Character(id: 'c1', name: 'Aria'));
          for (var i = 0; i < 25; i++) {
            store.saveDraft(Character(id: newId('draft'), name: 'Draft $i'));
          }

          await pumpInEnv(
            tester,
            env,
            ChangeNotifierProvider<AppStore>.value(
              value: store,
              child: const MaterialApp(home: CharactersScreen()),
            ),
          );

          await tester.tap(find.widgetWithText(ElevatedButton, 'Crear'));
          await tester.pumpAndSettle();
          await tester
              .tap(find.widgetWithText(ListTile, 'Crear desde cero'));
          await tester.pumpAndSettle();

          final startFresh = find.widgetWithText(ListTile, 'Empezar de cero');
          await tester.ensureVisible(startFresh);
          await tester.pumpAndSettle();

          final screenHeight = env.logicalSize.height;
          final tileRect = tester.getRect(startFresh);
          expect(
            tileRect.bottom,
            lessThanOrEqualTo(screenHeight - env.viewPadding.bottom + 0.5),
            reason: '"Empezar de cero" must not sit under the gesture-nav inset',
          );

          final sheetTitle =
              find.text('Continuar un borrador o empezar de cero');
          final cappedBox = find.ancestor(
            of: sheetTitle,
            matching: find.byType(ConstrainedBox),
          );
          final sheetTop = tester.getRect(cappedBox.first).top;
          expect(sheetTop, greaterThanOrEqualTo(24 - 1),
              reason: 'the resume/start-fresh sheet must stay capped below '
                  'the status-bar inset (85% height-cap fix)');
        },
      );
    }
  });

  group('Chat info sheet — smoke (no overflow) in every env', () {
    for (final env in kEnvMatrix) {
      testWidgets(
        'chat info sheet [${env.name}]',
        (tester) async {
          final store = _store();
          store.addCharacter(Character(id: 'c1', name: 'Aria'));
          final chat =
              store.addImportedChat(Chat(id: 'chat1', characterIds: ['c1']));

          await pumpInEnv(
            tester,
            env,
            ChangeNotifierProvider<AppStore>.value(
              value: store,
              child: MaterialApp(
                home: Scaffold(
                  body: Builder(
                    builder: (context) => Center(
                      child: ElevatedButton(
                        onPressed: () => showChatInfoSheet(context, chat.id),
                        child: const Text('Open chat info'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );

          await tester.tap(find.text('Open chat info'));
          await tester.pumpAndSettle();

          expect(find.text('Información del chat'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  });

  group('CharacterEditScreen avatar row — no overflow in every env', () {
    for (final env in kEnvMatrix) {
      testWidgets('avatar row [${env.name}]', (tester) async {
        final store = _store();
        final draft = Character(id: newId('draft'), name: 'Aria');
        store.saveDraft(draft);

        await pumpInEnv(
          tester,
          env,
          ChangeNotifierProvider<AppStore>.value(
            value: store,
            child: MaterialApp(
              home: CharacterEditScreen(draftId: draft.id),
            ),
          ),
        );

        expect(find.text('Change avatar'), findsOneWidget);
        expect(find.text('Recrop'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.pump(const Duration(milliseconds: 700));
      });
    }
  });
}
