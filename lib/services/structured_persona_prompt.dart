import 'woman_persona_fields.dart';

/// Converts the native structured {{user}} profile into stable prompt text.
/// The structured map remains canonical persisted data; this projection keeps
/// existing prompt/export paths compatible without exposing raw JSON to models.
String buildStructuredPersonaPrompt(Map<String, dynamic> profile) {
  final out = StringBuffer();
  void value(String label, dynamic raw) {
    final text = raw?.toString().trim() ?? '';
    if (text.isNotEmpty) out.writeln('$label: $text');
  }

  Map<String, dynamic> map(dynamic raw) =>
      raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  List<dynamic> list(dynamic raw) => raw is List ? raw : const [];

  final id = map(profile['identidad']);
  out.writeln('Perfil de {{user}}');
  value('Nombre', id['nombre']);
  value('Apellido', id['apellido']);
  value('Apodo', id['apodo']);
  value('Edad', id['edad']);
  value('Género', id['genero']);
  value('Etnia', id['etnia']);
  value('Nacionalidad', id['nacionalidad']);

  final isWoman = id['genero'] == 'mujer';
  void writeFields(String heading, List<PersonaField> fields) {
    final details = StringBuffer();
    for (final field in fields) {
      Object? raw = profile;
      for (final key in field.path.split('.')) {
        raw = raw is Map ? raw[key] : null;
      }
      final text = raw?.toString().trim() ?? '';
      if (text.isNotEmpty) details.writeln('${field.label}: $text');
    }
    if (details.isNotEmpty) out.write('\n$heading\n$details');
  }

  if (isWoman) {
    writeFields('Perfil', womanIdentity);
    writeFields('Apariencia', [...womanAppearance, ...womanAppearanceDetails]);
    writeFields('Vestimenta', womanClothing);
  } else {
    final ap = map(profile['apariencia']);
    out.writeln('\nApariencia');
    value('Tono de piel', ap['tono_piel']);
    value('Complexión', ap['complexion']);
    value('Altura (cm)', ap['altura']);
    value('Peso (kg)', ap['peso']);
    value('Silueta', ap['silueta']);
    final gen = map(map(map(ap['anatomia'])['genitales'])['pene']);
    value('Longitud del pene (cm)', gen['longitud']);
    value('Circunferencia del pene (cm)', gen['circunferencia']);
    value('Forma del pene', gen['forma']);
    value('Forma del glande', gen['forma_glande']);
    final pubic = map(map(map(ap['anatomia'])['genitales'])['vello_pubico']);
    value('Presencia de vello púbico', pubic['presencia']);
    value('Estilo del vello púbico', pubic['estilo']);
    value('Color del vello púbico', pubic['color']);
    final hair = map(ap['cabello']);
    value('Color de cabello', hair['color']);
    value('Longitud de cabello', hair['longitud']);
    value('Peinado', hair['corte_estilo']);
    value('Fleco', hair['fleco']);
    final eyes = map(ap['ojos']);
    value('Color de ojos', eyes['color']);
    value('Forma de los ojos', eyes['forma']);
    value('Forma del rostro', ap['forma_rostro']);
    value('Detalles faciales', ap['detalles_faciales']);

    final clothes = map(profile['vestimenta']);
    out.writeln('\nVestimenta');
    value('Parte superior', clothes['parte_superior']);
    value('Parte inferior', clothes['parte_inferior']);
    value('Calzado', clothes['calzado']);
    value('Ropa interior', clothes['ropa_interior']);
    value('Accesorios', clothes['accesorios']);
    value('Detalles adicionales', clothes['descripcion']);
  }

  final personality = map(profile['personalidad']);
  out.writeln('\nPersonalidad');
  value('Personalidad general', personality['descripcion']);
  final traits = list(
    personality['rasgos'],
  ).map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
  if (traits.isNotEmpty) out.writeln('Rasgos: ${traits.join(', ')}');
  value('Gustos', personality['gustos']);
  value('Disgustos', personality['disgustos']);

  final occupations = list(profile['ocupaciones_actividades']);
  if (occupations.isNotEmpty) {
    out.writeln('\nOcupación o actividad');
    for (var i = 0; i < occupations.length; i++) {
      final o = map(occupations[i]);
      out.writeln('#${i + 1}');
      value('Ocupación o profesión', o['ocupacion_profesion']);
      value('Organización o institución', o['organizacion_institucion']);
      value('Cargo', o['cargo_posicion']);
      final skills = list(
        o['especialidades_habilidades'],
      ).map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
      if (skills.isNotEmpty)
        out.writeln('Especialidades o habilidades: ${skills.join(', ')}');
      value('Detalles', o['detalles']);
    }
  }

  final intimacy = map(profile['sexualidad_intimidad']);
  out.writeln('\nSexualidad e intimidad');
  value('Orientación sexual', intimacy['orientacion_sexual']);
  for (final raw in list(intimacy['preferencias_fetiches'])) {
    final item = map(raw);
    final type = item['tipo']?.toString().trim() ?? '';
    final name = item['nombre']?.toString().trim() ?? '';
    if (name.isNotEmpty)
      out.writeln('- ${type.isEmpty ? 'Preferencia' : type}: $name');
    value('  Detalles', item['descripcion']);
  }
  value('Detalles adicionales', intimacy['detalles_adicionales']);

  final history = map(profile['historia_biografia']);
  out.writeln('\nHistoria y biografía');
  value('Origen', history['origen']);
  value('Historia personal', history['historia_personal']);
  for (final raw in list(history['acontecimientos_importantes'])) {
    final event = map(raw);
    final name = event['nombre']?.toString().trim() ?? '';
    if (name.isNotEmpty) out.writeln('- Acontecimiento importante: $name');
    value('  Detalles', event['descripcion']);
  }
  value('Detalles adicionales', history['detalles_adicionales']);
  return out.toString().trim();
}
