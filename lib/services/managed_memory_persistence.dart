import 'memory_capacity.dart';

/// Persistence key for Pyre's managed historical-memory capacity.
///
/// This is intentionally separate from MemorySettings.memoryLimit, which is
/// the checkpoint-summary word target in legacy Pyre and is not a historical
/// token capacity.
const String kManagedMemoryTokensKey = 'managedMemoryTokens';

/// Reads the managed historical-memory capacity from a settings JSON map.
/// Missing/legacy data migrates to Pyre's 2M standard automatically.
int readManagedMemoryTokens(Map<String, dynamic> json) {
  final raw = json[kManagedMemoryTokensKey];
  return normalizeMemoryCapacityTokens(raw is num ? raw.toInt() : null);
}

/// Writes the selected managed-memory tier to a settings JSON map.
/// Only the supported 1M / 2M / 10M values can reach persistence.
void writeManagedMemoryTokens(Map<String, dynamic> json, int tokens) {
  json[kManagedMemoryTokensKey] = normalizeMemoryCapacityTokens(tokens);
}
