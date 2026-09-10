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
