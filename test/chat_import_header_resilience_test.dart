import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pyre/services/chat_import.dart';

void main() {
  group('chat import header resilience', () {
    test('foreign JSONL without character_name uses the fallback title', () {
      final jsonl = [
        jsonEncode({
          'user_name': 'Alice',
          'create_date': '2024-01-01',
          'chat_metadata': <String, dynamic>{},
        }),
        jsonEncode({
          'name': 'Bob',
          'is_user': false,
          'is_system': false,
          'mes': 'Hello',
        }),
      ].join('\n');

      final result = importChat(jsonl);

      expect(result.summary.format, ChatImportFormat.foreignJsonl);
      expect(result.summary.title, 'Imported chat');
      expect(result.summary.messageCount, 1);
      expect(result.chat.messages.single.text, 'Hello');
    });

    test('blank character_name also uses the fallback title', () {
      final jsonl = [
        jsonEncode({
          'user_name': 'Alice',
          'character_name': '   ',
          'chat_metadata': <String, dynamic>{},
        }),
        jsonEncode({
          'name': 'Bob',
          'is_user': false,
          'mes': 'Hello again',
        }),
      ].join('\n');

      final result = importChat(jsonl);

      expect(result.summary.title, 'Imported chat');
      expect(result.summary.messageCount, 1);
    });
  });
}
