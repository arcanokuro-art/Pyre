import '../models/models.dart';
import 'managed_memory_retention.dart';
import 'managed_memory_settings.dart';

/// Applies Pyre's managed historical-memory capacity to the existing
/// checkpoint chain while preserving append order and the newest history.
///
/// This helper is the migration seam for replacing memory.dart's legacy fixed
/// 60-checkpoint cap. It intentionally operates on the existing
/// MemoryCheckpoint objects so branch hashes, content hashes and retry/delete
/// behavior remain untouched.
void pruneCheckpointsForManagedMemory(
  Chat chat, {
  required ManagedMemorySettings settings,
  int estimatedTokensPerCheckpoint =
      ManagedMemoryRetentionPolicy.defaultEstimatedTokensPerCheckpoint,
}) {
  final policy = ManagedMemoryRetentionPolicy.forSettings(
    settings,
    estimatedTokensPerCheckpoint: estimatedTokensPerCheckpoint,
  );
  final overflow = policy.overflowCount(chat.memoryCheckpoints.length);
  if (overflow <= 0) return;
  chat.memoryCheckpoints.removeRange(0, overflow);
}

/// Applies managed retention to a branch-valid checkpoint view and returns the
/// checkpoints that remain eligible for prompt recall. The source chat keeps
/// its existing checkpoint objects and hashes; only capacity pruning is
/// performed after validity has already been decided by Pyre's branch logic.
List<MemoryCheckpoint> retainValidCheckpointsForManagedMemory(
  Chat chat,
  Iterable<MemoryCheckpoint> validCheckpoints, {
  required ManagedMemorySettings settings,
  int estimatedTokensPerCheckpoint =
      ManagedMemoryRetentionPolicy.defaultEstimatedTokensPerCheckpoint,
}) {
  final validIds = validCheckpoints.map((checkpoint) => checkpoint.id).toSet();
  pruneCheckpointsForManagedMemory(
    chat,
    settings: settings,
    estimatedTokensPerCheckpoint: estimatedTokensPerCheckpoint,
  );
  return chat.memoryCheckpoints
      .where((checkpoint) => validIds.contains(checkpoint.id))
      .toList(growable: false);
}

/// Appends a checkpoint and immediately enforces the selected managed-memory
/// tier. Kept separate from legacy applyCheckpoint until its callers are
/// migrated, which lets us replace the old behavior incrementally and safely.
void applyManagedCheckpoint(
  Chat chat,
  MemoryCheckpoint checkpoint, {
  required ManagedMemorySettings settings,
  int estimatedTokensPerCheckpoint =
      ManagedMemoryRetentionPolicy.defaultEstimatedTokensPerCheckpoint,
}) {
  chat.memoryCheckpoints.add(checkpoint);
  pruneCheckpointsForManagedMemory(
    chat,
    settings: settings,
    estimatedTokensPerCheckpoint: estimatedTokensPerCheckpoint,
  );
}
