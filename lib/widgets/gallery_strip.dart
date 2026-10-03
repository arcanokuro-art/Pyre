import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/attachment_store.dart';
import '../services/image_export.dart';
import '../theme.dart';
import 'lightbox.dart';

class GalleryStrip extends StatelessWidget {
  final List<String> refs;
  final String? avatarRef;
  final void Function(int index)? onUseAsAvatar;
  final String ownerName;

  const GalleryStrip({super.key, required this.refs, this.avatarRef, this.onUseAsAvatar, this.ownerName = ''});

  @override
  Widget build(BuildContext context) {
    if (refs.isEmpty) return const SizedBox.shrink();
    final es = AppStrings.of(context).es;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(top: 14, bottom: 8), child: Text(es ? 'GALERÍA' : 'GALLERY', style: TextStyle(color: EmberColors.textDim, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8))),
      SizedBox(height: 92, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: refs.length, separatorBuilder: (_, _) => const SizedBox(width: 8), itemBuilder: (_, i) => _Thumb(ref: refs[i], onTap: () => _openViewer(context, galleryIndex: i), onUseAsAvatar: onUseAsAvatar == null ? null : () => onUseAsAvatar!(i)))),
    ]);
  }

  void _openViewer(BuildContext context, {required int galleryIndex}) {
    final hasAvatar = avatarRef != null && avatarRef!.isNotEmpty;
    final order = <String>[if (hasAvatar) avatarRef!, ...refs];
    final avatarOffset = hasAvatar ? 1 : 0;
    Navigator.of(context).push(MaterialPageRoute(fullscreenDialog: true, builder: (_) => _GallerySwipeViewer(refs: order, initialIndex: avatarOffset + galleryIndex, galleryStartIndex: avatarOffset, ownerName: ownerName)));
  }
}

void showImageSwipeViewer(BuildContext context, {required List<String> refs, int initialIndex = 0, String ownerName = ''}) {
  if (refs.isEmpty) return;
  Navigator.of(context).push(MaterialPageRoute(fullscreenDialog: true, builder: (_) => _GallerySwipeViewer(refs: refs, initialIndex: initialIndex.clamp(0, refs.length - 1), ownerName: ownerName)));
}

class _Thumb extends StatelessWidget {
  final String ref;
  final VoidCallback onTap;
  final VoidCallback? onUseAsAvatar;
  const _Thumb({required this.ref, required this.onTap, this.onUseAsAvatar});

  ImageProvider? _resolve() {
    if (kIsWeb) {
      final req = AttachmentStore.webAttachmentRequest(ref);
      return req == null ? null : NetworkImage(req.url, headers: req.headers);
    }
    final f = AttachmentStore.fileForSync(ref);
    return f == null ? null : FileImage(f);
  }

  void _showActions(BuildContext context) {
    final useAsAvatar = onUseAsAvatar;
    if (useAsAvatar == null) return;
    final es = AppStrings.of(context).es;
    showModalBottomSheet<void>(context: context, backgroundColor: EmberColors.bgPanel, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))), builder: (sheet) => SafeArea(top: false, child: Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(leading: Icon(Icons.fullscreen, color: EmberColors.textMid), title: Text(es ? 'Ver en pantalla completa' : 'View fullscreen'), onTap: () { Navigator.pop(sheet); onTap(); }),
      ListTile(leading: Icon(Icons.account_circle_outlined, color: EmberColors.textMid), title: Text(es ? 'Usar como avatar' : 'Use as avatar'), onTap: () { Navigator.pop(sheet); useAsAvatar(); }),
    ])));
  }

  @override
  Widget build(BuildContext context) {
    final image = _resolve();
    return GestureDetector(onTap: onTap, onLongPress: onUseAsAvatar == null ? null : () => _showActions(context), child: Container(width: 84, height: 84, decoration: BoxDecoration(color: EmberColors.bgDeep, borderRadius: BorderRadius.circular(8), border: Border.all(color: EmberColors.stroke), image: image == null ? null : DecorationImage(image: image, fit: BoxFit.cover)), child: image == null ? Center(child: Icon(Icons.broken_image_outlined, color: EmberColors.textDim, size: 28)) : null));
  }
}

class _GallerySwipeViewer extends StatefulWidget {
  final List<String> refs;
  final int initialIndex;
  final int galleryStartIndex;
  final String ownerName;
  const _GallerySwipeViewer({required this.refs, required this.initialIndex, this.galleryStartIndex = 0, this.ownerName = ''});
  @override
  State<_GallerySwipeViewer> createState() => _GallerySwipeViewerState();
}

class _GallerySwipeViewerState extends State<_GallerySwipeViewer> {
  late final PageController _controller;
  late int _index;
  @override void initState() { super.initState(); _index = widget.initialIndex.clamp(0, widget.refs.length - 1); _controller = PageController(initialPage: _index); }
  @override void dispose() { _controller.dispose(); super.dispose(); }

  Future<void> _saveCurrent() async {
    final messenger = ScaffoldMessenger.of(context);
    final es = AppStrings.of(context).es;
    final bytes = await resolveAvatarBytes(widget.refs[_index]);
    if (!mounted) return;
    if (bytes == null) { messenger.showSnackBar(SnackBar(content: Text(es ? 'No se pudo cargar esta imagen para guardarla.' : "Couldn't load this image to save."))); return; }
    final safeOwner = widget.ownerName.replaceAll(RegExp(r'[^A-Za-z0-9 _\-.]'), '').trim().replaceAll(' ', '_');
    final owner = safeOwner.isEmpty ? 'image' : safeOwner;
    final isAvatarPage = _index < widget.galleryStartIndex;
    final filename = isAvatarPage ? '${owner}_avatar.png' : '${owner}_gallery_${_index - widget.galleryStartIndex + 1}.png';
    await saveImageBytesToExports(context, bytes, filename, shareSubject: widget.ownerName.isEmpty ? (es ? 'Imagen de Pyre' : 'Image from Pyre') : (es ? '${widget.ownerName} — imagen de Pyre' : '${widget.ownerName} — image from Pyre'));
  }

  @override
  Widget build(BuildContext context) {
    final es = AppStrings.of(context).es;
    final count = widget.refs.length;
    return Scaffold(backgroundColor: Colors.black.withValues(alpha: 0.96), body: SafeArea(child: Stack(children: [
      PageView.builder(controller: _controller, itemCount: count, onPageChanged: (i) => setState(() => _index = i), itemBuilder: (_, i) { final img = Lightbox.resolveImage(widget.refs[i]); final content = img == null ? const Center(child: Icon(Icons.broken_image_outlined, color: Colors.white54, size: 72)) : InteractiveViewer(minScale: 1, maxScale: 5, child: Center(child: Lightbox.imageWidget(img))); return GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).pop(), child: content); }),
      if (count > 1) Positioned(bottom: 16, left: 0, right: 0, child: Center(child: Text('${_index + 1} / $count', style: const TextStyle(color: Colors.white70, fontSize: 13)))),
      Positioned(top: 8, right: 8, child: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(tooltip: es ? 'Guardar imagen' : 'Save image', icon: const Icon(Icons.download, color: Colors.white), onPressed: _saveCurrent), IconButton(tooltip: es ? 'Cerrar' : 'Close', icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.of(context).pop())])),
    ])));
  }
}
