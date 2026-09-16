import 'managed_memory_app_store_adapter.dart';
import 'memory_capacity.dart';

/// Lightweight release-readiness probe for Pyre's replacement memory system.
///
/// It validates the three supported capacities through the same persistence
/// and runtime-policy seams used by the application. This is intentionally
/// deterministic so CI can use it as a final integration invariant.
bool managedMemoryReleaseGatePasses() {
  const expected = <MemoryCapacityTier, int>{
    MemoryCapacityTier.minimum: 1000000,
    MemoryCapacityTier.standard: 2000000,
    MemoryCapacityTier.maximum: 10000000,
  };

  for (final entry in expected.entries) {
    final source = <String, dynamic>{
      'memoryLimit': 1000,
      'managedMemoryTokens': 2000000,
      'releaseGateMarker': true,
    };
    final adapter = ManagedMemoryAppStoreAdapter.fromSettingsJson(source);
    Map<String, dynamic>? persisted;

    adapter.selectTierAndPersist(
      entry.key,
      source,
      (json) => persisted = json,
    );

    final saved = persisted;
    if (saved == null || saved['managedMemoryTokens'] != entry.value) {
      return false;
    }
    if (saved['memoryLimit'] != 1000 || saved['releaseGateMarker'] != true) {
      return false;
    }

    final restored = ManagedMemoryAppStoreAdapter.fromSettingsJson(saved);
    final policy = restored.policyForContext(128000);
    if (restored.capacityTokens != entry.value ||
        policy.historicalCapacityTokens != entry.value ||
        policy.promptBudgetTokens >= policy.contextWindowTokens ||
        !policy.canUseManagedMemory) {
      return false;
    }
  }

  return true;
}
