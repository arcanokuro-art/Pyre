import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:pyre/l10n/app_strings.dart';

void main() {
  group('persona party localization', () {
    const es = AppStrings(Locale('es'));
    const en = AppStrings(Locale('en'));

    test('party status stays localized for solo and multiple personas', () {
      expect(es.soloPersonaStatus, 'Solo — 1 persona');
      expect(en.soloPersonaStatus, 'Solo — 1 persona');
      expect(
        es.personaPartyStatus(3),
        'Grupo de personas — 3 personas (tus mensajes = todo el grupo)',
      );
      expect(
        en.personaPartyStatus(3),
        'Persona party — 3 personas (your messages = the whole group)',
      );
    });

    test('empty states remain bilingual', () {
      expect(es.createPersonaIdentityHelp, contains('Crea una'));
      expect(en.createPersonaIdentityHelp, contains('Create one'));
      expect(es.nothingMatchesSearch, 'Nada coincide con tu búsqueda.');
      expect(en.nothingMatchesSearch, 'Nothing matches your search.');
    });
  });
}
