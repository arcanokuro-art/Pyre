// Wave CY.18.32: unified Character Creator settings screen.
//
// This screen consolidates what used to be two separate More entries:
//   - "Character Creator prompt" (Wave CY.18.10 — your additions
//     textarea + read-only base prompts)
//   - "Character Creator help" (Wave G — how the creator works,
//     model recommendations)
//
// And ALSO pulls in:
//   - "About Me" (Wave CY.18.30 — was on the Profile screen, but
//     conceptually belongs here next to "Your additions" since both
//     feed the architect's system prompt). Profile keeps the avatar
//     + username; this screen owns the creator-context fields.
//
// Layout, top to bottom:
//   1. Recommended models banner (DeepSeek V4 Pro for the creator;
//      Qwen 3.6 Plus Uncensored for vision) — front and centre so
//      users don't burn hours on a bad model before realising why
//      the experience is awful.
//   2. Your additions card — custom architect rules, debounce-saved.
//   3. Architect prompt preset — the active forkable CreatorPreset
//      with a button to manage/fork it (opens CreatorPresetsScreen).
//   4. How it works — collapsible help with the rest of the content
//      from the old standalone help screen (phases, attach buttons,
//      tips, troubleshooting).
//
// Wave CY.18.108: the old read-only base-prompt viewers (sections that
// just displayed kCardAssistantPrompt etc. behind ExpansionTiles) were
// removed. The forkable CreatorPreset (Wave 107) — previously its own
// "Creator Prompts" More entry — replaces them: the user sees the
// active preset and forks/edits it here instead of merely reading the
// shipped prompts. The runtime already swaps the base architect prompt
// from the active preset (`_architectPromptForSession`), so this is a
// pure UI/navigation consolidation.
//
// The screen is one ListView so everything scrolls naturally. No tabs
// (over-engineering for ~4 sections), no separate sub-screens beyond
// the preset manager (which is shared with nothing else now).

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../l10n/app_strings.dart';
import '../services/creator_schema.dart' show CreatorDescriptionSize;
import '../services/token_estimate.dart';
import '../state/app_store.dart';
import '../theme.dart';
import '../widgets/how_it_works_card.dart';
import '../widgets/setting_slider.dart';
import 'creator_presets_screen.dart';

class CharacterCreatorScreen extends StatefulWidget {
  const CharacterCreatorScreen({super.key});

  @override
  State<CharacterCreatorScreen> createState() =>
      _CharacterCreatorScreenState();
}

class _CharacterCreatorScreenState extends State<CharacterCreatorScreen> {
  late final TextEditingController _additionsCtl;
  Timer? _additionsDebounce;

  @override
  void initState() {
    super.initState();
    final store = context.read<AppStore>();
    _additionsCtl = TextEditingController(
        text: store.modelSettings.creatorPromptAddendum);
  }

  @override
  void dispose() {
    // Flush any pending debounced edits before tearing down so a fast
    // exit doesn't drop the tail keystrokes.
    _additionsDebounce?.cancel();
    final store = context.read<AppStore>();
    final pendingAdditions = _additionsCtl.text;
    if (store.modelSettings.creatorPromptAddendum != pendingAdditions) {
      final ms = store.modelSettings;
      ms.creatorPromptAddendum = pendingAdditions;
      store.updateModelSettings(ms);
    }
    _additionsCtl.dispose();
    super.dispose();
  }

  void _scheduleAdditionsCommit() {
    _additionsDebounce?.cancel();
    _additionsDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      final store = context.read<AppStore>();
      final ms = store.modelSettings;
      ms.creatorPromptAddendum = _additionsCtl.text;
      store.updateModelSettings(ms);
    });
  }

  void _clearAdditions() {
    setState(() => _additionsCtl.text = '');
    _additionsDebounce?.cancel();
    final store = context.read<AppStore>();
    final ms = store.modelSettings;
    ms.creatorPromptAddendum = '';
    store.updateModelSettings(ms);
  }

  @override
  Widget build(BuildContext context) {
    final additionsTokens = formatApproxTokens(_additionsCtl.text);
    final hasAdditions = _additionsCtl.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.of(context).es ? 'Ajustes del creador' : 'Creator settings'),
        actions: [
          if (hasAdditions)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TextButton(
                onPressed: _clearAdditions,
                child: Text(AppStrings.of(context).es ? 'Borrar añadidos' : 'Clear additions'),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: [
          // 1. Recommended models banner — sits at the very top so
          //    nobody misses it. Two distinct recommendations: one
          //    for the architect text model (the creator side), one
          //    for the vision model (image analysis).
          const _ModelRecommendationsBanner(),
          const SizedBox(height: 14),

          // 2. Your additions — custom architect rules appended at
          //    the end of the system prompt.
          //
          // Wave CY.18.36: the About Me card that used to sit here
          // moved to the Profile screen — it's now pure personal bio,
          // not architect context. The architect customisation lives
          // entirely in this card.
          _YourAdditionsCard(
            controller: _additionsCtl,
            onChanged: (_) {
              _scheduleAdditionsCommit();
              setState(() {});
            },
            tokens: additionsTokens,
          ),
          const SizedBox(height: 16),

          // Wave CY.18.192: the creator sampling knobs (max tokens +
          // three temperatures) moved here from the deleted Model
          // Settings screen. They only affect calls made inside the
          // Creator (design chat, image analysis, sheet update), so
          // they belong next to the architect customisation rather than
          // mixed in with the chat sampling defaults (now on Presets).
          // Collapsed by default — most users never need to touch them.
          const _GenerationSettingsCard(),
          const SizedBox(height: 16),

          // 3. Architect prompt preset — the active forkable
          //    CreatorPreset. Wave CY.18.108: replaces the old
          //    read-only base-prompt viewers. Shows which preset the
          //    Creator runs on and lets the user fork/edit it (opens
          //    the shared CreatorPresetsScreen manager).
          _SectionHeader(AppStrings.of(context).es ? 'Prompt del arquitecto' : 'Architect prompt'),
          const SizedBox(height: 6),
          const _ArchitectPresetCard(),

          const SizedBox(height: 8),

          // 4. How it works — collapsible help. Content lifted from
          //    the old standalone help screen, minus the now-redundant
          //    "Provider sign-up links" button (Bug #8 — value unclear,
          //    most users find their own way to a provider site).
          _HowItWorksCard(),
        ],
      ),
    );
  }
}

