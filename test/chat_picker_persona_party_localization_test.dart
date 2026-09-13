import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyre/l10n/app_strings.dart';

void main() {
  group('persona party localization', () {
    const es = AppStrings(Locale('es'));
    const en = AppStrings(Locale('en'));

    test('party status is localized and preserves the count', () {
      expect(es.soloPersonaStatus, 'Solo — 1 persona');
      expect(en.soloPersonaStatus, 'Solo — 1 persona');
      expect(es.personaPartyStatus(3), contains('3 personas'));
      expect(en.personaPartyStatus(3), contains('3 personas'));
      expect(es.personaPartyStatus(3), contains('tus mensajes'));
      expect(en.personaPartyStatus(3), contains('your messages'));
    });

    test('empty-state guidance is bilingual', () {
      expect(es.createPersonaIdentityHelp, contains('Crea una'));
      expect(en.createPersonaIdentityHelp, contains('Create one'));
      expect(es.nothingMatchesSearch, 'Nada coincide con tu búsqueda.');
      expect(en.nothingMatchesSearch, 'Nothing matches your search.');
    });
  });
}
