import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/memory_capacity.dart';
import '../state/app_store.dart';
import '../theme.dart';

class LongTermMemoryScreen extends StatelessWidget {
  const LongTermMemoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final selected = store.managedMemoryTier;
    return Scaffold(
      appBar: AppBar(title: const Text('Memoria')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Capacidad general de memoria',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecciona cuánta memoria histórica administrará Pyre. 2M es la configuración estándar.',
            style: TextStyle(color: EmberColors.textMid),
          ),
          const SizedBox(height: 20),
          SegmentedButton<MemoryCapacityTier>(
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
            selected: {selected},
            showSelectedIcon: true,
            onSelectionChanged: (values) {
              if (values.isNotEmpty) {
                store.updateManagedMemoryTier(values.first);
              }
            },
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                selected == MemoryCapacityTier.minimum
                    ? '1M · Memoria mínima'
                    : selected == MemoryCapacityTier.maximum
                    ? '10M · Memoria máxima'
                    : '2M · Memoria estándar y predeterminada',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
