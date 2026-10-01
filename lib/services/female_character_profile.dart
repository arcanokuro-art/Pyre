import 'dart:convert';

import '../models/models.dart';
import 'female_character_schema.dart';
import 'male_character_schema.dart';

/// Versioned structured data lives in card extensions, so existing card
/// imports, exports, snapshots and draft persistence retain every field.
const femaleProfileKey = 'pyre_female_profile';
const maleProfileKey = 'pyre_male_profile';

bool isMaleProfile(Map profile) => profile['gender'] == 'male';

List<Map<String, dynamic>> characterSections(Map profile) =>
    isMaleProfile(profile) ? maleSections : femaleSections;

Map<String, dynamic> newFemaleProfile() => {
  'version': 1,
  'gender': 'female',
  'fields': <String, dynamic>{},
  'lists': <String, dynamic>{},
  'resources': <String, dynamic>{},
};

Map<String, dynamic> newMaleProfile() => {
  ...newFemaleProfile(),
  'gender': 'male',
  'fields': <String, dynamic>{
    'identidad.genero': 'hombre',
    'identidad.orientacion': 'heterosexual',
  },
};

// Kept as a compatibility entry point for the existing editor.
Map<String, dynamic>? readFemaleProfile(Character character) {
  final raw = character.extensions[maleProfileKey] ?? character.extensions[femaleProfileKey];
  if (raw is! Map) return null;
  final result = (jsonDecode(jsonEncode(raw)) as Map).cast<String, dynamic>();
  result.putIfAbsent('fields', () => <String, dynamic>{});
  result.putIfAbsent('lists', () => <String, dynamic>{});
  result.putIfAbsent('resources', () => <String, dynamic>{});
  return result;
}

String _renderValue(dynamic value, Map<String, String> names) {
  if (value == null) return '';
  if (value is List) {
    return value
        .map((v) => _renderValue(v, names))
        .where((v) => v.isNotEmpty)
        .join('\n');
  }
  if (value is Map) {
    return value.entries
        .where(
          (e) =>
              e.key != 'id' &&
              !e.key.toString().endsWith('.custom') &&
              (e.key != 'user_id' || value['with'] == 'user') &&
              (e.key != 'char_id' || value['with'] == 'char') &&
              (e.key != 'name' || value['with'] == 'unregistered'),
        )
        .map((e) {
          final raw = e.value?.toString() ?? '';
          final isCustom =
              raw == '__custom' ||
              raw == 'custom' ||
              raw.toLowerCase().startsWith('personaliz');
          final rendered = _renderValue(
            isCustom ? value['${e.key}.custom'] : e.value,
            names,
          );
          return rendered.isEmpty ? '' : '${e.key}: $rendered';
        })
        .where((v) => v.isNotEmpty)
        .join('\n');
  }
  final text = value.toString().trim();
  return names[text] ?? text;
}