/// Section header used between cards. Small uppercase label, primary
/// colour, matches the existing inline header style elsewhere.
class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 4, bottom: 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: EmberColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

/// Wave CY.18.32: recommended-models banner at the top of the screen.
/// Pre-Wave this info was buried inside a long help screen — most
/// users never saw it and ended up using GPT/Claude for the Creator,
/// hitting refusals, and assuming the app was broken.
class _ModelRecommendationsBanner extends StatelessWidget {
  const _ModelRecommendationsBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: EmberColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: EmberColors.primary.withValues(alpha: 0.45),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.recommend_outlined,
                  size: 18, color: EmberColors.primary),
              SizedBox(width: 8),
              Text(
                AppStrings.of(context).es ? 'MODELOS RECOMENDADOS' : 'RECOMMENDED MODELS',
                style: TextStyle(
                  color: EmberColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.of(context).es ? 'Para el Creador de personajes (esta pantalla):' : 'For the Character Creator (this screen):',
            style: TextStyle(
              color: EmberColors.textHigh,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text(
              AppStrings.of(context).es ? '➤  DeepSeek V4 Pro — con diferencia, el mejor. Otros modelos de la familia DeepSeek (V3.2, V3 chat) también funcionan bien. Los modelos FUERA de la familia DeepSeek tienden a rechazar o fallar con contenido NSFW de las tarjetas, incluso con los añadidos de abajo.' : '➤  DeepSeek V4 Pro — by far the best. Other DeepSeek family models (V3.2, V3 chat) also work well. Models OUTSIDE the DeepSeek family tend to refuse or stumble on NSFW card content, even with the addendum below.',
              style: TextStyle(
                color: EmberColors.textHigh,
                fontSize: 12.5,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.of(context).es ? 'Para Visión (análisis de imágenes al crear tarjetas):' : 'For Vision (image analysis when building cards):',
            style: TextStyle(
              color: EmberColors.textHigh,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(left: 6),
            child: Text(
              AppStrings.of(context).es ? '➤  Qwen 3.6 Plus Uncensored — disponible en Venice y NanoGPT. Ofrece los mejores resultados para las descripciones clínicas de personajes que solicita el prompt de visión de Pyre.' : '➤  Qwen 3.6 Plus Uncensored — available on Venice and NanoGPT. Best results for the clinical character descriptions Pyre\'s vision prompt asks for.',
              style: TextStyle(
                color: EmberColors.textHigh,
                fontSize: 12.5,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: EmberColors.bgDeep.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline,
                    size: 13, color: EmberColors.textMid),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.of(context).es ? 'Configúralos en Más → Conexiones API. La tarjeta superior permite elegir proveedores distintos para Creador y Visión, independientemente del proveedor del chat principal.' : 'Set these in More → API Connections. The top card lets you override the Creator and Vision providers independently from the main chat provider.',
                    style: TextStyle(
                      color: EmberColors.textMid,
                      fontSize: 11.5,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom rules appended to the architect's prompt. Power-user knob.
class _YourAdditionsCard extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? tokens;
  const _YourAdditionsCard({
    required this.controller,
    required this.onChanged,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.of(context).es ? 'Tus añadidos' : 'Your additions',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                if (tokens != null && tokens!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: EmberColors.bgDeep,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: EmberColors.stroke, width: 1),
                    ),
                    child: Text(
                      tokens!,
                      style: TextStyle(
                        color: EmberColors.textDim,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.of(context).es ? 'Reglas personalizadas que se añaden al prompt del arquitecto. Ejemplos: "Responde siempre en portugués de Brasil.", "Mantén las apariencias en PG-13 salvo que indique lo contrario.", "Usa por defecto escenarios de instituto de anime."' : 'Custom rules appended to the architect\'s prompt. Examples: "Always respond in Brazilian Portuguese.", "Keep appearances PG-13 unless I say otherwise.", "Default scenarios to anime high-school settings."',
              style: TextStyle(
                color: EmberColors.textMid,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              onChanged: onChanged,
              minLines: 5,
              maxLines: 10,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: AppStrings.of(context).es ? 'Escribe reglas adicionales, pautas de estilo o preferencias de idioma. Déjalo en blanco para ejecutar el arquitecto exactamente como viene configurado.' : 'Type extra rules / style guidelines / language preferences. Leave blank to run the architect exactly as shipped.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wave CY.18.192: the creator sampling knobs, moved here from the
/// deleted Model Settings screen. These only affect calls made inside
/// the Character Creator — the regular chat ignores them entirely and
/// uses the global "Default generation" defaults (now on the Presets
/// screen). Wrapped in an [ExpansionTile], collapsed by default, since
/// the shipped defaults work for almost everyone.
///
/// Stateful: holds a working `_draft` ModelSettings (clone-mutate-commit,
/// same pattern as the old Model Settings screen) so each slider drag
/// updates instantly and persists on release. Only the four creator
/// fields are edited; everything else round-trips untouched.
class _GenerationSettingsCard extends StatefulWidget {
  const _GenerationSettingsCard();

  @override
  State<_GenerationSettingsCard> createState() =>
      _GenerationSettingsCardState();
}

class _GenerationSettingsCardState extends State<_GenerationSettingsCard> {
  late ModelSettings _draft;

  @override
  void initState() {
    super.initState();
    _draft = context.read<AppStore>().modelSettings.copy();
  }

  // Copy the four creator knobs we own onto the LIVE store object rather
  // than replacing it with `_draft`. The "Your additions" textarea on
  // this same screen debounces edits straight onto `store.modelSettings`
  // — replacing the whole object here would clobber a pending addendum
  // edit (the draft was cloned at initState with the old addendum).
  void _commit() {
    final store = context.read<AppStore>();
    final ms = store.modelSettings;
    ms.creatorMaxTokens = _draft.creatorMaxTokens;
    ms.creatorTemperature = _draft.creatorTemperature;
    ms.visionTemperature = _draft.visionTemperature;
    ms.sheetTemperature = _draft.sheetTemperature;
    ms.creatorDescriptionSize = _draft.creatorDescriptionSize;
    store.updateModelSettings(ms);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        leading: Icon(Icons.tune, color: EmberColors.primary, size: 20),
        title: Text(AppStrings.of(context).es ? 'Ajustes de generación' : 'Generation settings',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          AppStrings.of(context).es ? 'Controles de muestreo solo para el Creador (chat, análisis de imágenes y actualización de ficha). Los valores predeterminados funcionan en la mayoría de configuraciones.' : 'Sampling knobs for the Creator only (chat, image analysis, sheet update). Defaults work for most setups.',
          style: TextStyle(color: EmberColors.textMid, fontSize: 12),
        ),
        children: [
          // Wave CY.18.265: DESIRED size of the generated Description (char +
          // persona). A soft target, NOT the token cap below.
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.of(context).es ? 'Tamaño de la descripción' : 'Description size',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  AppStrings.of(context).es ? 'Define qué tan larga será la descripción que el Creador escribe para personajes y personas. Es un objetivo aproximado, no un límite; Estándar coincide con el valor predeterminado de Pyre.' : 'How long a Description the Creator writes for characters and personas. A soft target, not a cap — Standard matches Pyre\'s default.',
                  style: TextStyle(color: EmberColors.textMid, fontSize: 12),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<CreatorDescriptionSize>(
                    segments: [
                      ButtonSegment(value: CreatorDescriptionSize.concise, label: Text(AppStrings.of(context).es ? 'Concisa' : 'Concise')),
                      ButtonSegment(value: CreatorDescriptionSize.standard, label: Text(AppStrings.of(context).es ? 'Estándar' : 'Standard')),
                      ButtonSegment(value: CreatorDescriptionSize.detailed, label: Text(AppStrings.of(context).es ? 'Detallada' : 'Detailed')),
                      ButtonSegment(value: CreatorDescriptionSize.veryDetailed, label: Text(AppStrings.of(context).es ? 'Máx.' : 'Max')),
                    ],
                    selected: {_draft.creatorDescriptionSize},
                    showSelectedIcon: false,
                    onSelectionChanged: (s) {
                      setState(() => _draft.creatorDescriptionSize = s.first);
                      _commit();
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.selected)
                              ? EmberColors.primary
                              : EmberColors.bgElevated),
                      foregroundColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.selected)
                              ? Colors.white
                              : EmberColors.textMid),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          SliderCard(
            label: AppStrings.of(context).es ? 'Máximo de tokens del Creador' : 'Creator max tokens',
            subtitle: AppStrings.of(context).es ? 'Límite para las tres llamadas del Creador. Los modelos de razonamiento intensivo (DeepSeek V4, R1) consumen 3–5 mil tokens solo al razonar; mantenlo alto para dejar espacio al contenido de la tarjeta. Predeterminado: 12000.' : 'Cap for all three creator calls. Heavy-reasoning models (DeepSeek V4, R1) burn 3-5k tokens on thinking alone — keep this high so the actual card content has room. Default 12000.',
            value: _draft.creatorMaxTokens.toDouble(),
            min: 1024,
            max: 32768,
            divisions: 62,
            display: _draft.creatorMaxTokens.toString(),
            onChanged: (v) =>
                setState(() => _draft.creatorMaxTokens = v.round()),
            onChangeEnd: (_) => _commit(),
          ),
          SliderCard(
            label: AppStrings.of(context).es ? 'Temperatura — chat del Creador' : 'Temperature — creator chat',
            subtitle: AppStrings.of(context).es ? 'Conversación de diseño con el asistente. Predeterminado 0.95 = creativo; bájalo para obtener respuestas más enfocadas.' : 'Design conversation with the assistant. Default 0.95 = creative; lower for more focused replies.',
            value: _draft.creatorTemperature,
            min: 0,
            max: 2,
            divisions: 40,
            display: _draft.creatorTemperature.toStringAsFixed(2),
            onChanged: (v) => setState(() => _draft.creatorTemperature = v),
            onChangeEnd: (_) => _commit(),
          ),
          SliderCard(
            label: AppStrings.of(context).es ? 'Temperatura — análisis de imágenes' : 'Temperature — image analysis',
            subtitle: AppStrings.of(context).es ? 'Llamada de Visión que describe las imágenes adjuntas. Mantenla baja (0.3–0.5) para que el modelo describa lo que ve en vez de inventar.' : 'Vision call that describes attached images. Keep low (0.3-0.5) so the model captures what it sees instead of inventing.',
            value: _draft.visionTemperature,
            min: 0,
            max: 1.5,
            divisions: 30,
            display: _draft.visionTemperature.toStringAsFixed(2),
            onChanged: (v) => setState(() => _draft.visionTemperature = v),
            onChangeEnd: (_) => _commit(),
          ),
          SliderCard(
            label: AppStrings.of(context).es ? 'Temperatura — actualización de ficha' : 'Temperature — sheet update',
            subtitle: AppStrings.of(context).es ? 'Combinador JSON estructurado que rellena el lienzo después de cada turno. Un valor cercano a cero (0.0–0.3) mantiene la salida procesable.' : 'Structured JSON merger that fills the canvas after each turn. Near-zero (0.0-0.3) keeps the output parseable.',
            value: _draft.sheetTemperature,
            min: 0,
            max: 1,
            divisions: 20,
            display: _draft.sheetTemperature.toStringAsFixed(2),
            onChanged: (v) => setState(() => _draft.sheetTemperature = v),
            onChangeEnd: (_) => _commit(),
          ),
        ],
      ),
    );
  }
}

/// Wave CY.18.108: the active forkable architect-prompt preset, shown
/// inline in Character Creator. Replaces the three old read-only
/// `_BasePromptSection` viewers AND the standalone "Creator Prompts"
/// More entry.
///
/// Shows the active [CreatorPreset] (name + DEFAULT badge when locked +
/// a one-line preview of its character prompt) and a button that opens
/// the shared [CreatorPresetsScreen] manager to fork/edit/switch
/// presets. The locked "Pyre Default" stays read-only there; the user
/// copies it to get an editable fork. The runtime already swaps the
/// base architect prompt from whichever preset is active
/// (`_architectPromptForSession`), so this card only surfaces that
/// choice — it does not change generation behaviour.
class _ArchitectPresetCard extends StatelessWidget {
  const _ArchitectPresetCard();

  @override
  Widget build(BuildContext context) {
    // Watch the store so the active-preset name/badge refresh in place
    // after the user forks or switches presets in the manager.
    final store = context.watch<AppStore>();
    final active = store.activeCreatorPreset;
    final locked = active?.locked ?? true;
    final name = active?.name ?? 'Pyre Default';
    final preview = _presetPreview(active);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  locked ? Icons.lock_outline : Icons.layers_outlined,
                  size: 18,
                  color: EmberColors.primary,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
                if (locked) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: EmberColors.primary.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color:
                              EmberColors.primary.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      AppStrings.of(context).es ? 'PREDETERMINADO' : 'DEFAULT',
                      style: TextStyle(
                        color: EmberColors.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.of(context).es ? 'Los prompts base del arquitecto (Personaje / Escenario / Edición) que utiliza el Creador. "Pyre Default" es de solo lectura; crea una copia personalizada para modificar los prompts base. Tus añadidos de arriba se siguen agregando al preajuste que esté activo.' : 'The base architect prompts (Character / Scenario / Edit) the Creator runs on. The shipped "Pyre Default" is read-only — fork it to a custom preset to rewrite the base prompts. Your additions above still append on top of whichever preset is active.',
              style: TextStyle(
                color: EmberColors.textMid,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            if (preview != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: EmberColors.bgElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: EmberColors.stroke, width: 1),
                ),
                child: Text(
                  preview,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: EmberColors.textHigh,
                    fontSize: 11,
                    height: 1.4,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const CreatorPresetsScreen()),
                ),
                icon: const Icon(Icons.tune, size: 18),
                label: Text(AppStrings.of(context).es ? (locked ? 'Copiar o cambiar preajuste' : 'Administrar preajustes de prompts') : (locked ? 'Fork or switch preset' : 'Manage prompt presets')),
                style: TextButton.styleFrom(
                  foregroundColor: EmberColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// One-line preview of the preset's character prompt (collapsed
  /// whitespace), or null when there's nothing to show.
  static String? _presetPreview(CreatorPreset? p) {
    if (p == null) return null;
    final src = p.characterPrompt.trim();
    if (src.isEmpty) return null;
    return src.replaceAll(RegExp(r'\s+'), ' ');
  }
}

/// Wave CY.18.32: collapsible help card. Distilled from the old
/// CharacterCreatorHelpScreen, with the model-recommendation content
/// removed (it's the prominent banner at the top of this screen now)
/// and the Provider Sign-up Links button removed entirely (Bug #8 —
/// the button was a low-value extra step; people who want providers
/// can search). What stays: how the conversation phases work, attach
/// buttons, NSFW guidance, tips, and the troubleshooting bullets.
///
/// Wave CY.18.201: expanded with the "What the Character Creator is"
/// overview and "The four conversation phases" sections, moved here
/// from CharacterCreatorHelpScreen (which is now a concise tips-only
/// quick-reference). This card is now the canonical long-form docs
/// surface; the in-Creator "?" help is actionable-tips-only.
// Wave CY.18.206: this card now delegates ALL rendering to the shared
// [HowItWorksCard] widget (lib/widgets/how_it_works_card.dart) — the
// same renderer the Long-term Memory / Live Sheet / Script explainers
// use. The content below is unchanged from the previous inline version
// (just restructured into HowItWorksSection blocks), so the Creator card
// renders byte-identical to before.
class _HowItWorksCard extends StatelessWidget {
  const _HowItWorksCard();

  @override
  Widget build(BuildContext context) {
    final es = AppStrings.of(context).es;
    return HowItWorksCard(
      title: es ? 'Cómo funciona el Creador de personajes' : 'How the Character Creator works',
      subtitle: es ? 'Qué es, fases, modos, consejos y solución de problemas.' : 'What it is, phases, modes, tips, troubleshooting.',
      sections: [
        // 0. Entry-point overview — what the Creator is.
        HowItWorksSection(es ? 'Qué es el Creador de personajes' : 'What the Character Creator is', [
          HowItWorksBlock.paragraph(
              'Open Library tab → tap +. Three ways to build:\n'
              '  • Build with AI assistant — what this section covers\n'
              '  • Create from scratch — manual editor, full control\n'
              '  • Import — PNG / JSON / URL\n\n'
              'The AI assistant flow is a conversation. You sketch the '
              'character, the AI asks targeted questions to fill in '
              'gaps, and when you\'re both happy it writes the full '
              'card.'),
        ]),

        // 0b. How a session flows (structured build — the old GREETING/
        // BUILD-UP/GENERATE/REFINE phase model + "Generate" button were
        // retired with the deterministic build).
        HowItWorksSection(es ? 'Cómo transcurre una sesión' : 'How a session flows', [
          HowItWorksBlock.paragraph(es
              ? '1) **Habla sobre la idea** — cuéntale a la IA el concepto. Puede ser algo vago; hará algunas preguntas específicas. La ficha permanece vacía mientras conversan: todavía no se escribe nada.\\n\\n2) **Crear** — cuando la IA proponga crearla, o cuando tú estés listo, indícalo (o escribe /build). Entonces escribe TODA la tarjeta mediante varias pasadas automáticas.\\n\\n3) **Revisar** — la tarjeta terminada aparece campo por campo en el lienzo. Revísala y toca cualquier campo para editarlo manualmente.\\n\\n4) **Refinar o guardar** — sigue conversando para pedir cambios; la IA modifica solo lo que pediste y deja lo demás intacto, o guarda la tarjeta en tu biblioteca.'
              : '1) **Talk it out** — tell the AI the vibe. Vague is fine; it asks a few targeted questions. The sheet stays empty while you chat.\\n\\n2) **Build** — when the AI proposes building, or any time you are ready, say the word (or type /build). It writes the whole card over a few automatic passes.\\n\\n3) **Review** — the finished card appears field-by-field in the canvas. Read it and edit any field by hand.\\n\\n4) **Refine or save** — keep chatting to ask for changes, or save it to your library.'),
        ]),

        // 1. Building modes — what the new-session picker offers.
        HowItWorksSection(es ? 'Qué puedes crear' : 'What you can build', [
          HowItWorksBlock.paragraph(
              es ? 'Una nueva sesión del Creador pregunta qué vas a crear; tu elección determina qué arquitecto se utiliza:' : 'A new Creator session asks what you\'re making — the choice sets which architect runs the show:'),
          HowItWorksBlock.bullet(
              es ? '**Personaje** — una sola persona para roleplay. Nombre, apariencia, voz, personalidad, contradicciones e intereses. Es la opción predeterminada y la más común.' : '**Character** — a single persona for roleplay. Name, look, voice, personality, contradictions, kinks. The default and most common.'),
          HowItWorksBlock.bullet(
              es ? '**Escenario** — un entorno con un narrador que interpreta NPC y describe escenas. Úsalo cuando estés creando un mundo o un centro de interacción, no un solo personaje.' : '**Scenario** — a setting with a narrator that voices NPCs and describes scenes. Use when you\'re building a world or hub ("haunted mansion", "supernatural school", "free-use city"), not a single character.'),
          HowItWorksBlock.bullet(
              es ? '**Libros de lore** ya no son una opción inicial aquí; créalos desde la sección Libros de lore de tu biblioteca (Crear → Crear con IA). Las sesiones de personajes todavía pueden preparar entradas de lore para la tarjeta durante el proceso.' : '**Lorebooks** aren\'t a starting choice here anymore — create them from the Lorebooks section of your library (Create → Build with AI). Character sessions can still draft lorebook entries for the card as you go.'),
          HowItWorksBlock.paragraph(es
    ? '**Editar con IA** no es una opción inicial: sirve para volver a abrir en el Creador un personaje o persona EXISTENTE desde su acción «Editar con IA». Carga la tarjeta en la ficha y cada mensaje se convierte en una edición parcial, modificando solo lo que pidas. Funciona con tarjetas creadas en cualquier lugar y conserva el formato original salvo que pidas cambiarlo.'
    : '**Edit with AI** isn\'t a starting choice — it\'s how you open an EXISTING character or persona back into the Creator. It loads the card on the sheet and every message becomes a partial edit, touching only what you asked. It works on cards built ANYWHERE and preserves the original format unless you ask it to change.'),
        ]),

        // Wave CY.18.101: guided flow removed — single freeform flow.
        HowItWorksSection(es ? 'Cómo se ejecuta la creación' : 'How the build runs', [
          HowItWorksBlock.paragraph(
              es ? 'Cuando indicas que se cree, el arquitecto escribe toda la ficha mediante varias pasadas automáticas (verás un contador «pasada X de N»); no tienes que confirmar nada durante el proceso. Normalmente tarda unos minutos según tu proveedor, y Pyre continúa generando en segundo plano si minimizas la aplicación.' : 'When you say to build, the architect writes the whole sheet over a few automatic passes (you\'ll see a "pass X of N" counter) — you don\'t confirm anything along the way. It usually takes a few minutes depending on your provider, and Pyre keeps generating in the background if you minimise the app.'),
        ]),

        // 3. What gets built. (Wave CY.18.112: de-jargoned — the
        // user-facing help no longer exposes the internal "block"
        // scaffolding; it just describes the card's contents.)
        HowItWorksSection(es ? 'Qué se crea' : 'What gets built', [
          HowItWorksBlock.paragraph(
              'You don\'t drive any of this — the architect fills the '
              'whole card for you in order, saving the wrap-up '
              '(tagline, creator notes, tags) for last so it can '
              'reference everything that came before. A character '
              'card covers:'),
          HowItWorksBlock.bullet(
              es ? 'Apariencia — aspecto, complexión y rasgos distintivos' : 'Appearance — look, build, distinctive features'),
          HowItWorksBlock.bullet(es ? 'Personalidad y psicología' : 'Personality & psychology'),
          HowItWorksBlock.bullet(es ? 'Habilidades, lore y mundo' : 'Abilities, lore & world'),
          HowItWorksBlock.bullet(
              es ? 'La apertura — escenario, primer mensaje y ejemplos' : 'The opening — scenario, first message & examples'),
          HowItWorksBlock.bullet(
              es ? 'Eslogan, notas del creador y etiquetas (el cierre)' : 'Tagline, creator notes & tags (the wrap-up)'),
          HowItWorksBlock.paragraph(
              'A scenario card covers the same ground re-aimed at a '
              'setting: the world and its rules, the cast (NPCs), the '
              'opening scene, and the same wrap-up.'),
          HowItWorksBlock.paragraph(
              'The automatic build doesn\'t write alternate greetings — '
              'you can add those by hand in the editor after saving '
              '(Advanced → Alternate greetings).'),
        ]),

        // 4. Your additions reach the architect.
        //
        // Wave CY.18.92: About Me used to feed here as "soft
        // context" but Wave CY.18.36 demoted it to pure personal
        // bio on the Profile screen. The architect now ONLY sees
        // Your additions — keeping the help text in sync.
        HowItWorksSection(es ? 'Tus añadidos' : 'Your additions', [
          HowItWorksBlock.paragraph(
              es ? 'El cuadro de texto de arriba se añade al prompt de sistema de cada sesión del Creador como reglas obligatorias.' : 'The text box higher up on this screen is appended to every Creator session\'s system prompt as hard rules.'),
          HowItWorksBlock.bullet(
              'Custom architect behaviour you want enforced — '
              '"always respond in Brazilian Portuguese", "keep '
              'appearances PG-13 unless I say otherwise", "default '
              'scenarios to anime high-school". These override the '
              'architect\'s defaults.'),
          HowItWorksBlock.bullet(
              es ? 'Déjalo vacío y el prompt base se ejecutará sin cambios.' : 'Leave it empty and the base prompt runs unchanged.'),
          HowItWorksBlock.paragraph(
              'Your Profile "About Me" is NOT sent to the architect '
              '— it\'s a local bio on the Profile screen, not a '
              'context input.'),
        ]),

        // 5. Attach buttons.
        HowItWorksSection(es ? 'Botones para adjuntar' : 'Attach buttons', [
          HowItWorksBlock.paragraph(
              es ? 'En la barra de entrada tienes tres iconos antes del campo de texto:' : 'In the input bar you have three icons before the text field:'),
          HowItWorksBlock.bullet(
              es ? '**Imagen** — selecciona una imagen de referencia. El modelo de visión describe detalladamente el aspecto del personaje, personajes o escenario, y el arquitecto usa ese perfil como contexto de referencia. Requiere un proveedor compatible con visión.' : '**Image** — pick a reference picture. The vision model describes what the character (or characters, or setting) looks like in clinical detail, then the architect uses that profile as authoritative context. Requires a vision-capable provider — Qwen 3.6 Plus Uncensored on Venice or NanoGPT is the pick.'),
          HowItWorksBlock.bullet(
              es ? '**Tarjeta de personaje** — selecciona un PNG o JSON chara_card_v2. Los metadatos completos se incorporan a la conversación para que puedas editar una tarjeta existente o usarla como referencia.' : '**Character card** — pick a chara_card_v2 PNG or JSON. The full metadata is injected into the conversation so you can edit an existing card or use it as a reference ("make me a card like this one but darker").'),
          HowItWorksBlock.bullet(
              es ? '**Documento** — selecciona un TXT, MD o PDF. Se incorpora el texto completo, sin recortarlo. Es útil para lore del mundo y documentos de contexto. Los PDF que sean imágenes escaneadas no funcionan todavía porque no hay OCR.' : '**Document** — pick a TXT, MD, or PDF. The full text is injected (no truncation). Useful for world lore, background docs, "here\'s the setting, build me an NPC that fits". PDFs that are scanned images won\'t work — no OCR yet.'),
        ]),

        // 6. After the card is built.
        HowItWorksSection(es ? 'Después de crear la tarjeta' : 'After the card is built', [
          HowItWorksBlock.paragraph(
              es ? 'Cuando termina el cierre, la tarjeta queda lista. En este punto puedes hacer varias cosas:' : 'Once the wrap-up lands, the card is shippable. A few things you can do at this point:'),
          HowItWorksBlock.bullet(
              es ? '**Guardar tarjeta** — la añade a tu biblioteca de Personajes. El avatar predeterminado será la imagen de referencia que adjuntaste (o un marcador). Después de guardar, puedes iniciar un chat con la nueva tarjeta.' : '**Save card** — commits to your Characters library. Default avatar is the reference image you attached (or a placeholder). After saving, the screen offers to start a chat with the new card.'),
          HowItWorksBlock.bullet(
              '**Ask for an image prompt** — "give me an image '
              'prompt" / "avatar prompt" produces TWO formats in '
              'one go: natural-language flow (for GPT Image, '
              'Midjourney, Flux) and danbooru tags (for SDXL / Pony '
              '/ Illustrious). Recommended dimensions: 768×1280 '
              'portrait.'),
          HowItWorksBlock.bullet(
              '**Add alternate greetings by hand** — the build '
              'doesn\'t write these, but you can add as many as you '
              'like in the editor (Advanced → Alternate greetings) '
              'after saving. Mix POVs, times of day, tones — '
              'each greeting is its own opening.'),
          HowItWorksBlock.bullet(
              es ? '**Seguir refinando mediante el chat** — cualquier mensaje después del cierre se interpreta como una edición parcial, igual que en el modo Editar con IA.' : '**Continue refining via chat** — any message after the wrap-up is interpreted as a partial edit. Same shape as Edit-with-AI mode.'),
        ]),

        // 7. Background generation.
        HowItWorksSection(es ? 'Generación en segundo plano' : 'Background generation', [
          HowItWorksBlock.paragraph(
              es ? 'Una creación completa normalmente tarda unos minutos; cada pasada puede durar entre 30 y 90 segundos. Pyre usa un servicio en primer plano para continuar generando al minimizar la aplicación o apagar la pantalla; no cierres el proceso. Mientras la generación esté activa aparecerá una notificación persistente.' : 'A full build usually takes a few minutes; each pass can be 30–90 seconds. Pyre uses a foreground service so generation continues when you minimise the app or screen-off — just don\'t kill the process. A persistent notification appears while generation is active.'),
          HowItWorksBlock.bullet(
              es ? 'Pulsa **Detener** en el mensaje del asistente en cualquier momento para cancelar durante la generación. NO se reanuda automáticamente; tú decides cuándo continuar.' : 'Hit **Stop** on the streaming assistant message any time to cancel mid-generation. It does NOT auto-resume — you\'re in control of when to continue.'),
          HowItWorksBlock.bullet(
              es ? 'Pulsa **Reintentar** en el último mensaje del asistente para regenerar la sección más reciente. Se restaura la instantánea del lienzo anterior al turno para empezar desde un estado limpio, sin campos parciales sobrantes.' : 'Hit **Retry** on the last assistant message to regenerate the most recent section. The pre-turn canvas snapshot restores so retry starts from a clean state — no leftover partial fields.'),
        ]),

        // 8. Tips.
        HowItWorksSection(es ? 'Consejos que realmente ayudan' : 'Tips that actually help', [
          HowItWorksBlock.bullet(
              'Start with a vibe, not a checklist. "broken '
              'princess, cold on the outside, soft underneath" '
              'gives the architect more to work with than '
              '"name: X, age: 18, hair: blonde".'),
          HowItWorksBlock.bullet(
              es ? 'Si tienes una imagen de referencia, adjúntala PRIMERO, antes de conversar. El perfil de visión se convierte en contexto para las preguntas posteriores.' : 'If you have a reference image, attach it FIRST — before talking. The vision profile becomes context for every later question.'),
          HowItWorksBlock.bullet(
              es ? 'Al refinar, sé específico. «Cambia su edad a 22» funciona mejor que «Hazla mayor», que obliga al modelo a adivinar.' : 'When refining, be specific. "Change her age to 22" works. "Make her older" makes the model guess.'),
          HowItWorksBlock.bullet(
              'If the assistant tries to be vanilla or dodges '
              'NSFW requests, your provider has refusal patterns. '
              'The model matters more than the prompt — see the '
              'recommendations at the top of this screen. DeepSeek '
              'family models just write what you ask.'),
          HowItWorksBlock.bullet(
              'Magic phrases in Freeform mode work in any '
              'language. "faz a ficha", "build it", "vai", "go", '
              '"作って" — the architect detects build intent '
              'semantically, not from a phrase list.'),
        ]),

        // 9. NSFW reality.
        HowItWorksSection(es ? 'Sobre el contenido para adultos' : 'Honest section', [
          HowItWorksBlock.paragraph(
              'Most people building cards in tools like this are '
              'doing roleplay that\'s adult, often explicit, often '
              'weird. That\'s fine — Pyre is built for that. The '
              'model you pick matters more than the prompt you '
              'write. Big-name commercial models (Claude, GPT) '
              'will dance around NSFW no matter how clever your '
              'prompt; open-weight models and uncensored hosts '
              '(DeepSeek direct, Venice, NanoGPT, Soji, '
              'Featherless, Arli, Infermatic) just write what you '
              'ask. Pyre doesn\'t take a side here — your '
              'providers, your choice, your tokens.'),
        ]),

        // 10. Troubleshooting.
        HowItWorksSection(es ? 'Solución de problemas' : 'Troubleshooting', [
          HowItWorksBlock.bullet(
              es ? '**«No hay ningún proveedor configurado»** — abre Más → Conexiones API y añade un proveedor. Si lo necesitas, usa la tarjeta de configuración superior para establecer proveedores separados para Creador y Visión.' : '**"No provider configured"** — Open More → API Connections and add a provider. Use the override card at the top to set a separate Creator and Vision provider if needed.'),
          HowItWorksBlock.bullet(
              es ? '**«Falló el análisis de la imagen»** — tu proveedor activo no admite visión. Configura un proveedor específico compatible con visión.' : '**"Image analysis failed"** — your active provider doesn\'t support vision. Set a vision-specific provider (Qwen 3.6 Plus Uncensored on Venice or NanoGPT).'),
          HowItWorksBlock.bullet(
              '**"The architect claimed a section was done '
              'but never wrote the structured card data"** — '
              'your model is ignoring structured-output discipline. '
              'Switch to a DeepSeek-family model. Pyre will '
              'auto-retry up to 3 times before surfacing this '
              'warning.'),
          HowItWorksBlock.bullet(
              '**Card seems lobotomised after a small edit** — '
              'your model probably ignored the "preserve every '
              'field" rule and rewrote everything. Same fix: '
              'switch to a model that follows instructions better.'),
          HowItWorksBlock.bullet(
              '**Generating takes forever / hangs silently** — '
              'long card outputs can hit 4–8k tokens. Increase '
              '"Creator max tokens" in the Generation settings '
              'section above. Also check the persistent '
              'notification — if it disappeared, the OS killed the '
              'foreground service and you\'ll need to restart the '
              'generation.'),
          HowItWorksBlock.bullet(
              '**Imported card got reformatted unexpectedly** — '
              'this should NOT happen in Edit-with-AI mode. The '
              'edit architect explicitly preserves W++ / prose / '
              'XML / labeled-line conventions in place. If your '
              'model normalised the format anyway, it\'s ignoring '
              'the prompt — try a different DeepSeek model.'),
          HowItWorksBlock.bullet(
              '**A field already filled but the architect '
              're-fills it** — confused model loop. Hit Retry once; '
              'if it persists, tell it explicitly to move on to '
              'what\'s still missing.'),
        ]),
      ],
    );
  }
}
