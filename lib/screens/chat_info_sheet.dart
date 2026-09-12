// Chat info sheet — shows the token-budget breakdown by source.
//
// Wave CM. Lets the user see at a glance which part of the context is
// eating their budget (preset prompts vs character descriptions vs
// lorebooks vs message history). Pure read-only, no actions.

import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/chat_api.dart' show stripStreamArtifacts;
import '../services/chat_persona.dart';
import '../services/chat_prompt_builder.dart' show fillNamePlaceholders;
import '../services/regex_rules.dart';
import '../services/live_sheet.dart' as lsheet;
import '../services/lorebook_inject.dart';
import '../services/memory.dart' as ltm;
import '../services/model_metadata.dart';
import '../services/story_roadmap.dart' as roadmap;
import '../services/token_estimate.dart';
import '../state/app_store.dart';
import '../theme.dart';

class ChatInfoSheet extends StatefulWidget {
  final String chatId;
  const ChatInfoSheet({super.key, required this.chatId});

  @override
  State<ChatInfoSheet> createState() => _ChatInfoSheetState();
}

class _ChatInfoSheetState extends State<ChatInfoSheet> {
  bool _charsExpanded = false;
  String? _ctxKey;
  Future<int?>? _ctxFuture;

  Future<int?> _contextWindowFuture(ApiProvider? p) {
    if (p == null) return Future<int?>.value(null);
    final key = '${p.id}|${p.model}|${p.contextWindow}';
    if (key != _ctxKey) {
      _ctxKey = key;
      _ctxFuture = fetchContextWindow(p);
    }
    return _ctxFuture!;
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    Chat? chat;
    for (final c in store.chats) {
      if (c.id == widget.chatId) {
        chat = c;
        break;
      }
    }
    if (chat == null) return const SizedBox.shrink();
    final breakdown = _buildBreakdown(store, chat);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    width: 40,
                    height: 4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: EmberColors.stroke,
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                      ),
                    ),
                  ),
                ),
              ),
              const Text(
                'Información del chat',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Approximate token weight of every component sent to the '
                'model on the next turn. Counts use the chars/4 heuristic '
                '(close enough for the "is this big or small" question).',
                style: TextStyle(color: EmberColors.textMid, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: EmberColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: EmberColors.primary.withValues(alpha: 0.40)),
                ),
                child: Row(children: [
                  Icon(Icons.toll, color: EmberColors.primary, size: 22),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Total context', style: TextStyle(color: EmberColors.textHigh, fontWeight: FontWeight.w600))),
                  Text(formatTokenCount(breakdown.total) ?? '~0 tokens', style: TextStyle(color: EmberColors.primary, fontWeight: FontWeight.w700, fontSize: 16, fontFeatures: [FontFeature.tabularFigures()])),
                ]),
              ),
              const SizedBox(height: 10),
              FutureBuilder<int?>(
                future: _contextWindowFuture(store.chatPrimaryProvider(chat)),
                builder: (ctx, snap) => _ContextWindowRow(loading: snap.connectionState == ConnectionState.waiting, window: snap.data, used: breakdown.total),
              ),
              const SizedBox(height: 12),
              ..._row('Preset', 'mainPrompt + post-history', breakdown.preset, breakdown.total, Icons.tune),
              ..._charactersRow(breakdown),
              ..._row('Persona', breakdown.personaName ?? '(no persona)', breakdown.persona, breakdown.total, Icons.face),
              ..._row(breakdown.lorebookNames.length > 1 ? 'Lorebooks (${breakdown.lorebookNames.length})' : 'Lorebooks', breakdown.lorebookNames.isEmpty ? '(none active)' : breakdown.lorebookNames.join(', '), breakdown.lorebooks, breakdown.total, Icons.menu_book_outlined),
              ..._loreActivationSection(breakdown),
              if (breakdown.liveSheet > 0) ..._row('Live Sheet', 'active state snapshot', breakdown.liveSheet, breakdown.total, Icons.track_changes_outlined),
              if (breakdown.script > 0) ..._row('Script', 'story beats roadmap', breakdown.script, breakdown.total, Icons.auto_stories_outlined),
              ..._row('Memory summary', breakdown.memoryNote, breakdown.memory, breakdown.total, Icons.psychology),
              ..._row('Messages', '${breakdown.messageCount} kept in window', breakdown.messages, breakdown.total, Icons.chat_bubble_outline),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _row(String title, String subtitle, int tokens, int total, IconData icon) {
    final pct = total == 0 ? 0.0 : (tokens / total).clamp(0.0, 1.0);
    final tokenLabel = formatTokenCount(tokens) ?? '~0 tokens';
    return [Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, size: 16, color: EmberColors.textMid), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: EmberColors.textMid, fontSize: 11))])), const SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(tokenLabel, style: TextStyle(color: EmberColors.textHigh, fontSize: 12, fontWeight: FontWeight.w600, fontFeatures: [FontFeature.tabularFigures()])), const SizedBox(height: 2), SizedBox(width: 64, height: 4, child: Stack(children: [Container(decoration: BoxDecoration(color: EmberColors.stroke, borderRadius: BorderRadius.circular(2))), FractionallySizedBox(widthFactor: pct, child: Container(decoration: BoxDecoration(color: EmberColors.primary, borderRadius: BorderRadius.circular(2))))]))])]))];
  }

  List<Widget> _loreActivationSection(_ChatBreakdown breakdown) {
    if (breakdown.lorebookNames.isEmpty) return const [];
    final fired = breakdown.loreFired;
    final total = breakdown.loreTotal;
    final widgets = <Widget>[Padding(padding: const EdgeInsets.fromLTRB(26, 0, 0, 4), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.bolt, size: 13, color: EmberColors.textMid), const SizedBox(width: 5), Expanded(child: Text('Lore active: $fired of $total ${total == 1 ? 'entry' : 'entries'}', style: TextStyle(color: EmberColors.textMid, fontSize: 11, fontWeight: FontWeight.w600)))]))];
    if (fired == 0) {
      widgets.add(Padding(padding: const EdgeInsets.fromLTRB(31, 0, 0, 8), child: Text(total == 0 ? 'no enabled entries in the attached lorebooks' : 'no entries matched the recent conversation yet', style: TextStyle(color: EmberColors.textMid, fontSize: 11, fontStyle: FontStyle.italic))));
    } else {
      for (final line in breakdown.loreTrace) { widgets.add(Padding(padding: const EdgeInsets.fromLTRB(31, 0, 0, 2), child: Text(line, style: TextStyle(color: EmberColors.textMid, fontSize: 11)))); }
      widgets.add(const SizedBox(height: 6));
    }
    return widgets;
  }

  List<Widget> _charactersRow(_ChatBreakdown breakdown) {
    final names = breakdown.characterNames;
    final hasMany = names.length > 1;
    final headerTitle = hasMany ? 'Characters (${names.length})' : 'Character';
    final headerSubtitle = names.join(', ');
    final pct = breakdown.total == 0 ? 0.0 : (breakdown.characters / breakdown.total).clamp(0.0, 1.0);
    final tokenLabel = formatTokenCount(breakdown.characters) ?? '~0 tokens';
    final canExpand = breakdown.characterBreakdown.length > 1;
    final header = InkWell(onTap: canExpand ? () => setState(() => _charsExpanded = !_charsExpanded) : null, borderRadius: BorderRadius.circular(6), child: Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.person, size: 16, color: EmberColors.textMid), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(headerTitle, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600))), if (canExpand) ...[const SizedBox(width: 4), Icon(_charsExpanded ? Icons.expand_less : Icons.expand_more, size: 16, color: EmberColors.textMid)]]), Text(headerSubtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: EmberColors.textMid, fontSize: 11))])), const SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(tokenLabel, style: TextStyle(color: EmberColors.textHigh, fontSize: 12, fontWeight: FontWeight.w600, fontFeatures: [FontFeature.tabularFigures()])), const SizedBox(height: 2), SizedBox(width: 64, height: 4, child: Stack(children: [Container(decoration: BoxDecoration(color: EmberColors.stroke, borderRadius: BorderRadius.circular(2))), FractionallySizedBox(widthFactor: pct, child: Container(decoration: BoxDecoration(color: EmberColors.primary, borderRadius: BorderRadius.circular(2))))]))])])));
    final children = <Widget>[header];
    if (canExpand && _charsExpanded) {
      for (final entry in breakdown.characterBreakdown) {
        final entryPct = breakdown.characters == 0 ? 0.0 : (entry.value / breakdown.characters).clamp(0.0, 1.0);
        final entryLabel = formatTokenCount(entry.value) ?? '~0 tokens';
        children.add(Padding(padding: const EdgeInsets.fromLTRB(34, 2, 0, 6), child: Row(children: [Icon(Icons.arrow_right, size: 14, color: EmberColors.textMid), const SizedBox(width: 4), Expanded(child: Text(entry.key, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: EmberColors.textMid, fontSize: 12))), Text(entryLabel, style: TextStyle(color: EmberColors.textHigh, fontSize: 11, fontWeight: FontWeight.w500, fontFeatures: [FontFeature.tabularFigures()])), const SizedBox(width: 8), SizedBox(width: 48, height: 3, child: Stack(children: [Container(decoration: BoxDecoration(color: EmberColors.stroke, borderRadius: BorderRadius.circular(2))), FractionallySizedBox(widthFactor: entryPct, child: Container(decoration: BoxDecoration(color: EmberColors.primary.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(2))))]))])));
      }
    }
    return children;
  }
}

