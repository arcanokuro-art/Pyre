import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/attachment_store.dart';

@visibleForTesting
final Map<String, MemoryImage> rawBase64Cache = <String, MemoryImage>{};
const int _rawBase64CacheMax = 16;

/// Tap-to-dismiss fullscreen image viewer with pinch-zoom + pan.
class Lightbox extends StatelessWidget {
  final String? dataUrl;
  final String? heroTag;
  final String fallback;
  const Lightbox({
    super.key,
    required this.dataUrl,
    required this.fallback,
    this.heroTag,
  });

  ImageProvider? _decode() => resolveImage(dataUrl);

  /// Resolve any avatar/gallery image reference to an [ImageProvider].
  static ImageProvider? resolveImage(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('data:')) {
      final comma = url.indexOf(',');
      if (comma > 0) {
        try {
          return MemoryImage(
            Uint8List.fromList(base64Decode(url.substring(comma + 1))),
          );
        } catch (_) {}
      }
      return null;
    }
    if (url.startsWith('http')) return NetworkImage(url);
    if (AttachmentStore.isPyreUrl(url)) {
      if (kIsWeb) {
        final req = AttachmentStore.webAttachmentRequest(url);
        if (req != null) return NetworkImage(req.url, headers: req.headers);
        return null;
      }
      final f = AttachmentStore.fileForSync(url);
      if (f != null) return FileImage(f);
      return null;
    }
    try {
      final cleaned = url.replaceAll(RegExp(r'\s+'), '');
      if (cleaned.length >= 16) {
        final existing = rawBase64Cache[cleaned];
        if (existing != null) return existing;
        final img = MemoryImage(Uint8List.fromList(base64Decode(cleaned)));
        if (rawBase64Cache.length >= _rawBase64CacheMax) {
          rawBase64Cache.clear();
        }
        rawBase64Cache[cleaned] = img;
        return img;
      }
    } catch (_) {}
    return null;
  }

  static Widget imageWidget(ImageProvider img) => Image(
        image: img,
        errorBuilder: (_, _, _) => const Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: Colors.white54,
            size: 72,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final es = AppStrings.of(context).es;
    final img = _decode();
    final content = img == null
        ? Center(
            child: Text(
              fallback.isNotEmpty
                  ? fallback.characters.first.toUpperCase()
                  : '?',
              style: const TextStyle(color: Colors.white, fontSize: 96),
            ),
          )
        : InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: Center(
              child: heroTag != null
                  ? Hero(tag: heroTag!, child: imageWidget(img))
                  : imageWidget(img),
            ),
          );
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.96),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
                child: content,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                tooltip: es ? 'Cerrar' : 'Close',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void show(
    BuildContext context, {
    required String? dataUrl,
    required String fallback,
    String? heroTag,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => Lightbox(
          dataUrl: dataUrl,
          fallback: fallback,
          heroTag: heroTag,
        ),
      ),
    );
  }
}
