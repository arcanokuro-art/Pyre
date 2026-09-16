import 'package:flutter_test/flutter_test.dart';
import 'package:pyre/services/managed_memory_app_store_adapter.dart';
import 'package:pyre/services/memory_capacity.dart';

void main() {
  group('ManagedMemoryAppStoreAdapter', () {
    test('legacy AppStore settings start on the 2M standard tier', () {
      final adapter = ManagedMemoryAppStoreAdapter.fromSettingsJson(
        const <String, dynamic>{
          'memoryLimit': 1000,
          'theme': 'dark',
        },
      );

      expect(adapter.tier, MemoryCapacityTier.standard);
      expect(adapter.capacityTokens, 2000000);
    });

    test('tier selection returns persistence-ready settings without mutation', () {
      final source = <String, dynamic>{
        'memoryLimit': 1000,
        'theme': 'dark',
      };
      final adapter = ManagedMemoryAppStoreAdapter.fromSettingsJson(source);

      final saved = adapter.selectTier(MemoryCapacityTier.maximum, source);

      expect(adapter.tier, MemoryCapacityTier.maximum);
      expect(saved['managedMemoryTokens'], 10000000);
      expect(saved['memoryLimit'], 1000);
      expect(saved['theme'], 'dark');
      expect(source.containsKey('managedMemoryTokens'), isFalse);
    });

    test('reload follows imported memory tier', () {
      final adapter = ManagedMemoryAppStoreAdapter.fromSettingsJson(
        const <String, dynamic>{'managedMemoryTokens': 1000000},
      );
      expect(adapter.tier, MemoryCapacityTier.minimum);

      adapter.reload(
        const <String, dynamic>{'managedMemoryTokens': 10000000},
      );

      expect(adapter.tier, MemoryCapacityTier.maximum);
      expect(adapter.capacityTokens, 10000000);
    });

    test('runtime policy uses the same tier exposed to AppStore', () {
      final adapter = ManagedMemoryAppStoreAdapter.fromSettingsJson(
        const <String, dynamic>{'managedMemoryTokens': 2000000},
      );

      final policy = adapter.policyForContext(128000);

      expect(adapter.tier, MemoryCapacityTier.standard);
      expect(policy.historicalCapacityTokens, 2000000);
      expect(policy.contextWindowTokens, 128000);
      expect(policy.promptBudgetTokens, 109312);
    });
  });
}
