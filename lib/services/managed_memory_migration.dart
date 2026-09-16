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
