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
  out.writeln('{{user}} profile');
  value('Name', id['nombre']);
  value('Surname', id['apellido']);
  value('Nickname', id['apodo']);
  value('Age', id['edad']);
  value('Gender', id['genero']);
  value('Ethnicity', id['etnia']);
  value('Nationality', id['nacionalidad']);

  final ap = map(profile['apariencia']);
  out.writeln('\nAppearance');
  value('Skin tone', ap['tono_piel']);
  value('Build', ap['complexion']);
  value('Height (cm)', ap['altura']);
  value('Weight (kg)', ap['peso']);
  value('Silhouette', ap['silueta']);
  final gen = map(map(map(ap['anatomia'])['genitales'])['pene']);
  value('Penis length (cm)', gen['longitud']);
  value('Penis circumference (cm)', gen['circunferencia']);
  value('Penis shape', gen['forma']);
  value('Glans shape', gen['forma_glande']);
  final pubic = map(map(map(ap['anatomia'])['genitales'])['vello_pubico']);
  value('Pubic hair presence', pubic['presencia']);
  value('Pubic hair style', pubic['estilo']);
  value('Pubic hair color', pubic['color']);
  final hair = map(ap['cabello']);
  value('Hair color', hair['color']); value('Hair length', hair['longitud']);
  value('Hair style', hair['corte_estilo']); value('Fringe', hair['fleco']);
  final eyes = map(ap['ojos']);
  value('Eye color', eyes['color']); value('Eye shape', eyes['forma']);
  value('Face shape', ap['forma_rostro']); value('Facial details', ap['detalles_faciales']);

  final clothes = map(profile['vestimenta']);
  out.writeln('\nClothing');
  value('Top', clothes['parte_superior']); value('Bottom', clothes['parte_inferior']);
  value('Footwear', clothes['calzado']); value('Underwear', clothes['ropa_interior']);
  value('Accessories', clothes['accesorios']); value('Additional details', clothes['descripcion']);

  final personality = map(profile['personalidad']);
  out.writeln('\nPersonality');
  value('General personality', personality['descripcion']);
  final traits = list(personality['rasgos']).map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
  if (traits.isNotEmpty) out.writeln('Traits: ${traits.join(', ')}');
  value('Likes', personality['gustos']); value('Dislikes', personality['disgustos']);

  final occupations = list(profile['ocupaciones_actividades']);
  if (occupations.isNotEmpty) {
    out.writeln('\nOccupation / activity');
    for (var i = 0; i < occupations.length; i++) {
      final o = map(occupations[i]);
      out.writeln('#${i + 1}');
      value('Occupation / profession', o['ocupacion_profesion']);
      value('Organization / institution', o['organizacion_institucion']);
      value('Role / position', o['cargo_posicion']);
      final skills = list(o['especialidades_habilidades']).map((e)=>e.toString().trim()).where((e)=>e.isNotEmpty).toList();
      if (skills.isNotEmpty) out.writeln('Specialties / skills: ${skills.join(', ')}');
      value('Details', o['detalles']);
    }
  }

  final intimacy = map(profile['sexualidad_intimidad']);
  out.writeln('\nSexuality and intimacy');
  value('Sexual orientation', intimacy['orientacion_sexual']);
  for (final raw in list(intimacy['preferencias_fetiches'])) {
    final item = map(raw);
    final type = item['tipo']?.toString().trim() ?? '';
    final name = item['nombre']?.toString().trim() ?? '';
    if (type.isNotEmpty || name.isNotEmpty) out.writeln('- ${type.isEmpty ? 'Preference' : type}: $name');
    value('  Details', item['descripcion']);
  }
  value('Additional details', intimacy['detalles_adicionales']);

  final history = map(profile['historia_biografia']);
  out.writeln('\nHistory / biography');
  value('Origin', history['origen']); value('Personal history', history['historia_personal']);
  for (final raw in list(history['acontecimientos_importantes'])) {
    final event = map(raw);
    final name = event['nombre']?.toString().trim() ?? '';
    if (name.isNotEmpty) out.writeln('- Important event: $name');
    value('  Details', event['descripcion']);
  }
  value('Additional details', history['detalles_adicionales']);
  return out.toString().trim();
}
