import 'package:flutter_test/flutter_test.dart';
import 'package:pyre/services/structured_persona_prompt.dart';

void main() {
  test('structured male persona projects core fields into prompt text', () {
    final profile = <String, dynamic>{
      'identidad': {'nombre': 'Haruto', 'apellido': 'Takahashi', 'genero': 'hombre'},
      'apariencia': {
        'altura': '180',
        'anatomia': {'genitales': {'pene': {'longitud': '13'}}}
      },
      'personalidad': {'rasgos': ['Leal', 'Calmado']},
      'sexualidad_intimidad': {'orientacion_sexual': 'heterosexual'},
      'historia_biografia': {'origen': 'Tokio'},
    };
    final text = buildStructuredPersonaPrompt(profile);
    expect(text, contains('Name: Haruto'));
    expect(text, contains('Gender: hombre'));
    expect(text, contains('Height (cm): 180'));
    expect(text, contains('Penis length (cm): 13'));
    expect(text, contains('Traits: Leal, Calmado'));
    expect(text, contains('Sexual orientation: heterosexual'));
    expect(text, contains('Origin: Tokio'));
  });

  test('empty optional sections do not throw or print null', () {
    final text = buildStructuredPersonaPrompt(<String, dynamic>{
      'identidad': {'nombre': 'Alex', 'genero': 'hombre'},
    });
    expect(text, contains('Name: Alex'));
    expect(text, isNot(contains('null')));
  });
}
