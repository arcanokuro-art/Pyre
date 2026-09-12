// Desktop-only pairing confirmation dialog.

import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/pairing_requests.dart';
import '../services/pyre_server.dart';

Future<void> showPairRequestDialog(
    BuildContext context, PendingPairRequest req) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final es = AppStrings.of(ctx).es;
      String t(String spanish, String english) => es ? spanish : english;
      return AlertDialog(
        title: Text(t('¿Permitir que este dispositivo se vincule?',
            'Allow this device to pair?')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t(
              'Un dispositivo quiere vincularse con esta PC y leer o modificar tu biblioteca a través de la red local.',
              'A device wants to pair with this PC and read/write your library over the local network.',
            )),
            const SizedBox(height: 14),
            Text(
              t('Desde:  ${req.requesterLabel}', 'From:  ${req.requesterLabel}'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (req.deviceName.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(t('Nombre:  ${req.deviceName.trim()}',
                    'Name:  ${req.deviceName.trim()}')),
              ),
            const SizedBox(height: 14),
            Text(
              t(
                'Permítelo únicamente si acabas de abrir Pyre en un navegador. Si no esperabas esta solicitud, pulsa Denegar.',
                'Only allow this if you just opened Pyre in a browser yourself. If you weren’t expecting it, tap Deny.',
              ),
              style: TextStyle(
                fontSize: 12.5,
                color: Theme.of(ctx).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              PyreServer.instance.denyPairRequest(req.requestId);
              Navigator.of(ctx).pop();
            },
            child: Text(t('Denegar', 'Deny')),
          ),
          TextButton(
            onPressed: () async {
              final nav = Navigator.of(ctx);
              await PyreServer.instance.approvePairRequest(req.requestId);
              nav.pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.primary,
            ),
            child: Text(t('Permitir', 'Allow')),
          ),
        ],
      );
    },
  );
}
