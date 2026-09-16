import 'managed_memory_settings.dart';
import 'memory_capacity.dart';

/// Capacity-aware replacement for Pyre's old fixed 60-checkpoint retention.
///
/// The historical-memory tier is expressed in tokens, while checkpoints are
/// variable-size narrative summaries. Retention therefore works from an
/// estimated token cost per checkpoint and never treats 1M/2M/10M as a prompt
/// size. Prompt construction remains governed separately by ManagedMemoryPolicy.
class ManagedMemoryRetentionPolicy {
  static const int defaultEstimatedTokensPerCheckpoint = 1024;

  final int historicalCapacityTokens;
  final int estimatedTokensPerCheckpoint;

  const ManagedMemoryRetentionPolicy({
    required this.historicalCapacityTokens,
    this.estimatedTokensPerCheckpoint = defaultEstimatedTokensPerCheckpoint,
  });

  factory ManagedMemoryRetentionPolicy.forSettings(
    ManagedMemorySettings settings, {
    int estimatedTokensPerCheckpoint = defaultEstimatedTokensPerCheckpoint,
  }) {
    return ManagedMemoryRetentionPolicy(
      historicalCapacityTokens: settings.capacityTokens,
      estimatedTokensPerCheckpoint: estimatedTokensPerCheckpoint,
    );
  }

  factory ManagedMemoryRetentionPolicy.forTier(
    MemoryCapacityTier tier, {
    int estimatedTokensPerCheckpoint = defaultEstimatedTokensPerCheckpoint,
  }) {
    return ManagedMemoryRetentionPolicy(
      historicalCapacityTokens: tier.tokens,
      estimatedTokensPerCheckpoint: estimatedTokensPerCheckpoint,
    );
  }

  int get maxRetainedCheckpoints {
    if (estimatedTokensPerCheckpoint <= 0) return 0;
    return historicalCapacityTokens ~/ estimatedTokensPerCheckpoint;
  }

  /// Returns how many oldest entries should be removed after an append.
  int overflowCount(int checkpointCount) {
    if (checkpointCount <= 0) return 0;
    final max = maxRetainedCheckpoints;
    if (max <= 0) return checkpointCount;
    return checkpointCount > max ? checkpointCount - max : 0;
  }
}
