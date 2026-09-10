// Renders a message body with chub-style typographic distinctions:
//   "quoted text"   → dialogue, ember-warm
//   *italic* / _italic_ → narration emphasis, muted
//   **bold**        → bold
//   `code`          → monospace, dim background
//
// Falls back to plain text on parse problems. Single-pass tokenizer over a
// flat character stream — Markdown nesting is intentionally minimal so that
// half-finished tokens during streaming don't visually flicker.

import 'dart:convert';

import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../theme.dart';
import 'lightbox.dart';

class ChatText extends StatelessWidget {
  final String body;
  final TextStyle? baseStyle;
  final bool hideReasoning;
  final bool isStreaming;
  const ChatText(
    this.body, {
    super.key,
    this.baseStyle,
    this.hideReasoning = true,
    this.isStreaming = false,
  });

  static final _thinkBlock = RegExp(r'<think>[\s\S]*?</think>', caseSensitive: false, multiLine: true);
  static final _danglingThink = RegExp(r'<think>[\s\S]*$', caseSensitive: false, multiLine: true);
  static final Map<_ParseKey, List<InlineSpan>> _parseCache = {};
  static const int _parseCacheMax = 300;
  static _ParseKey? _streamParseKey;
  static List<InlineSpan>? _streamParseSpans;

  @override
  Widget build(BuildContext context) {
    var src = body;
    if (hideReasoning) {
      src = src.replaceAll(_thinkBlock, '').replaceAll(_danglingThink, '').trimLeft();
    }
    final base = (baseStyle ?? DefaultTextStyle.of(context).style).copyWith(
      color: baseStyle?.color ?? EmberColors.textHigh,
    );
    final key = _ParseKey(src, base, EmberColors.textHigh, EmberColors.textMid, EmberColors.bgElevated);
    List<InlineSpan> spans;
    if (isStreaming) {
      if (_streamParseKey == key && _streamParseSpans != null) {
        spans = _streamParseSpans!;
      } else {
        spans = _parse(src, base);
        _streamParseKey = key;
        _streamParseSpans = spans;
      }
    } else {
      spans = _parseCache[key] ??= _parse(src, base);
      if (_parseCache.length > _parseCacheMax) _parseCache.remove(_parseCache.keys.first);
    }
    return Text.rich(TextSpan(children: spans), style: base);
  }

  static List<InlineSpan> _parse(String src, TextStyle base) {
    final out = <InlineSpan>[];
    var i = 0;
    while (i < src.length) {
      if (src.startsWith('![', i)) {
        final closeAlt = src.indexOf('](', i + 2);
        if (closeAlt >= 0) {
          final closeUrl = src.indexOf(')', closeAlt + 2);
          if (closeUrl >= 0) {
            final alt = src.substring(i + 2, closeAlt);
            final url = src.substring(closeAlt + 2, closeUrl).trim();
            if (url.isNotEmpty) {
              out.add(WidgetSpan(alignment: PlaceholderAlignment.middle, child: _InlineImage(url: url, alt: alt)));
              i = closeUrl + 1;
              continue;
            }
          }
        }
      }
      if (src.startsWith('**', i)) {
        final end = src.indexOf('**', i + 2);
        if (end > i + 2) {
          out.add(TextSpan(text: src.substring(i + 2, end), style: base.copyWith(fontWeight: FontWeight.w700)));
          i = end + 2;
          continue;
        }
      }
      if (src[i] == '`') {
        final end = src.indexOf('`', i + 1);
        if (end > i + 1) {
          out.add(TextSpan(text: src.substring(i + 1, end), style: base.copyWith(fontFamily: 'monospace', color: EmberColors.textMid, backgroundColor: EmberColors.bgElevated)));
          i = end + 1;
          continue;
        }
      }
      if (src[i] == '"') {
        final end = src.indexOf('"', i + 1);
        if (end > i) {
          out.add(TextSpan(text: src.substring(i, end + 1), style: base.copyWith(color: EmberColors.textHigh)));
          i = end + 1;
          continue;
        }
      }
      if (src[i] == '*' || src[i] == '_') {
        final marker = src[i];
        final end = src.indexOf(marker, i + 1);
        if (end > i + 1) {
          out.add(TextSpan(text: src.substring(i + 1, end), style: base.copyWith(fontStyle: FontStyle.italic, color: EmberColors.textMid)));
          i = end + 1;
          continue;
        }
      }
      final next = _nextSpecial(src, i + 1);
      final end = next < 0 ? src.length : next;
      out.add(TextSpan(text: src.substring(i, end), style: base));
      i = end;
    }
    return out;
  }

  static int _nextSpecial(String src, int from) {
    var best = -1;
    for (final c in ['![', '**', '`', '"', '*', '_']) {
      final idx = src.indexOf(c, from);
      if (idx >= 0 && (best < 0 || idx < best)) best = idx;
    }
    return best;
  }
}

@immutable
class _ParseKey {
  final String src;
  final TextStyle base;
  final Color textHigh;
  final Color textMid;
  final Color bgElevated;
  const _ParseKey(this.src, this.base, this.textHigh, this.textMid, this.bgElevated);
  @override
  bool operator ==(Object other) => other is _ParseKey && other.src == src && other.base == base && other.textHigh == textHigh && other.textMid == textMid && other.bgElevated == bgElevated;
  @override
  int get hashCode => Object.hash(src, base, textHigh, textMid, bgElevated);
}

class _InlineImage extends StatelessWidget {
  final String url;
  final String alt;
  const _InlineImage({required this.url, required this.alt});

  Widget _frame(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: ClipRRect(borderRadius: BorderRadius.circular(10), child: child),
  );

  Widget _brokenInner(BuildContext context) => Container(
    width: 220,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    color: EmberColors.bgElevated,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.broken_image_outlined, size: 18, color: EmberColors.textDim),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            alt.trim().isNotEmpty ? alt.trim() : (AppStrings.of(context).es ? 'imagen no disponible' : 'image unavailable'),
            style: TextStyle(color: EmberColors.textDim, fontSize: 13),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    final maxW = (media.width - 96).clamp(180.0, 560.0);
    final maxH = (media.height * 0.55).clamp(200.0, 620.0);
    final constraints = BoxConstraints(maxWidth: maxW, maxHeight: maxH);
    Widget inner;
    if (url.startsWith('data:')) {
      try {
        final comma = url.indexOf(',');
        final bytes = base64Decode(url.substring(comma + 1));
        inner = Image.memory(bytes, fit: BoxFit.contain, errorBuilder: (_, _, _) => _brokenInner(context));
      } catch (_) {
        inner = _brokenInner(context);
      }
    } else {
      inner = Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _brokenInner(context),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: 200,
            height: 150,
            color: EmberColors.bgElevated,
            alignment: Alignment.center,
            child: const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
      );
    }
    return _frame(
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Lightbox.show(context, dataUrl: url, fallback: alt),
        child: ConstrainedBox(constraints: constraints, child: inner),
      ),
    );
  }
}
