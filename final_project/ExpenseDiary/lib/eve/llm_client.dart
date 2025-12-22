import 'dart:convert';
import 'package:http/http.dart' as http;

class LLMClient {
  final String apiKey;

  LLMClient(this.apiKey);

  Future<String> complete({
    required String systemPrompt,
    required String userPrompt,
  }) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userPrompt},
        ],
        'temperature': 0.4,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('LLM call failed');
    }

    final decoded = jsonDecode(response.body);
    return decoded['choices'][0]['message']['content'];
  }
}
