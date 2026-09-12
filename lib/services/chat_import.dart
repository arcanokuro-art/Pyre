// Import a Pyre chat file back into the app — the inverse of
// services/chat_export.dart. A user who exported a chat (to move it to another
// device, share it, or keep a "forever" backup) can now load it back.
//
// Three shapes are recognised, in this order:
//
//   1. pyre.chat.v1 JSON (`{format: "pyre.chat.v1", chat: <Chat.toJson()>}`)
//      — FULL FIDELITY. Reconstructed via `Chat.fromJson`, so variants,
//      per-variant downstream snapshots, checkpoints, live-sheet snapshots,
//      the manual title, and character/persona bindings all survive.
//
//   2. Pyre JSONL (SillyTavern-compatible, `chat_metadata.pyre_origin: true`)
//      — one JSON object per line. Line 0 is the header; each following line is
//      a message. We rebuild messages in order using `extra.pyre_kind` for the
//      MessageKind, `extra.pyre_variants` to restore alternates, and strip the
//      `[OOC]:`/`[Scene]:` prefix the exporter adds to the canonical `mes`.
//      Lossy vs. pyre.chat.v1: the JSONL export carries NO chat title, no
//      memory checkpoints, live-sheet snapshots, story beats, per-chat
//      settings, or per-variant downstream branches — only the visible message
//      timeline (text, kind, variants, selection, timestamps, speaker id).
//
//   3. Foreign SillyTavern JSONL (no Pyre hints) — best-effort: `is_user` /
//      `is_system` pick the kind, `swipes[]` become variants. Imported as an
//      UNBOUND chat (no character binding).
//
// PURE: no Flutter, no store, no file I/O. Detection + reconstruction only.
// Callers pass the set of library character ids (for the binding decision) and
// existing chat ids (for collision-safe id assignment). On any unusable input
// this THROWS a typed [ChatImportException] BEFORE returning a chat, so a
// caller never half-imports — either it gets a complete [ChatImportResult] or a
// readable error.

import 'dart:convert';

import '../models/models.dart';

enum ChatImportFormat { pyreJson, pyreJsonl, foreignJsonl }

enum ChatImportErrorKind { notReadable, unsupported, empty }

class ChatImportException implements Exception {
  final ChatImportErrorKind kind;
  final String message;
  const ChatImportException(this.kind, this.message);

  @override
  String toString() => 'ChatImportException($kind): $message';
}

class ChatImportSummary {
  final ChatImportFormat format;
  final String title;
  final int messageCount;
  final int variantCount;
  final bool characterBound;
  final List<String> warnings;

  const ChatImportSummary({
    required this.format,
    required this.title,
    required this.messageCount,
    required this.variantCount,
    required this.characterBound,
    required this.warnings,
  });
}

class ChatImportResult {
  final Chat chat;
  final ChatImportSummary summary;
  const ChatImportResult({required this.chat, required this.summary});
}

ChatImportResult importChat(
  String content, {
  Set<String> knownCharacterIds = const {},
  Set<String> existingChatIds = const {},
}) {
  final trimmed = content.trim();
  if (trimmed.isEmpty) {
    throw const ChatImportException(
        ChatImportErrorKind.notReadable, 'The chat file is empty.');
  }

  Map<String, dynamic>? whole;
  try {
    final decoded = jsonDecode(trimmed);
    if (decoded is Map) whole = decoded.cast<String, dynamic>();
  } catch (_) {}

  if (whole != null && whole['format'] == 'pyre.chat.v1') {
    return _importPyreJson(whole,
        knownCharacterIds: knownCharacterIds,
        existingChatIds: existingChatIds);
  }

  return _importJsonl(content,
      knownCharacterIds: knownCharacterIds, existingChatIds: existingChatIds);
}

