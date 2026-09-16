import 'managed_memory_policy.dart';
import 'managed_memory_settings.dart';
import 'memory_capacity.dart';

/// Owns the replacement managed-memory selection and exposes the context-safe
/// runtime policy derived from it.
///
/// This keeps UI code from manipulating raw token values and provides a single
/// place to load, change and serialize the supported 1M / 2M / 10M tiers.
class ManagedMemoryController {
  ManagedMemorySettings _settings;

  ManagedMemoryController({ManagedMemorySettings? settings})
      : _settings = settings?.copy() ?? ManagedMemorySettings();

  factory ManagedMemoryController.fromJson(Map<String, dynamic> json) {
    return ManagedMemoryController(
      settings: ManagedMemorySettings.fromJson(json),
    );
  }

  ManagedMemorySettings get settings => _settings.copy();

  MemoryCapacityTier get tier => _settings.tier;

  int get capacityTokens => _settings.capacityTokens;

  void setTier(MemoryCapacityTier tier) {
    _settings.setTier(tier);
  }

  ManagedMemoryPolicy policyForContext(int contextWindowTokens) {
    return ManagedMemoryPolicy.forSettings(
      settings: _settings,
      contextWindowTokens: contextWindowTokens,
    );
  }

  Map<String, dynamic> toJson() => _settings.toJson();
}
