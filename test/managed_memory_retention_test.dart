import 'package:flutter_test/flutter_test.dart';
import 'package:pyre/services/managed_memory_retention.dart';
import 'package:pyre/services/managed_memory_settings.dart';
import 'package:pyre/services/memory_capacity.dart';

void main() {
  group('ManagedMemoryRetentionPolicy', () {
    test('retention budget grows with the selected historical-memory tier', () {
      final minimum = ManagedMemoryRetentionPolicy.forTier(
        MemoryCapacityTier.minimum,
      );
      final standard = ManagedMemoryRetentionPolicy.forTier(
        MemoryCapacityTier.standard,
      );
      final maximum = ManagedMemoryRetentionPolicy.forTier(
        MemoryCapacityTier.maximum,
      );

      expect(minimum.approximateCharacterCapacity, 4000000);
      expect(standard.approximateCharacterCapacity, 8000000);
      expect(maximum.approximateCharacterCapacity, 40000000);
    });

    test('uses the persisted managed-memory setting', () {
      final settings = ManagedMemorySettings(capacityTokens: 10000000);
      final retention = ManagedMemoryRetentionPolicy.forSettings(settings);
      expect(retention.historicalCapacityTokens, 10000000);
      expect(retention.approximateCharacterCapacity, 40000000);
    });

    test('prunes oldest summaries by actual size instead of fixed count', () {
      const retention = ManagedMemoryRetentionPolicy(
        historicalCapacityTokens: 10,
      );

      // 10 historical tokens => ~40 retained characters. The newest 20-char
      // checkpoint plus its 15-char predecessor fit; the next 10-char older
      // checkpoint would overflow, so only the two newest survive.
      expect(retention.firstRetainedIndex([10, 10, 15, 20]), 2);
      expect(retention.overflowCountForSummaryLengths([10, 10, 15, 20]), 2);
    });

    test('keeps every checkpoint when actual summaries fit the tier', () {
      const retention = ManagedMemoryRetentionPolicy(
        historicalCapacityTokens: 10,
      );
      expect(retention.firstRetainedIndex([5, 10, 10, 15]), 0);
    });

    test('always keeps newest checkpoint even when it exceeds capacity', () {
      const retention = ManagedMemoryRetentionPolicy(
        historicalCapacityTokens: 10,
      );
      expect(retention.firstRetainedIndex([5, 100]), 1);
    });
  });
}
