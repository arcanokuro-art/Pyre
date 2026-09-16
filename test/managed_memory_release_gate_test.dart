import 'package:flutter_test/flutter_test.dart';
import 'package:pyre/services/managed_memory_app_store_adapter.dart';
import 'package:pyre/services/memory_capacity.dart';

void main() {
  test('release gate keeps one persisted source of truth for every tier', () {
    const expected = <MemoryCapacityTier, int>{
      MemoryCapacityTier.minimum: 1000000,
      MemoryCapacityTier.standard: 2000000,
      MemoryCapacityTier.maximum: 10000000,
    };

    for (final entry in expected.entries) {
      final source = <String, dynamic>{
        'memoryLimit': 1000,
        'managedMemoryTokens': 2000000,
        'theme': 'dark',
      };
      final adapter = ManagedMemoryAppStoreAdapter.fromSettingsJson(source);
      Map<String, dynamic>? persisted;

      adapter.selectTierAndPersist(
        entry.key,
        source,
        (json) => persisted = json,
      );

      final restored =
          ManagedMemoryAppStoreAdapter.fromSettingsJson(persisted!);
      final runtime = restored.policyForContext(128000);

      expect(adapter.capacityTokens, entry.value);
      expect(persisted!['managedMemoryTokens'], entry.value);
      expect(restored.capacityTokens, entry.value);
      expect(runtime.historicalCapacityTokens, entry.value);
      expect(runtime.promptBudgetTokens, lessThan(128000));
      expect(persisted!['memoryLimit'], 1000);
      expect(persisted!['theme'], 'dark');
    }
  });
}
