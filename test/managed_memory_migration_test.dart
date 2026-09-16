import 'package:flutter_test/flutter_test.dart';
import 'package:pyre/models/models.dart';
import 'package:pyre/services/managed_memory_migration.dart';
import 'package:pyre/services/managed_memory_settings.dart';

MemoryCheckpoint _checkpoint(int index, {int summaryLength = 1000000}) =>
    MemoryCheckpoint(
      id: 'migration-$index',
      summary: List.filled(summaryLength, 'x').join(),
      anchorMessageIdx: index,
      pathHash: 'path-$index',
      contentHash: 'content-$index',
    );

Chat _chat(String id) => Chat(id: id, characterIds: const ['character']);

void main() {
  group('managed memory migration adapter', () {
    test('defaults legacy callers to the 2M standard tier', () {
      final chat = _chat('default-adapter');
      chat.memoryCheckpoints.addAll(
        List.generate(8, (index) => _checkpoint(index)),
      );

      applyCheckpointWithManagedRetention(chat, _checkpoint(8));

      expect(chat.memoryCheckpoints.length, 8);
      expect(chat.memoryCheckpoints.first.id, 'migration-1');
      expect(chat.memoryCheckpoints.last.id, 'migration-8');
    });

    test('forwards the selected 1M tier', () {
      final chat = _chat('minimum-adapter');
      chat.memoryCheckpoints.addAll(
        List.generate(8, (index) => _checkpoint(index)),
      );

      applyCheckpointWithManagedRetention(
        chat,
        _checkpoint(8),
        settings: ManagedMemorySettings(capacityTokens: 1000000),
      );

      expect(chat.memoryCheckpoints.length, 4);
      expect(chat.memoryCheckpoints.first.id, 'migration-5');
      expect(chat.memoryCheckpoints.last.id, 'migration-8');
    });

    test('forwards the selected 10M tier without premature pruning', () {
      final chat = _chat('maximum-adapter');
      chat.memoryCheckpoints.addAll(
        List.generate(8, (index) => _checkpoint(index)),
      );

      applyCheckpointWithManagedRetention(
        chat,
        _checkpoint(8),
        settings: ManagedMemorySettings(capacityTokens: 10000000),
      );

      expect(chat.memoryCheckpoints.length, 9);
      expect(chat.memoryCheckpoints.first.id, 'migration-0');
      expect(chat.memoryCheckpoints.last.id, 'migration-8');
    });

    test('persisted settings default missing capacity to 2M', () {
      final chat = _chat('persisted-default');
      chat.memoryCheckpoints.addAll(
        List.generate(8, (index) => _checkpoint(index)),
      );

      applyCheckpointWithPersistedManagedRetention(
        chat,
        _checkpoint(8),
        const <String, dynamic>{},
      );

      expect(chat.memoryCheckpoints.length, 8);
      expect(chat.memoryCheckpoints.first.id, 'migration-1');
      expect(chat.memoryCheckpoints.last.id, 'migration-8');
    });

    test('persisted settings preserve explicit 10M selection', () {
      final chat = _chat('persisted-maximum');
      chat.memoryCheckpoints.addAll(
        List.generate(8, (index) => _checkpoint(index)),
      );

      applyCheckpointWithPersistedManagedRetention(
        chat,
        _checkpoint(8),
        const <String, dynamic>{'managedMemoryTokens': 10000000},
      );

      expect(chat.memoryCheckpoints.length, 9);
      expect(chat.memoryCheckpoints.first.id, 'migration-0');
      expect(chat.memoryCheckpoints.last.id, 'migration-8');
    });
  });
}
