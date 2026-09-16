import 'managed_memory_policy.dart';
import 'managed_memory_settings.dart';
import 'managed_memory_store_bridge.dart';
import 'memory_capacity.dart';

/// Thin state adapter for the final AppStore integration.
///
/// It deliberately operates on Pyre's existing settings JSON so the managed
/// 1M / 2M / 10M capacity can be wired into the large AppStore safely without
/// repurposing the legacy checkpoint `memoryLimit` field.
class ManagedMemoryAppStoreAdapter {
  final ManagedMemoryStoreBridge _bridge;

  ManagedMemoryAppStoreAdapter._(this._bridge);

  factory ManagedMemoryAppStoreAdapter.fromSettingsJson(
    Map<String, dynamic> settingsJson,
  ) {
    return ManagedMemoryAppStoreAdapter._(
      ManagedMemoryStoreBridge.fromSettingsJson(settingsJson),
    );
  }

  MemoryCapacityTier get tier => _bridge.tier;
  int get capacityTokens => _bridge.capacityTokens;
  ManagedMemorySettings get settings => _bridge.settings;

  Map<String, dynamic> selectTier(
    MemoryCapacityTier tier,
    Map<String, dynamic> settingsJson,
  ) {
    return _bridge.setTierAndMergeIntoSettingsJson(tier, settingsJson);
  }

  void reload(Map<String, dynamic> settingsJson) {
    _bridge.replaceFromSettingsJson(settingsJson);
  }

  ManagedMemoryPolicy policyForContext(int contextWindowTokens) {
    return _bridge.policyForContext(contextWindowTokens);
  }
}