ChatImportResult _importPyreJson(
  Map<String, dynamic> root, {
  required Set<String> knownCharacterIds,
  required Set<String> existingChatIds,
}) {
  final chatJson = root['chat'];
  if (chatJson is! Map) {
    throw const ChatImportException(ChatImportErrorKind.unsupported,
        'This looks like a Pyre chat file but its data block is missing or corrupted.');
  }

  final Chat chat;
  try {
    chat = Chat.fromJson(chatJson.cast<String, dynamic>());
  } catch (e) {
    throw ChatImportException(ChatImportErrorKind.unsupported,
        'This Pyre chat file could not be read (corrupted data): $e');
  }

  if (chat.messages.isEmpty) {
    throw const ChatImportException(
        ChatImportErrorKind.empty, 'This chat file has no messages.');
  }

  final warnings = <String>[];
  if (existingChatIds.contains(chat.id)) {
    chat.id = newId('chat');
    warnings.add('A chat with the same id already exists — imported as a new copy.');
  }

  final primary = chat.primaryCharacterId;
  final bound = primary != null && knownCharacterIds.contains(primary);
  if (primary != null && !bound) {
    final name = chat.characterSnapshots[primary]?.name;
    warnings.add(name != null && name.isNotEmpty
        ? "The character '$name' isn't in your library — imported as a standalone copy (it uses the snapshot saved in the file)."
        : "This chat's character isn't in your library — imported as a standalone copy.");
  }

  final title = _titleFor(chat, chat.characterSnapshots[primary]?.name);
  return ChatImportResult(
    chat: chat,
    summary: ChatImportSummary(
      format: ChatImportFormat.pyreJson,
      title: title,
      messageCount: chat.messages.length,
      variantCount: _countVariantMessages(chat.messages),
      characterBound: bound,
      warnings: warnings,
    ),
  );
}

ChatImportResult _importJsonl(
  String content, {
  required Set<String> knownCharacterIds,
  required Set<String> existingChatIds,
}) {
  final objects = <Map<String, dynamic>>[];
  var anyLineParsed = false;
  for (final raw in const LineSplitter().convert(content)) {
    final line = raw.trim();
    if (line.isEmpty) continue;
    final dynamic decoded;
    try {
      decoded = jsonDecode(line);
    } catch (_) {
      continue;
    }
    if (decoded is! Map) continue;
    anyLineParsed = true;
    objects.add(decoded.cast<String, dynamic>());
  }

  if (!anyLineParsed) {
    throw const ChatImportException(ChatImportErrorKind.notReadable,
        "This file isn't a Pyre or SillyTavern chat — it couldn't be read as JSON or JSONL.");
  }

  Map<String, dynamic>? header;
  var start = 0;
  if (objects.isNotEmpty && _looksLikeHeader(objects.first)) {
    header = objects.first;
    start = 1;
  }

  final meta = header?['chat_metadata'];
  final pyreOrigin = meta is Map && meta['pyre_origin'] == true;
  final format =
      pyreOrigin ? ChatImportFormat.pyreJsonl : ChatImportFormat.foreignJsonl;

  final warnings = <String>[];
  final messages = <Message>[];
  String? candidateCharacterId;

  for (var i = start; i < objects.length; i++) {
    final obj = objects[i];
    final msg = pyreOrigin
        ? _messageFromPyreLine(obj)
        : _messageFromForeignLine(obj);
    if (msg == null) continue;
    if (candidateCharacterId == null &&
        msg.kind == MessageKind.char &&
        msg.characterId != null &&
        msg.characterId!.isNotEmpty) {
      candidateCharacterId = msg.characterId;
    }
    messages.add(msg);
  }

  if (messages.isEmpty) {
    throw const ChatImportException(
        ChatImportErrorKind.empty, 'This chat file has no messages.');
  }

  final bound = candidateCharacterId != null &&
      knownCharacterIds.contains(candidateCharacterId);
  final characterIds = <String>[];
  if (bound) {
    characterIds.add(candidateCharacterId);
  } else {
    for (final m in messages) {
      m.characterId = null;
    }
    if (candidateCharacterId != null) {
      final name = (header?['character_name'] as String?)?.trim();
      warnings.add(name != null && name.isNotEmpty
          ? "The character '$name' isn't in your library — imported as a standalone chat."
          : "This chat's character isn't in your library — imported as a standalone chat.");
    }
  }

  var chatId = newId('chat');
  if (pyreOrigin) {
    final savedId = meta['pyre_chat_id'];
    if (savedId is String && savedId.isNotEmpty) {
      if (existingChatIds.contains(savedId)) {
        warnings.add('A chat with the same id already exists — imported as a new copy.');
      } else {
        chatId = savedId;
      }
    }
  }

  final createdAt = _parseDate(header?['create_date']);
  final chat = Chat(
    id: chatId,
    characterIds: characterIds,
    messages: messages,
    createdAt: createdAt,
  );

  if (format == ChatImportFormat.pyreJsonl) {
    warnings.add('JSONL import restores the message timeline only — chat title, memory, and branch snapshots are in the full-fidelity Pyre JSON export.');
  }

  final title = (header?['character_name'] as String?)?.trim();
  return ChatImportResult(
    chat: chat,
    summary: ChatImportSummary(
      format: format,
      title: (title != null && title.isNotEmpty) ? title : 'Imported chat',
      messageCount: messages.length,
      variantCount: _countVariantMessages(messages),
      characterBound: bound,
      warnings: warnings,
    ),
  );
}

