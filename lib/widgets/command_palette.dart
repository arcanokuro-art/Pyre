// Wave CY.18.58: extracted from main.dart so the More screen can also
// open the same palette (without dragging a private `_class` import).

import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/desktop_shortcuts.dart';
import '../services/focus_bus.dart';
import '../state/app_store.dart';

Future<void> showCommandPalette(BuildContext context, AppStore store) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => CommandPaletteDialog(store: store),
  );
}

class CommandPaletteDialog extends StatelessWidget {
  final AppStore store;
  const CommandPaletteDialog({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final es = AppStrings.of(context).es;
    String t(String spanish, String english) => es ? spanish : english;
    String shortcutFor(String actionId) =>
        effectiveBinding(actionId, store.uiPrefs).label();

    final entries = <_PaletteEntry>[
      _PaletteEntry(
        label: t('Abrir Ajustes', 'Open Settings'),
        shortcut: shortcutFor(ShortcutAction.openSettings),
        icon: Icons.settings_outlined,
        run: () => store.setActiveTab('more'),
      ),
      _PaletteEntry(
        label: t('Nuevo chat — elegir un personaje', 'New chat — pick a character'),
        shortcut: shortcutFor(ShortcutAction.newChat),
        icon: Icons.chat_bubble_outline,
        run: () => store.setActiveTab('characters'),
      ),
      _PaletteEntry(
        label: t('Buscar personajes', 'Search characters'),
        shortcut: shortcutFor(ShortcutAction.searchCharacters),
        icon: Icons.search,
        run: () {
          store.setActiveTab('characters');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            FocusBus.focusCharactersSearch();
          });
        },
      ),
      _PaletteEntry(
        label: t('Abrir lista de chats', 'Open chats list'),
        shortcut: null,
        icon: Icons.forum_outlined,
        run: () => store.setActiveTab('chats'),
      ),
      _PaletteEntry(
        label: t('Descubrir (BotBooru)', 'Discover (BotBooru)'),
        shortcut: null,
        icon: Icons.explore_outlined,
        run: () => store.setActiveTab('discover'),
      ),
      _PaletteEntry(
        label: t('Mostrar esta paleta', 'Show this palette'),
        shortcut: shortcutFor(ShortcutAction.commandPalette),
        icon: Icons.search,
        run: null,
      ),
      _PaletteEntry(
        label: t('Enviar mensaje (en el campo de chat)', 'Send message (in chat input)'),
        shortcut: 'Enter',
        icon: Icons.send_outlined,
        run: null,
      ),
      _PaletteEntry(
        label: t('Nueva línea (en el campo de chat)', 'New line (in chat input)'),
        shortcut: 'Shift + Enter',
        icon: Icons.subdirectory_arrow_left,
        run: null,
      ),
    ];

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 60, vertical: 80),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    t('Pyre — comandos', 'Pyre — commands'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    iconSize: 18,
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: t('Cerrar', 'Close'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: entries.length,
                itemBuilder: (ctx, i) {
                  final e = entries[i];
                  return ListTile(
                    leading: Icon(e.icon),
                    title: Text(e.label),
                    trailing: e.shortcut == null
                        ? null
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              e.shortcut!,
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                            ),
                          ),
                    onTap: e.run == null
                        ? null
                        : () {
                            Navigator.of(context).pop();
                            e.run!();
                          },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaletteEntry {
  final String label;
  final String? shortcut;
  final IconData icon;
  final VoidCallback? run;
  _PaletteEntry({required this.label, required this.shortcut, required this.icon, required this.run});
}
