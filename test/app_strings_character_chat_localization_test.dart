import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyre/l10n/app_strings.dart';

void main() {
  group('AppStrings character and chat localization', () {
    const es = AppStrings(Locale('es'));
    const en = AppStrings(Locale('en'));

    test('character editor strings are localized', () {
      expect(es.changeAvatar, 'Cambiar avatar');
      expect(es.recrop, 'Recortar de nuevo');
      expect(es.chatBubbleColor, 'Color de burbuja del chat');
      expect(es.greetingSection, 'Saludo');
      expect(es.systemPromptOverride, 'Sobrescritura del prompt del sistema');
      expect(es.legacyPersonality, 'Personalidad (campo heredado; normalmente vacío)');
      expect(en.changeAvatar, 'Change avatar');
      expect(en.recrop, 'Recrop');
    });

    test('chat picker dynamic strings are localized', () {
      expect(es.personasForChat('Luna'), 'Personas para el chat con Luna');
      expect(en.personasForChat('Luna'), 'Personas for the chat with Luna');
      expect(
        es.groupMemberPickerHelp('Luna'),
        'Elige los miembros. Luna inicia el chat (su saludo lo comienza); todos se unen a la escena.',
      );
      expect(
        es.groupMemberPickerHelp(null),
        'Elige los miembros. El primero que elijas inicia el chat (su saludo lo comienza); todos se unen a la escena.',
      );
      expect(es.personaForThisChat, 'Persona para este chat');
      expect(es.createPersonaIdentityHelp, 'Crea una desde la pestaña Personas para usar una identidad específica.');
      expect(es.nothingMatchesSearch, 'Nada coincide con tu búsqueda.');
    });
  });
}