Message? _messageFromPyreLine(Map<String, dynamic> obj) {
  final mes = obj['mes'];
  final extra = obj['extra'];
  final extraMap = extra is Map ? extra : const {};
  final kind = _kindFromName(extraMap['pyre_kind']) ??
      _kindFromFlags(obj['is_user'] == true, obj['is_system'] == true);
  final canonical = mes is String ? _stripKindPrefix(mes, kind) : '';
  final rawVariants = extraMap['pyre_variants'];
  final variants = <String>[];
  if (rawVariants is List) {
    for (final v in rawVariants) {
      if (v is String) variants.add(v);
    }
  }
  var selected = 0;
  if (variants.isEmpty) {
    variants.add(canonical);
  } else {
    final idx = variants.indexOf(canonical);
    selected = idx >= 0 ? idx : 0;
  }
  if (variants.every((v) => v.isEmpty)) return null;

  final characterId = extraMap['pyre_character_id'];
  return Message(
    id: newId('msg'),
    kind: kind,
    characterId: (kind == MessageKind.char &&
            characterId is String &&
            characterId.isNotEmpty)
        ? characterId
        : null,
    variants: variants,
    selectedVariant: selected,
    createdAt: _parseDate(obj['send_date']),
  );
}

Message? _messageFromForeignLine(Map<String, dynamic> obj) {
  final variants = <String>[];
  final swipes = obj['swipes'];
  if (swipes is List) {
    for (final s in swipes) {
      if (s is String) variants.add(s);
    }
  }
  if (variants.isEmpty) {
    final mes = obj['mes'];
    if (mes is String) variants.add(mes);
  }
  if (variants.isEmpty) return null;

  var selected = 0;
  final swipeId = obj['swipe_id'];
  if (swipeId is num) selected = swipeId.toInt();
  if (selected < 0 || selected >= variants.length) selected = 0;

  final kind = _kindFromFlags(obj['is_user'] == true, obj['is_system'] == true);
  return Message(
    id: newId('msg'),
    kind: kind,
    variants: variants,
    selectedVariant: selected,
    createdAt: _parseDate(obj['send_date']),
  );
}

bool _looksLikeHeader(Map<String, dynamic> obj) {
  if (obj.containsKey('mes') || obj.containsKey('swipes')) return false;
  return obj.containsKey('user_name') ||
      obj.containsKey('character_name') ||
      obj.containsKey('create_date') ||
      obj.containsKey('chat_metadata');
}

MessageKind? _kindFromName(dynamic name) {
  if (name is! String) return null;
  for (final k in MessageKind.values) {
    if (k.name == name) return k;
  }
  return null;
}

MessageKind _kindFromFlags(bool isUser, bool isSystem) => isUser
    ? MessageKind.user
    : (isSystem ? MessageKind.system : MessageKind.char);

String _stripKindPrefix(String mes, MessageKind kind) {
  const oocPrefix = '[OOC]: ';
  const scenePrefix = '[Scene]: ';
  if (kind == MessageKind.ooc && mes.startsWith(oocPrefix)) {
    return mes.substring(oocPrefix.length);
  }
  if (kind == MessageKind.scene && mes.startsWith(scenePrefix)) {
    return mes.substring(scenePrefix.length);
  }
  return mes;
}

int _countVariantMessages(List<Message> messages) =>
    messages.where((m) => m.variants.length > 1).length;

String _titleFor(Chat chat, String? characterName) {
  final t = chat.title?.trim();
  if (t != null && t.isNotEmpty) return t;
  if (characterName != null && characterName.isNotEmpty) return characterName;
  return 'Imported chat';
}

int _parseDate(dynamic v) {
  if (v is num) return v.toInt();
  if (v is String && v.trim().isNotEmpty) {
    final iso = DateTime.tryParse(v.trim());
    if (iso != null) return iso.millisecondsSinceEpoch;
  }
  return DateTime.now().millisecondsSinceEpoch;
}
