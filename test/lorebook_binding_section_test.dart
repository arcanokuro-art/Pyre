import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pyre/models/models.dart';
import 'package:pyre/state/app_store.dart';
import 'package:pyre/widgets/lorebook_binding_section.dart';

void main() {
  Future<void> pumpPicker(WidgetTester tester, Locale locale) async {
    final store = AppStore();
    store.lorebooks.addAll([
      Lorebook(
        id: 'one',
        name: 'Uno',
        entries: [LoreEntry(id: 'e1', keys: const [], content: '')],
      ),
      Lorebook(
        id: 'two',
        name: 'Dos',
        entries: [
          LoreEntry(id: 'e2', keys: const [], content: ''),
          LoreEntry(id: 'e3', keys: const [], content: ''),
        ],
      ),
    ]);

    await tester.pumpWidget(
      ChangeNotifierProvider<AppStore>.value(
        value: store,
        child: MaterialApp(
          locale: locale,
          supportedLocales: const [Locale('en'), Locale('es')],
          home: const Scaffold(
            body: LorebookBindingSection(
              selectedIds: [],
              onChanged: _noop,
            ),
          ),
        ),
      ),
    );

    await tester.tap(
      find.text(locale.languageCode == 'es' ? 'Añadir lorebook' : 'Add lorebook'),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('lorebook picker pluralizes entry counts in Spanish',
      (tester) async {
    await pumpPicker(tester, const Locale('es'));

    expect(find.text('Elige un lorebook'), findsOneWidget);
    expect(find.text('1 entrada'), findsOneWidget);
    expect(find.text('2 entradas'), findsOneWidget);
    expect(find.text('Pick a lorebook'), findsNothing);
  });

  testWidgets('lorebook picker pluralizes entry counts in English',
      (tester) async {
    await pumpPicker(tester, const Locale('en'));

    expect(find.text('Pick a lorebook'), findsOneWidget);
    expect(find.text('1 entry'), findsOneWidget);
    expect(find.text('2 entries'), findsOneWidget);
    expect(find.text('Elige un lorebook'), findsNothing);
  });
}

void _noop(List<String> _) {}
