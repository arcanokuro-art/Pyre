import 'package:flutter_test/flutter_test.dart';
import 'package:pyre/services/managed_memory_store_bridge.dart';
import 'package:pyre/services/memory_capacity.dart';

void main() {
  group('ManagedMemoryStoreBridge', () {
    test('legacy settings load as 2M without touching checkpoint settings', () {
      final source = <String, dynamic>{
        'autoEvery': 10,
        'memoryLimit': 1000,
        'newChatsEnabled': true,
      };
      final bridge = ManagedMemoryStoreBridge.fromSettingsJson(source);
      final merged = bridge.mergeIntoSettingsJson(source);

      expect(bridge.capacityTokens, 2000000);
      expect(merged['managedMemoryTokens'], 2000000);
      expect(merged['memoryLimit'], 1000);
      expect(merged['autoEvery'], 10);
      expect(merged['newChatsEnabled'], isTrue);
    });

    test('10M selection merges without deleting unrelated settings', () {
      final source = <String, dynamic>{
        'theme': 'dark',
        'memoryLimit': 750,
        'customSetting': 'keep-me',
      };
      final bridge = ManagedMemoryStoreBridge.fromSettingsJson(source);
      bridge.setTier(MemoryCapacityTier.maximum);
      final merged = bridge.mergeIntoSettingsJson(source);

      expect(merged['managedMemoryTokens'], 10000000);
      expect(merged['memoryLimit'], 750);
      expect(merged['theme'], 'dark');
      expect(merged['customSetting'], 'keep-me');
    });

    test('imported unsupported capacity normalizes before the next save', () {
      final source = <String, dynamic>{'managedMemoryTokens': 7000000};
      final bridge = ManagedMemoryStoreBridge.fromSettingsJson(source);
      final merged = bridge.mergeIntoSettingsJson(source);

      expect(bridge.tier, MemoryCapacityTier.maximum);
      expect(merged['managedMemoryTokens'], 10000000);
    });

    test('runtime policy follows the persisted tier and model context window', () {
      final bridge = ManagedMemoryStoreBridge.fromSettingsJson(
        const <String, dynamic>{'managedMemoryTokens': 10000000},
      );

      final policy = bridge.policyForContext(128000);

      expect(policy.historicalCapacityTokens, 10000000);
      expect(policy.contextWindowTokens, 128000);
      expect(policy.promptBudgetTokens, 109312);
      expect(policy.recallBudgetTokens, 65587);
      expect(policy.recentConversationBudgetTokens, 43725);
      expect(policy.canUseManagedMemory, isTrue);
    });

    test('changing tier immediately changes the runtime policy source', () {
      final bridge = ManagedMemoryStoreBridge();
      expect(bridge.policyForContext(4000000).historicalCapacityTokens, 2000000);

      bridge.setTier(MemoryCapacityTier.minimum);
      expect(bridge.policyForContext(4000000).historicalCapacityTokens, 1000000);

      bridge.setTier(MemoryCapacityTier.maximum);
      expect(bridge.policyForContext(4000000).historicalCapacityTokens, 10000000);
    });

    test('atomic tier update returns persistence-ready settings', () {
      final source = <String, dynamic>{
        'theme': 'dark',
        'memoryLimit': 1000,
        'managedMemoryTokens': 2000000,
      };
      final bridge = ManagedMemoryStoreBridge.fromSettingsJson(source);

      final merged = bridge.setTierAndMergeIntoSettingsJson(
        MemoryCapacityTier.maximum,
        source,
      );

      expect(bridge.tier, MemoryCapacityTier.maximum);
      expect(bridge.capacityTokens, 10000000);
      expect(merged['managedMemoryTokens'], 10000000);
      expect(merged['memoryLimit'], 1000);
      expect(merged['theme'], 'dark');
      expect(source['managedMemoryTokens'], 2000000);
    });
  });
}
