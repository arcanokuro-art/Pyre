import 'memory_capacity.dart';

/// Runtime policy for Pyre's replacement long-term memory system.
///
/// [historicalCapacityTokens] is the amount of history Pyre may manage over
/// time. [promptBudgetTokens] is deliberately much smaller and is calculated
/// from the active model's context window so the historical-memory setting can
/// never force an oversized API request.
class ManagedMemoryPolicy {
  final int historicalCapacityTokens;
  final int contextWindowTokens;
  final int reservedOutputTokens;
  final int reservedCorePromptTokens;

  const ManagedMemoryPolicy({
    required this.historicalCapacityTokens,
    required this.contextWindowTokens,
    this.reservedOutputTokens = 4096,
    this.reservedCorePromptTokens = 8192,
  });

  factory ManagedMemoryPolicy.forTier({
    required MemoryCapacityTier tier,
    required int contextWindowTokens,
    int reservedOutputTokens = 4096,
    int reservedCorePromptTokens = 8192,
  }) {
    return ManagedMemoryPolicy(
      historicalCapacityTokens: tier.tokens,
      contextWindowTokens: contextWindowTokens,
      reservedOutputTokens: reservedOutputTokens,
      reservedCorePromptTokens: reservedCorePromptTokens,
    );
  }

  /// Tokens available for recent chat + retrieved long-term memories.
  ///
  /// A safety margin keeps provider-side tokenisation differences and small
  /// prompt additions from overflowing the advertised model context window.
  int get promptBudgetTokens {
    if (contextWindowTokens <= 0) return 0;
    final safetyMargin = (contextWindowTokens * 0.05).ceil();
    final available = contextWindowTokens -
        reservedOutputTokens -
        reservedCorePromptTokens -
        safetyMargin;
    if (available <= 0) return 0;
    return available > historicalCapacityTokens
        ? historicalCapacityTokens
        : available;
  }

  /// Long-term recall may use at most 60% of the dynamic prompt budget.
  /// The rest remains available for the recent conversation so continuity is
  /// not sacrificed just because a large historical store exists.
  int get recallBudgetTokens => (promptBudgetTokens * 0.60).floor();

  int get recentConversationBudgetTokens =>
      promptBudgetTokens - recallBudgetTokens;

  bool get canUseManagedMemory =>
      historicalCapacityTokens >= kMemoryCapacityMinimumTokens &&
      contextWindowTokens > 0 &&
      promptBudgetTokens > 0;
}
