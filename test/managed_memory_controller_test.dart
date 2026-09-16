import 'package:flutter_test/flutter_test.dart';
import 'package:pyre/services/managed_memory_controller.dart';
import 'package:pyre/services/memory_capacity.dart';

void main() {
  group('ManagedMemoryController', () {
    test('starts at the 2M standard tier', () {
      final controller = ManagedMemoryController();
      expect(controller.tier, MemoryCapacityTier.standard);
      expect(controller.capacityTokens, 2000000);
    });

    test('changes only between the supported tiers', () {
      final controller = ManagedMemoryController();
      controller.setTier(MemoryCapacityTier.minimum);
      expect(controller.capacityTokens, 1000000);
      controller.setTier(MemoryCapacityTier.maximum);
      expect(controller.capacityTokens, 10000000);
    });

    test('restores persisted tier and builds a context-safe policy', () {
      final controller = ManagedMemoryController.fromJson(
        {'managedMemoryTokens': 10000000},
      );
      final policy = controller.policyForContext(128000);

      expect(controller.capacityTokens, 10000000);
      expect(policy.historicalCapacityTokens, 10000000);
      expect(policy.promptBudgetTokens, lessThan(128000));
    });

    test('legacy or missing state migrates to 2M', () {
      final controller = ManagedMemoryController.fromJson(<String, dynamic>{});
      expect(controller.capacityTokens, 2000000);
      expect(controller.toJson()['managedMemoryTokens'], 2000000);
    });
  });
}
