import 'managed_memory_persistence.dart';
import 'memory_capacity.dart';

/// Standalone settings state for Pyre's replacement managed-memory system.
///
/// Keeping this state separate from the legacy checkpoint word limit avoids
/// conflating historical capacity (1M/2M/10M) with summary length. It can be
/// embedded into the app settings model while the old checkpoint controls are
/// removed from the user-facing configuration.
class ManagedMemorySettings {
  int capacityTokens;

  ManagedMemorySettings({
    int capacityTokens = kMemoryCapacityDefaultTokens,
  }) : capacityTokens = normalizeMemoryCapacityTokens(capacityTokens);

  MemoryCapacityTier get tier => nearestMemoryCapacityTier(capacityTokens);

  void setTier(MemoryCapacityTier value) {
    capacityTokens = value.tokens;
  }

  factory ManagedMemorySettings.fromJson(Map<String, dynamic> json) {
    return ManagedMemorySettings(
      capacityTokens: readManagedMemoryTokens(json),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    writeManagedMemoryTokens(json, capacityTokens);
    return json;
  }

  ManagedMemorySettings copy() =>
      ManagedMemorySettings(capacityTokens: capacityTokens);
}
