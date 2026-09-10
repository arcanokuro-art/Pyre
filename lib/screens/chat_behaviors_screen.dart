import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_strings.dart';
import '../models/models.dart';
import '../state/app_store.dart';
import '../theme.dart';
import '../widgets/how_it_works_card.dart';

class ChatBehaviorsScreen extends StatefulWidget {
  const ChatBehaviorsScreen({super.key});

  @override
  State<ChatBehaviorsScreen> createState() => _ChatBehaviorsScreenState();
}

class _ChatBehaviorsScreenState extends State<ChatBehaviorsScreen> {
  late ChatSettings _draft;

  @override
  void initState() {
    super.initState();
    _draft = context.read<AppStore>().chatSettings.copyWith();
  }

  void _commit() => context.read<AppStore>().updateChatSettings(_draft);

  @override
  Widget build(BuildContext context) {
    final es = AppStrings.of(context).es;
    String t(String spanish, String english) => es ? spanish : english;

    return Scaffold(
      appBar: AppBar(title: Text(t('Comportamiento', 'Behaviors'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: [
          HowItWorksCard(
            title: t('Cómo funciona el comportamiento', 'How behaviors work'),
            subtitle: t('Qué controla cada opción.', 'What each toggle controls.'),
            sections: [
              HowItWorksSection(t('Qué es', 'What it is'), [
                HowItWorksBlock.paragraph(t(
                  'Estos ajustes controlan cómo se **comporta** un chat durante su uso: qué ocurre al eliminar un mensaje y si los chats nuevos preguntan qué persona usar.',
                  'These settings control how a chat **behaves** during use — what deleting a message does and whether new chats ask for a persona.',
                )),
                HowItWorksBlock.paragraph(t(
                  'Son ajustes **globales**: se aplican a todos los chats, no solamente al chat desde el que llegaste.',
                  'They are **global** — they apply to every chat, not just the one you came from.',
                )),
              ]),
              HowItWorksSection(t('Las opciones', 'The toggles'), [
                HowItWorksBlock.bullet(t(
                  '**Comportamiento al eliminar** — elige si al borrar un mensaje se elimina únicamente ese mensaje o también todos los mensajes posteriores.',
                  '**Delete behavior** — choose whether deleting a message removes only that one, or that message and everything after it.',
                )),
                HowItWorksBlock.bullet(t(
                  '**Preguntar persona al iniciar un chat** — cuando está activado, un chat nuevo abre primero el selector de persona; cuando está desactivado, utiliza automáticamente tu persona predeterminada.',
                  '**Ask persona on new chat** — when on, starting a new chat opens the persona picker first; when off, it uses your default persona automatically.',
                )),
              ]),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t('Comportamiento al eliminar', 'Delete behavior'), style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(t('Qué ocurre cuando eliminas un mensaje del chat.', 'When you delete a message in a chat.'), style: TextStyle(color: EmberColors.textMid, fontSize: 12)),
                  const SizedBox(height: 12),
                  SegmentedButton<DeleteBehavior>(
                    segments: [
                      ButtonSegment(value: DeleteBehavior.onlyThis, label: Text(t('Solo este mensaje', 'Only this message'))),
                      ButtonSegment(value: DeleteBehavior.thisAndAfter, label: Text(t('Este y los posteriores', 'This message and after'))),
                    ],
                    selected: {_draft.deleteBehavior},
                    showSelectedIcon: false,
                    onSelectionChanged: (s) {
                      setState(() => _draft.deleteBehavior = s.first);
                      _commit();
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? EmberColors.primary : EmberColors.bgElevated),
                      foregroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? Colors.white : EmberColors.textMid),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: SwitchListTile(
              title: Text(t('Preguntar persona al iniciar un chat', 'Ask persona on new chat'), style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                t(
                  'Cuando está ACTIVADO, al iniciar un chat nuevo con un personaje se abre primero el selector de persona. Cuando está DESACTIVADO, se utiliza automáticamente tu persona predeterminada.',
                  'When ON, starting a new chat with a character opens the persona picker first. When OFF, it uses your default persona automatically.',
                ),
                style: TextStyle(color: EmberColors.textMid, fontSize: 12),
              ),
              value: _draft.askPersonaOnNewChat,
              activeThumbColor: EmberColors.primary,
              onChanged: (v) {
                setState(() => _draft.askPersonaOnNewChat = v);
                _commit();
              },
            ),
          ),
        ],
      ),
    );
  }
}
