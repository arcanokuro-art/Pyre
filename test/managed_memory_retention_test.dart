import 'package:flutter_test/flutter_test.dart';
import 'package:pyre/services/managed_memory_retention.dart';
import 'package:pyre/services/managed_memory_settings.dart';
import 'package:pyre/services/memory_capacity.dart';

void main() {
  group('ManagedMemoryRetentionPolicy', () {
    test('retention grows with the selected historical-memory tier', () {
      final minimum = ManagedMemoryRetentionPolicy.forTier(
        MemoryCapacityTier.minimum,
      );
      final standard = ManagedMemoryRetentionPolicy.forTier(
        MemoryCapacityTier.standard,
      );
      final maximum = ManagedMemoryRetentionPolicy.forTier(
        MemoryCapacityTier.maximum,
      );

      expect(minimum.maxRetainedCheckpoints, 976);
      expect(standard.maxRetainedCheckpoints, 1953);
      expect(maximum.maxRetainedCheckpoints, 9765);
      expect(standard.maxRetainedCheckpoints,
          greaterThan(minimum.maxRetainedCheckpoints));
      expect(maximum.maxRetainedCheckpoints,
          greaterThan(standard.maxRetainedCheckpoints));
    });

    test('uses the persisted managed-memory setting', () {
      final settings = ManagedMemorySettings(capacityTokens: 10000000);
      final retention = ManagedMemoryRetentionPolicy.forSettings(settings);
      expect(retention.historicalCapacityTokens, 10000000);
      expect(retention.maxRetainedCheckpoints, 9765);
    });

    test('reports only oldest overflow that must be pruned', () {
      final retention = ManagedMemoryRetentionPolicy.forTier(
        MemoryCapacityTier.minimum,
        estimatedTokensPerCheckpoint: 100000,
      );

      expect(retention.maxRetainedCheckpoints, 10);
      expect(retention.overflowCount(8), 0);
      expect(retention.overflowCount(10), 0);
      expect(retention.overflowCount(13), 3);
    });

    test('invalid checkpoint estimate fails closed', () {
      const retention = ManagedMemoryRetentionPolicy(
        historicalCapacityTokens: 2000000,
        estimatedTokensPerCheckpoint: 0,
      );
      expect(retention.maxRetainedCheckpoints, 0);
      expect(retention.overflowCount(4), 4);
    });
  });
}
