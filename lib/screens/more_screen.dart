import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_strings.dart';
import '../state/app_store.dart';
import '../theme.dart';
import '../services/lan_client.dart';
import '../services/update_check.dart';
import 'api_connections_screen.dart';
import 'lan_connect_screen.dart';
import 'network_settings_screen.dart';
import 'backup_restore_screen.dart';
import 'botbooru_profile_screen.dart';
import 'character_creator_screen.dart';
import 'chat_settings_screen.dart';
import 'theme_settings_screen.dart';
import 'about_pyre_screen.dart';
import 'desktop_shortcuts_screen.dart';
import 'storage_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final l = AppStrings.of(context);
    final notSet = l.es ? 'Sin configurar' : 'Not set';
    final activeProviderName = store.activeProvider?.name ?? notSet;
    final botbooruHandle = store.botbooruUsername.isEmpty ? notSet : store.botbooruUsername;

    return Scaffold(
      appBar: AppBar(title: Text(l.more)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        children: [
          _MoreCard(rows: [
            _MoreRow(
              label: l.es ? 'Conexiones API' : 'API Connections',
              trailing: activeProviderName,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ApiConnectionsScreen())),
            ),
            _MoreRow(
              label: l.es ? 'Perfil' : 'Profile',
              trailing: botbooruHandle,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BotbooruProfileScreen())),
            ),
          ]),
          const SizedBox(height: 12),
          _MoreCard(rows: [
            _MoreRow(
              label: l.appearance,
              trailing: _themeName(store.uiPrefs.activeThemeId),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ThemeSettingsScreen())),
            ),
            _MoreRow(
              label: l.es ? 'Idioma' : 'Language',
              trailing: store.uiPrefs.languageCode == 'en' ? 'English' : 'Español',
              onTap: () => _showLanguagePicker(context, store),
            ),
          ]),
          const SizedBox(height: 12),
          _MoreCard(rows: [
            _MoreRow(
              label: l.es ? 'Ajustes del creador' : 'Creator settings',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CharacterCreatorScreen())),
            ),
            _MoreRow(
              label: l.es ? 'Ajustes del chat' : 'Chat Settings',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChatSettingsScreen())),
            ),
          ]),
          const SizedBox(height: 12),
          _MoreCard(rows: [
            _MoreRow(
              label: l.storage,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StorageScreen())),
            ),
            _MoreRow(
              label: l.es ? 'Copia de seguridad y restauración' : 'Backup and Restore',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BackupRestoreScreen())),
            ),
            _MoreRow(
              label: l.es ? 'Acerca de Pyre' : 'About Pyre',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AboutPyreScreen())),
            ),
          ]),
          if (kIsWeb || Platform.isAndroid || Platform.isIOS) ...[
            const SizedBox(height: 12),
            _MoreCard(rows: [
              _MoreRow(
                label: l.es ? 'Conectar a LAN' : 'Connect to LAN',
                trailing: LanClient.instance.isPaired
                    ? (l.es ? 'Vinculado' : 'Paired')
                    : (l.es ? 'Sin vincular' : 'Not paired'),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LanConnectScreen())),
              ),
            ]),
          ],
          if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) ...[
            const SizedBox(height: 12),
            _MoreCard(rows: [
              _MoreRow(
                label: l.es ? 'Atajos de escritorio' : 'Desktop Shortcuts',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DesktopShortcutsScreen())),
              ),
              _MoreRow(
                label: l.es ? 'Red (sincronización LAN)' : 'Network (LAN sync)',
                trailing: store.uiPrefs.lanServerEnabled
                    ? (l.es ? 'Activado' : 'On')
                    : (l.es ? 'Desactivado' : 'Off'),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NetworkSettingsScreen())),
              ),
            ]),
          ],
          const _VersionFooter(),
        ],
      ),
    );
  }
}

