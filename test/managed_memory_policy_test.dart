import 'package:flutter_test/flutter_test.dart';
import 'package:pyre/services/managed_memory_policy.dart';
import 'package:pyre/services/managed_memory_settings.dart';
import 'package:pyre/services/memory_capacity.dart';

void main() {
  group('ManagedMemoryPolicy', () {
    test('2M historical memory does not become a 2M API prompt', () {
      final policy = ManagedMemoryPolicy.forTier(
        tier: MemoryCapacityTier.standard,
        contextWindowTokens: 128000,
      );

      expect(policy.historicalCapacityTokens, 2000000);
      expect(policy.promptBudgetTokens, lessThan(128000));
      expect(policy.recallBudgetTokens, lessThan(policy.promptBudgetTokens));
    });

    test('runtime policy follows the persisted user tier', () {
      final settings = ManagedMemorySettings(capacityTokens: 10000000);
      final policy = ManagedMemoryPolicy.forSettings(
        settings: settings,
        contextWindowTokens: 128000,
      );

      expect(policy.historicalCapacityTokens, 10000000);
      expect(policy.promptBudgetTokens, lessThan(128000));

      settings.setTier(MemoryCapacityTier.minimum);
      final reduced = ManagedMemoryPolicy.forSettings(
        settings: settings,
        contextWindowTokens: 128000,
      );
      expect(reduced.historicalCapacityTokens, 1000000);
    });

    test('10M tier still respects a small model context window', () {
      final policy = ManagedMemoryPolicy.forTier(
        tier: MemoryCapacityTier.maximum,
        contextWindowTokens: 32768,
      );

      expect(policy.historicalCapacityTokens, 10000000);
      expect(policy.promptBudgetTokens, lessThan(32768));
      expect(policy.canUseManagedMemory, isTrue);
    });

    test('reserves recent-conversation space alongside recalled memory', () {
      final policy = ManagedMemoryPolicy.forTier(
        tier: MemoryCapacityTier.minimum,
        contextWindowTokens: 128000,
      );

      expect(
        policy.recallBudgetTokens + policy.recentConversationBudgetTokens,
        policy.promptBudgetTokens,
      );
      expect(policy.recentConversationBudgetTokens, greaterThan(0));
    });

    test('fails closed when context metadata is unusable', () {
      final policy = ManagedMemoryPolicy.forTier(
        tier: MemoryCapacityTier.standard,
        contextWindowTokens: 0,
      );

      expect(policy.promptBudgetTokens, 0);
      expect(policy.canUseManagedMemory, isFalse);
    });

    test('negative provider reservations cannot inflate prompt budget', () {
      final normal = ManagedMemoryPolicy.forTier(
        tier: MemoryCapacityTier.standard,
        contextWindowTokens: 128000,
        reservedOutputTokens: 0,
        reservedCorePromptTokens: 0,
      );
      final malformed = ManagedMemoryPolicy.forTier(
        tier: MemoryCapacityTier.standard,
        contextWindowTokens: 128000,
        reservedOutputTokens: -50000,
        reservedCorePromptTokens: -50000,
      );

      expect(malformed.promptBudgetTokens, normal.promptBudgetTokens);
      expect(malformed.promptBudgetTokens, lessThan(128000));
    });

    test('oversized reservations disable managed-memory prompt injection', () {
      final policy = ManagedMemoryPolicy.forTier(
        tier: MemoryCapacityTier.maximum,
        contextWindowTokens: 8192,
        reservedOutputTokens: 8192,
        reservedCorePromptTokens: 8192,
      );

      expect(policy.promptBudgetTokens, 0);
      expect(policy.recallBudgetTokens, 0);
      expect(policy.recentConversationBudgetTokens, 0);
      expect(policy.canUseManagedMemory, isFalse);
    });
  });
}
