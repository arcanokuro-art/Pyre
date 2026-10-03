import 'dart:async';
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_strings.dart';

/// Show an export confirmation SnackBar that is guaranteed to dismiss.
void showExportSnack(
  ScaffoldMessengerState messenger,
  String banner,
  Future<void> Function()? onShare, {
  Duration visible = const Duration(seconds: 4),
  bool spanish = false,
}) {
  final controller = messenger.showSnackBar(
    SnackBar(
      content: Text(banner),
      action: onShare == null
          ? null
          : SnackBarAction(
              label: spanish ? 'Compartir' : 'Share',
              onPressed: () => onShare(),
            ),
      duration: visible,
    ),
  );
  Timer(visible + const Duration(seconds: 1), () {
    try {
      controller.close();
    } catch (_) {
      // Messenger gone (user navigated away) — nothing to close.
    }
  });
}

/// Deliver a freshly-exported file to the user the right way for the platform.
Future<void> deliverExport(
  ScaffoldMessengerState messenger,
  List<XFile> files, {
  required String savedBanner,
  required String shareSubject,
  required String shareText,
  Uint8List? saveBytes,
  String? saveFileName,
  List<String>? saveExtensions,
  BuildContext? context,
}) async {
  final es = context != null && AppStrings.of(context).es;
  String t(String spanish, String english) => es ? spanish : english;

  Future<void> share() async {
    try {
      await Share.shareXFiles(files, subject: shareSubject, text: shareText);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(t('No se pudo compartir: $e', 'Share failed: $e'))),
      );
    }
  }

  final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  if (isMobile) {
    if (saveBytes != null && saveFileName != null) {
      String? savedPath;
      try {
        savedPath = await FilePicker.platform.saveFile(
          dialogTitle: t('Guardar $saveFileName', 'Save $saveFileName'),
          fileName: saveFileName,
          bytes: saveBytes,
          type: saveExtensions == null ? FileType.any : FileType.custom,
          allowedExtensions: saveExtensions,
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text(t('No se pudo guardar: $e', 'Save failed: $e'))),
        );
      }
      showExportSnack(
        messenger,
        savedPath != null
            ? t('Guardado en tu dispositivo', 'Saved to your device')
            : t('No se guardó. ¿Quieres compartir el archivo?', 'Not saved — share it?'),
        share,
        spanish: es,
      );
      return;
    }
    await share();
    return;
  }
  messenger.hideCurrentSnackBar();
  showExportSnack(messenger, savedBanner, share, spanish: es);
}
