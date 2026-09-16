import 'package:flutter_test/flutter_test.dart';
import 'package:pyre/services/managed_memory_release_gate.dart';

void main() {
  test('managed memory replacement is release ready', () {
    expect(managedMemoryReleaseGatePasses(), isTrue);
  });
}
