import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../theme.dart';

/// Shows a small confirmation dialog for destructive actions.
///
/// Returns `true` when the user explicitly confirms via the danger-coloured
/// button. Tapping cancel or dismissing the dialog resolves to `false`.
Future<bool> confirmDelete(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
  String? cancelLabel,
}) async {
  final es = AppStrings.of(context).es;
  final resolvedConfirmLabel = confirmLabel ?? (es ? 'Eliminar' : 'Delete');
  final resolvedCancelLabel = cancelLabel ?? (es ? 'Cancelar' : 'Cancel');
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: EmberColors.bgPanel,
      title: Text(title),
      content: Text(
        message,
        style: TextStyle(color: EmberColors.textMid),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(resolvedCancelLabel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: TextButton.styleFrom(foregroundColor: EmberColors.danger),
          child: Text(resolvedConfirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
