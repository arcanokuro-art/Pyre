import 'package:flutter_test/flutter_test.dart';
import 'package:pyre/models/models.dart';
import 'package:pyre/services/managed_memory_checkpoint_retention.dart';
import 'package:pyre/services/managed_memory_settings.dart';

MemoryCheckpoint _checkpoint(int index, {int summaryLength = 10}) =>
    MemoryCheckpoint(
      id: 'mc-$index',
      summary: List.filled(summaryLength, 'x').join(),
      anchorMessageIdx: index,
      pathHash: 'path-$index',
      contentHash: 'content-$index',
    );

Chat _chat(String id) => Chat(id: id, characterIds: const ['character']);

void main() {
  group('managed checkpoint retention', () {
    test('prunes oldest checkpoints by actual summary size', () {
      final chat = _chat('retention-test');
      chat.memoryCheckpoints.addAll(
        List.generate(6, (index) => _checkpoint(index, summaryLength: 1000000)),
      );

      pruneCheckpointsForManagedMemory(
        chat,
        settings: ManagedMemorySettings(capacityTokens: 1000000),
      );

      expect(chat.memoryCheckpoints.length, 4);
      expect(chat.memoryCheckpoints.first.id, 'mc-2');
      expect(chat.memoryCheckpoints.last.id, 'mc-5');
      expect(chat.memoryCheckpoints.last.pathHash, 'path-5');
      expect(chat.memoryCheckpoints.last.contentHash, 'content-5');
    });

    test('append helper enforces selected capacity immediately', () {
      final chat = _chat('append-test');
      chat.memoryCheckpoints.addAll(
        List.generate(4, (index) => _checkpoint(index, summaryLength: 1000000)),
      );

      applyManagedCheckpoint(
        chat,
        _checkpoint(4, summaryLength: 1000000),
        settings: ManagedMemorySettings(capacityTokens: 1000000),
      );

      expect(chat.memoryCheckpoints.length, 4);
      expect(chat.memoryCheckpoints.first.id, 'mc-1');
      expect(chat.memoryCheckpoints.last.id, 'mc-4');
    });

    test('default migration seam uses the 2M standard capacity', () {
      final chat = _chat('default-standard');
      chat.memoryCheckpoints.addAll(
        List.generate(8, (index) => _checkpoint(index, summaryLength: 1000000)),
      );

      applyDefaultManagedCheckpoint(
        chat,
        _checkpoint(8, summaryLength: 1000000),
      );

      // 2M historical tokens map to an ~8M-character retention budget.
      // Nine 1M-character checkpoints therefore prune only the oldest one.
      expect(chat.memoryCheckpoints.length, 8);
      expect(chat.memoryCheckpoints.first.id, 'mc-1');
      expect(chat.memoryCheckpoints.last.id, 'mc-8');
    });

    test('larger tier retains history that the minimum tier prunes', () {
      final minimumChat = _chat('minimum');
      final maximumChat = _chat('maximum');
      minimumChat.memoryCheckpoints.addAll(
        List.generate(6, (index) => _checkpoint(index, summaryLength: 1000000)),
      );
      maximumChat.memoryCheckpoints.addAll(
        List.generate(6, (index) => _checkpoint(index, summaryLength: 1000000)),
      );

      pruneCheckpointsForManagedMemory(
        minimumChat,
        settings: ManagedMemorySettings(capacityTokens: 1000000),
      );
      pruneCheckpointsForManagedMemory(
        maximumChat,
        settings: ManagedMemorySettings(capacityTokens: 10000000),
      );

      expect(minimumChat.memoryCheckpoints.length, 4);
      expect(maximumChat.memoryCheckpoints.length, 6);
    });

    test('capacity pruning never reintroduces branch-invalid checkpoints', () {
      final chat = _chat('branch-validity');
      chat.memoryCheckpoints.addAll(
        List.generate(6, (index) => _checkpoint(index, summaryLength: 1000000)),
      );
      final valid = chat.memoryCheckpoints.where((checkpoint) {
        final index = int.parse(checkpoint.id.substring(3));
        return index.isEven;
      }).toList();

      final retained = retainValidCheckpointsForManagedMemory(
        chat,
        valid,
        settings: ManagedMemorySettings(capacityTokens: 1000000),
      );

      expect(chat.memoryCheckpoints.length, 4);
      expect(chat.memoryCheckpoints.first.id, 'mc-2');
      expect(retained.map((checkpoint) => checkpoint.id), ['mc-2', 'mc-4']);
    });
  });
}
