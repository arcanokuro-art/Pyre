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

void main() {
  group('managed checkpoint retention', () {
    test('prunes oldest checkpoints and preserves newest order', () {
      final chat = Chat(name: 'Retention test');
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
      final chat = Chat(name: 'Append test');
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
      final minimumChat = Chat(name: 'Minimum');
      final maximumChat = Chat(name: 'Maximum');
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
  });
}
