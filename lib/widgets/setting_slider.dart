import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../theme.dart';

/// Wave CY.18.192: a labelled slider Card with a subtitle, a tap-to-type
/// numeric input dialog (bypasses the slider's snap-grid for precise
/// values), and an optional preset-override badge.
class SliderCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String display;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;
  final String? overrideValue;

  const SliderCard({
    super.key,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.display,
    required this.onChanged,
    this.onChangeEnd,
    this.overrideValue,
  });

  String _fmtBound(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  Future<void> _openEditDialog(BuildContext context) async {
    final es = AppStrings.of(context).es;
    String t(String spanish, String english) => es ? spanish : english;
    final controller = TextEditingController(text: display);
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: display.length,
    );
    final raw = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(label),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                hintText: t('Introduce un número', 'Enter a number'),
                isDense: true,
              ),
              onSubmitted: (s) => Navigator.pop(ctx, s),
            ),
            const SizedBox(height: 8),
            Text(
              t(
                'Rango: ${_fmtBound(min)} – ${_fmtBound(max)}',
                'Range: ${_fmtBound(min)} – ${_fmtBound(max)}',
              ),
              style: TextStyle(
                color: EmberColors.textDim,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t('Cancelar', 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text(t('Establecer', 'Set')),
          ),
        ],
      ),
    );
    controller.dispose();
    if (raw == null) return;
    final parsed = double.tryParse(raw.trim().replaceAll(',', '.'));
    if (parsed == null) return;
    final clamped = parsed.clamp(min, max);
    onChanged(clamped);
    onChangeEnd?.call(clamped);
  }

  double get _clampedSliderValue =>
      max <= min ? min : value.clamp(min, max);

  @override
  Widget build(BuildContext context) {
    final es = AppStrings.of(context).es;
    final isOverridden = overrideValue != null;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            label,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          if (isOverridden) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: EmberColors.primary.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                es ? 'ANULADO POR PREAJUSTE' : 'PRESET OVERRIDE',
                                style: TextStyle(
                                  color: EmberColors.primary,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: EmberColors.textMid,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (isOverridden)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        overrideValue!,
                        style: TextStyle(
                          color: EmberColors.primary,
                          fontWeight: FontWeight.w700,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      InkWell(
                        onTap: () => _openEditDialog(context),
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                es ? 'era $display' : 'was $display',
                                style: TextStyle(
                                  color: EmberColors.textDim,
                                  fontSize: 10,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                              const SizedBox(width: 3),
                              Icon(
                                Icons.edit,
                                size: 10,
                                color: EmberColors.textDim,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  InkWell(
                    onTap: () => _openEditDialog(context),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            display,
                            style: TextStyle(
                              color: EmberColors.textMid,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.edit,
                            size: 12,
                            color: EmberColors.textDim,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Opacity(
              opacity: isOverridden ? 0.45 : 1.0,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8,
                  ),
                ),
                child: Slider(
                  value: _clampedSliderValue,
                  min: min,
                  max: max,
                  divisions: divisions,
                  activeColor: EmberColors.primary,
                  onChanged: onChanged,
                  onChangeEnd: onChangeEnd,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
