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

/// Backward-compatible migration seam for memory.dart. Existing checkpoint
/// callers can move off the legacy fixed 60-item cap without first depending
/// on UI/AppStore state. Until persisted settings are wired into that flow,
/// the unified memory system uses its required 2M standard tier by default.
void applyDefaultManagedCheckpoint(Chat chat, MemoryCheckpoint checkpoint) {
  applyManagedCheckpoint(
    chat,
    checkpoint,
    settings: ManagedMemorySettings(),
  );
}
