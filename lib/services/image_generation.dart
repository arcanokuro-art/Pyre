import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/models.dart';
import 'chat_api.dart';

typedef ImageHttpClientFactory = http.Client Function();

class GeneratedImage {
  final Uint8List bytes;
  final String mimeType;
  const GeneratedImage(this.bytes, {this.mimeType = 'image/png'});
}

/// Generate one image through an OpenAI-compatible `/v1/images/generations`
/// endpoint. This is intentionally separate from chat completions: a provider
/// may support text/vision without exposing image generation.
Future<GeneratedImage> generateImage({
  required ApiProvider provider,
  required String prompt,
  String size = '1024x1024',
  ImageHttpClientFactory? clientFactory,
}) async {
  final cleanPrompt = prompt.trim();
  if (cleanPrompt.isEmpty) {
    throw ChatApiError('Image prompt is empty');
  }
  if (provider.baseUrl.trim().isEmpty) {
    throw ChatApiError('Provider has no baseUrl configured');
  }
  if (provider.format != ApiFormat.openai) {
    throw ChatApiError(
      'This provider does not expose the OpenAI-compatible image endpoint.',
    );
  }

  final uri = Uri.parse(buildChatUrl(provider.baseUrl, 'images/generations'));
  final request = http.Request('POST', uri)
    ..headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...providerRestAuthHeaders(
        format: provider.format,
        apiKey: provider.apiKey,
      ),
      ...provider.headers,
    })
    ..body = jsonEncode({
      'model': provider.model,
      'prompt': cleanPrompt,
      'n': 1,
      'size': size,
      'response_format': 'b64_json',
    });

  final client = clientFactory?.call() ?? http.Client();
  try {
    final streamed = await client.send(request);
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ChatApiError(
        'Image generation failed (HTTP ${response.statusCode}): '
        '${scrubProviderBody(response.body, apiKey: provider.apiKey)}',
      );
    }
    final decoded = jsonDecode(response.body);
    final data = decoded is Map ? decoded['data'] : null;
    final first = data is List && data.isNotEmpty ? data.first : null;
    final b64 = first is Map ? first['b64_json'] : null;
    if (b64 is String && b64.isNotEmpty) {
      return GeneratedImage(base64Decode(b64));
    }

    // Some OpenAI-compatible image providers ignore response_format and
    // return a temporary HTTPS URL instead. Follow it here so the rest of
    // Pyre always receives bytes and chat persistence stays provider-agnostic.
    final remoteUrl = first is Map ? first['url'] : null;
    if (remoteUrl is String && remoteUrl.trim().isNotEmpty) {
      final imageUri = Uri.tryParse(remoteUrl.trim());
      if (imageUri == null ||
          (imageUri.scheme != 'https' && imageUri.scheme != 'http')) {
        throw ChatApiError('Image provider returned an invalid image URL.');
      }
      final downloaded = await client.get(imageUri);
      if (downloaded.statusCode < 200 || downloaded.statusCode >= 300) {
        throw ChatApiError(
          'Generated image download failed (HTTP ${downloaded.statusCode}).',
        );
      }
      final contentType =
          downloaded.headers['content-type']?.split(';').first.trim();
      return GeneratedImage(
        downloaded.bodyBytes,
        mimeType: contentType?.startsWith('image/') == true
            ? contentType!
            : 'image/png',
      );
    }

    throw ChatApiError(
      'Image provider returned neither b64_json nor an image URL. '
      'The selected model may not support image generation.',
    );
  } on ChatApiError {
    rethrow;
  } catch (e) {
    throw ChatApiError('Image generation failed: $e');
  } finally {
    client.close();
  }
}
