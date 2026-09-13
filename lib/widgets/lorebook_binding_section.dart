import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_strings.dart';
import '../models/models.dart';
import '../state/app_store.dart';
import '../theme.dart';

Future<bool?> askEmbeddedChoice(BuildContext context) {
  final es = AppStrings.of(context).es;
  String t(String s, String e) => es ? s : e;
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: EmberColors.bgPanel,
      title: Text(t('Conservar este lorebook…', 'Keep this lorebook…')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t('Integrado (solo tarjeta): permanece con esta tarjeta, oculto de la lista de Lorebooks. Viaja dentro de la tarjeta al exportarla.', 'Embedded (card-only): lives with this card, hidden from the Lorebooks list. Travels inside the card on export.'), style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 12),
          Text(t('Compartido: aparece en la sección Lorebooks de la biblioteca y puede reutilizarse en varias tarjetas. También se incluye al exportar cuando está vinculado.', 'Shared: visible in the library\'s Lorebooks section and reusable across multiple cards. Also travels on export when bound.'), style: const TextStyle(fontSize: 13)),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('Cancelar', 'Cancel'))),
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t('Compartido', 'Shared'))),
        ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t('Integrado', 'Embedded'))),
      ],
    ),
  );
}

class LorebookBindingSection extends StatelessWidget {
  final List<String> selectedIds;
  final ValueChanged<List<String>>? onChanged;
  final String label;
  final String? sublabel;

