import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_strings.dart';
import '../models/models.dart';
import '../state/app_store.dart';
import '../theme.dart';
import '../widgets/avatar.dart';
import '../widgets/gallery_strip.dart';
import '../widgets/lorebook_binding_section.dart';
import '../widgets/menu_sheet.dart';
import 'character_assistant_screen.dart';
import 'character_edit_screen.dart';
import 'chat_picker_screens.dart';
import 'persona_editor.dart';

String _tr(BuildContext context, String es, String en) =>
    AppStrings.of(context).es ? es : en;

class _DetailField {
  final String label;
  final String content;
  const _DetailField(this.label, this.content);
}

class _DetailsSheetBody extends StatelessWidget {
  final String? avatar;
  final String? avatarOriginal;
  final String name;
  final String? tagline;
  final List<_DetailField> fields;
  final List<String> gallery;
  final List<String> lorebookIds;
  final bool showStartChat;
  final VoidCallback? onStartChat;
  final VoidCallback? onStartGroupChat;
  final String startChatLabel;
  final String editLabel;
  final VoidCallback onEdit;
  final void Function(int index)? onUseAsAvatar;

  const _DetailsSheetBody({
    required this.avatar,
    this.avatarOriginal,
    required this.name,
    required this.tagline,
    required this.fields,
    required this.gallery,
    required this.lorebookIds,
    required this.showStartChat,
    required this.onStartChat,
    this.onStartGroupChat,
    required this.startChatLabel,
    required this.editLabel,
    required this.onEdit,
    required this.onUseAsAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scroll) => Container(
        color: EmberColors.bgPanel,
        child: ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Center(child: SizedBox(width: 40, height: 4, child: DecoratedBox(decoration: BoxDecoration(color: EmberColors.stroke, borderRadius: const BorderRadius.all(Radius.circular(2)))))),
            const SizedBox(height: 16),
            Center(child: AvatarBubble(dataUrl: avatar, fallback: name, radius: 56, tappableLightbox: true, fullImageUrl: avatarOriginal ?? avatar)),
            const SizedBox(height: 12),
            Center(child: Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700))),
            if (tagline != null && tagline!.isNotEmpty)
              Center(child: Padding(padding: const EdgeInsets.only(top: 4), child: Text(tagline!, textAlign: TextAlign.center, style: TextStyle(color: EmberColors.textMid, fontSize: 14)))),
            const SizedBox(height: 16),
            Row(children: [
              if (showStartChat) ...[
                Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.chat_bubble_outline, size: 16), label: Text(startChatLabel), onPressed: onStartChat)),
                if (onStartGroupChat != null) ...[
                  const SizedBox(width: 8),
                  OutlinedButton.icon(icon: const Icon(Icons.group_add_outlined, size: 16), label: Text(_tr(context, 'Grupo', 'Group')), onPressed: onStartGroupChat),
                ],
                const SizedBox(width: 8),
                OutlinedButton.icon(icon: const Icon(Icons.edit_outlined, size: 16), label: Text(editLabel), onPressed: onEdit),
              ] else
                Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.edit_outlined, size: 16), label: Text(editLabel), onPressed: onEdit)),
            ]),
            const SizedBox(height: 16),
            GalleryStrip(refs: gallery, avatarRef: avatar, onUseAsAvatar: onUseAsAvatar, ownerName: name),
            for (final f in fields) _section(f.label, f.content),
            if (lorebookIds.isNotEmpty) ...[
              const SizedBox(height: 18),
              LorebookBindingSection(
                selectedIds: lorebookIds,
                onChanged: null,
                sublabel: _tr(context, 'Se activan automáticamente en cada chat. Toca Editar arriba para añadir o quitar vinculaciones.', 'Auto-activate in every chat. Tap Edit at the top to add or remove bindings.'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget _section(String label, String content) {
    if (content.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(), style: TextStyle(color: EmberColors.textDim, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
        const SizedBox(height: 4),
        Text(content, style: TextStyle(color: EmberColors.textHigh, height: 1.4, fontSize: 14)),
      ]),
    );
  }
}

class CharacterDetailsSheet extends StatelessWidget {
  final String characterId;
  final String? chatId;
  const CharacterDetailsSheet({super.key, required this.characterId, this.chatId});

  Character? _resolve(AppStore store) {
    if (chatId != null) {
      final chat = store.chats.firstWhere((c) => c.id == chatId, orElse: () => Chat(id: 'noop', characterIds: const []));
      final snap = chat.characterSnapshots[characterId];
      if (snap != null) return snap;
    }
    return store.characterById(characterId);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final c = _resolve(store);
    if (c == null) {
      return SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Text(_tr(context, 'Personaje no encontrado.', 'Character not found.'))));
    }
    return _DetailsSheetBody(
      avatar: c.avatar,
      avatarOriginal: c.avatarOriginal,
      name: c.name,
      tagline: c.tagline,
      gallery: c.gallery,
      lorebookIds: c.lorebookIds,
      showStartChat: true,
      startChatLabel: chatId == null ? _tr(context, 'Iniciar chat', 'Start chat') : _tr(context, 'Volver al chat', 'Back to chat'),
      onStartChat: () {
        Navigator.of(context).pop();
        if (chatId == null) startNewChatWithPersonaPrompt(context, c);
      },
      onStartGroupChat: chatId == null && store.characters.length > 1
          ? () { Navigator.of(context).pop(); startNewGroupChat(context, c); }
          : null,
      editLabel: chatId == null ? _tr(context, 'Editar', 'Edit') : _tr(context, 'Editar (este chat)', 'Edit (this chat)'),
      onEdit: () => _onEditPressed(context, c),
      onUseAsAvatar: chatId != null ? null : (i) {
        if (i < 0 || i >= c.gallery.length) return;
        c.avatar = c.gallery[i];
        store.updateCharacter(c);
      },
      fields: [
        _DetailField(_tr(context, 'Descripción', 'Description'), c.description),
        _DetailField(_tr(context, 'Personalidad', 'Personality'), c.personality),
        _DetailField(_tr(context, 'Escenario', 'Scenario'), c.scenario),
        _DetailField(_tr(context, 'Primer mensaje', 'First message'), c.firstMes),
        if (c.alternateGreetings.isNotEmpty)
          _DetailField(_tr(context, 'Saludos alternativos', 'Alternate greetings'), c.alternateGreetings.join('\n\n— — —\n\n')),
        _DetailField(_tr(context, 'Diálogo de ejemplo', 'Example dialogue'), c.mesExample),
        _DetailField(_tr(context, 'Prompt del sistema', 'System prompt'), c.systemPrompt),
        _DetailField(_tr(context, 'Instrucciones posteriores al historial', 'Post-history instructions'), c.postHistoryInstructions),
        if (c.tags.isNotEmpty) _DetailField(_tr(context, 'Etiquetas', 'Tags'), c.tags.join(', ')),
        _DetailField(_tr(context, 'Creador', 'Creator'), c.creator),
        _DetailField(_tr(context, 'Versión', 'Version'), c.characterVersion),
      ],
    );
  }

  void _onEditPressed(BuildContext context, Character c) {
    if (chatId != null) {
      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => CharacterEditScreen(characterId: c.id, overrideChatId: chatId)));
      return;
    }
    showMenuSheet<void>(
      context,
      itemsBuilder: (sheet) => [
        const SizedBox(height: 8),
        Center(child: SizedBox(width: 40, height: 4, child: DecoratedBox(decoration: BoxDecoration(color: EmberColors.stroke, borderRadius: const BorderRadius.all(Radius.circular(2)))))),
        const SizedBox(height: 12),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Align(alignment: Alignment.centerLeft, child: Text(_tr(context, 'Editar este personaje', 'Edit this character'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)))),
        const SizedBox(height: 4),
        ListTile(
          leading: Icon(Icons.auto_awesome, color: EmberColors.primary),
          title: Text(_tr(context, 'Editar con IA', 'Edit with AI')),
          subtitle: Text(_tr(context, 'Abre el Creador de personajes con esta ficha precargada y conversa con el asistente para hacer cambios grandes o pequeños.', 'Open the Character Creator with this sheet pre-loaded — chat with the assistant to make big or small changes.'), style: TextStyle(color: EmberColors.textMid, fontSize: 12)),
          onTap: () {
            Navigator.pop(sheet); Navigator.of(context).pop();
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => CharacterAssistantScreen(editingCharacterId: c.id)));
          },
        ),
        ListTile(
          leading: const Icon(Icons.edit_outlined),
          title: Text(_tr(context, 'Editar manualmente', 'Edit manually')),
          subtitle: Text(_tr(context, 'Abre el formulario clásico para modificar los campos directamente.', 'Open the classic form to tweak fields directly.'), style: TextStyle(color: EmberColors.textMid, fontSize: 12)),
          onTap: () {
            Navigator.pop(sheet); Navigator.of(context).pop();
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => CharacterEditScreen(characterId: c.id, overrideChatId: chatId)));
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

