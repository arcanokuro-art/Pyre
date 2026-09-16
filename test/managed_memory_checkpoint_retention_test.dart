import 'package:flutter_test/flutter_test.dart';
import 'package:pyre/models/models.dart';
import 'package:pyre/services/managed_memory_checkpoint_retention.dart';
import 'package:pyre/services/managed_memory_settings.dart';

MemoryCheckpoint _checkpoint(int index) => MemoryCheckpoint(
      id: 'mc-$index',
      summary: 'checkpoint $index',
      anchorMessageIdx: index,
      pathHash: 'path-$index',
      contentHash: 'content-$index',
    );

Chat _chat(String id) => Chat(id: id, characterIds: const ['character']);

void main() {
  group('managed checkpoint retention', () {
    test('prunes oldest checkpoints and preserves newest order', () {
      final chat = _chat('retention-test');
      chat.memoryCheckpoints.addAll(List.generate(13, _checkpoint));
      final settings = ManagedMemorySettings(capacityTokens: 1000000);

      pruneCheckpointsForManagedMemory(
        chat,
        settings: settings,
        estimatedTokensPerCheckpoint: 100000,
      );

      expect(chat.memoryCheckpoints.length, 10);
      expect(chat.memoryCheckpoints.first.id, 'mc-3');
      expect(chat.memoryCheckpoints.last.id, 'mc-12');
      expect(chat.memoryCheckpoints.last.pathHash, 'path-12');
      expect(chat.memoryCheckpoints.last.contentHash, 'content-12');
    });

    test('append helper enforces selected capacity immediately', () {
      final chat = _chat('append-test');
      chat.memoryCheckpoints.addAll(List.generate(10, _checkpoint));
      final settings = ManagedMemorySettings(capacityTokens: 1000000);

      applyManagedCheckpoint(
        chat,
        _checkpoint(10),
        settings: settings,
        estimatedTokensPerCheckpoint: 100000,
      );

      expect(chat.memoryCheckpoints.length, 10);
      expect(chat.memoryCheckpoints.first.id, 'mc-1');
      expect(chat.memoryCheckpoints.last.id, 'mc-10');
    });

    test('larger tier retains history that the minimum tier would prune', () {
      final minimumChat = _chat('minimum');
      final maximumChat = _chat('maximum');
      minimumChat.memoryCheckpoints.addAll(List.generate(50, _checkpoint));
      maximumChat.memoryCheckpoints.addAll(List.generate(50, _checkpoint));

      pruneCheckpointsForManagedMemory(
        minimumChat,
        settings: ManagedMemorySettings(capacityTokens: 1000000),
        estimatedTokensPerCheckpoint: 100000,
      );
      pruneCheckpointsForManagedMemory(
        maximumChat,
        settings: ManagedMemorySettings(capacityTokens: 10000000),
        estimatedTokensPerCheckpoint: 100000,
      );

      expect(minimumChat.memoryCheckpoints.length, 10);
      expect(maximumChat.memoryCheckpoints.length, 50);
    });

    test('capacity pruning never reintroduces branch-invalid checkpoints', () {
      final chat = _chat('branch-validity');
      chat.memoryCheckpoints.addAll(List.generate(12, _checkpoint));
      final valid = chat.memoryCheckpoints.where((checkpoint) {
        final index = int.parse(checkpoint.id.substring(3));
        return index.isEven;
      }).toList();

      final retained = retainValidCheckpointsForManagedMemory(
        chat,
        valid,
        settings: ManagedMemorySettings(capacityTokens: 1000000),
        estimatedTokensPerCheckpoint: 100000,
      );

      expect(chat.memoryCheckpoints.length, 10);
      expect(chat.memoryCheckpoints.first.id, 'mc-2');
      expect(retained.map((checkpoint) => checkpoint.id),
          ['mc-2', 'mc-4', 'mc-6', 'mc-8', 'mc-10']);
    });
  });
}
