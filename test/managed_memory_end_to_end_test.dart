import 'package:flutter_test/flutter_test.dart';
import 'package:pyre/services/managed_memory_app_store_adapter.dart';
import 'package:pyre/services/memory_capacity.dart';

void main() {
  test('managed memory survives select save reload and runtime policy', () {
    final legacySettings = <String, dynamic>{
      'memoryLimit': 1000,
      'theme': 'dark',
    };

    final firstSession =
        ManagedMemoryAppStoreAdapter.fromSettingsJson(legacySettings);
    expect(firstSession.tier, MemoryCapacityTier.standard);
    expect(firstSession.capacityTokens, 2000000);

    Map<String, dynamic>? persisted;
    firstSession.selectTierAndPersist(
      MemoryCapacityTier.maximum,
      legacySettings,
      (json) => persisted = json,
    );

    expect(persisted, isNotNull);
    expect(persisted!['managedMemoryTokens'], 10000000);
    expect(persisted!['memoryLimit'], 1000);
    expect(persisted!['theme'], 'dark');

    final restoredSession =
        ManagedMemoryAppStoreAdapter.fromSettingsJson(persisted!);
    expect(restoredSession.tier, MemoryCapacityTier.maximum);
    expect(restoredSession.capacityTokens, 10000000);

    final policy = restoredSession.policyForContext(128000);
    expect(policy.historicalCapacityTokens, 10000000);
    expect(policy.contextWindowTokens, 128000);
    expect(policy.promptBudgetTokens, 109312);
    expect(policy.promptBudgetTokens, lessThan(128000));
    expect(policy.canUseManagedMemory, isTrue);
  });

  test('all supported tiers survive the complete persistence lifecycle', () {
    const cases = <MemoryCapacityTier, int>{
      MemoryCapacityTier.minimum: 1000000,
      MemoryCapacityTier.standard: 2000000,
      MemoryCapacityTier.maximum: 10000000,
    };

    for (final entry in cases.entries) {
      final source = <String, dynamic>{
        'memoryLimit': 1000,
        'managedMemoryTokens': 2000000,
      };
      final session = ManagedMemoryAppStoreAdapter.fromSettingsJson(source);
      Map<String, dynamic>? persisted;

      session.selectTierAndPersist(
        entry.key,
        source,
        (json) => persisted = json,
      );

      final restored =
          ManagedMemoryAppStoreAdapter.fromSettingsJson(persisted!);
      final policy = restored.policyForContext(128000);

      expect(restored.tier, entry.key);
      expect(restored.capacityTokens, entry.value);
      expect(persisted!['managedMemoryTokens'], entry.value);
      expect(persisted!['memoryLimit'], 1000);
      expect(policy.historicalCapacityTokens, entry.value);
      expect(policy.promptBudgetTokens, lessThan(128000));
    }
  });
}
