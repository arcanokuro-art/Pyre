/// Managed historical-memory capacity for Pyre.
///
/// These values describe how much conversation history Pyre may retain and
/// manage over time. They are deliberately NOT the amount of context sent to
/// the model on every request. Prompt construction must still respect the
/// active provider/model context window.
const int kMemoryCapacityMinimumTokens = 1000000;
const int kMemoryCapacityDefaultTokens = 2000000;
const int kMemoryCapacityMaximumTokens = 10000000;

/// User-facing presets for managed historical memory.
enum MemoryCapacityTier {
  minimum,
  standard,
  maximum,
}

extension MemoryCapacityTierValue on MemoryCapacityTier {
  int get tokens {
    switch (this) {
      case MemoryCapacityTier.minimum:
        return kMemoryCapacityMinimumTokens;
      case MemoryCapacityTier.standard:
        return kMemoryCapacityDefaultTokens;
      case MemoryCapacityTier.maximum:
        return kMemoryCapacityMaximumTokens;
    }
  }
}

/// Converts persisted/imported values to one of Pyre's three supported
/// managed-memory tiers. A missing or invalid value resolves to the 2M
/// standard. This deliberately prevents hidden/custom capacities from
/// creating a fourth memory mode outside the 1M / 2M / 10M design.
int normalizeMemoryCapacityTokens(int? value) {
  if (value == null || value <= 0) return kMemoryCapacityDefaultTokens;
  return nearestMemoryCapacityTier(value).tokens;
}

/// Returns the supported tier nearest to [value]. Ties prefer the smaller
/// tier so an imported value never unexpectedly increases memory usage.
MemoryCapacityTier nearestMemoryCapacityTier(int? value) {
  if (value == null || value <= 0) return MemoryCapacityTier.standard;

  final dMin = (value - kMemoryCapacityMinimumTokens).abs();
  final dStd = (value - kMemoryCapacityDefaultTokens).abs();
  final dMax = (value - kMemoryCapacityMaximumTokens).abs();

  if (dMin <= dStd && dMin <= dMax) return MemoryCapacityTier.minimum;
  if (dStd <= dMax) return MemoryCapacityTier.standard;
  return MemoryCapacityTier.maximum;
}