class _ChatBreakdown {
  final int preset; final int characters; final int persona; final int lorebooks; final int memory; final int liveSheet; final int script; final int messages;
  final List<String> characterNames; final List<MapEntry<String, int>> characterBreakdown; final String? personaName; final List<String> lorebookNames; final int loreFired; final int loreTotal; final List<String> loreTrace; final String memoryNote; final int messageCount;
  int get total => preset + characters + persona + lorebooks + memory + liveSheet + script + messages;
  _ChatBreakdown({required this.preset, required this.characters, required this.persona, required this.lorebooks, required this.memory, required this.liveSheet, required this.script, required this.messages, required this.characterNames, required this.characterBreakdown, required this.personaName, required this.lorebookNames, required this.loreFired, required this.loreTotal, required this.loreTrace, required this.memoryNote, required this.messageCount});
}

_ChatBreakdown _buildBreakdown(AppStore store, Chat chat) {
  final preset = store.activePreset;
  var presetTokens = 0;
  if (preset != null) { presetTokens += approxTokens(preset.mainPrompt); presetTokens += approxTokens(preset.postHistoryInstructions); }
  var charTokens = 0; final charNames = <String>[]; final charBreakdown = <MapEntry<String, int>>[];
  for (final cid in chat.characterIds) { final c = chat.characterSnapshots[cid] ?? store.characterById(cid); if (c == null) continue; final t = approxTokensForCharacter(c); charNames.add(c.name); charBreakdown.add(MapEntry(c.name, t)); charTokens += t; }
  final persona = chatPersonaFor(store, chat);
  final List<Persona> partyPersonas = chat.personaIds.isNotEmpty ? [for (final pid in chat.personaIds) if (pid != kExplicitNoPersonaId) store.personaById(pid)].whereType<Persona>().toList() : (persona != null ? [persona] : const <Persona>[]);
  final personaTokens = partyPersonas.fold<int>(0, (sum, p) => sum + approxTokensForPersona(p));
  final personaDisplayName = partyPersonas.length > 1 ? partyPersonas.map((p) => p.name).join(' + ') : (partyPersonas.isNotEmpty ? partyPersonas.first.name : null);
  final attachedBooks = collectBoundLorebooks(chat: chat, persona: persona, lookupBook: store.lorebookById, lookupCharacter: store.characterById);
  var loreTokens = 0; for (final b in attachedBooks) { loreTokens += approxTokensForLorebook(b); }
  final loreScan = scanLorebookHits(attachedBooks, chat.messages, rng: Random(chat.messages.length), fillMacros: (s) => fillNamePlaceholders(s, charName: charNames.isNotEmpty ? charNames.first : null, personaName: partyPersonas.length > 1 ? partyPersonas.map((p) => p.name).join(', ') : (persona?.name ?? 'You')), sceneCharacterNames: charNames, effectiveTextOf: (m) { if (hiddenByGreetingVariant(chat.messages, m)) return null; switch (m.kind) { case MessageKind.user: return applyRegexRules(m.text, store.regexRules, stream: RegexStream.userInput, stage: RegexStage.prompt); case MessageKind.char: return applyRegexRules(stripStreamArtifacts(m.text), store.regexRules, stream: RegexStream.aiOutput, stage: RegexStage.prompt); default: return m.text; } });
  final loreFired = loreScan.hits.length; final loreTotal = loreScan.totalScanned - loreScan.skippedDisabled;
  final validCheckpoints = ltm.findValidCheckpoints(chat); var memTokens = 0; for (final c in validCheckpoints) { memTokens += approxTokens(c.summary); }
  final memNote = validCheckpoints.isEmpty ? '(no checkpoints yet)' : '${validCheckpoints.length} checkpoint${validCheckpoints.length == 1 ? "" : "s"}';
  final liveSheetTokens = approxTokens(lsheet.buildLiveSheetBlock(chat));
  final scriptTokens = approxTokens(roadmap.buildStoryRoadmapBlock(chat, beatsCap: store.scriptSettings.beatsCap));
  final ltmStart = ltm.firstUncoveredIndex(chat); final recent = chat.messages.sublist(ltmStart.clamp(0, chat.messages.length)); var msgTokens = 0; for (final m in recent) { msgTokens += approxTokens(m.text); }
  return _ChatBreakdown(preset: presetTokens, characters: charTokens, persona: personaTokens, lorebooks: loreTokens, memory: memTokens, liveSheet: liveSheetTokens, script: scriptTokens, messages: msgTokens, characterNames: charNames, characterBreakdown: charBreakdown, personaName: personaDisplayName, lorebookNames: attachedBooks.map((b) => b.name).toList(), loreFired: loreFired, loreTotal: loreTotal, loreTrace: loreScan.trace, memoryNote: memNote, messageCount: recent.length);
}

