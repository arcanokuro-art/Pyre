# Managed Memory Replacement — Release Status

Status: **validated for integration**

Pyre's managed historical memory replacement supports exactly these capacities:

- 1,000,000 tokens — minimum
- 2,000,000 tokens — standard/default
- 10,000,000 tokens — maximum

## Validated invariants

- Historical capacity is independent from the legacy `memoryLimit` checkpoint target.
- Missing or invalid managed-memory settings normalize to the 2M default tier.
- Capacity selection survives persistence and restoration.
- All three tiers flow through the AppStore-ready adapter into the runtime memory policy.
- Runtime prompt budgets remain below the active model context window.
- Invalid negative provider reservations cannot inflate the prompt budget.
- Oversized reservations fail closed instead of overflowing model context.
- Managed checkpoint retention no longer uses the legacy fixed checkpoint-count cap.
- Existing unrelated settings survive managed-memory updates.

## CI release gate

The `Managed memory integration validation` workflow explicitly analyzes the managed-memory services, runs the complete managed-memory test suite, runs the end-to-end lifecycle test, runs the release-readiness gate, and verifies the replacement invariants.

Validated branch: `pyre-memory-1m-10m`

This document records the integration milestone; it does not claim that 1M/2M/10M tokens are sent to an API request. Those values are managed historical capacity. Runtime retrieval remains constrained by the active provider/model context window.
