import 'package:flutter_test/flutter_test.dart';
import 'package:pyre/services/memory_capacity.dart';

void main() {
  group('managed memory capacity', () {
    test('uses the requested 1M / 2M / 10M tiers', () {
      expect(MemoryCapacityTier.minimum.tokens, 1000000);
      expect(MemoryCapacityTier.standard.tokens, 2000000);
      expect(MemoryCapacityTier.maximum.tokens, 10000000);
    });

    test('defaults missing or invalid values to 2M', () {
      expect(normalizeMemoryCapacityTokens(null), 2000000);
      expect(normalizeMemoryCapacityTokens(0), 2000000);
      expect(normalizeMemoryCapacityTokens(-1), 2000000);
    });

    test('clamps persisted values to the supported range', () {
      expect(normalizeMemoryCapacityTokens(500000), 1000000);
      expect(normalizeMemoryCapacityTokens(1500000), 1500000);
      expect(normalizeMemoryCapacityTokens(12000000), 10000000);
    });

    test('maps values to the nearest user-facing tier', () {
      expect(nearestMemoryCapacityTier(1000000), MemoryCapacityTier.minimum);
      expect(nearestMemoryCapacityTier(2000000), MemoryCapacityTier.standard);
      expect(nearestMemoryCapacityTier(10000000), MemoryCapacityTier.maximum);
    });
  });
}
