// Wave CY.18.128: reusable native gallery editor section.

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/attachment_store.dart';
import '../services/image_pick.dart';
import '../theme.dart';

class GalleryEditorSection extends StatefulWidget {
  final List<String> gallery;
  final void Function(List<String>) onChanged;
  final void Function(int index)? onUseAsAvatar;

  const GalleryEditorSection({
    super.key,
    required this.gallery,
    required this.onChanged,
    this.onUseAsAvatar,
  });

  @override
  State<GalleryEditorSection> createState() => _GalleryEditorSectionState();
}

class _GalleryEditorSectionState extends State<GalleryEditorSection> {
  bool _adding = false;

  Future<void> _addImage() async {
    if (kIsWeb || _adding) return;
    setState(() => _adding = true);
    try {
      final picked = await pickOneImage();
      if (picked == null) return;
      final bytes = picked.bytes;
      if (bytes.isEmpty) return;
      final ext = picked.ext;
      final mime = ext.isEmpty ? 'image/png' : 'image/$ext';
      final ref = await AttachmentStore.store(bytes, mime: mime);
      if (ref == null) return;
      if (!mounted) return;
      widget.onChanged([...widget.gallery, ref]);
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  void _remove(int index) {
    if (index < 0 || index >= widget.gallery.length) return;
    final next = [...widget.gallery]..removeAt(index);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final es = AppStrings.of(context).es;
    String t(String spanish, String english) => es ? spanish : english;
    final gallery = widget.gallery;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 4),
          child: Text(
            t('GALERÍA', 'GALLERY'),
            style: TextStyle(
              color: EmberColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            t(
              'Imágenes adicionales aparte del avatar. Toca una miniatura para ver las opciones.',
              'Extra images beyond the avatar. Tap a thumbnail for options.',
            ),
            style: TextStyle(color: EmberColors.textMid, fontSize: 12, height: 1.4),
          ),
        ),
        if (gallery.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              t('Todavía no hay imágenes en la galería.', 'No gallery images yet.'),
              style: TextStyle(color: EmberColors.textDim, fontSize: 13),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < gallery.length; i++)
                _GalleryThumb(
                  ref: gallery[i],
                  index: i,
                  onRemove: () => _remove(i),
                  onUseAsAvatar: widget.onUseAsAvatar == null
                      ? null
                      : () => widget.onUseAsAvatar!(i),
                ),
            ],
          ),
        if (kIsWeb)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              t(
                'Añade imágenes a la galería desde la aplicación de escritorio o móvil.',
                'Add gallery images on desktop or mobile.',
              ),
              style: TextStyle(color: EmberColors.textDim, fontSize: 12),
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: _adding
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_photo_alternate_outlined, size: 18),
              label: Text(t('Añadir imagen', 'Add image')),
              onPressed: _adding ? null : _addImage,
            ),
          ),
      ],
    );
  }
}

class _GalleryThumb extends StatelessWidget {
  final String ref;
  final int index;
  final VoidCallback onRemove;
  final VoidCallback? onUseAsAvatar;

  const _GalleryThumb({
    required this.ref,
    required this.index,
    required this.onRemove,
    this.onUseAsAvatar,
  });

  ImageProvider? _resolve() {
    if (kIsWeb) return null;
    final f = AttachmentStore.fileForSync(ref);
    if (f == null) return null;
    return FileImage(f);
  }

  void _showActions(BuildContext context) {
    final es = AppStrings.of(context).es;
    String t(String spanish, String english) => es ? spanish : english;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: EmberColors.bgPanel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheet) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onUseAsAvatar != null)
              ListTile(
                leading: Icon(Icons.account_circle_outlined, color: EmberColors.textMid),
                title: Text(t('Usar como avatar', 'Use as avatar')),
                onTap: () {
                  Navigator.pop(sheet);
                  onUseAsAvatar!();
                },
              ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: EmberColors.danger),
              title: Text(t('Quitar de la galería', 'Remove from gallery')),
              onTap: () {
                Navigator.pop(sheet);
                onRemove();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = _resolve();
    const double size = 84;
    return GestureDetector(
      onTap: () => _showActions(context),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: EmberColors.bgDeep,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: EmberColors.stroke),
          image: image == null ? null : DecorationImage(image: image, fit: BoxFit.cover),
        ),
        child: image == null
            ? Center(
                child: Icon(Icons.broken_image_outlined, color: EmberColors.textDim, size: 28),
              )
            : null,
      ),
    );
  }
}
