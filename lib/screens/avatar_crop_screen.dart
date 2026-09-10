import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../l10n/app_strings.dart';
import '../theme.dart';

class AvatarCropScreen extends StatefulWidget {
  final Uint8List sourceBytes;
  const AvatarCropScreen({super.key, required this.sourceBytes});

  @override
  State<AvatarCropScreen> createState() => _AvatarCropScreenState();
}

class _AvatarCropScreenState extends State<AvatarCropScreen> {
  final GlobalKey _captureKey = GlobalKey();
  final TransformationController _tx = TransformationController();
  bool _saving = false;

  String _t(String spanish, String english) => AppStrings.of(context).es ? spanish : english;

  @override
  void dispose() {
    _tx.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final boundary = _captureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) throw _t('no se pudo codificar la imagen', 'failed to encode');
      final data = bytes.buffer.asUint8List();
      if (!mounted) return;
      Navigator.of(context).pop(data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('Error al recortar: $e', 'Crop failed: $e'))),
      );
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String t(String spanish, String english) => AppStrings.of(context).es ? spanish : english;
    return Scaffold(
      backgroundColor: EmberColors.bgDeep,
      appBar: AppBar(
        title: Text(t('Recortar avatar', 'Crop avatar')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: t('Restablecer', 'Reset'),
            onPressed: () => _tx.value = Matrix4.identity(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text(t('Pellizca para ampliar · arrastra para posicionar', 'Pinch to zoom · drag to position'), style: TextStyle(color: EmberColors.textMid)),
            const SizedBox(height: 16),
            ClipOval(
              child: RepaintBoundary(
                key: _captureKey,
                child: SizedBox(
                  width: 256,
                  height: 256,
                  child: ColoredBox(
                    color: EmberColors.bgElevated,
                    child: InteractiveViewer(
                      transformationController: _tx,
                      minScale: 0.5,
                      maxScale: 4,
                      child: Image.memory(widget.sourceBytes, fit: BoxFit.contain, gaplessPlayback: true),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _saving ? null : () => Navigator.of(context).pop(null),
                  child: Text(t('Cancelar', 'Cancel')),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: Text(t('Usar este recorte', 'Use this crop')),
                  onPressed: _saving ? null : _save,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<Uint8List?> cropAvatar(BuildContext context, Uint8List sourceBytes) async {
  return Navigator.of(context).push<Uint8List>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => AvatarCropScreen(sourceBytes: sourceBytes),
    ),
  );
}
