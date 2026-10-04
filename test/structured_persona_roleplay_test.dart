import 'package:flutter_test/flutter_test.dart';
import 'package:pyre/models/models.dart';
import 'package:pyre/services/chat_prompt_builder.dart';

void main() {
  test('roleplay persona block prefers canonical structured profile', () {
    final persona = Persona(
      id: 'p1',
      name: 'Haruto',
      description: 'STALE LEGACY DESCRIPTION',
      structuredProfile: {
        'identidad': {
          'nombre': 'Haruto',
          'genero': 'hombre',
        },
        'personalidad': {
          'rasgos': ['Leal'],
        },
      },
    );
    final block = buildSinglePersonaBlock(persona);
    expect(block, contains('Name: Haruto'));
    expect(block, contains('Gender: hombre'));
    expect(block, contains('Traits: Leal'));
    expect(block, isNot(contains('STALE LEGACY DESCRIPTION')));
  });

  test('legacy persona block remains byte-compatible', () {
    final persona = Persona(
      id: 'legacy',
      name: 'You',
      description: 'Legacy free-form persona.',
    );
    expect(buildSinglePersonaBlock(persona), 'Legacy free-form persona.');
  });
}
