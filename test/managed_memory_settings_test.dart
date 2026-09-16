import 'package:flutter_test/flutter_test.dart';
import 'package:pyre/services/managed_memory_settings.dart';
import 'package:pyre/services/memory_capacity.dart';

void main() {
  group('ManagedMemorySettings', () {
    test('defaults to the 2M standard tier', () {
      final settings = ManagedMemorySettings();
      expect(settings.capacityTokens, 2000000);
      expect(settings.tier, MemoryCapacityTier.standard);
    });

    test('only exposes exact 1M 2M and 10M tiers', () {
      final settings = ManagedMemorySettings(capacityTokens: 1500000);
      expect(settings.capacityTokens, 1000000);

      settings.setTier(MemoryCapacityTier.standard);
      expect(settings.capacityTokens, 2000000);

      settings.setTier(MemoryCapacityTier.maximum);
      expect(settings.capacityTokens, 10000000);
    });

    test('round-trips persisted capacity', () {
      final settings = ManagedMemorySettings(capacityTokens: 10000000);
      final restored = ManagedMemorySettings.fromJson(settings.toJson());
      expect(restored.capacityTokens, 10000000);
      expect(restored.tier, MemoryCapacityTier.maximum);
    });

    test('legacy data with no capacity migrates to 2M', () {
      final restored = ManagedMemorySettings.fromJson(<String, dynamic>{});
      expect(restored.capacityTokens, 2000000);
    });
  });
}
