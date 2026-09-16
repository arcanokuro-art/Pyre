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
  });
}
