import 'managed_memory_settings.dart';
import 'memory_capacity.dart';

/// Capacity-aware replacement for Pyre's old fixed 60-checkpoint retention.
///
/// The historical-memory tier is expressed in tokens, while checkpoints are
/// variable-size narrative summaries. Retention therefore uses the actual
/// summary lengths instead of assuming every checkpoint costs the same amount.
/// Prompt construction remains governed separately by ManagedMemoryPolicy.
class ManagedMemoryRetentionPolicy {
  /// A deterministic storage estimate. This is not provider tokenization: it
  /// only translates the user's historical token tier into a text-retention
  /// budget. Four characters per token is a conservative common approximation.
  static const int approximateCharactersPerToken = 4;

  final int historicalCapacityTokens;

  const ManagedMemoryRetentionPolicy({
    required this.historicalCapacityTokens,
  });

  factory ManagedMemoryRetentionPolicy.forSettings(
    ManagedMemorySettings settings,
  ) {
    return ManagedMemoryRetentionPolicy(
      historicalCapacityTokens: settings.capacityTokens,
    );
  }

  factory ManagedMemoryRetentionPolicy.forTier(MemoryCapacityTier tier) {
    return ManagedMemoryRetentionPolicy(
      historicalCapacityTokens: tier.tokens,
    );
  }

  int get approximateCharacterCapacity =>
      historicalCapacityTokens * approximateCharactersPerToken;

  /// Returns the first index to retain from an oldest-first checkpoint list.
  /// The newest checkpoint is always retained even if it alone exceeds the
  /// budget, preserving the most recent continuity.
  int firstRetainedIndex(List<int> summaryCharacterLengths) {
    if (summaryCharacterLengths.isEmpty) return 0;

    final budget = approximateCharacterCapacity;
    var used = 0;
    for (var i = summaryCharacterLengths.length - 1; i >= 0; i--) {
      final length = summaryCharacterLengths[i] < 0
          ? 0
          : summaryCharacterLengths[i];
      final isNewest = i == summaryCharacterLengths.length - 1;
      if (!isNewest && used + length > budget) return i + 1;
      used += length;
    }
    return 0;
  }

  /// Convenience helper for callers that only need the number of oldest
  /// checkpoints to prune.
  int overflowCountForSummaryLengths(List<int> summaryCharacterLengths) =>
      firstRetainedIndex(summaryCharacterLengths);
}
