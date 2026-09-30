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
      expect(tester.takeException(), isNull);
    },
  );
}
