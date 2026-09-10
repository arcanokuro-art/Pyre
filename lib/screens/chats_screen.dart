import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_strings.dart';
import '../models/models.dart';
import '../state/app_store.dart';
import '../theme.dart';
import '../widgets/avatar.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';
import 'chat_picker_screens.dart';
import 'chat_screen.dart';
import 'chats_of_character_screen.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.read<AppStore>();
    final l10n = AppStrings.of(context);
    final chats = store.chats.where((c) => !c.deleted).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final newChatButton = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.add, size: 16),
        label: Text(l10n.newChat),
        onPressed: () => startNewChatFlow(context),
      ),
    );

    if (chats.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Pyre', style: TextStyle(color: EmberColors.primary, fontWeight: FontWeight.w700)),
          centerTitle: true,
          actions: [newChatButton],
        ),
        body: EmptyState(
          icon: Icons.chat_bubble_outline,
          title: l10n.noChats,
          subtitle: l10n.startChatHint,
          ctaLabel: l10n.newChat,
          ctaIcon: Icons.add,
          onCta: () => startNewChatFlow(context),
        ),
      );
    }

    final order = <String>[];
    final groups = <String, List<Chat>>{};
    for (final c in chats) {
      final key = c.primaryCharacterId ?? '__orphan_${c.id}';
      if (!groups.containsKey(key)) {
        order.add(key);
        groups[key] = [];
      }
      groups[key]!.add(c);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Pyre', style: TextStyle(color: EmberColors.primary, fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [newChatButton],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(children: [
            Text(l10n.allChats, style: TextStyle(color: EmberColors.textMid, fontSize: 12, letterSpacing: 0.4)),
            const Spacer(),
            Text(l10n.chatCount(chats.length), style: TextStyle(color: EmberColors.textMid, fontSize: 12)),
          ]),
        ),
        Divider(color: EmberColors.stroke, height: 1, indent: 16, endIndent: 16),
        Expanded(
          child: ListView.separated(
            itemCount: order.length,
            separatorBuilder: (_, __) => Divider(color: EmberColors.stroke, height: 1, indent: 72, endIndent: 16),
            itemBuilder: (context, i) {
              final key = order[i];
              final list = groups[key]!;
              final character = list.first.primaryCharacterId == null
                  ? null
                  : (list.first.characterSnapshots[list.first.primaryCharacterId] ?? store.characterById(list.first.primaryCharacterId!));
              return _CharacterChatsRow(
                characterId: list.first.primaryCharacterId,
                character: character,
                chats: list,
                store: store,
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _CharacterChatsRow extends StatelessWidget {
  final String? characterId;
  final Character? character;
  final List<Chat> chats;
  final AppStore store;
  const _CharacterChatsRow({required this.characterId, required this.character, required this.chats, required this.store});

  void _open(BuildContext context) {
    if (chats.length == 1) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatScreen(chatId: chats.first.id)));
      return;
    }
    if (characterId == null) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatsOfCharacterScreen(characterId: characterId!)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppStrings.of(context);
    final latest = chats.first;
    final lastText = latest.messages.isEmpty ? l10n.noMessages : latest.messages.last.text;
    final count = chats.length;
    final infoParts = <String>[];
    if (latest.characterIds.length > 1) {
      final names = latest.characterIds
          .map((id) => (latest.characterSnapshots[id] ?? store.characterById(id))?.name)
          .whereType<String>()
          .toList();
      infoParts.add(l10n.es
          ? 'Grupo: ${names.join(', ')}${latest.partyMode ? ' · Modo grupo' : ''}'
          : 'Group: ${names.join(', ')}${latest.partyMode ? ' · Party mode' : ''}');
    }
    if (latest.personaIds.length > 1) {
      final names = latest.personaIds.map((id) => store.personaById(id)?.name).whereType<String>().toList();
      if (names.isNotEmpty) infoParts.add(l10n.es ? 'como ${names.join(', ')}' : 'as ${names.join(', ')}');
    }

    return InkWell(
      onTap: () => _open(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AvatarBubble(dataUrl: character?.avatar, fallback: character?.name ?? '?', radius: 20, tappableLightbox: true, fullImageUrl: character?.avatarOriginal),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(character?.name ?? (l10n.es ? 'Chat' : 'Chat'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 2),
            Text('${l10n.chatCount(count)} · ${_relative(latest.updatedAt, l10n)}', style: TextStyle(color: EmberColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
            if (infoParts.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(infoParts.join('  ·  '), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: EmberColors.textMid, fontSize: 12)),
            ],
            const SizedBox(height: 2),
            Text(lastText, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: EmberColors.textMid, fontStyle: FontStyle.italic, fontSize: 13)),
          ])),
          IconButton(icon: Icon(Icons.more_vert, color: EmberColors.textDim), tooltip: l10n.actions, onPressed: () => _showGroupKebab(context)),
        ]),
      ),
    );
  }

  void _showGroupKebab(BuildContext context) {
    final l10n = AppStrings.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: EmberColors.bgPanel,
      builder: (sheet) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (chats.length > 1 && characterId != null)
            ListTile(
              leading: const Icon(Icons.list_alt_outlined),
              title: Text(l10n.openChatList),
              onTap: () {
                Navigator.pop(sheet);
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatsOfCharacterScreen(characterId: characterId!)));
              },
            ),
          ListTile(
            leading: Icon(Icons.add_comment_outlined, color: EmberColors.primary),
            title: Text(l10n.newChat),
            onTap: () {
              Navigator.pop(sheet);
              if (character == null) return;
              startNewChatWithPersonaPrompt(context, character!);
            },
          ),
          if (chats.length == 1)
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline),
              title: Text(l10n.renameChat),
              onTap: () {
                Navigator.pop(sheet);
                renameChatPrompt(context, store, chats.first);
              },
            ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: EmberColors.danger),
            title: Text(chats.length == 1 ? l10n.deleteChat : l10n.deleteAllChats(chats.length), style: TextStyle(color: EmberColors.danger)),
            onTap: () async {
              Navigator.pop(sheet);
              final ok = await confirmDelete(
                context,
                title: chats.length == 1 ? l10n.deleteChatQuestion : l10n.deleteAllChatsQuestion(chats.length),
                message: l10n.deleteChatWarning(chats.length),
              );
              if (!ok) return;
              for (final c in chats) {
                store.removeChat(c.id);
              }
            },
          ),
        ]),
      ),
    );
  }
}

String _relative(int ms, AppStrings l10n) {
  final now = DateTime.now();
  final d = DateTime.fromMillisecondsSinceEpoch(ms);
  final diff = now.difference(d);
  if (diff.inMinutes < 1) return l10n.justNow;
  if (diff.inMinutes < 60) return l10n.es ? 'hace ${diff.inMinutes} min' : '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return l10n.es ? 'hace ${diff.inHours} h' : '${diff.inHours}h ago';
  if (diff.inDays < 30) return l10n.es ? 'hace ${diff.inDays} d' : '${diff.inDays}d ago';
  return '${d.day}/${d.month}/${d.year}';
}
