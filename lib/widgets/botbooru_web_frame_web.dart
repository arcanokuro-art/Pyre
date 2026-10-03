// Pyre — Web-only BotBooru iframe widget (v2 SECURE).

import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../l10n/app_strings.dart';
import '../services/bbx_utils.dart';
import '../theme.dart';

const _kViewType = 'pyre-bbx-frame';
bool _registered = false;
web.HTMLIFrameElement? _iframe;
String? _latestBbxHref;
StreamSubscription<web.MessageEvent>? _msgSub;

void _ensureRegistered(String bbxOrigin) {
  if (_registered) return;
  _registered = true;
  _iframe = web.HTMLIFrameElement()
    ..src = '$bbxOrigin/'
    ..style.border = 'none'
    ..style.width = '100%'
    ..style.height = '100%'
    ..setAttribute('sandbox',
        'allow-scripts allow-same-origin allow-forms allow-popups allow-popups-to-escape-sandbox');
  ui_web.platformViewRegistry.registerViewFactory(
    _kViewType,
    (int id) => _iframe!,
  );
}

void setBotbooruFrameInteractive(bool interactive) {
  try {
    _iframe?.style.pointerEvents = interactive ? 'auto' : 'none';
  } catch (_) {}
}

Future<int?> _fetchBbxPort() async {
  try {
    final resp = await web.window.fetch('/bbx-info'.toJS).toDart;
    final jsText = await resp.text().toDart;
    final text = jsText.toDart;
    final decoded = jsonDecode(text);
    if (decoded is! Map) return null;
    final port = decoded['port'];
    if (port is int) return port;
    if (port is double) return port.toInt();
    return null;
  } catch (_) {
    return null;
  }
}

class BotbooruWebFrame extends StatefulWidget {
  final void Function(String botbooruUrl, String bbxOrigin)? onImport;
  final void Function(String b64)? onImportBytes;

  const BotbooruWebFrame({super.key, this.onImport, this.onImportBytes});

  @override
  State<BotbooruWebFrame> createState() => _BotbooruWebFrameState();
}

class _BotbooruWebFrameState extends State<BotbooruWebFrame> {
  bool _loading = true;
  String? _bbxOriginLocal;

