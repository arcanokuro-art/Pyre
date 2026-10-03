import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../theme.dart';

/// Practical tips for using the AI Character Creator.
class CharacterCreatorHelpScreen extends StatelessWidget {
  const CharacterCreatorHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final es = AppStrings.of(context).es;
    String t(String spanish, String english) => es ? spanish : english;

    return Scaffold(
      appBar: AppBar(title: Text(t('Consejos del creador', 'Creator tips'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          _h1(t('Consejos del creador', 'Creator tips')),
          _p(t(
            'Referencia rápida mientras creas. Para una explicación completa del Creador —el proceso de creación, los modos y los ajustes— abre Más → Ajustes del creador → «Cómo funciona el Creador de personajes».',
            'Quick reference for while you\'re building. For a full explanation of how the Creator works — the build, the building modes, the settings — open More → Creator settings → "How the Character Creator works".',
          )),
          _h2(t('Botón Adjuntar', 'Attach button')),
          _p(t(
            'El botón + antes del campo de texto abre tres opciones para adjuntar:',
            'The + button before the text field opens three attach options:',
          )),
          _bullet(t(
            '🖼  Imagen — elige una imagen de referencia. El modelo de visión describe la apariencia del personaje y el asistente usa ese perfil como contexto de referencia. Requiere un proveedor compatible con visión (configúralo en Más → Conexiones API).',
            '🖼  Image — pick a reference picture. The vision model describes what the character looks like, then the assistant uses that profile as authoritative context. Requires a vision-capable provider (set one in More → API Connections).',
          )),
          _bullet(t(
            '📛  Tarjeta de personaje — elige un PNG o JSON chara_card_v2. Los metadatos completos se incorporan a la conversación para que puedas editar una tarjeta existente o usarla como referencia.',
            '📛  Character card — pick a chara_card_v2 PNG or JSON. The full metadata is injected into the conversation so you can edit an existing card or use it as a reference.',
          )),
          _bullet(t(
            '📄  Documento — elige un TXT, MD o PDF. Se incorpora el texto completo, sin truncarlo. Es útil para lore del mundo, documentos de contexto o escenarios. Los PDF que solo contienen imágenes escaneadas todavía no funcionan porque Pyre no dispone de OCR.',
            '📄  Document — pick a TXT, MD, or PDF. The full text is injected (no truncation). Useful for world lore, background docs, or settings. PDFs that are scanned images won\'t work — Pyre can\'t OCR them yet.',
          )),
          _h2(t('Consejos útiles', 'Tips that actually help')),
          _bullet(t(
            'Empieza describiendo la idea o el ambiente, no con una lista. Una descripción como «princesa rota, fría por fuera y dulce por dentro» da a la IA más material con el que trabajar que una simple lista de atributos.',
            'Start with a vibe, not a checklist. A descriptive concept gives the AI more to work with than a simple list of attributes.',
          )),
          _bullet(t(
            'Si tienes una imagen de referencia, adjúntala PRIMERO, antes de conversar. El perfil visual se convertirá en contexto para las preguntas posteriores.',
            'If you have a reference image, attach it FIRST — before talking. The vision profile becomes context for every later question.',
          )),
          _bullet(t(
            'Al hacer ajustes, sé específico. «Cambia su edad a 22» funciona mejor que «Hazla mayor», porque así el modelo no tiene que adivinar.',
            'When refining, be specific. "Change her age to 22" works better than "Make her older" because the model does not have to guess.',
          )),
          _bullet(t(
            'No hay un botón «Generar»: tú le indicas a la IA cuándo debe construir la tarjeta. Cuando estés listo, indícalo o escribe /build. Entonces generará la tarjeta completa en varias pasadas.',
            'There is no "Generate" button — you tell the AI when to build. When you are ready, say so or type /build. It then writes the whole card in a multi-pass run.',
          )),
          _bullet(t(
            'La ficha permanece vacía mientras conversas y se completa cuando ejecutas la creación. Es el comportamiento esperado. Después revisa los campos y edita manualmente lo que quieras antes de guardar.',
            'The sheet stays empty while you talk and fills in when you build. That is expected. Review every field and edit anything you want before saving.',
          )),
          _h2(t('Sobre los modelos', 'About models')),
          _p(t(
            'Pyre te permite elegir el proveedor y el modelo. Cada modelo tiene capacidades y políticas diferentes, por lo que los resultados pueden variar. Si uno no responde como necesitas, prueba otro proveedor o modelo compatible con tu caso de uso.',
            'Pyre lets you choose your provider and model. Different models have different capabilities and policies, so results can vary. If one does not respond as needed, try another provider or model that fits your use case.',
          )),
          _h2(t('Solución de problemas', 'Troubleshooting')),
          _bullet(t(
            '«No hay ningún proveedor configurado» — abre Más → Conexiones API y añade primero un proveedor. En una instalación nueva también puedes configurarlo mediante el asistente inicial.',
            '"No provider configured" — open More → API Connections and add a provider first. On a fresh install you can also use the onboarding wizard.',
          )),
          _bullet(t(
            '«Falló el análisis de imagen» — el proveedor activo probablemente no admite visión. Configura un proveedor de visión para el creador en Más → Conexiones API.',
            '"Image analysis failed" — your active provider probably does not support vision. Set a creator vision provider in More → API Connections.',
          )),
          _bullet(t(
            'Si la creación falla o algún campo queda vacío, escribe /build para intentarlo de nuevo o cambia a otro modelo.',
            'If the build fails or a field comes back empty, type /build to run it again or switch to another model.',
          )),
          _bullet(t(
            'Si una edición pequeña cambia demasiado la tarjeta, el modelo puede haber ignorado la instrucción de conservar los demás campos. Prueba un modelo más preciso para las ediciones.',
            'If a small edit changes too much of the card, the model may have ignored the instruction to preserve the other fields. Try a more precise model for edits.',
          )),
          _bullet(t(
            'Si la generación tarda demasiado, las tarjetas largas pueden requerir miles de tokens. Aumenta los tokens máximos de respuesta en Más → Ajustes del creador → Ajustes de generación.',
            'If generation takes too long, long cards can require thousands of tokens. Increase Max Response Tokens in More → Creator settings → Generation settings.',
          )),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  static Widget _h1(String text) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Text(text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
      );

  static Widget _h2(String text) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 6),
        child: Text(text.toUpperCase(), style: TextStyle(color: EmberColors.primary, fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 1.2)),
      );

  static Widget _p(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: TextStyle(color: EmberColors.textHigh, fontSize: 13, height: 1.5)),
      );

  static Widget _bullet(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.only(right: 8, top: 6), child: Icon(Icons.circle, size: 4, color: EmberColors.textMid)),
            Expanded(child: Text(text, style: TextStyle(color: EmberColors.textHigh, fontSize: 13, height: 1.45))),
          ],
        ),
      );
}
