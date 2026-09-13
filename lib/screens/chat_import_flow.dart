// UI flow for importing a single Pyre chat file.
// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/models.dart';
import '../services/chat_import.dart';
import '../state/app_store.dart';
import '../theme.dart';

const int _kMaxChatImportBytes = 25 * 1024 * 1024;

Future<void> runPyreChatImport(BuildContext context, AppStore store) async {
  final messenger = ScaffoldMessenger.of(context);
  final es = AppStrings.of(context).es;
  String t(String spanish, String english) => es ? spanish : english;

  final FilePickerResult? result;
  try {
    result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json', 'jsonl'],
      withData: true,
    );
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(t('No se pudo abrir el selector de archivos: $e', 'Could not open picker: $e'))));
    return;
  }
  if (result == null || result.files.isEmpty) return;

  final file = result.files.single;
  final bytes = file.bytes;
  if (bytes == null) {
    messenger.showSnackBar(SnackBar(content: Text(t('No se pudo leer el archivo del chat.', 'Could not read the chat file.'))));
    return;
  }
  if (bytes.length > _kMaxChatImportBytes) {
    messenger.showSnackBar(SnackBar(content: Text(t(
      'El archivo del chat es demasiado grande (${(bytes.length / 1024 / 1024).toStringAsFixed(1)} MB). El máximo es 25 MB.',
      'Chat file is too large (${(bytes.length / 1024 / 1024).toStringAsFixed(1)} MB). Max 25 MB.',
    ))));
    return;
  }

  final String content;
  try {
    content = utf8.decode(bytes);
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(t(
      'Este archivo no contiene texto válido; puede estar dañado.',
      "This file isn't valid text — it may be corrupted.",
    ))));
    return;
  }

  final ChatImportResult imported;
  try {
    imported = importChat(
      content,
      knownCharacterIds: store.characters.map((c) => c.id).toSet(),
      existingChatIds: store.chats.map((c) => c.id).toSet(),
    );
  } on ChatImportException catch (e) {
    final message = es
        ? switch (e.kind) {
            ChatImportErrorKind.notReadable =>
              'No se pudo leer el archivo como un chat válido de Pyre o SillyTavern.',
            ChatImportErrorKind.unsupported =>
              'El archivo de chat no es compatible o contiene datos dañados.',
            ChatImportErrorKind.empty =>
              'El archivo de chat no contiene mensajes.',
          }
        : e.message;
    messenger.showSnackBar(SnackBar(content: Text(message)));
    return;
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(t('Error al importar: $e', 'Import failed: $e'))));
    return;
  }

  final chat = imported.chat;
  final primary = chat.primaryCharacterId;
  if (imported.summary.characterBound && primary != null && chat.characterSnapshots.isEmpty) {
    final live = store.characterById(primary);
    if (live != null) {
      chat.characterSnapshots[primary] = Character.fromJson(live.toJson());
    }
  }

  store.addImportedChat(chat);

  if (!context.mounted) return;
  await _showChatImportSummary(context, imported.summary);
}

Future<void> _showChatImportSummary(BuildContext context, ChatImportSummary summary) async {
  final es = AppStrings.of(context).es;
  String t(String spanish, String english) => es ? spanish : english;
  String quantity(int n, String singularEs, String pluralEs, String singularEn, String pluralEn) =>
      es ? '$n ${n == 1 ? singularEs : pluralEs}' : '$n ${n == 1 ? singularEn : pluralEn}';

  final formatLabel = switch (summary.format) {
    ChatImportFormat.pyreJson => t('Pyre JSON (fidelidad completa)', 'Pyre JSON (full fidelity)'),
    ChatImportFormat.pyreJsonl => 'Pyre JSONL',
    ChatImportFormat.foreignJsonl => 'SillyTavern JSONL',
  };

  final displayTitle = es && summary.title == 'Imported chat'
      ? 'Chat importado'
      : summary.title;

  String localizedWarning(String warning) {
    if (!es) return warning;
    if (warning.startsWith('A chat with the same id already exists')) {
      return 'Ya existe un chat con el mismo identificador; se importó como una copia nueva.';
    }
    if (warning.startsWith('JSONL import restores the message timeline only')) {
      return 'La importación JSONL restaura únicamente la cronología de mensajes; el título del chat, la memoria y las instantáneas de ramas están disponibles en la exportación JSON de Pyre con fidelidad completa.';
    }
    if (warning.contains("isn't in your library")) {
      final match = RegExp(r"The character '(.+)' isn't in your library").firstMatch(warning);
      final name = match?.group(1);
      final subject = name != null
          ? 'El personaje «$name» no está en tu biblioteca'
          : 'El personaje de este chat no está en tu biblioteca';
      if (warning.contains('standalone copy')) {
        final snapshotNote = warning.contains('snapshot saved in the file')
            ? ' (usa la instantánea guardada en el archivo)'
            : '';
        return '$subject; se importó como una copia independiente$snapshotNote.';
      }
      if (warning.contains('standalone chat')) {
        return '$subject; se importó como un chat independiente.';
      }
    }
    return warning;
  }

  final lines = <String>[
    t(
      'Se importó «$displayTitle» — ${quantity(summary.messageCount, 'mensaje', 'mensajes', 'message', 'messages')}.',
      'Imported "$displayTitle" — ${quantity(summary.messageCount, 'mensaje', 'mensajes', 'message', 'messages')}.',
    ),
  ];
  if (summary.variantCount > 0) {
    lines.add(t(
      '${quantity(summary.variantCount, 'mensaje', 'mensajes', 'message', 'messages')} con respuestas alternativas guardadas restauradas.',
      '${quantity(summary.variantCount, 'mensaje', 'mensajes', 'message', 'messages')} with saved alternates restored.',
    ));
  }
  lines.add(summary.characterBound
      ? t('Vinculado con su personaje de tu biblioteca.', 'Linked to its character in your library.')
      : t('Importado como chat independiente.', 'Imported as a standalone chat.'));
  lines.add(t('Formato: $formatLabel.', 'Format: $formatLabel.'));
  lines.addAll(summary.warnings.map(localizedWarning));

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: EmberColors.bgPanel,
      title: Row(
        children: [
          Icon(Icons.download_done, color: EmberColors.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(child: Text(t('Chat importado', 'Chat imported'))),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < lines.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              Text(lines[i], style: TextStyle(color: i == 0 ? EmberColors.textHigh : EmberColors.textMid, fontSize: 14, height: 1.4, fontWeight: i == 0 ? FontWeight.w600 : FontWeight.w400)),
            ],
          ],
        ),
      ),
      actions: [
        FilledButton(onPressed: () => Navigator.pop(ctx), child: Text(t('Listo', 'Done'))),
      ],
    ),
  );
}
