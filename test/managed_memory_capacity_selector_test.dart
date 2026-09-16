import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyre/services/managed_memory_settings.dart';
import 'package:pyre/services/memory_capacity.dart';
import 'package:pyre/widgets/managed_memory_capacity_selector.dart';

void main() {
  testWidgets('shows only the supported 1M 2M and 10M tiers', (tester) async {
    final settings = ManagedMemorySettings();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ManagedMemoryCapacitySelector(
            settings: settings,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('1M'), findsOneWidget);
    expect(find.text('2M · Estándar'), findsOneWidget);
    expect(find.text('10M'), findsOneWidget);
    expect(settings.tier, MemoryCapacityTier.standard);
  });

  testWidgets('reports a 10M selection without inventing a custom tier',
      (tester) async {
    final settings = ManagedMemorySettings();
    MemoryCapacityTier? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ManagedMemoryCapacitySelector(
            settings: settings,
            onChanged: (tier) => selected = tier,
          ),
        ),
      ),
    );

    await tester.tap(find.text('10M'));
    await tester.pump();

    expect(selected, MemoryCapacityTier.maximum);
    expect(MemoryCapacityTier.maximum.tokens, 10000000);
  });
}