Future<void> showChatInfoSheet(BuildContext context, String chatId) {
  return showModalBottomSheet<void>(context: context, isScrollControlled: true, backgroundColor: EmberColors.bgPanel, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))), builder: (_) => ChatInfoSheet(chatId: chatId));
}

class _ContextWindowRow extends StatelessWidget {
  final bool loading; final int? window; final int used;
  const _ContextWindowRow({required this.loading, required this.window, required this.used});
  static String _compact(int n) { if (n < 1000) return '$n'; if (n < 1000000) { final k = n / 1000; return k >= 100 ? '${k.round()}k' : '${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}k'; } final m = n / 1000000; return '${m.toStringAsFixed(m.truncateToDouble() == m ? 0 : 1)}M'; }
  @override Widget build(BuildContext context) {
    if (loading) return Padding(padding: EdgeInsets.symmetric(vertical: 2), child: Text('Checking model context window…', style: TextStyle(color: EmberColors.textDim, fontSize: 11)));
    if (window == null || window! <= 0) return Padding(padding: EdgeInsets.symmetric(vertical: 2), child: Text('Context window: unknown — set it manually in More → API Connections if you want the usage bar.', style: TextStyle(color: EmberColors.textDim, fontSize: 11)));
    final pct = (used / window!).clamp(0.0, 1.0); final pctLabel = (pct * 100).clamp(0, 100).toStringAsFixed(0); final Color barColor = pct >= 0.9 ? Colors.redAccent : (pct >= 0.7 ? Colors.amber : EmberColors.primary);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(Icons.data_usage, size: 14, color: EmberColors.textMid), const SizedBox(width: 6), Expanded(child: Text('${_compact(used)} of ~${_compact(window!)} window', style: TextStyle(color: EmberColors.textMid, fontSize: 12))), Text('$pctLabel%', style: TextStyle(color: barColor, fontSize: 12, fontWeight: FontWeight.w700, fontFeatures: const [FontFeature.tabularFigures()]))]), const SizedBox(height: 4), ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(value: pct, minHeight: 5, backgroundColor: EmberColors.bgDeep, valueColor: AlwaysStoppedAnimation<Color>(barColor)))]);
  }
}
