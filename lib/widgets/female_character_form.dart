import 'package:flutter/material.dart';

import '../services/female_character_profile.dart';
import '../services/female_character_schema.dart';
import '../services/image_pick.dart';
import '../services/attachment_store.dart';
import 'avatar.dart';

/// Uses Pyre's inherited theme; no prototype HTML/CSS in the native app.
class FemaleCharacterForm extends StatefulWidget {
  final Map<String, dynamic> profile;
  final Map<String, String> characters;
  final Map<String, String> personas;
  final VoidCallback onChanged;
  final bool resourcesOnly;
  const FemaleCharacterForm({
    super.key,
    required this.profile,
    required this.characters,
    required this.personas,
    required this.onChanged,
    this.resourcesOnly = false,
  });

  @override
  State<FemaleCharacterForm> createState() => _FemaleCharacterFormState();
}

class _FemaleCharacterFormState extends State<FemaleCharacterForm> {
  bool _quick = false;
  bool _picking = false;
  Map<String, dynamic> get fields =>
      widget.profile['fields'] as Map<String, dynamic>;
  Map<String, dynamic> get lists =>
      widget.profile['lists'] as Map<String, dynamic>;
  Map<String, dynamic> get resources =>
      widget.profile['resources'] as Map<String, dynamic>;

  @override
  void initState() {
    super.initState();
    for (final section in femaleSections) {
      for (final raw in section['fields'] as List) {
        final f = raw as Map;
        if (f['default'] != null) {
          fields.putIfAbsent(f['key'] as String, () => f['default']);
        }
      }
    }
  }

  void _notifyChanged() {
    widget.profile['edited'] = true;
    widget.onChanged();
  }

  void changed() {
    _notifyChanged();
    setState(() {});
  }

