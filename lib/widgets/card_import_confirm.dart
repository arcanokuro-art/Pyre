import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/models.dart';
import '../theme.dart';

/// Shows the imported character's text fields BEFORE committing the import.
///
/// Character cards are user-supplied content that gets templated into every
/// system prompt — including text that purports to be "AI instructions" or
/// "system rules". A malicious card can attempt prompt injection. Surfacing
/// the raw content forces the user to review what they're about to add.
typedef CardImportChoice = ({bool import, bool withGallery});

Future<CardImportChoice> confirmCardImport(
  BuildContext context,
  Character c, {
  int galleryCount = 0,
}) async {
  final es = AppStrings.of(context).es;
  String t(String spanish, String english) => es ? spanish : english;

  final preview = StringBuffer();
  if (c.tagline != null && c.tagline!.isNotEmpty) {
    preview.writeln('${t('Eslogan', 'Tagline')}:\n${c.tagline}\n');
  }
  if (c.description.isNotEmpty) {
    preview.writeln('${t('Descripción', 'Description')}:\n${c.description}\n');
  }
  if (c.personality.isNotEmpty) {
    preview.writeln('${t('Personalidad', 'Personality')}:\n${c.personality}\n');
  }
  if (c.scenario.isNotEmpty) {
    preview.writeln('${t('Escenario', 'Scenario')}:\n${c.scenario}\n');
  }
  if (c.systemPrompt.isNotEmpty) {
    preview.writeln(
      '${t('Prompt del sistema (se añade a cada respuesta)', 'System prompt (added to every reply)')}:\n${c.systemPrompt}\n',
    );
  }
  if (c.postHistoryInstructions.isNotEmpty) {
    preview.writeln(
      '${t('Bloque posterior al historial', 'Post-history block')}:\n${c.postHistoryInstructions}\n',
    );
  }

  var withGallery = galleryCount > 0;
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        backgroundColor: EmberColors.bgPanel,
        title: Text(t('¿Importar «${c.name}»?', 'Import "${c.name}"?')),
        content: SizedBox(
          width: 500,
          height: 380,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t(
                  'El texto de esta tarjeta se añade a cada prompt del sistema enviado a la IA. Revísalo antes de importarla: una tarjeta maliciosa puede intentar realizar una inyección de prompt.',
                  'This card\'s text is added to every system prompt sent to the AI. Review it before importing — malicious cards can attempt prompt injection.',
                ),
                style: TextStyle(
                  color: EmberColors.textMid,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: EmberColors.bgElevated,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: EmberColors.stroke),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      preview.toString().trim().isEmpty
                          ? t('(No hay campos de descripción configurados.)', '(No description fields set.)')
                          : preview.toString().trim(),
                      style: const TextStyle(fontSize: 12, height: 1.4),
                    ),
                  ),
                ),
              ),
              if (galleryCount > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: CheckboxListTile(
                    value: withGallery,
                    onChanged: (v) => setState(() => withGallery = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(
                      es
                          ? 'Importar galería ($galleryCount ${galleryCount == 1 ? 'imagen' : 'imágenes'})'
                          : 'Import gallery ($galleryCount ${galleryCount == 1 ? 'image' : 'images'})',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t('Cancelar', 'Cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t('Importar', 'Import')),
          ),
        ],
      ),
    ),
  );
  final imported = result == true;
  return (import: imported, withGallery: imported && withGallery);
}
