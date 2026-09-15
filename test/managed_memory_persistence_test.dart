import 'package:flutter_test/flutter_test.dart';
import 'package:pyre/services/managed_memory_persistence.dart';

void main() {
  group('managed memory persistence', () {
    test('legacy settings without capacity migrate to 2M', () {
      expect(readManagedMemoryTokens(<String, dynamic>{}), 2000000);
    });

    test('persisted supported tiers round-trip exactly', () {
      for (final tokens in <int>[1000000, 2000000, 10000000]) {
        final json = <String, dynamic>{};
        writeManagedMemoryTokens(json, tokens);
        expect(json[kManagedMemoryTokensKey], tokens);
        expect(readManagedMemoryTokens(json), tokens);
      }
    });

    test('invalid imported values normalize to supported tiers', () {
      expect(readManagedMemoryTokens({'managedMemoryTokens': 1500000}), 1000000);
      expect(readManagedMemoryTokens({'managedMemoryTokens': 1800000}), 2000000);
      expect(readManagedMemoryTokens({'managedMemoryTokens': 7000000}), 10000000);
      expect(readManagedMemoryTokens({'managedMemoryTokens': 'bad'}), 2000000);
    });

    test('writes never persist a hidden fourth capacity tier', () {
      final json = <String, dynamic>{};
      writeManagedMemoryTokens(json, 6000000);
      expect(json[kManagedMemoryTokensKey], 2000000);
    });
  });
}
