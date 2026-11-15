import 'package:flutter_test/flutter_test.dart';
import 'package:pyre/models/models.dart';

void main() {
  test('Persona structuredProfile round-trips through native JSON', () {
    final profile = <String, dynamic>{
      'identidad': {
        'nombre': 'Haruto',
        'genero': 'hombre',
      },
      'personalidad': {
        'rasgos': ['Leal', 'Calmado'],
      },
      'ocupaciones_actividades': [
        {
          'ocupacion_profesion': 'Estudiante',
          'especialidades_habilidades': ['Dibujo'],
        }
      ],
    };
    final original = Persona(
      id: 'persona-structured',
      name: 'Haruto',
      description: 'prompt projection',
      structuredProfile: profile,
    );
    final restored = Persona.fromJson(original.toJson());
    expect(restored.structuredProfile, equals(profile));
    expect(restored.description, 'prompt projection');
  });

  test('legacy Persona JSON remains compatible without structuredProfile', () {
    final restored = Persona.fromJson({
      'id': 'legacy',
      'name': 'Legacy User',
      'description': 'Old free-form persona',
    });
    expect(restored.structuredProfile, isEmpty);
    expect(restored.description, 'Old free-form persona');
  });
}
