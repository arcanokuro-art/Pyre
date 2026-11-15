import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyre/models/models.dart';
import 'package:pyre/services/female_character_profile.dart';
import 'package:pyre/services/male_character_schema.dart';

void main() {
  test('male catalogue has 89 unique fields and no female appearance fields', () {
    final keys = [for (final s in maleSections) for (final f in s['fields'] as List) f['key']];
    expect(keys.length, 89);
    expect(keys.toSet().length, keys.length);
    expect(keys, contains('apariencia.cabello.corte_estilo'));
    expect(keys, isNot(contains('physical.busto.copa')));
  });
  test('male profile exports, reopens and preserves Avatar and Lorebooks', () {
    final p = newMaleProfile();
    p['fields']['identity.nombre'] = 'Haruto';
    p['fields']['identity.apellido'] = 'Takahashi';
    p['fields']['apariencia.cabello.color'] = 'Negro';
    p['fields']['initial_outfit.ropa_interior'] = 'Bóxer';
    p['resources']['front_view'] = 'pyre://attachment/male-front';
    final c = Character(id: 'male', name: '', avatar: 'avatar', lorebookIds: ['book']);
    applyFemaleProfile(c, p);
    final restored = Character.fromJson(jsonDecode(jsonEncode(c.toJson())));
    final read = readFemaleProfile(restored)!;
    expect(read['gender'], 'male');
    expect(read['fields']['apariencia.cabello.color'], 'Negro');
    expect(read['resources']['front_view'], 'pyre://attachment/male-front');
    expect(restored.name, 'Haruto Takahashi');
    expect(restored.avatar, 'avatar');
    expect(restored.lorebookIds, ['book']);
    expect(restored.extensions.containsKey(femaleProfileKey), false);
    expect(restored.description, contains('Género: Hombre'));
    expect(restored.description, isNot(contains('Género: Mujer')));
  });
  test('male fixed identity is enforced when compiling imported data', () {
    final p = newMaleProfile();
    p['fields']['identidad.genero'] = 'changed';
    p['fields']['identidad.orientacion'] = 'changed';
    final c = Character(id: 'male', name: '');
    applyFemaleProfile(c, p);
    expect(p['fields']['identidad.genero'], 'hombre');
    expect(p['fields']['identidad.orientacion'], 'heterosexual');
    expect(c.description, isNot(contains('changed')));
  });
}
