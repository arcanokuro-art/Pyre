import 'package:flutter/widgets.dart';

/// Pyre localization foundation.
/// Spanish is the default language and English is the secondary language.
class AppStrings {
  final Locale locale;
  const AppStrings(this.locale);

  static const defaultLocale = Locale('es');
  static const supportedLocales = <Locale>[Locale('es'), Locale('en')];

  static AppStrings of(BuildContext context) =>
      Localizations.of<AppStrings>(context, AppStrings) ??
      const AppStrings(defaultLocale);

  bool get es => locale.languageCode == 'es';

  String get language => es ? 'Idioma' : 'Language';
  String get spanish => 'Español';
  String get english => 'English';
  String get chats => 'Chats';
  String get library => es ? 'Biblioteca' : 'Library';
  String get characters => es ? 'Personajes' : 'Characters';
  String get personas => 'Personas';
  String get lorebooks => es ? 'Libros de lore' : 'Lorebooks';
  String get discover => es ? 'Descubrir' : 'Discover';
  String get more => es ? 'Más' : 'More';
  String get settings => es ? 'Ajustes' : 'Settings';
  String get view => es ? 'Ver' : 'View';
  String get save => es ? 'Guardar' : 'Save';
  String get cancel => es ? 'Cancelar' : 'Cancel';
  String get delete => es ? 'Eliminar' : 'Delete';
  String get edit => es ? 'Editar' : 'Edit';
  String get create => es ? 'Crear' : 'Create';
  String get search => es ? 'Buscar' : 'Search';
  String get import => es ? 'Importar' : 'Import';
  String get export => es ? 'Exportar' : 'Export';
  String get name => es ? 'Nombre' : 'Name';
  String get description => es ? 'Descripción' : 'Description';
  String get appearance => es ? 'Apariencia' : 'Appearance';
  String get personality => es ? 'Personalidad' : 'Personality';
  String get scenario => es ? 'Escenario' : 'Scenario';
  String get greeting => es ? 'Primer mensaje' : 'First message';
  String get advanced => es ? 'Avanzado' : 'Advanced';
  String get storage => es ? 'Almacenamiento' : 'Storage';
  String get network => es ? 'Red' : 'Network';
  String get privacy => es ? 'Privacidad' : 'Privacy';
  String get about => es ? 'Acerca de' : 'About';
  String get newChat => es ? 'Nuevo chat' : 'New chat';
  String get newCharacter => es ? 'Nuevo personaje' : 'New character';
  String get editCharacter => es ? 'Editar personaje' : 'Edit character';
  String get editThisChatOnly =>
      es ? 'Editar (solo este chat)' : 'Edit (this chat only)';
  String get drafts => es ? 'Borradores' : 'Drafts';
  String get changeAvatar => es ? 'Cambiar avatar' : 'Change avatar';
  String get recrop => es ? 'Recortar de nuevo' : 'Recrop';
  String get chatBubbleColor =>
      es ? 'Color de burbuja del chat' : 'Chat bubble color';
  String get identity => es ? 'Identidad' : 'Identity';
  String get descriptionAndWorld =>
      es ? 'Descripción y mundo' : 'Description & World';
  String get exampleDialogue =>
      es ? 'Diálogo de ejemplo' : 'Example dialogue';
  String get cardMetadata => es ? 'Metadatos de la tarjeta' : 'Card metadata';
  String get creatorNotes => es ? 'Notas del creador' : 'Creator notes';
  String get alternateGreetings =>
      es ? 'Saludos alternativos' : 'Alternate greetings';
  String get addGreeting => es ? 'Agregar saludo' : 'Add greeting';
  String get deleteDraftQuestion =>
      es ? '¿Eliminar borrador?' : 'Delete draft?';
  String get noDraftsYet => es ? 'Aún no hay borradores.' : 'No drafts yet.';
  String get cardWeight => es ? 'Peso de la tarjeta' : 'Card weight';
  String get greetingSection => es ? 'Saludo' : 'Greeting';
  String get tagsCommaSeparated =>
      es ? 'Etiquetas (separadas por comas)' : 'Tags (comma-separated)';
  String get tagline => es ? 'Eslogan' : 'Tagline';
  String get systemPromptOverride =>
      es ? 'Sobrescritura del prompt del sistema' : 'System prompt override';
  String get postHistoryInstructions => es
      ? 'Instrucciones posteriores al historial'
      : 'Post-history instructions';
  String get creator => es ? 'Creador' : 'Creator';
  String get characterVersion =>
      es ? 'Versión del personaje' : 'Character version';
  String get removeGreeting =>
      es ? 'Eliminar este saludo' : 'Remove this greeting';
  String get editing => es ? 'editando' : 'editing';
  String get draftSavedResume => es
      ? 'Borrador guardado. Continúa desde Crear → Continuar borrador.'
      : 'Draft saved. Resume from Create → Resume draft.';
  String get characterLorebookOverrideHelp => es
      ? 'Añadir un libro aquí lo adjunta SOLO a este chat. Quitar uno solo lo desactiva para este chat; las vinculaciones propias del personaje (y los demás chats) no se ven afectadas.'
      : 'Adding a book here attaches it to THIS chat only. Removing one only turns it off for this chat — the character\'s own bindings (and other chats) are unaffected.';
  String get characterLorebookHelp => es
      ? 'Estos libros se inyectan en cada chat con este personaje, además de los libros adjuntos a cada chat. Úsalo para el contexto del mundo o ambientación que acompaña al personaje.'
      : 'These books inject in every chat with this character — on top of any books attached per-chat. Use this for world / setting context that travels with the character.';
  String get characterAdvancedHelp => es
      ? 'Personalidad (vacía por especificación), prompts del sistema, saludos alternativos y campos avanzados conservados.'
      : 'Personality (kept empty by spec), system prompts, alternate greetings, and preserved advanced fields.';
  String get legacyPersonality => es
      ? 'Personalidad (campo heredado; normalmente vacío)'
      : 'Personality (legacy field — usually empty)';
  String get chatOnlyCharacterEditNotice => es
      ? 'Los cambios realizados aquí solo afectan a este chat. No modifican el personaje global.'
      : 'Edits here only affect this chat. They do not touch the global character.';
  String get draftsHelp => es
      ? 'Tarjetas en progreso guardadas automáticamente mientras escribes. Toca para cambiar; mantén pulsado para eliminar.'
      : 'In-progress cards saved automatically as you type. Tap to switch; long-press to delete.';
  String get unnamedDraft => es ? '(borrador sin nombre)' : '(unnamed draft)';
  String get greetingHint => es
      ? '*Ella levanta la mirada.* **"¿Otra vez aquí?"**'
      : '*She glances up.* **"Back again?"**';
  String deleteDraftWarning(String title) => es
      ? '¿Descartar "$title" permanentemente? Esta acción no se puede deshacer.'
      : 'Permanently discard "$title"? This cannot be undone.';
  String personasForChat(String characterName) => es
      ? 'Personas para el chat con $characterName'
      : 'Personas for the chat with $characterName';
  String groupMemberPickerHelp(String? primaryName) => primaryName != null
      ? (es
          ? 'Elige los miembros. $primaryName inicia el chat (su saludo lo comienza); todos se unen a la escena.'
          : 'Pick the members. $primaryName opens the chat (their greeting starts it); everyone joins the scene.')
      : (es
          ? 'Elige los miembros. El primero que elijas inicia el chat (su saludo lo comienza); todos se unen a la escena.'
          : 'Pick the members. The first one you pick opens the chat (their greeting starts it); everyone joins the scene.');
  String get personaForThisChat =>
      es ? 'Persona para este chat' : 'Persona for this chat';
  String get createPersonaIdentityHelp => es
      ? 'Crea una desde la pestaña Personas para usar una identidad específica.'
      : 'Create one from the Personas tab to play as a specific identity.';
  String get nothingMatchesSearch =>
      es ? 'Nada coincide con tu búsqueda.' : 'Nothing matches your search.';
  String get soloPersonaStatus => es ? 'Solo — 1 persona' : 'Solo — 1 persona';
  String personaPartyStatus(int count) => es
      ? 'Grupo de personas — $count personas (tus mensajes = todo el grupo)'
      : 'Persona party — $count personas (your messages = the whole group)';
  String get noChats => es ? 'Aún no hay chats' : 'No chats yet';
  String get noCharacters => es ? 'Aún no hay personajes' : 'No characters yet';
  String get allChats => es ? 'Todos los chats' : 'All Chats';
  String get actions => es ? 'Acciones' : 'Actions';
  String get openChatList => es ? 'Abrir lista de chats' : 'Open chat list';
  String get renameChat => es ? 'Renombrar chat' : 'Rename chat';
  String get deleteChat => es ? 'Eliminar chat' : 'Delete chat';
  String get deleteChatQuestion => es ? '¿Eliminar chat?' : 'Delete chat?';
  String get noMessages => es ? 'Aún no hay mensajes.' : 'No messages yet.';
  String get justNow => es ? 'ahora mismo' : 'just now';
  String get searchCharacter => es ? 'Buscar personaje' : 'Search Character';
  String get searchPersona => es ? 'Buscar persona' : 'Search Persona';
  String get searchLorebook => es ? 'Buscar libro de lore' : 'Search Lorebook';
  String get buildWithAi => es ? 'Crear con asistente de IA' : 'Build with AI assistant';
  String get createManually => es ? 'Crear manualmente' : 'Create manually';
  String get importFromFile => es ? 'Importar desde archivo' : 'Import from file';
  String get importFromJson => es ? 'Importar desde JSON' : 'Import from JSON';
  String get startChatHint => es
      ? 'Inicia uno aquí — individual o grupal — o toca un personaje en la pestaña Biblioteca.'
      : 'Start one here — solo or a whole group — or tap a character in the Library tab.';
  String chatCount(int count) => count == 1 ? '1 chat' : '$count chats';
  String deleteAllChats(int count) =>
      es ? 'Eliminar los $count chats' : 'Delete all $count chats';
  String deleteAllChatsQuestion(int count) =>
      es ? '¿Eliminar los $count chats?' : 'Delete all $count chats?';
  String deleteChatWarning(int count) => count == 1
      ? (es
          ? 'Esta conversación y todos sus mensajes se perderán para siempre.'
          : 'This conversation and all its messages will be lost forever.')
      : (es
          ? 'Las $count conversaciones con este personaje se perderán para siempre.'
          : 'All $count conversations with this character will be lost forever.');
  String updateAvailable(String version) => es
      ? 'Pyre $version ya está disponible'
      : 'Pyre $version is out';
}

class AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const AppStringsDelegate();

  @override
  bool isSupported(Locale locale) => AppStrings.supportedLocales
      .any((item) => item.languageCode == locale.languageCode);

  @override
  Future<AppStrings> load(Locale locale) async => AppStrings(locale);

  @override
  bool shouldReload(covariant AppStringsDelegate old) => false;
}
