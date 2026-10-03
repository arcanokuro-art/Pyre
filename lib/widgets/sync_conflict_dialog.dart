// Mega-audit 2026-06-05 (H-4): the WARNING dialog shown before a pull is
// applied when the user picked SyncConflictMode.ask and a genuine conflict
// (the same item changed on BOTH devices since the last sync) was detected.

import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/sync_conflict.dart';
import '../theme.dart';

String _kindLabel(String kind, bool es) {
  switch (kind) {
    case 'character':
      return es ? 'Personaje' : 'Character';
    case 'persona':
      return 'Persona';
    case 'chat':
      return es ? 'Chat' : 'Chat';
    case 'preset':
      return es ? 'Preajuste' : 'Preset';
    case 'lorebook':
      return es ? 'Libro de lore' : 'Lorebook';
    case 'regexRule':
      return es ? 'Regla regex' : 'Regex rule';
    case 'folder':
      return es ? 'Carpeta' : 'Folder';
    case 'creatorPreset':
      return es ? 'Preajuste del creador' : 'Creator preset';
    default:
      return kind;
  }
}

Future<bool?> showSyncConflictDialog(
  BuildContext context,
  List<SyncConflict> conflicts,
) {
  final es = AppStrings.of(context).es;
  String t(String spanish, String english) => es ? spanish : english;
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return AlertDialog(
        title: Text(t('Conflicto de sincronización', 'Sync conflict')),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 360, maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                conflicts.length == 1
                    ? t(
                        '1 elemento cambió tanto en este dispositivo como en el otro desde la última sincronización. Elige qué copia conservar.',
                        '1 item was changed on both this device and the other device since the last sync. Choose which copy to keep.',
                      )
                    : t(
                        '${conflicts.length} elementos cambiaron tanto en este dispositivo como en el otro desde la última sincronización. Elige qué copia conservar (se aplicará a todos).',
                        '${conflicts.length} items were changed on both this device and the other device since the last sync. Choose which copy to keep (applies to all).',
                      ),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: conflicts.length,
                  itemBuilder: (_, i) {
                    final c = conflicts[i];
                    final name = c.remote.name.isNotEmpty
                        ? c.remote.name
                        : (c.local.name.isNotEmpty ? c.local.name : c.id);
                    final rawNewer = c.newerSideLabel;
                    final newer = es
                        ? (rawNewer == 'This device'
                            ? 'Este dispositivo'
                            : rawNewer == 'Other device'
                                ? 'Otro dispositivo'
                                : rawNewer)
                        : rawNewer;
                    final deletedNote = c.remote.deleted
                        ? t(' · eliminado en el otro dispositivo', ' · deleted on other device')
                        : (c.local.deleted
                            ? t(' · eliminado en este dispositivo', ' · deleted on this device')
                            : '');
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Text(
                        es
                            ? '• ${_kindLabel(c.kind, true)}: $name  (más reciente: $newer$deletedNote)'
                            : '• ${_kindLabel(c.kind, false)}: $name  (newer: $newer$deletedNote)',
                        style: TextStyle(fontSize: 12, color: EmberColors.textMid),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: Text(t('Cancelar', 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t('Conservar este dispositivo', 'Keep this device')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t('Usar el otro dispositivo', 'Take other device')),
          ),
        ],
      );
    },
  );
}
