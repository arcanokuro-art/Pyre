import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:pyre/models/models.dart';
import 'package:pyre/services/image_generation.dart';

void main() {
  ApiProvider provider() => ApiProvider(
        id: 'image-test',
        name: 'Image test',
        baseUrl: 'https://example.test/v1',
        apiKey: 'secret',
        model: 'image-model',
      );

  test('decodes b64_json image responses', () async {
    final result = await generateImage(
      provider: provider(),
      prompt: 'a quiet forest',
      clientFactory: () => MockClient((request) async {
        expect(request.url.toString(),
            'https://example.test/v1/images/generations');
        expect(request.headers['authorization'], 'Bearer secret');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['prompt'], 'a quiet forest');
        expect(body['response_format'], 'b64_json');
        return http.Response(
          jsonEncode({
            'data': [
              {'b64_json': base64Encode([1, 2, 3, 4])}
            ]
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    expect(result.bytes, [1, 2, 3, 4]);
    expect(result.mimeType, 'image/png');
  });

  test('downloads URL image responses', () async {
    final result = await generateImage(
      provider: provider(),
      prompt: 'city at night',
      clientFactory: () => MockClient((request) async {
        if (request.url.host == 'cdn.example.test') {
          return http.Response.bytes(
            [9, 8, 7],
            200,
            headers: {'content-type': 'image/webp'},
          );
        }
        return http.Response(
          jsonEncode({
            'data': [
              {'url': 'https://cdn.example.test/generated.webp'}
            ]
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    expect(result.bytes, [9, 8, 7]);
    expect(result.mimeType, 'image/webp');
  });
}
