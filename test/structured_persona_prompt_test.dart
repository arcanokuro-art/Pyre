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
    expect(text, contains('Nombre: Haruto'));
    expect(text, contains('Género: hombre'));
    expect(text, contains('Altura (cm): 180'));
    expect(text, contains('Longitud del pene (cm): 13'));
    expect(text, contains('Rasgos: Leal, Calmado'));
    expect(text, contains('Orientación sexual: heterosexual'));
    expect(text, contains('Origen: Tokio'));
  });

  test('empty optional sections do not throw or print null', () {
    final text = buildStructuredPersonaPrompt(<String, dynamic>{
      'identidad': {'nombre': 'Alex', 'genero': 'hombre'},
    });
    expect(text, contains('Nombre: Alex'));
    expect(text, isNot(contains('null')));
  });
}
