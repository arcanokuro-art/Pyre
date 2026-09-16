import '../models/models.dart';
import 'managed_memory_retention.dart';
import 'managed_memory_settings.dart';

/// Applies Pyre's managed historical-memory capacity to the existing
/// checkpoint chain while preserving append order and the newest history.
///
/// Retention is based on the actual stored summary sizes. Branch/content
/// fingerprints remain untouched because the existing MemoryCheckpoint
/// objects are retained verbatim; only oldest overflow entries are removed.
void pruneCheckpointsForManagedMemory(
  Chat chat, {
  required ManagedMemorySettings settings,
}) {
  final policy = ManagedMemoryRetentionPolicy.forSettings(settings);
  final firstRetained = policy.firstRetainedIndex([
    for (final checkpoint in chat.memoryCheckpoints) checkpoint.summary.length,
  ]);
  if (firstRetained <= 0) return;
  chat.memoryCheckpoints.removeRange(0, firstRetained);
}

/// Applies managed retention to a branch-valid checkpoint view and returns the
/// checkpoints that remain eligible for prompt recall. Capacity pruning never
/// turns an invalid branch checkpoint into a valid one.
List<MemoryCheckpoint> retainValidCheckpointsForManagedMemory(
  Chat chat,
  Iterable<MemoryCheckpoint> validCheckpoints, {
  required ManagedMemorySettings settings,
}) {
  final validIds = validCheckpoints.map((checkpoint) => checkpoint.id).toSet();
  pruneCheckpointsForManagedMemory(chat, settings: settings);
  return chat.memoryCheckpoints
      .where((checkpoint) => validIds.contains(checkpoint.id))
      .toList(growable: false);
}

/// Appends a checkpoint and immediately enforces the selected managed-memory
/// tier using the actual size of the stored summaries.
void applyManagedCheckpoint(
  Chat chat,
  MemoryCheckpoint checkpoint, {
  required ManagedMemorySettings settings,
}) {
  chat.memoryCheckpoints.add(checkpoint);
  pruneCheckpointsForManagedMemory(chat, settings: settings);
}

/// Migration seam used while memory.dart moves away from its legacy fixed
/// checkpoint-count cap. Existing callers remain source-compatible, while
/// callers that already know the persisted 1M/2M/10M selection can pass it
/// immediately. A missing setting intentionally resolves to the required 2M
/// standard tier.
void applyConfiguredManagedCheckpoint(
  Chat chat,
  MemoryCheckpoint checkpoint, {
  ManagedMemorySettings? settings,
}) {
  applyManagedCheckpoint(
    chat,
    checkpoint,
    settings: settings ?? ManagedMemorySettings(),
  );
}

/// Backward-compatible default wrapper retained for the first migration step.
/// It delegates to the same configurable path so there is only one retention
/// implementation to maintain.
void applyDefaultManagedCheckpoint(Chat chat, MemoryCheckpoint checkpoint) {
  applyConfiguredManagedCheckpoint(chat, checkpoint);
}
