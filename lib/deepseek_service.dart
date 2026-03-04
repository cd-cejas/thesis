import 'dart:convert';
import 'package:http/http.dart' as http;

// Built-in DeepSeek API key — can be overridden via
// --dart-define=DEEPSEEK_API_KEY=your_key at build/run time.
const String _kDeepSeekApiKey = String.fromEnvironment(
  'DEEPSEEK_API_KEY',
  defaultValue: 'sk-5c3de2bbc15c4931bf33ac6a152db767',
);

class DeepSeekService {
  DeepSeekService({http.Client? client, String? apiKey})
    : _client = client ?? http.Client(),
      _apiKey = apiKey ?? _kDeepSeekApiKey;

  final http.Client _client;
  final String _apiKey;

  static const String _endpoint = 'https://api.deepseek.com/chat/completions';

  // System prompt to set the AI's role
  static const String systemPrompt =
      'You are an AI Career Guidance Assistant for Filipino students. '
      'You help students discover suitable careers, college courses, and universities '
      'in the Philippines based on their interests, skills, and RIASEC results. '
      'Keep responses concise, friendly, and informative. '
      'When discussing salaries, use Philippine Peso (₱). '
      'Focus on actionable advice and encourage students in their career exploration. '
      'Use official Philippine School official websites for reference when suggesting courses/programs and universities.'
      'IMPORTANT FORMATTING RULES: Do NOT use asterisks (*) or hashtags (#) in your responses. '
      'For emphasis, use Flutter-renderable bold formatting only — never markdown asterisks. ';

  /// Sends a message to DeepSeek API with full conversation history.
  /// Returns the assistant's reply or an error message prefixed with "Error:".
  Future<String> sendMessage(List<Map<String, String>> messageHistory) async {
    if (_apiKey.isEmpty) {
      return 'Error: Missing DeepSeek API key. Provide --dart-define=DEEPSEEK_API_KEY=your_key when building the app.';
    }

    try {
      final response = await _client
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': 'deepseek-chat',
              'messages': messageHistory,
              'temperature': 0.7,
              'max_tokens': 1024,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final choices = data['choices'] as List?;
        if (choices != null && choices.isNotEmpty) {
          final raw =
              choices[0]['message']['content'] as String? ??
              'No response received.';
          return _cleanResponse(raw);
        }
        return 'Error: Empty response from AI.';
      } else if (response.statusCode == 401) {
        return 'Error: Invalid API key. Please check your DeepSeek API key.';
      } else if (response.statusCode == 429) {
        return 'Error: Too many requests. Please wait a moment and try again.';
      } else {
        return 'Error: Server returned status ${response.statusCode}. Please try again.';
      }
    } on http.ClientException catch (e) {
      return 'Error: Connection failed. Please check your internet connection. ($e)';
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        return 'Error: Request timed out. Please try again.';
      }
      return 'Error: Something went wrong. Please try again. ($e)';
    }
  }

  void dispose() => _client.close();

  /// Strips markdown asterisks and replaces & with 'and'
  /// so responses render cleanly in plain Flutter Text widgets.
  String _cleanResponse(String text) {
    return text
        .replaceAll('***', '')
        .replaceAll('**', '')
        .replaceAll('*', '')
        .replaceAll('###', '')
        .replaceAll('##', '')
        .replaceAll('#', '')
        .trim();
  }
}
