import 'package:flutter/material.dart';

import '../theme.dart';
import '../models/models.dart';
import 'persona_editor.dart';
import 'structured_persona_editor.dart';

/// Chooser shown by Personas -> Create -> Create manually.
Future<void> showManualPersonaGenderChooser(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: EmberColors.bgPanel,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheet) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Crear persona manualmente',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.male, color: EmberColors.primary),
              title: const Text('Usuario hombre'),
              onTap: () {
                Navigator.pop(sheet);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const StructuredPersonaEditorScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.female, color: EmberColors.primary),
              title: const Text('Usuario mujer'),
              onTap: () {
                Navigator.pop(sheet);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const StructuredPersonaEditorScreen(isWoman: true),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

/// Structured personas reopen in their original editor. Legacy personas keep their own editor.
void showManualPersonaEditor(
  BuildContext context, {
  required Persona existing,
}) {
  final identity = existing.structuredProfile['identidad'];
  final gender = identity is Map ? identity['genero'] : null;
  if (gender == 'hombre' || gender == 'mujer') {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StructuredPersonaEditorScreen(
          existing: existing,
          isWoman: gender == 'mujer',
        ),
      ),
    );
  } else {
    showPersonaEditor(context, existing: existing);
  }
}
