import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:pyre/l10n/app_strings.dart';

void main() {
  group('chat picker localization', () {
    const es = AppStrings(Locale('es'));
    const en = AppStrings(Locale('en'));

    test('solo chat persona title keeps the character name', () {
      expect(es.personasForChat('Luna'), 'Personas para el chat con Luna');
      expect(en.personasForChat('Luna'), 'Personas for the chat with Luna');
    });

    test('group member help covers locked and first-picked flows', () {
      expect(es.groupMemberPickerHelp('Luna'), contains('Luna inicia el chat'));
      expect(en.groupMemberPickerHelp('Luna'), contains('Luna opens the chat'));
      expect(es.groupMemberPickerHelp(null), contains('El primero que elijas'));
      expect(en.groupMemberPickerHelp(null), contains('The first one you pick'));
    });

    test('persona picker defaults and empty states are bilingual', () {
      expect(es.personaForThisChat, 'Persona para este chat');
      expect(en.personaForThisChat, 'Persona for this chat');
      expect(es.createPersonaIdentityHelp, contains('Crea una'));
      expect(en.createPersonaIdentityHelp, contains('Create one'));
      expect(es.nothingMatchesSearch, 'Nada coincide con tu búsqueda.');
      expect(en.nothingMatchesSearch, 'Nothing matches your search.');
    });

    test('persona party statuses stay localized', () {
      expect(es.soloPersonaStatus, 'Solo — 1 persona');
      expect(en.soloPersonaStatus, 'Solo — 1 persona');
      expect(es.personaPartyStatus(3), contains('3 personas'));
      expect(es.personaPartyStatus(3), contains('tus mensajes'));
      expect(en.personaPartyStatus(3), contains('3 personas'));
      expect(en.personaPartyStatus(3), contains('your messages'));
    });
  });
}
