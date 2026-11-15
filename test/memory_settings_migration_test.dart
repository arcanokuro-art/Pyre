import 'package:flutter_test/flutter_test.dart';
import 'package:pyre/models/models.dart';

void main() {
  test('legacy settings migrate to the standard managed capacity', () {
    final settings = MemorySettings.fromJson({
      'autoEvery': 20,
      'memoryLimit': 300,
      'newChatsEnabled': false,
      'summaryPrompt': 'Previous format',
    });

    expect(settings.toJson(), {'managedMemoryTokens': 2000000});
  });

  test(
    'an explicit managed capacity survives legacy settings and round trips',
    () {
      for (final capacity in [1000000, 2000000, 10000000]) {
        final settings = MemorySettings.fromJson({
          'autoEvery': 12,
          'managedMemoryTokens': capacity,
        });

        expect(
          MemorySettings.fromJson(settings.toJson()).managedMemoryTokens,
          capacity,
        );
      }
    },
  );
}
