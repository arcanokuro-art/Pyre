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

/// Keeps persisted/imported values inside Pyre's supported managed-memory
/// range. A missing or invalid value resolves to the 2M standard.
int normalizeMemoryCapacityTokens(int? value) {
  if (value == null || value <= 0) return kMemoryCapacityDefaultTokens;
  if (value < kMemoryCapacityMinimumTokens) return kMemoryCapacityMinimumTokens;
  if (value > kMemoryCapacityMaximumTokens) return kMemoryCapacityMaximumTokens;
  return value;
}

MemoryCapacityTier nearestMemoryCapacityTier(int? value) {
  final normalized = normalizeMemoryCapacityTokens(value);
  final dMin = (normalized - kMemoryCapacityMinimumTokens).abs();
  final dStd = (normalized - kMemoryCapacityDefaultTokens).abs();
  final dMax = (normalized - kMemoryCapacityMaximumTokens).abs();

  if (dMin <= dStd && dMin <= dMax) return MemoryCapacityTier.minimum;
  if (dStd <= dMax) return MemoryCapacityTier.standard;
  return MemoryCapacityTier.maximum;
}
