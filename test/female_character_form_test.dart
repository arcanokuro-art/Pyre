import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyre/services/female_character_profile.dart';
import 'package:pyre/widgets/female_character_form.dart';

void main() {
  testWidgets(
    'female form fits a 360px phone and preserves entered values on rebuild',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final profile = newFemaleProfile();
      var changes = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FemaleCharacterForm(
                profile: profile,
                characters: const {'other': 'Akemi'},
                personas: const {'user': 'Kuro'},
                onChanged: () => changes++,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.enterText(
        find.byKey(const ValueKey('profile:identity.nombre')),
        'Lilian',
      );
      expect(profile['fields']['identity.nombre'], 'Lilian');
      expect(profile['edited'], true);
      expect(changes, greaterThan(0));
      await tester.tap(find.text('Rápida'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('profile:identity.nombre')),
        findsOneWidget,
      );
      expect(profile['fields']['identity.nombre'], 'Lilian');
      expect(find.byKey(const PageStorageKey('female:apariencia')), findsOneWidget);
      expect(find.byKey(const PageStorageKey('female:sexualidad')), findsOneWidget);
      expect(find.byKey(const PageStorageKey('female:relchars')), findsNothing);
      expect(find.byKey(const ValueKey('profile:profile.especie')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('all detailed sections survive scrolling and parent rebuilds', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final profile = newFemaleProfile();
    late StateSetter rebuild;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: StatefulBuilder(
      builder: (context, setState) {
        rebuild = setState;
        return ListView(children: [
          FemaleCharacterForm(profile: profile,
            characters: const {'other': 'Akemi'}, personas: const {'user': 'Kuro'},
            onChanged: () => setState(() {})),
        ]);
      },
    ))));
    await tester.pumpAndSettle();
    for (final id in ['apariencia', 'vestimenta-inicial', 'personalidad', 'contexto', 'sexualidad', 'reluser', 'relchars', 'mensajes', 'expresion', 'bot']) {
      final section = find.byKey(PageStorageKey('female:$id'));
      await tester.ensureVisible(section);
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(of: section, matching: find.byType(ListTile)).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Opening $id');
      rebuild(() {});
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Rebuilding $id');
      await tester.tap(find.descendant(of: section, matching: find.byType(ListTile)).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Closing $id');
    }
  });
  testWidgets('male detailed sections survive scrolling and parent rebuilds', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final profile = newMaleProfile();
    late StateSetter rebuild;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: StatefulBuilder(
      builder: (context, setState) {
        rebuild = setState;
        return ListView(children: [
          FemaleCharacterForm(profile: profile,
            characters: const {'other': 'Akemi'}, personas: const {'user': 'Kuro'},
            onChanged: () => setState(() {})),
        ]);
      },
    ))));
    await tester.pumpAndSettle();
    for (final id in ['apariencia', 'vestimenta-inicial', 'personalidad', 'contexto', 'sexualidad', 'reluser', 'relchars', 'mensajes', 'expresion', 'bot']) {
      final section = find.byKey(PageStorageKey('male:$id'));
      await tester.ensureVisible(section);
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(of: section, matching: find.byType(ListTile)).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Opening $id');
      rebuild(() {});
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Rebuilding $id');
      await tester.tap(find.descendant(of: section, matching: find.byType(ListTile)).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Closing $id');
    }
  });
}
