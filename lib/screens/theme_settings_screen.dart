// Wave B — Theme settings screen.
//
// Lets the user pick one of the three curated palettes (Ember / Moonlit /
// Hearth) and optionally override the primary accent color on top of the
// chosen palette. Both controls call the already-shipped AppStore methods
// (setActiveTheme / setAccentColor) so the whole app recolors live.
//
// Section layout:
//   1. Theme tiles — one card per palette in kCuratedPalettes.  Each tile
//      shows the palette name and a 5-chip swatch row preview
//      (bgDeep / bgPanel / bgElevated / primary / textHigh).  The active
//      theme gets a primary-colored border + check icon.
//   2. Accent color — a "Match theme" chip (accent = null) plus a curated
//      row of tinted accent swatches.  The same circular-swatch widget used
//      in chat_appearance_screen.dart's bubble-color row, for consistency.
//
// Constraints observed:
//   • Does NOT modify theme.dart, models.dart, or app_store.dart.
//   • Does NOT touch bubble / chat appearance behavior.
//   • Uses EmberColors.* for its own chrome (screen follows active theme).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_store.dart';
import '../theme.dart';
// 2026-07-03: "Display" merged into this "Appearance" screen — reuse its cards.
import 'display_settings_screen.dart'
    show AppTextSizeCard, WideLayoutCard, isDesktopLikePlatform;

const List<int?> _kAccentPalette = <int?>[
  null,
  0xFFFF6A3D,
  0xFF8FA8FF,
  0xFFE8A24C,
  0xFFD46A9E,
  0xFF64C8A0,
  0xFF6EC6FF,
  0xFFB388FF,
  0xFFFF7B7B,
  0xFFFFC84A,
  0xFF80CBC4,
];

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final activeId = store.uiPrefs.activeThemeId;
    final accentArgb = store.uiPrefs.accentArgb;

    return Scaffold(
      appBar: AppBar(title: const Text('Apariencia')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
        children: [
          _SectionLabel(label: 'Tema'),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                for (int i = 0; i < kCuratedPalettes.length; i++) ...[
                  if (i > 0)
                    Divider(
                      color: EmberColors.stroke,
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                  _ThemeTile(
                    palette: kCuratedPalettes[i],
                    isSelected: kCuratedPalettes[i].id == activeId,
                    onTap: () => context
                        .read<AppStore>()
                        .setActiveTheme(kCuratedPalettes[i].id),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SectionLabel(label: 'Color de acento'),
          const SizedBox(height: 4),
          Text(
            'Reemplaza el color principal del tema activo. '
            '“Igualar al tema” restaura el color de acento original del tema.',
            style: TextStyle(
                color: EmberColors.textMid, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 10),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: _AccentRow(
                selectedArgb: accentArgb,
                onPick: (argb) =>
                    context.read<AppStore>().setAccentColor(argb),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _SectionLabel(label: 'Tamaño del texto'),
          const SizedBox(height: 8),
          const AppTextSizeCard(),
          if (isDesktopLikePlatform) ...[
            const SizedBox(height: 20),
            _SectionLabel(label: 'Diseño'),
            const SizedBox(height: 8),
            const WideLayoutCard(),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: EmberColors.textDim,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final EmberPalette palette;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.palette,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        decoration: isSelected
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: EmberColors.primary,
                  width: 2,
                ),
              )
            : null,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    palette.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _PaletteSwatchRow(palette: palette),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (isSelected)
              Icon(Icons.check_circle_rounded,
                  color: EmberColors.primary, size: 22)
            else
              const SizedBox(width: 22),
          ],
        ),
      ),
    );
  }
}

class _PaletteSwatchRow extends StatelessWidget {
  final EmberPalette palette;
  const _PaletteSwatchRow({required this.palette});

  @override
  Widget build(BuildContext context) {
    final chips = [
      palette.bgDeep,
      palette.bgPanel,
      palette.bgElevated,
      palette.primary,
      palette.textHigh,
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < chips.length; i++)
          Container(
            width: 28,
            height: 20,
            margin: EdgeInsets.only(right: i < chips.length - 1 ? 4 : 0),
            decoration: BoxDecoration(
              color: chips[i],
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: EmberColors.stroke.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
          ),
      ],
    );
  }
}

class _AccentRow extends StatelessWidget {
  final int? selectedArgb;
  final ValueChanged<int?> onPick;

  const _AccentRow({
    required this.selectedArgb,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final argb in _kAccentPalette)
          if (argb == null)
            ChoiceChip(
              label: const Text('Igualar al tema'),
              selected: selectedArgb == null,
              selectedColor: EmberColors.primary.withValues(alpha: 0.22),
              onSelected: (_) => onPick(null),
            )
          else
            _AccentSwatch(
              color: Color(argb),
              selected: selectedArgb == argb,
              onTap: () => onPick(argb),
            ),
      ],
    );
  }
}

class _AccentSwatch extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _AccentSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? EmberColors.primary : EmberColors.stroke,
            width: selected ? 3 : 1,
          ),
        ),
        child: selected
            ? Icon(Icons.check, size: 16, color: foregroundOnAccent(color))
            : null,
      ),
    );
  }
}
