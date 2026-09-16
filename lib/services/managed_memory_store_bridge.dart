import 'managed_memory_controller.dart';
import 'managed_memory_policy.dart';
import 'managed_memory_settings.dart';
import 'memory_capacity.dart';

/// Small persistence bridge for wiring managed memory into Pyre's settings
/// blob without conflating it with the legacy checkpoint `memoryLimit`.
///
/// AppStore can load this bridge from the same settings JSON it already owns,
/// update the selected tier, then merge the managed-memory key back into that
/// JSON during save/sync. This keeps old backups compatible: missing state
/// automatically resolves to the 2M standard tier.
class ManagedMemoryStoreBridge {
  ManagedMemoryController _controller;

  ManagedMemoryStoreBridge({ManagedMemoryController? controller})
      : _controller = controller ?? ManagedMemoryController();

  factory ManagedMemoryStoreBridge.fromSettingsJson(
    Map<String, dynamic> settingsJson,
  ) {
    return ManagedMemoryStoreBridge(
      controller: ManagedMemoryController.fromJson(settingsJson),
    );
  }

  MemoryCapacityTier get tier => _controller.tier;
  int get capacityTokens => _controller.capacityTokens;

  /// Snapshot intended for AppStore/UI consumers. Returning a copy prevents a
  /// widget from mutating persisted state without going through [setTier].
  ManagedMemorySettings get settings => _controller.settings;

  void setTier(MemoryCapacityTier tier) {
    _controller.setTier(tier);
  }

  /// AppStore-friendly atomic update: select a tier and return the complete
  /// settings blob ready for persistence without dropping unrelated values.
  Map<String, dynamic> setTierAndMergeIntoSettingsJson(
    MemoryCapacityTier tier,
    Map<String, dynamic> source,
  ) {
    setTier(tier);
    return mergeIntoSettingsJson(source);
  }

  /// Replaces the managed-memory state from a freshly loaded settings blob.
  /// AppStore can call this after restore/import without replacing the bridge
  /// instance observed by the rest of the app.
  void replaceFromSettingsJson(Map<String, dynamic> settingsJson) {
    _controller = ManagedMemoryController.fromJson(settingsJson);
  }

  /// Builds the context-safe runtime policy from the same persisted state that
  /// AppStore exposes to the UI. This keeps the selected 1M / 2M / 10M tier
  /// and the model's actual context-window budget on one source of truth.
  ManagedMemoryPolicy policyForContext(int contextWindowTokens) {
    return _controller.policyForContext(contextWindowTokens);
  }

  /// Returns a copy so callers never lose unrelated Pyre settings.
  Map<String, dynamic> mergeIntoSettingsJson(Map<String, dynamic> source) {
    final merged = Map<String, dynamic>.of(source);
    merged.addAll(_controller.toJson());
    return merged;
  }

  ManagedMemoryController get controller =>
      ManagedMemoryController.fromJson(_controller.toJson());
}
