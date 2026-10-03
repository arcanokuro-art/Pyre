import 'package:flutter/material.dart';

import '../theme.dart';
import 'persona_editor.dart';

/// Chooser shown by Personas -> Create -> Create manually.
/// Male is implemented first; female deliberately has a stable entry point
/// ready for its future schema instead of inventing fields before design.
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
            const Text('Create persona manually',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.male, color: EmberColors.primary),
              title: const Text('Male user'),
              subtitle: const Text('Create {{user}} Male'),
              onTap: () {
                Navigator.pop(sheet);
                showPersonaEditor(context, profileGender: 'male');
              },
            ),
            ListTile(
              enabled: false,
              leading: const Icon(Icons.female),
              title: const Text('Female user'),
              subtitle: const Text('Coming soon'),
            ),
          ],
        ),
      ),
    ),
  );
}
