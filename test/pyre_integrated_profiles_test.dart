import 'package:flutter_test/flutter_test.dart';
import 'package:pyre/models/models.dart';
import 'package:pyre/services/card_import.dart';
import 'package:pyre/services/chat_prompt_builder.dart';
import 'package:pyre/services/female_character_profile.dart';
import 'package:pyre/services/png_encoder.dart';
import 'package:pyre/services/png_parser.dart';
import 'package:pyre/services/structured_persona_prompt.dart';

void main() {
  test('native card type survives save, Tavern export and import', () {
    for (final isMale in [true, false]) {
      final profile = isMale ? newMaleProfile() : newFemaleProfile();
      (profile['fields'] as Map)['identity.nombre'] = 'Nerea';
      final card = Character(id: 'native', name: '');
      applyFemaleProfile(card, profile);
      final type = isMale ? 'male' : 'female';
      expect(Character.fromJson(card.toJson()).charType, type);
      final raw = buildCharaCardV2Json(card);
      final reimport = characterFromCharaCard(
        CharaCard(card: raw['data'] as Map<String, dynamic>, raw: raw),
      );
      expect(reimport.charType, type);
      expect(reimport.name, 'Nerea');
      expect(readFemaleProfile(reimport), isNotNull);
      expect(
        isMale
            ? buildFixedMaleDynamicsBlock(reimport)
            : buildFixedFemaleDynamicsBlock(reimport),
        isNotEmpty,
      );
    }
  });

  test('woman profile reaches the Spanish prompt after a save round trip', () {
    final stored = Persona(
      id: 'ana',
      name: 'Ana',
      structuredProfile: {
        'identidad': {'genero': 'mujer', 'nombre': 'Ana'},
        'profile': {'especie': 'Elfa'},
        'apariencia': {'piel': 'Clara'},
        'vestimenta': {'prenda_exterior': 'Gabardina'},
        'historia_biografia': {'origen': 'Reynosa'},
      },
    );
    final restored = Persona.fromJson(stored.toJson());
    final prompt = buildStructuredPersonaPrompt(restored.structuredProfile);
    expect(prompt, contains('Género: mujer'));
    expect(prompt, contains('Especie: Elfa'));
    expect(prompt, contains('Tono de piel: Clara'));
    expect(prompt, contains('Prenda exterior: Gabardina'));
    expect(prompt, contains('Origen: Reynosa'));
  });
}
