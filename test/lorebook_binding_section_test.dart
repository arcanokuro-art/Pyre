import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pyre/l10n/app_strings.dart';
import 'package:pyre/models/models.dart';
import 'package:pyre/state/app_store.dart';
import 'package:pyre/widgets/lorebook_binding_section.dart';

void main() {
  testWidgets('lorebook picker pluralizes entry counts in Spanish',
      (tester) async {
    final store = AppStore();
    store.lorebooks.addAll([
      Lorebook(id: 'one', name: 'Uno', entries: [LorebookEntry()]),
      Lorebook(
        id: 'two',
        name: 'Dos',
        entries: [LorebookEntry(), LorebookEntry()],
      ),
    ]);

    await tester.pumpWidget(
      ChangeNotifierProvider<AppStore>.value(
        value: store,
        child: MaterialApp(
          locale: const Locale('es'),
          home: const Scaffold(
            body: LorebookBindingSection(
              selectedIds: [],
              onChanged: _noop,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Añadir lorebook'));
    await tester.pumpAndSettle();

    expect(find.textContaining('1 entrada'), findsOneWidget);
    expect(find.textContaining('2 entradas'), findsOneWidget);
  });
}

void _noop(List<String> _) {}
