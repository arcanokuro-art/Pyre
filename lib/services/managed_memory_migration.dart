import '../models/models.dart';
import 'managed_memory_checkpoint_retention.dart';
import 'managed_memory_settings.dart';

/// Single migration adapter for legacy memory.dart call sites.
///
/// Existing callers can move away from Pyre's fixed checkpoint-count cap
/// without knowing how the managed 1M / 2M / 10M retention policy works.
/// Passing no settings deliberately selects the 2M standard tier.
void applyCheckpointWithManagedRetention(
  Chat chat,
  MemoryCheckpoint checkpoint, {
  ManagedMemorySettings? settings,
}) {
  applyConfiguredManagedCheckpoint(
    chat,
    checkpoint,
    settings: settings ?? ManagedMemorySettings(),
  );
}

/// Settings-aware entry point for callers that already persist the replacement
/// managed-memory configuration as JSON. Missing or invalid capacity values
/// normalize through [ManagedMemorySettings.fromJson], so legacy installs
/// safely migrate to the 2M standard tier while explicit 1M/10M selections
/// are preserved.
void applyCheckpointWithPersistedManagedRetention(
  Chat chat,
  MemoryCheckpoint checkpoint,
  Map<String, dynamic> settingsJson,
) {
  applyCheckpointWithManagedRetention(
    chat,
    checkpoint,
    settings: ManagedMemorySettings.fromJson(settingsJson),
  );
}
