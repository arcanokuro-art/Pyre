// Customization audit follow-up (2026-07-15): the bubble color swatch row,
// EXTRACTED from chat_appearance_screen (where it was private) so the
// character editor's per-character bubble tint reuses the exact same palette
// and interaction — one source, no drift.

import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../theme.dart';

const List<int?> kBubbleColorPalette = <int?>[
  null,
  0xFF14141B,
  0xFF1B1B24,
  0xFF2A1D17,
  0xFF3A2018,
  0xFF1A2230,
  0xFF152619,
  0xFF241526,
  0xFF2C2233,
];

class BubbleColorRow extends StatelessWidget {
  final int? selected;
  final List<int?> palette;
  final ValueChanged<int?> onPick;
  const BubbleColorRow({
    super.key,
    required this.selected,
    this.palette = kBubbleColorPalette,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final es = AppStrings.of(context).es;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final argb in palette)
          if (argb == null)
            ChoiceChip(
              label: Text(es ? 'Predeterminado' : 'Default'),
              selected: selected == null,
              selectedColor: EmberColors.primary.withValues(alpha: 0.25),
              onSelected: (_) => onPick(null),
            )
          else
            BubbleColorSwatch(
              color: Color(argb),
              selected: selected == argb,
              onTap: () => onPick(argb),
            ),
      ],
    );
  }
}

class BubbleColorSwatch extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const BubbleColorSwatch({
    super.key,
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
            ? Icon(Icons.check, size: 16, color: EmberColors.textHigh)
            : null,
      ),
    );
  }
}
