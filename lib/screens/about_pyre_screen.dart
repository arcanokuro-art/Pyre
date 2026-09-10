import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_strings.dart';
import '../services/stability_mode.dart';
import '../theme.dart';

const _privacyPolicyUrl = 'https://pyrechat.app/legal/privacy-policy/';
const _termsOfServiceUrl = 'https://pyrechat.app/legal/terms-of-use/';
const _supportUrl = 'https://pyrechat.app/help/faq/';
const _koFiUrl = 'https://ko-fi.com/pyredevs';

class AboutPyreScreen extends StatefulWidget {
  const AboutPyreScreen({super.key});

  @override
  State<AboutPyreScreen> createState() => _AboutPyreScreenState();
}

class _AboutPyreScreenState extends State<AboutPyreScreen> {
  bool _stabilityOn = false;
  String _version = '';

  String _t(String spanish, String english) => AppStrings.of(context).es ? spanish : english;

  @override
  void initState() {
    super.initState();
    if (StabilityMode.supported) _stabilityOn = StabilityMode.isEnabled();
    PackageInfo.fromPlatform().then((info) {
      if (!mounted) return;
      setState(() => _version = info.version);
    }).catchError((_) {});
  }

  Future<void> _setStability(bool value) async {
    await StabilityMode.setEnabled(value);
    if (!mounted) return;
    setState(() => _stabilityOn = StabilityMode.isEnabled());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
      _stabilityOn
          ? _t('El modo de estabilidad se aplicará la próxima vez que inicies Pyre.', 'Stability mode will apply the next time you start Pyre.')
          : _t('Modo de estabilidad desactivado. Reinicia Pyre para volver al funcionamiento normal.', 'Stability mode off — restart Pyre to return to normal.'),
    )));
  }

  Future<void> _open(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t('No se pudo abrir el enlace.', 'Could not open link.'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    String t(String spanish, String english) => AppStrings.of(context).es ? spanish : english;
    Text section(String text) => Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: EmberColors.textDim, letterSpacing: 0.4));
    final bodyStyle = TextStyle(color: EmberColors.textMid, fontSize: 12, height: 1.5);

    return Scaffold(
      appBar: AppBar(title: Text(t('Acerca de Pyre', 'About Pyre'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        children: [
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 36, height: 36, decoration: BoxDecoration(color: EmberColors.primary.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.local_fire_department, color: EmberColors.primary, size: 20)),
                const SizedBox(width: 10),
                const Text('Pyre', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
              ]),
              const SizedBox(height: 12),
              Text(t('Una potente interfaz privada para roleplay.', 'A powerful, private roleplay frontend.'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              Text(t(
                'BYOK: usa tu propia clave API. Todos los personajes, chats, presets y lorebooks se guardan en este dispositivo. Pyre se conecta directamente al proveedor de IA que configures; no existe un servidor de Pyre como intermediario.',
                'BYOK: bring your own API key. All characters, chats, presets and lorebooks live on this device. Pyre connects directly to the AI provider you configure — there is no Pyre backend in between.'), style: bodyStyle),
              const SizedBox(height: 8),
              Text(t('Importa tarjetas SillyTavern v1/v2, presets y lorebooks. También permite explorar botbooru.com desde la aplicación.', 'Imports SillyTavern v1/v2 cards, presets, and lorebooks. Browses botbooru.com inside the app.'), style: bodyStyle),
            ]),
          )),
          const SizedBox(height: 16),
          Padding(padding: const EdgeInsets.fromLTRB(4, 4, 4, 8), child: section(t('Privacidad', 'Privacy'))),
          Card(child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t('Pyre no recopila nada', 'Pyre collects nothing'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(t('Sin analíticas, telemetría ni informes de fallos: nada de eso sale de tu dispositivo. No hay servidor de Pyre ni necesitas una cuenta.', 'No analytics, no telemetry, no crash reports — nothing leaves your device. There is no Pyre server and no account.'), style: bodyStyle),
              const SizedBox(height: 8),
              Text(t('Tus personajes, chats y claves permanecen únicamente en tu dispositivo y, si activas la sincronización, se comparten directamente con tus otros dispositivos mediante tu propia red.', 'Your characters, chats and keys live only on your device — and, if you turn it on, sync directly to your other devices over your own network.'), style: bodyStyle),
            ]),
          )),
          const SizedBox(height: 20),
          Padding(padding: const EdgeInsets.fromLTRB(4, 4, 4, 8), child: section(t('Legal y soporte', 'Legal & support'))),
          Card(child: Column(children: [
            ListTile(leading: Icon(Icons.coffee_outlined, color: EmberColors.primary), title: Text(t('Apoyar a Pyre', 'Support Pyre')), subtitle: Text(t('Pyre es gratuito. Si quieres apoyar su desarrollo, puedes invitar a sus desarrolladores a un café.', 'Pyre is free. If you want to support development, you can throw a coffee on the bonfire.'), style: TextStyle(color: EmberColors.textMid, fontSize: 12)), trailing: Icon(Icons.open_in_new, size: 18, color: EmberColors.textDim), onTap: () => _open(_koFiUrl)),
            Divider(color: EmberColors.stroke, height: 1, indent: 16),
            ListTile(leading: Icon(Icons.shield_outlined, color: EmberColors.primary), title: Text(t('Política de privacidad', 'Privacy Policy')), trailing: Icon(Icons.open_in_new, size: 18, color: EmberColors.textDim), onTap: () => _open(_privacyPolicyUrl)),
            Divider(color: EmberColors.stroke, height: 1, indent: 16),
            ListTile(leading: Icon(Icons.description_outlined, color: EmberColors.primary), title: Text(t('Términos de uso', 'Terms of Use')), trailing: Icon(Icons.open_in_new, size: 18, color: EmberColors.textDim), onTap: () => _open(_termsOfServiceUrl)),
            Divider(color: EmberColors.stroke, height: 1, indent: 16),
            ListTile(leading: Icon(Icons.help_outline, color: EmberColors.primary), title: Text(t('Ayuda y soporte', 'Help & support')), trailing: Icon(Icons.open_in_new, size: 18, color: EmberColors.textDim), onTap: () => _open(_supportUrl)),
          ])),
          if (StabilityMode.supported) ...[
            const SizedBox(height: 20),
            Padding(padding: const EdgeInsets.fromLTRB(4, 4, 4, 8), child: section(t('Solución de problemas', 'Troubleshooting'))),
            Card(child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SwitchListTile(
                  value: _stabilityOn,
                  onChanged: _setStability,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  title: Text(t('Modo de estabilidad', 'Stability mode')),
                  subtitle: Text(t('Para fallos poco frecuentes durante un uso intenso en algunas configuraciones NVIDIA, especialmente con la superposición de GeForce activa. Utiliza una ruta gráfica y de accesibilidad más segura. Se aplica después de reiniciar Pyre.', 'For rare crashes during heavy use on some NVIDIA setups, often when the GeForce overlay is on. Uses a safer graphics and accessibility path. Takes effect after you restart Pyre.'), style: TextStyle(color: EmberColors.textMid, fontSize: 12, height: 1.4)),
                ),
                Padding(padding: const EdgeInsets.fromLTRB(16, 2, 16, 6), child: Text(t('Consejo: si los fallos continúan, desactivar la superposición de NVIDIA dentro del juego para Pyre suele ser la solución más fiable.', 'Tip: if crashes continue, turning off the NVIDIA in-game overlay for Pyre is the most reliable fix.'), style: TextStyle(color: EmberColors.textDim, fontSize: 11, height: 1.4))),
              ]),
            )),
          ],
          const SizedBox(height: 20),
          Center(child: Text(_version.isEmpty ? 'Pyre' : 'Pyre $_version', style: TextStyle(color: EmberColors.textDim, fontSize: 11))),
        ],
      ),
    );
  }
}
