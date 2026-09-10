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