  Widget _field(Map f, Map<String, dynamic> target, String identity) {
    final key = f['key'] as String;
    final label = f['label'] as String;
    final type = f['type'] as String? ?? 'text';
    var options = <Map<String, String>>[];
    if (type == 'character' || type == 'persona' || type == 'participant') {
      final entries = type == 'participant'
          ? <String, String>{
              'active_user': 'Perfil {{user}} activo',
              ...widget.characters,
              ...widget.personas,
            }
          : type == 'character'
          ? widget.characters
          : widget.personas;
      options = [
        {'value': '', 'label': 'Sin seleccionar'},
        for (final entry in entries.entries)
          {'value': entry.key, 'label': entry.value},
      ];
      final current = target[key]?.toString() ?? '';
      if (current.isNotEmpty && !entries.containsKey(current)) {
        options.add({
          'value': current,
          'label': 'Referencia no disponible ($current)',
        });
      }
    } else {
      options = [
        for (final o in (f['options'] as List? ?? const []))
          {'value': o['value'].toString(), 'label': o['label'].toString()},
      ];
    }
    if (key == 'physical.cabello.corte') {
      final length = fields['physical.cabello.longitud'];
      const short = [
        'Pixie',
        'Garcon',
        'Buzz cut',
        'Bixie',
        'Mixie',
        'Undercut',
        'Bowl cut',
        'Micro',
        'Bob',
      ];
      const medium = [
        'Bob',
        'Long Bob',
        'Clavicut',
        'Shag',
        'Wolf cut',
        'Mullet',
        'Corte hongo',
        'Blunt Bob',
        'French Bob',
        'Italian Bob',
      ];
      const long = [
        'Corte recto',
        'Corte en capas',
        'Corte Mariposa',
        'Corte en V',
        'Corte en U',
        'Hime cut',
        'Octopus cut',
        'Jellyfish cut',
      ];
      final styles = ['Muy corto', 'Corto'].contains(length)
          ? short
          : length == 'Medio'
          ? medium
          : ['Largo', 'Muy largo'].contains(length)
          ? long
          : {...short, ...medium, ...long}.toList();
      options = [
        {'value': '', 'label': 'Sin especificar'},
        for (final style in styles) {'value': style, 'label': style},
        {'value': '__custom', 'label': 'Personalizado…'},
      ];
    }
    final current = target[key]?.toString() ?? '';
    if (options.isNotEmpty) {
      if (current.isEmpty && !options.any((o) => o['value'] == '')) {
        options.insert(0, {'value': '', 'label': 'Sin especificar'});
      }
      final selected = options.any((o) => o['value'] == current)
          ? current
          : '__custom';
      if (!options.any((o) => o['value'] == selected)) {
        options.add({'value': '__custom', 'label': 'Personalizado…'});
      }
      final custom =
          selected == '__custom' ||
          selected.toLowerCase().startsWith('personaliz') ||
          selected == 'custom';
      return Padding(
        key: PageStorageKey('female-field:$identity:$key'),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              key: ValueKey('$identity:$key:$selected:${options.length}'),
              initialValue: selected,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
              ),
              items: [
                for (final o in options)
                  DropdownMenuItem(
                    value: o['value'],
                    child: Text(o['label']!, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (v) {
                target[key] = v ?? '';
                changed();
              },
            ),
            if (custom && key != 'relationship_scenario.primary_type')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextFormField(
                  key: ValueKey('$identity:$key:custom'),
                  initialValue:
                      target['$key.custom']?.toString() ??
                      (selected == '__custom' && current != '__custom'
                          ? current
                          : ''),
                  decoration: InputDecoration(labelText: 'Especificar $label'),
                  onChanged: (v) {
                    target['$key.custom'] = v;
                    if (selected == '__custom') target[key] = '__custom';
                    widget.profile['edited'] = true;
                    _notifyChanged();
                  },
                ),
              ),
          ],
        ),
      );
    }
    return Padding(
      key: PageStorageKey('female-field:$identity:$key'),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        key: ValueKey('$identity:$key'),
        initialValue: current,
        minLines: 1,
        maxLines: f['multiline'] == true ? 6 : 1,
        keyboardType: type == 'number'
            ? const TextInputType.numberWithOptions(decimal: true)
            : f['multiline'] == true
            ? TextInputType.multiline
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: (v) {
          target[key] = v;
          _notifyChanged();
        },
      ),
    );
  }

  Widget _list(String key) {
    final entries = lists.putIfAbsent(key, () => <dynamic>[]) as List;
    final defs = _listFields[key]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            femaleListTitles[key]!,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        for (final entry in entries)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${femaleListTitles[key]} #${entries.indexOf(entry) + 1}',
                        ),
                      ),
                      IconButton(
                        tooltip: 'Eliminar',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          entries.remove(entry);
                          changed();
                        },
                      ),
                    ],
                  ),
                  for (final f in defs)
                    if (_listFieldVisible(f, entry as Map))
                      _field(
                        f,
                        entry.cast<String, dynamic>(),
                        '${entry['id']}',
                      ),
                  if (key == 'character_relations')
                    _bonds(entry.cast<String, dynamic>()),
                ],
              ),
            ),
          ),
        OutlinedButton.icon(
          icon: const Icon(Icons.add),
          label: Text('Añadir ${femaleListTitles[key]!.toLowerCase()}'),
          onPressed: () {
            entries.add(<String, dynamic>{
              'id': '${DateTime.now().microsecondsSinceEpoch}',
            });
            changed();
          },
        ),
      ],
    );
  }

  bool _listFieldVisible(Map f, Map entry) {
    if (f['key'] == 'user_id') return entry['with'] == 'user';
    if (f['key'] == 'char_id') return entry['with'] == 'char';
    if (f['key'] == 'name') return entry['with'] == 'unregistered';
    return true;
  }

  Widget _bonds(Map<String, dynamic> entry) {
    final bonds = entry.putIfAbsent('bonds', () => <dynamic>[]) as List;
    return Column(
      children: [
        for (final bond in bonds)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  for (final f in _bondFields)
                    _field(
                      f,
                      (bond as Map).cast<String, dynamic>(),
                      '${entry['id']}:${bond['id']}',
                    ),
                  TextButton(
                    onPressed: () {
                      bonds.remove(bond);
                      changed();
                    },
                    child: const Text('Eliminar vínculo'),
                  ),
                ],
              ),
            ),
          ),
        TextButton.icon(
          onPressed: () {
            bonds.add(<String, dynamic>{
              'id': '${DateTime.now().microsecondsSinceEpoch}',
            });
            changed();
          },
          icon: const Icon(Icons.add),
          label: const Text('Añadir vínculo'),
        ),
      ],
    );
  }

  Future<void> _pickResource(Map<String, dynamic> target, String key) async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final image = await pickOneImage();
      if (image == null || !mounted) return;
      final ref = await externalizeImageBytes(image.bytes);
      if (!mounted) return;
      target[key] = ref;
      changed();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo guardar la imagen.')),
        );
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Widget _image(String title, Map<String, dynamic> target, String key) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            AvatarBubble(
              dataUrl: target[key] as String?,
              fallback: '?',
              radius: 28,
              tappableLightbox: true,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
            IconButton(
              tooltip: 'Seleccionar imagen',
              onPressed: _picking ? null : () => _pickResource(target, key),
              icon: const Icon(Icons.add_photo_alternate_outlined),
            ),
            if (target[key] != null)
              IconButton(
                tooltip: 'Eliminar imagen',
                onPressed: () {
                  target.remove(key);
                  changed();
                },
                icon: const Icon(Icons.delete_outline),
              ),
          ],
        ),
      );

  Widget _visuals() {
    final expressions =
        lists.putIfAbsent('expressions', () => <dynamic>[]) as List;
    return ExpansionTile(
      title: const Text('Recursos visuales'),
      children: [
        _image('Modelo global / Model Sheet', resources, 'model_sheet'),
        _image('Vista frontal', resources, 'front_view'),
        _image('Vista trasera', resources, 'back_view'),
        for (final entry in expressions)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  _field(
                    {'key': 'label', 'label': 'Etiqueta de expresión'},
                    (entry as Map).cast<String, dynamic>(),
                    '${entry['id']}',
                  ),
                  _image(
                    'Imagen de expresión',
                    entry.cast<String, dynamic>(),
                    'image',
                  ),
                  TextButton(
                    onPressed: () {
                      expressions.remove(entry);
                      changed();
                    },
                    child: const Text('Eliminar expresión'),
                  ),
                ],
              ),
            ),
          ),
        OutlinedButton.icon(
          onPressed: () {
            expressions.add(<String, dynamic>{
              'id': '${DateTime.now().microsecondsSinceEpoch}',
            });
            changed();
          },
          icon: const Icon(Icons.add),
          label: const Text('Añadir expresión facial'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.resourcesOnly) return _visuals();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Personaje femenino',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text('Género: Mujer'),
        ),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('Rápida')),
            ButtonSegment(value: false, label: Text('Detallada')),
          ],
          selected: {_quick},
          onSelectionChanged: (s) => setState(() => _quick = s.first),
        ),
        for (final section in femaleSections)
          if (!_quick || section['advanced'] != true)
            Card(
              child: ExpansionTile(
                key: PageStorageKey('female:${section['id']}'),
                initiallyExpanded: section['id'] == 'perfil',
                title: Text(section['title'] as String),
                childrenPadding: const EdgeInsets.all(12),
                children: [
                  for (final raw in section['fields'] as List)
                    if ((!_quick || (raw as Map)['advanced'] != true) &&
                        femaleFieldVisible(raw as Map, fields))
                      _field(raw, fields, 'profile'),
                  for (final key
                      in femaleListsBySection[section['id']] ??
                          const <String>[])
                    if (!_quick || key == 'traits') _list(key),
                  if (section['id'] == 'bot') ...[
                    for (final rule in [
                      'No hablar por {{user}}',
                      'No controlar acciones de {{user}}',
                      'No describir pensamientos de {{user}}',
                      'No hacerse pasar por {{user}}',
                    ])
                      ListTile(
                        leading: const Icon(Icons.lock_outline),
                        title: Text(rule),
                      ),
                  ],
                ],
              ),
            ),
      ],
    );
  }
}