  bool get _es => AppStrings.of(context).es;
  String _t(String spanish, String english) => _es ? spanish : english;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final port = await _fetchBbxPort();
    if (!mounted) return;
    if (port == null) {
      setState(() => _loading = false);
      return;
    }
    final origin = '${Uri.base.scheme}://${Uri.base.host}:$port';
    _bbxOriginLocal = origin;
    _ensureRegistered(origin);
    final el = _iframe;
    if (el != null && !el.src.startsWith(origin)) {
      el.src = '$origin/';
    }
    _msgSub?.cancel();
    _msgSub = web.window.onMessage.listen(_onMessage);
    setState(() => _loading = false);
  }

  void _onMessage(web.MessageEvent event) {
    final expectedOrigin = _bbxOriginLocal;
    if (expectedOrigin == null) return;
    if (event.origin != expectedOrigin) return;
    try {
      final raw = event.data.dartify();
      if (raw == null) return;
      final jsonStr = raw is String ? raw : raw.toString();
      final data = jsonDecode(jsonStr) as Map<String, dynamic>?;
      if (data == null) return;
      final type = data['type'];
      if (type == 'pyre-bbx-loc') {
        final href = data['href'];
        if (href is String && href.isNotEmpty) _latestBbxHref = href;
        return;
      }
      if (type == 'pyre-bbx-card') {
        final b64 = data['b64'];
        if (b64 is String && b64.isNotEmpty) widget.onImportBytes?.call(b64);
        return;
      }
      if (type == 'pyre-bbx-card-error') {
        _showHint(_t(
          'Falló «Descargar PNG» de BotBooru. Inténtalo de nuevo o usa «Abrir externamente».',
          'BotBooru "Download PNG" failed — try again or use "Open externally".',
        ));
        return;
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    _msgSub = null;
    super.dispose();
  }

  void _goHome() {
    try {
      final el = _iframe;
      final origin = _bbxOriginLocal;
      if (el == null || origin == null) return;
      el.src = '$origin/';
    } catch (_) {}
  }

  void _goBack() {
    try {
      final el = _iframe;
      final origin = _bbxOriginLocal;
      if (el == null || origin == null) return;
      const msg = '{"type":"pyre-bbx-back"}';
      el.contentWindow?.postMessage(msg.toJS, origin.toJS);
    } catch (_) {}
  }

  void _handleImport() {
    final href = _latestBbxHref;
    final origin = _bbxOriginLocal;
    if (href == null || origin == null) {
      _showHint(_t(
        'Primero navega a la página de un personaje o lorebook en BotBooru.',
        'Navigate to a character or lorebook page on BotBooru first.',
      ));
      return;
    }
    final botbooruUrl = bbxOriginUrlToBotbooru(href, origin);
    if (botbooruUrl == null) {
      _showHint(_t(
        'Primero abre la página de un personaje o lorebook en BotBooru.',
        'Open a character or lorebook page on BotBooru first.',
      ));
      return;
    }
    widget.onImport?.call(botbooruUrl, origin);
  }

  void _showHint(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_bbxOriginLocal == null) return _buildWebFallback(context);
    return Column(
      children: [
        _Toolbar(
          onHome: _goHome,
          onBack: _goBack,
          onImport: widget.onImport != null ? _handleImport : null,
        ),
        const Expanded(child: HtmlElementView(viewType: _kViewType)),
      ],
    );
  }

  Widget _buildWebFallback(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.open_in_new, size: 48, color: EmberColors.textMid.withAlpha(128)),
          const SizedBox(height: 16),
          Text(
            _t(
              'El contenido integrado de BotBooru requiere la aplicación de escritorio de Pyre.',
              'BotBooru embed requires the Pyre desktop app.',
            ),
            style: TextStyle(color: EmberColors.textMid),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.open_in_new, size: 14),
            label: Text(_t('Abrir BotBooru externamente', 'Open BotBooru externally')),
            onPressed: () {
              try {
                web.window.open('https://botbooru.com/', '_blank');
              } catch (_) {}
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: EmberColors.textMid,
              side: BorderSide(color: EmberColors.stroke),
            ),
          ),
        ],
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  final VoidCallback onHome;
  final VoidCallback onBack;
  final VoidCallback? onImport;

  const _Toolbar({required this.onHome, required this.onBack, required this.onImport});

  @override
  Widget build(BuildContext context) {
    final es = AppStrings.of(context).es;
    String t(String spanish, String english) => es ? spanish : english;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: EmberColors.bgPanel,
        border: Border(bottom: BorderSide(color: EmberColors.stroke, width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.home_outlined, size: 18),
            tooltip: t('Inicio', 'Home'),
            color: EmberColors.textMid,
            visualDensity: VisualDensity.compact,
            onPressed: onHome,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 18),
            tooltip: t('Atrás', 'Back'),
            color: EmberColors.textMid,
            visualDensity: VisualDensity.compact,
            onPressed: onBack,
          ),
          const Spacer(),
          OutlinedButton.icon(
            icon: const Icon(Icons.download, size: 14),
            label: Text(t('Importar esta tarjeta', 'Import this card')),
            onPressed: onImport,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(fontSize: 12),
              foregroundColor: EmberColors.textMid,
              side: BorderSide(color: EmberColors.stroke),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.open_in_new, size: 14),
            label: Text(t('Abrir externamente', 'Open externally')),
            onPressed: () {
              try {
                web.window.open('https://botbooru.com/', '_blank');
              } catch (_) {}
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(fontSize: 12),
              foregroundColor: EmberColors.textMid,
              side: BorderSide(color: EmberColors.stroke),
            ),
          ),
        ],
      ),
    );
  }
}