/// Compile the form to the existing chara_card_v2 runtime fields. Empty or
/// hidden conditional fields are omitted, but their saved values are retained.
void applyFemaleProfile(
  Character card,
  Map<String, dynamic> profile, {
  Map<String, String> names = const {},
}) {
  final fields = (profile['fields'] as Map).cast<String, dynamic>();
  final lists = (profile['lists'] as Map).cast<String, dynamic>();
  String value(String key) {
    final raw = fields[key]?.toString() ?? '';
    final isCustom =
        raw == '__custom' ||
        raw == 'custom' ||
        raw.toLowerCase().startsWith('personaliz');
    return _renderValue(isCustom ? fields['$key.custom'] : fields[key], names);
  }

  final male = isMaleProfile(profile);
  final sections = characterSections(profile);
  if (male) {
    fields['identidad.genero'] = 'hombre';
    fields['identidad.orientacion'] = 'heterosexual';
  }
  card.extensions[male ? maleProfileKey : femaleProfileKey] = jsonDecode(jsonEncode(profile));
  card.name = [
    value('identity.nombre'),
    value('identity.apellido'),
  ].where((s) => s.isNotEmpty).join(' ');
  final description = StringBuffer();
  for (final section in sections) {
    if (['mensajes', 'bot'].contains(section['id'])) continue;
    final lines = <String>[];
    for (final raw in section['fields'] as List) {
      final f = raw as Map;
      if (!femaleFieldVisible(f, fields)) continue;
      final text = value(f['key'] as String);
      if (text.isEmpty || text == 'Sin especificar' || text == 'none') continue;
      String display = text;
      for (final option in (f['options'] as List? ?? const [])) {
        if (option['value'] == text) display = option['label'] as String;
      }
      lines.add('${f['label']}: $display');
    }
    final listKeys = femaleListsBySection[section['id']] ?? const <String>[];
    for (final key in listKeys) {
      if (['alternatives', 'example_dialogues', 'strict_rules'].contains(key)) {
        continue;
      }
      final text = _renderValue(lists[key], names);
      if (text.isNotEmpty) lines.add('${femaleListTitles[key]}:\n$text');
    }
    if (lines.isNotEmpty) {
      description.writeln('${section['title']}\n${lines.join('\n')}\n');
    }
  }
  // Imported text is kept once when an existing card opts into this editor.
  final legacy = profile['original_description'] as String? ?? '';
  card.description = [
    legacy,
    male ? 'Género: Hombre' : 'Género: Mujer',
    description.toString().trim(),
  ].where((s) => s.isNotEmpty).join('\n\n');
  card.personality = '';
  card.scenario = [
    value('context.situacion'),
    if (femaleFieldVisible({
      'scenario': [
        'netori',
        'ntr',
        'netorare',
        'netorase',
        'infidelity',
        'secret_affair',
        'double_relationship',
      ],
    }, fields))
      value('relationship_scenario.details'),
  ].where((s) => s.isNotEmpty).join('\n');
  card.firstMes = value('messages.initial');
  card.alternateGreetings = (lists['alternatives'] as List? ?? const [])
      .map((e) => _renderValue(e['message'], names))
      .where((s) => s.isNotEmpty)
      .toList();
  card.mesExample = (lists['example_dialogues'] as List? ?? const [])
      .map(
        (e) =>
            '<START>\n{{user}}: ${e['user'] ?? ''}\n{{char}}: ${e['char'] ?? ''}',
      )
      .join('\n');
  final rules = [
    'No hablar por {{user}}.',
    'No controlar las acciones de {{user}}.',
    'No describir los pensamientos de {{user}}.',
    'No hacerse pasar por {{user}}.',
    for (final entry in (lists['strict_rules'] as List? ?? const []))
      if (_renderValue(entry['rule'], names).isNotEmpty)
        _renderValue(entry['rule'], names),
  ];
  for (final raw
      in (sections.firstWhere((s) => s['id'] == 'bot')['fields']
          as List)) {
    final f = raw as Map;
    final text = value(f['key'] as String);
    if (text.isNotEmpty) rules.add('${f['label']}: $text');
  }
  card.postHistoryInstructions = [
    profile['original_post_history'] as String? ?? '',
    ...rules,
  ].where((s) => s.isNotEmpty).join('\n');
}

bool femaleFieldVisible(Map field, Map fields) {
  final scenarios = field['scenario'] as List?;
  if (scenarios != null &&
      !scenarios.contains(fields['relationship_scenario.primary_type'])) {
    return false;
  }
  final target = field['target'];
  if (target != null &&
      target != fields['sexuality.first_experience.with.type']) {
    return false;
  }
  return true;
}

const femaleListsBySection = <String, List<String>>{
  'personalidad': ['traits'],
  'contexto': ['past_relationships'],
  'sexualidad': ['past_experiences'],
  'relchars': ['character_relations'],
  'mensajes': ['alternatives', 'example_dialogues'],
  'expresion': ['secondary_languages'],
  'bot': ['strict_rules'],
};
const femaleListTitles = <String, String>{
  'traits': 'Rasgos principales',
  'past_relationships': 'Relaciones anteriores',
  'past_experiences': 'Experiencias anteriores',
  'character_relations': 'Relaciones con otros personajes',
  'alternatives': 'Mensajes alternativos',
  'example_dialogues': 'Diálogos de ejemplo',
  'secondary_languages': 'Idiomas secundarios',
  'strict_rules': 'Reglas estrictas personalizadas',
  'expressions': 'Expresiones faciales',
};