Future<void> _showLanguagePicker(BuildContext context, AppStore store) async {
  final l = AppStrings.of(context);
  final selected = await showModalBottomSheet<String>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: Text(l.es ? 'Idioma' : 'Language', style: const TextStyle(fontWeight: FontWeight.w700))),
          ListTile(
            leading: Icon(store.uiPrefs.languageCode == 'es' ? Icons.radio_button_checked : Icons.radio_button_off),
            title: const Text('Español'),
            onTap: () => Navigator.of(sheetContext).pop('es'),
          ),
          ListTile(
            leading: Icon(store.uiPrefs.languageCode == 'en' ? Icons.radio_button_checked : Icons.radio_button_off),
            title: const Text('English'),
            onTap: () => Navigator.of(sheetContext).pop('en'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (selected != null) store.setLanguageCode(selected);
}

class _VersionFooter extends StatefulWidget {
  const _VersionFooter();
  @override
  State<_VersionFooter> createState() => _VersionFooterState();
}

class _VersionFooterState extends State<_VersionFooter> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    if (availableUpdateNotifier.value == null) checkForUpdate();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _version = info.version);
    }).catchError((_) {});
  }

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l = AppStrings.of(context);
    return ValueListenableBuilder<UpdateInfo?>(
      valueListenable: availableUpdateNotifier,
      builder: (context, update, _) => Column(children: [
        const SizedBox(height: 16),
        Center(child: Text(_version.isEmpty ? 'Pyre' : 'Pyre $_version', style: TextStyle(color: EmberColors.textDim, fontSize: 11))),
        if (update != null && update.latestVersion != context.watch<AppStore>().dismissedUpdateVersion) ...[
          const SizedBox(height: 12),
          Center(child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: update.url.isEmpty ? null : () => _open(update.url),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: EmberColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: EmberColors.primary.withValues(alpha: 0.5)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.system_update_alt, size: 20, color: EmberColors.primary),
                const SizedBox(width: 10),
                Flexible(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.es ? 'Actualización disponible — Pyre ${update.latestVersion}' : 'Update available — Pyre ${update.latestVersion}', style: TextStyle(color: EmberColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                  if (update.notes.isNotEmpty)
                    Padding(padding: const EdgeInsets.only(top: 2), child: Text(update.notes, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: EmberColors.textMid, fontSize: 11)))
                  else
                    Padding(padding: const EdgeInsets.only(top: 2), child: Text(l.es ? 'Toca para descargar la versión más reciente.' : 'Tap to download the latest release.', style: TextStyle(color: EmberColors.textMid, fontSize: 11))),
                ])),
                const SizedBox(width: 10),
                Icon(Icons.download_rounded, size: 20, color: EmberColors.primary),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  color: EmberColors.textDim,
                  visualDensity: VisualDensity.compact,
                  tooltip: l.es ? 'Descartar' : 'Dismiss',
                  onPressed: () => context.read<AppStore>().dismissUpdate(update.latestVersion),
                ),
              ]),
            ),
          )),
        ],
      ]),
    );
  }
}

class _MoreCard extends StatelessWidget {
  final List<_MoreRow> rows;
  const _MoreCard({required this.rows});
  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      children.add(rows[i]);
      if (i < rows.length - 1) children.add(Divider(color: EmberColors.stroke, height: 1, indent: 16, endIndent: 16));
    }
    return Card(margin: EdgeInsets.zero, child: Column(children: children));
  }
}

class _MoreRow extends StatelessWidget {
  final String label;
  final String? trailing;
  final VoidCallback? onTap;
  const _MoreRow({required this.label, this.trailing, this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Row(children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
        if (trailing != null) ...[
          Text(trailing!, style: TextStyle(color: EmberColors.textMid, fontSize: 13)),
          const SizedBox(width: 6),
        ],
        Icon(Icons.chevron_right, color: EmberColors.textDim, size: 22),
      ]),
    ),
  );
}

String _themeName(String id) => paletteById(id).name;