const _personFields = <Map<String, dynamic>>[
  {
    'key': 'with',
    'label': 'Fue con',
    'type': 'select',
    'options': [
      {'value': '', 'label': 'Sin especificar'},
      {'value': 'user', 'label': '{{user}}'},
      {'value': 'char', 'label': 'Otro {{char}}'},
      {'value': 'unregistered', 'label': 'Personaje no registrado'},
    ],
  },
  {'key': 'user_id', 'label': 'Perfil {{user}}', 'type': 'persona'},
  {'key': 'char_id', 'label': 'Personaje vinculado', 'type': 'character'},
  {'key': 'name', 'label': 'Nombre del personaje'},
];
const _listFields = <String, List<Map<String, dynamic>>>{
  'traits': [
    {'key': 'trait', 'label': 'Rasgo principal'},
  ],
  'strict_rules': [
    {'key': 'rule', 'label': 'Regla personalizada', 'multiline': true},
  ],
  'alternatives': [
    {'key': 'message', 'label': 'Mensaje alternativo', 'multiline': true},
  ],
  'example_dialogues': [
    {'key': 'user', 'label': 'Interlocutor / {{user}}', 'multiline': true},
    {'key': 'char', 'label': 'Respuesta de {{char}}', 'multiline': true},
  ],
  'secondary_languages': [
    {
      'key': 'language',
      'label': 'Idioma',
      'type': 'select',
      'options': [
        {'value': 'Español', 'label': 'Español'},
        {'value': 'Inglés', 'label': 'Inglés'},
        {'value': 'Japonés', 'label': 'Japonés'},
        {'value': 'Italiano', 'label': 'Italiano'},
        {'value': 'Ruso', 'label': 'Ruso'},
        {'value': 'Francés', 'label': 'Francés'},
        {'value': 'Alemán', 'label': 'Alemán'},
        {'value': 'Coreano', 'label': 'Coreano'},
        {'value': 'Chino', 'label': 'Chino'},
        {'value': 'Personalizado…', 'label': 'Personalizado…'},
      ],
    },
    {'key': 'accent', 'label': 'Acento'},
    {'key': 'use', 'label': 'Uso', 'multiline': true},
  ],
  'past_relationships': [
    ..._personFields,
    {
      'key': 'relationship_type',
      'label': 'Tipo de relación',
      'type': 'select',
      'options': [
        {'value': 'Pareja', 'label': 'Pareja'},
        {'value': 'Compromiso', 'label': 'Compromiso'},
        {'value': 'Amor no correspondido', 'label': 'Amor no correspondido'},
        {'value': 'Noviazgo', 'label': 'Noviazgo'},
        {'value': 'Matrimonio', 'label': 'Matrimonio'},
        {'value': 'Relación informal', 'label': 'Relación informal'},
        {'value': 'Personalizado…', 'label': 'Personalizado…'},
      ],
    },
    {'key': 'period', 'label': 'Periodo'},
    {'key': 'end_reason', 'label': 'Motivo del final', 'multiline': true},
    {'key': 'after', 'label': 'Estado posterior'},
    {'key': 'context', 'label': 'Contexto', 'multiline': true},
  ],
  'past_experiences': [
    ..._personFields,
    {
      'key': 'bond',
      'label': 'Tipo de vínculo en ese momento',
      'type': 'select',
      'options': [
        {
          'value': 'Sin relación sentimental',
          'label': 'Sin relación sentimental',
        },
        {'value': 'Pareja', 'label': 'Pareja'},
        {'value': 'Noviazgo', 'label': 'Noviazgo'},
        {'value': 'Matrimonio', 'label': 'Matrimonio'},
        {'value': 'Expareja', 'label': 'Expareja'},
        {'value': 'Encuentro casual', 'label': 'Encuentro casual'},
        {'value': 'Personalizado…', 'label': 'Personalizado…'},
      ],
    },
    {'key': 'context', 'label': 'Contexto / descripción', 'multiline': true},
  ],
  'character_relations': [
    {
      'key': 'target_char_id',
      'label': 'Personaje vinculado',
      'type': 'character',
    },
    {'key': 'context', 'label': 'Contexto de la relación', 'multiline': true},
    {'key': 'current_state', 'label': 'Estado actual', 'multiline': true},
  ],
};
const _bondFields = <Map<String, dynamic>>[
  {
    'key': 'category',
    'label': 'Categoría',
    'type': 'select',
    'options': [
      {'value': 'Familia', 'label': 'Familia'},
      {'value': 'Romántica', 'label': 'Romántica'},
      {'value': 'Social', 'label': 'Social'},
      {'value': 'Profesional', 'label': 'Profesional'},
      {'value': 'Conflicto', 'label': 'Conflicto'},
      {'value': 'Personalizado…', 'label': 'Personalizado…'},
    ],
  },
  {'key': 'char_to_target', 'label': '{{char}} → personaje vinculado'},
  {'key': 'target_to_char', 'label': 'Personaje vinculado → {{char}}'},
];
