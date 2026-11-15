import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pyre/models/models.dart';
import 'package:pyre/services/female_character_profile.dart';
import 'package:pyre/services/female_character_schema.dart';
import 'package:pyre/services/attachment_refs.dart';

void main() {
  late Map<String, dynamic> profile;
  late Character card;
  setUp(() {
    profile = newFemaleProfile();
    card = Character(
      id: 'test',
      name: '',
      avatar: 'avatar',
      lorebookIds: ['book'],
      extensions: {
        'foreign_extension': {'preserve': true},
      },
    );
  });
  test('all 138 prototype fields have unique keys', () {
    final keys = [
      for (final s in femaleSections)
        for (final f in s['fields'] as List) f['key'],
    ];
    expect(keys.length, 138);
    expect(keys.toSet().length, keys.length);
  });
  test(
    'structured profile survives JSON export and reopening without aliasing',
    () {
      profile['fields']['identity.nombre'] = 'Lilian';
      profile['fields']['identity.apellido'] = 'Bellucci';
      profile['fields']['physical.cabello.color'] = 'Negro';
      profile['resources']['front_view'] = 'pyre://attachment/front';
      applyFemaleProfile(card, profile);
      final restored = Character.fromJson(
        jsonDecode(jsonEncode(card.toJson())),
      );
      final read = readFemaleProfile(restored)!;
      expect(restored.name, 'Lilian Bellucci');
      expect(read['resources']['front_view'], 'pyre://attachment/front');
      read['fields']['identity.nombre'] = 'Changed';
      expect(
        restored.extensions[femaleProfileKey]['fields']['identity.nombre'],
        'Lilian',
      );
      expect(restored.extensions['foreign_extension'], {'preserve': true});
      expect(restored.avatar, 'avatar');
      expect(restored.lorebookIds, ['book']);
    },
  );
  test('greetings and dialogue compile into real runtime card fields', () {
    profile['fields']['messages.initial'] = 'Bienvenido.';
    profile['lists']['alternatives'] = [
      {'id': 'a', 'message': 'Buenos días.'},
      {'id': 'b', 'message': ''},
    ];
    profile['lists']['example_dialogues'] = [
      {'user': 'Hola', 'char': 'Qué tal'},
    ];
    applyFemaleProfile(card, profile);
    expect(card.firstMes, 'Bienvenido.');
    expect(card.alternateGreetings, ['Buenos días.']);
    expect(card.mesExample, '<START>\n{{user}}: Hola\n{{char}}: Qué tal');
  });
  test(
    'custom selections render entered text and do not leak marker values',
    () {
      profile['fields']['profile.ocupacion'] = 'Personalizado…';
      profile['fields']['profile.ocupacion.custom'] = 'Bibliotecaria';
      applyFemaleProfile(card, profile);
      expect(card.description, contains('Bibliotecaria'));
      expect(card.description, isNot(contains('Personalizado…')));
      profile['fields']['profile.ocupacion'] = 'Artista';
      applyFemaleProfile(card, profile);
      expect(card.description, contains('Artista'));
      expect(card.description, isNot(contains('Bibliotecaria')));
    },
  );
  test('hidden scenario values stay saved but do not enter the prompt', () {
    profile['fields']['relationship_scenario.primary_type'] = 'none';
    profile['fields']['relationship_scenario.config.user_role'] =
        'hidden test value';
    profile['fields']['relationship_scenario.details'] = 'hidden scene';
    applyFemaleProfile(card, profile);
    expect(card.description, isNot(contains('hidden test value')));
    expect(card.scenario, isNot(contains('hidden scene')));
    expect(
      readFemaleProfile(
        card,
      )!['fields']['relationship_scenario.config.user_role'],
      'hidden test value',
    );
  });
  test(
    'person links use real names and exclude inactive historical targets',
    () {
      profile['lists']['past_relationships'] = [
        {
          'id': 'r',
          'with': 'char',
          'char_id': 'other',
          'user_id': 'stale-user',
          'context': 'Amistad',
        },
      ];
      profile['lists']['character_relations'] = [
        {
          'id': 'r2',
          'target_char_id': 'other',
          'bonds': [
            {
              'category': 'Social',
              'char_to_target': 'Amiga',
              'target_to_char': 'Amiga',
            },
          ],
        },
      ];
      applyFemaleProfile(
        card,
        profile,
        names: {'other': 'Akemi', 'stale-user': 'Ignored'},
      );
      expect(card.description, contains('Akemi'));
      expect(card.description, contains('Amiga'));
      expect(card.description, isNot(contains('Ignored')));
    },
  );
  test('bot style and custom rules reach post-history instructions', () {
    profile['fields']['bot.length'] = 'Larga';
    profile['lists']['strict_rules'] = [
      {'rule': 'Mantener el contexto.'},
    ];
    applyFemaleProfile(card, profile);
    expect(card.postHistoryInstructions, contains('No hablar por {{user}}'));
    expect(card.postHistoryInstructions, contains('Mantener el contexto.'));
    expect(card.postHistoryInstructions, contains('Larga'));
  });
  test('repeated saves do not duplicate generated content', () {
    profile['fields']['identity.nombre'] = 'Lilian';
    profile['fields']['history.biografia'] = 'Vive en una ciudad.';
    applyFemaleProfile(card, profile);
    final once = card.description;
    applyFemaleProfile(card, readFemaleProfile(card)!);
    expect(card.description, once);
  });
  test('native resource and expression refs are included in incoming sync', () {
    profile['resources']['front_view'] = 'pyre://attachment/front';
    profile['lists']['expressions'] = [
      {'label': 'Feliz', 'image': 'pyre://attachment/smile'},
    ];
    final refs = incomingRecordAttachmentRefs(
      extensions: {femaleProfileKey: profile},
    );
    expect(refs, {'pyre://attachment/front', 'pyre://attachment/smile'});
  });
  test('existing unstructured cards are not silently migrated', () {
    expect(readFemaleProfile(card), isNull);
    expect(card.extensions['foreign_extension'], {'preserve': true});
  });
}