Future<void> showCharacterDetailsSheet(BuildContext context, {required String characterId, String? chatId}) {
  return showModalBottomSheet<void>(context: context, backgroundColor: EmberColors.bgPanel, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))), builder: (_) => CharacterDetailsSheet(characterId: characterId, chatId: chatId));
}

class PersonaDetailsSheet extends StatelessWidget {
  final String personaId;
  const PersonaDetailsSheet({super.key, required this.personaId});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    Persona? p;
    for (final x in store.personas) { if (x.id == personaId) { p = x; break; } }
    if (p == null) {
      return SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Text(_tr(context, 'Persona no encontrada.', 'Persona not found.'))));
    }
    final persona = p;
    return _DetailsSheetBody(
      avatar: persona.avatar,
      avatarOriginal: persona.avatarOriginal,
      name: persona.name,
      tagline: persona.tagline,
      gallery: persona.gallery,
      lorebookIds: persona.lorebookIds,
      showStartChat: false,
      startChatLabel: '',
      onStartChat: null,
      editLabel: _tr(context, 'Editar', 'Edit'),
      onEdit: () => _onPersonaEditPressed(context, persona),
      onUseAsAvatar: (i) {
        if (i < 0 || i >= persona.gallery.length) return;
        persona.avatar = persona.gallery[i];
        store.updatePersona(persona);
      },
      fields: [
        _DetailField(_tr(context, 'Descripción', 'Description'), persona.description),
        _DetailField(_tr(context, 'Ejemplos de diálogo', 'Dialogue examples'), persona.dialogueExamples),
      ],
    );
  }

  void _onPersonaEditPressed(BuildContext context, Persona p) {
    showMenuSheet<void>(
      context,
      itemsBuilder: (sheet) => [
        const SizedBox(height: 8),
        Center(child: SizedBox(width: 40, height: 4, child: DecoratedBox(decoration: BoxDecoration(color: EmberColors.stroke, borderRadius: const BorderRadius.all(Radius.circular(2)))))),
        const SizedBox(height: 12),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Align(alignment: Alignment.centerLeft, child: Text(_tr(context, 'Editar esta persona', 'Edit this persona'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)))),
        const SizedBox(height: 4),
        ListTile(
          leading: Icon(Icons.auto_awesome, color: EmberColors.primary),
          title: Text(_tr(context, 'Editar con IA', 'Edit with AI')),
          subtitle: Text(_tr(context, 'Abre el Creador con esta persona precargada y conversa con el asistente para hacer cambios.', 'Open the Creator with this persona pre-loaded — chat with the assistant to make changes.'), style: TextStyle(color: EmberColors.textMid, fontSize: 12)),
          onTap: () {
            Navigator.pop(sheet); Navigator.of(context).pop();
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => CharacterAssistantScreen(editingPersonaId: p.id)));
          },
        ),
        ListTile(
          leading: const Icon(Icons.edit_outlined),
          title: Text(_tr(context, 'Editar manualmente', 'Edit manually')),
          subtitle: Text(_tr(context, 'Abre el formulario clásico para modificar los campos directamente.', 'Open the classic form to tweak fields directly.'), style: TextStyle(color: EmberColors.textMid, fontSize: 12)),
          onTap: () { Navigator.pop(sheet); Navigator.of(context).pop(); showPersonaEditor(context, existing: p); },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

Future<void> showPersonaDetailsSheet(BuildContext context, {required String personaId}) {
  return showModalBottomSheet<void>(context: context, backgroundColor: EmberColors.bgPanel, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))), builder: (_) => PersonaDetailsSheet(personaId: personaId));
}
