import 'package:flutter/material.dart';

import '../services/managed_memory_settings.dart';
import '../services/memory_capacity.dart';
import '../theme.dart';

/// Discrete selector for Pyre's replacement managed historical memory.
///
/// Deliberately separate from the legacy checkpoint word-limit slider: these
/// values describe retained historical capacity, not summary length and not
/// the number of tokens sent to an API request.
class ManagedMemoryCapacitySelector extends StatelessWidget {
  final ManagedMemorySettings settings;
  final ValueChanged<MemoryCapacityTier> onChanged;

  const ManagedMemoryCapacitySelector({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Capacidad de memoria administrada',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Historial que Pyre puede conservar y recuperar. El contexto '
              'del modelo sigue limitando cuánto se envía en cada solicitud.',
              style: TextStyle(color: EmberColors.textMid, fontSize: 12),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<MemoryCapacityTier>(
                segments: const [
                  ButtonSegment(
                    value: MemoryCapacityTier.minimum,
                    label: Text('1M'),
                  ),
                  ButtonSegment(
                    value: MemoryCapacityTier.standard,
                    label: Text('2M · Estándar'),
                  ),
                  ButtonSegment(
                    value: MemoryCapacityTier.maximum,
                    label: Text('10M'),
                  ),
                ],
                selected: {settings.tier},
                showSelectedIcon: false,
                onSelectionChanged: (selection) {
                  if (selection.isNotEmpty) onChanged(selection.first);
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectionDescription(settings.tier),
              style: TextStyle(color: EmberColors.textMid, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _selectionDescription(MemoryCapacityTier tier) {
    switch (tier) {
      case MemoryCapacityTier.minimum:
        return '1M · Menor uso de almacenamiento histórico.';
      case MemoryCapacityTier.standard:
        return '2M · Capacidad estándar y predeterminada de Pyre.';
      case MemoryCapacityTier.maximum:
        return '10M · Máxima capacidad de historial administrado.';
    }
  }
}