  const LorebookBindingSection({
    super.key,
    required this.selectedIds,
    this.onChanged,
    this.label = 'Linked lorebooks',
    this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final es = AppStrings.of(context).es;
    String t(String s, String e) => es ? s : e;
    final readOnly = onChanged == null;
    final boundBooks = selectedIds.map(store.lorebookById).whereType<Lorebook>().toList();
    final shownLabel = label == 'Linked lorebooks' ? t('Lorebooks vinculados', 'Linked lorebooks') : label;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(Icons.menu_book_outlined, size: 16, color: EmberColors.textMid),
          const SizedBox(width: 6),
          Text(shownLabel.toUpperCase(), style: TextStyle(color: EmberColors.textMid, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
        ]),
        if (sublabel != null) ...[
          const SizedBox(height: 4),
          Text(sublabel!, style: TextStyle(color: EmberColors.textDim, fontSize: 11, height: 1.4)),
        ],
        const SizedBox(height: 8),
        if (boundBooks.isEmpty && readOnly)
          Text(t('No hay lorebooks vinculados.', 'No linked lorebooks.'), style: TextStyle(color: EmberColors.textDim, fontStyle: FontStyle.italic))
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final b in boundBooks)
                Chip(
                  backgroundColor: EmberColors.primary.withValues(alpha: 0.12),
                  side: BorderSide(color: EmberColors.primary.withValues(alpha: 0.30)),
                  avatar: Icon(Icons.menu_book_outlined, size: 14, color: EmberColors.primary),
                  label: Text('${b.name} · ${b.entries.length}', style: TextStyle(color: EmberColors.textHigh, fontSize: 12)),
                  deleteIcon: readOnly ? null : const Icon(Icons.close, size: 16),
                  onDeleted: readOnly ? null : () {
                    final next = List<String>.from(selectedIds)..remove(b.id);
                    onChanged!(next);
                  },
                ),
              if (!readOnly)
                ActionChip(
                  backgroundColor: EmberColors.bgDeep,
                  side: BorderSide(color: EmberColors.stroke),
                  avatar: Icon(Icons.add, size: 14, color: EmberColors.textMid),
                  label: Text(t('Añadir lorebook', 'Add lorebook'), style: TextStyle(color: EmberColors.textMid, fontSize: 12)),
                  onPressed: () => _openPicker(context, store),
                ),
            ],
          ),
      ],
    );
  }

  Future<void> _openPicker(BuildContext context, AppStore store) async {
    final es = AppStrings.of(context).es;
    String t(String s, String e) => es ? s : e;
    final all = store.lorebooks;
    if (all.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('Todavía no tienes lorebooks. Crea uno en la sección Lorebooks de la pestaña Biblioteca y después vuelve aquí para vincularlo.', 'You don\'t have any lorebooks yet. Make one in the Lorebooks section of the Library tab, then come back to bind it.'))));
      return;
    }
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: EmberColors.bgPanel,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(children: [
                  Icon(Icons.menu_book_outlined, color: EmberColors.primary),
                  const SizedBox(width: 10),
                  Text(t('Elige un lorebook', 'Pick a lorebook'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const Spacer(),
                  IconButton(icon: Icon(Icons.close, color: EmberColors.textMid), onPressed: () => Navigator.pop(ctx)),
                ]),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  itemCount: all.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 4),
                  itemBuilder: (_, i) {
                    final b = all[i];
                    final alreadyBound = selectedIds.contains(b.id);
                    final entriesLabel = es ? '${b.entries.length} ${b.entries.length == 1 ? 'entrada' : 'entradas'}' : '${b.entries.length} entries';
                    return Card(
                      child: ListTile(
                        enabled: !alreadyBound,
                        leading: Icon(Icons.menu_book_outlined, color: alreadyBound ? EmberColors.textDim : EmberColors.textMid),
                        title: Text(b.name, style: TextStyle(fontWeight: FontWeight.w600, color: alreadyBound ? EmberColors.textDim : EmberColors.textHigh)),
                        subtitle: Text('$entriesLabel${b.hidden ? "  ·  ${t('integrado', 'embedded')}" : ""}${b.description.isNotEmpty ? "  ·  ${b.description}" : ""}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: EmberColors.textDim, fontSize: 11)),
                        trailing: alreadyBound ? Icon(Icons.check, color: EmberColors.textDim, size: 18) : null,
                        onTap: alreadyBound ? null : () => Navigator.pop(ctx, b.id),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (picked != null) onChanged!([...selectedIds, picked]);
  }
}

class LorebookUsedBySection extends StatelessWidget {
  final String lorebookId;
  const LorebookUsedBySection({super.key, required this.lorebookId});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final es = AppStrings.of(context).es;
    String t(String s, String e) => es ? s : e;
    final chars = store.characters.where((c) => c.lorebookIds.contains(lorebookId)).toList(growable: false);
    final personas = store.personas.where((p) => p.lorebookIds.contains(lorebookId)).toList(growable: false);
    final perChatRefs = store.chats.fold<int>(0, (n, c) => n + (c.attachedLorebookIds.contains(lorebookId) ? 1 : 0));
    final totalRefs = chars.length + personas.length + perChatRefs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(Icons.link, size: 16, color: EmberColors.textMid),
          const SizedBox(width: 6),
          Text(t('USADO POR', 'USED BY'), style: TextStyle(color: EmberColors.textMid, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
          const SizedBox(width: 6),
          if (totalRefs > 0) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: EmberColors.primary.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(8)), child: Text('$totalRefs', style: TextStyle(color: EmberColors.primary, fontSize: 10, fontWeight: FontWeight.w700))),
        ]),
        const SizedBox(height: 4),
        Text(t('Para vincular o desvincular, edita el personaje o la persona. Los adjuntos específicos de un chat se administran desde el panel Personalizar del chat.', 'To bind or unbind, edit the character or persona. Per-chat attachments are managed from the chat\'s Customize panel.'), style: TextStyle(color: EmberColors.textDim, fontSize: 11, height: 1.4)),
        const SizedBox(height: 8),
        if (chars.isEmpty && personas.isEmpty && perChatRefs == 0)
          Text(t('No está vinculado a ningún personaje, persona o chat.', 'Not bound to any character, persona, or chat.'), style: TextStyle(color: EmberColors.textDim, fontStyle: FontStyle.italic))
        else ...[
          if (chars.isNotEmpty) ...[
            Text(t('Personajes', 'Characters'), style: TextStyle(color: EmberColors.textDim, fontSize: 11, height: 1.6)),
            Wrap(spacing: 6, runSpacing: 6, children: [for (final c in chars) Chip(avatar: Icon(Icons.person, size: 14, color: EmberColors.primary), label: Text(c.name, style: TextStyle(color: EmberColors.textHigh)), backgroundColor: EmberColors.primary.withValues(alpha: 0.10))]),
          ],
          if (personas.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Personas', style: TextStyle(color: EmberColors.textDim, fontSize: 11, height: 1.6)),
            Wrap(spacing: 6, runSpacing: 6, children: [for (final p in personas) Chip(avatar: Icon(Icons.face, size: 14, color: EmberColors.primary), label: Text(p.name, style: TextStyle(color: EmberColors.textHigh)), backgroundColor: EmberColors.primary.withValues(alpha: 0.10))]),
          ],
          if (perChatRefs > 0) ...[
            const SizedBox(height: 8),
            Text(es ? 'Además, $perChatRefs ${perChatRefs == 1 ? 'adjunto específico de chat' : 'adjuntos específicos de chat'}.' : 'Plus $perChatRefs per-chat attachment${perChatRefs == 1 ? "" : "s"}.', style: TextStyle(color: EmberColors.textDim, fontSize: 11, fontStyle: FontStyle.italic)),
          ],
        ],
      ],
    );
  }
}
