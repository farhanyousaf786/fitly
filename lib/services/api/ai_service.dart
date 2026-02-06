import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'ai_config.dart';
import '../../models/user_config.dart';
import '../../models/extracted_user_data.dart';

class AiResponse {
  final String text;
  final Map<String, dynamic>? extractedData;

  AiResponse({required this.text, this.extractedData});
}

class AiService {
  String get _baseUrl {
    final url = dotenv.env['OPENAI_API_URL'] ?? "https://api.openai.com/v1";
    return "$url/chat/completions";
  }

  Future<AiResponse> getResponse({
    required List<Map<String, String>> history,
    required Map<String, dynamic> currentData,
    required Map<String, String> extractionStatus,
  }) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty || apiKey == 'YOUR_API_KEY_HERE') {
      return AiResponse(
        text:
            "⚠️ API Key not found. Please add your OpenAI API Key to the .env file.",
      );
    }

    try {
      final messages = [
        {
          "role": "system",
          "content":
              """${AiConfig.systemPrompt}
          
CURRENT DATA SNAPSHOT: ${jsonEncode(currentData)}
EXTRACTION STATUS: ${jsonEncode(extractionStatus)}

INSTRUCTIONS:
1. Review the extraction status.
2. If a category is '○ Not mentioned', try to naturally guide the conversation towards it.
3. If the user is vague (e.g., 'I eat normal food'), ask for specific examples.
4. If you have enough info, use the 'extract_user_info' function to save it.
5. Be concise and supportive.
""",
        },
        ...history,
      ];

      print("🚀 [FITLY_AI] PROMPT: ${jsonEncode(messages)}");

      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $apiKey",
            },
            body: jsonEncode({
              "model": AiConfig.model,
              "messages": messages,
              "functions": AiConfig.functions,
              "function_call": "auto",
              "max_tokens": 500,
              "temperature": 0.7,
            }),
          )
          .timeout(const Duration(seconds: 30));

      print("✅ [FITLY_AI] RESPONSE STATUS: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final choice = data['choices'][0]['message'];

        String content = choice['content'] ?? "";
        Map<String, dynamic>? extracted;

        if (choice['function_call'] != null) {
          final functionName = choice['function_call']['name'];
          print("🛠️ [FITLY_AI] FUNCTION CALL: $functionName");
          if (functionName == 'extract_user_info') {
            extracted = jsonDecode(choice['function_call']['arguments']);
            print("📦 [FITLY_AI] EXTRACTED: $extracted");
          }
        }

        if (content.isEmpty && extracted != null) {
          // If the AI forgot to speak, but extracted data, we try to ask for something specific
          final missing = extractionStatus.entries
              .where((e) => e.value.contains('○'))
              .map((e) => e.key)
              .toList();

          if (missing.isNotEmpty) {
            content =
                "Got it! By the way, tell me a bit about your ${missing.first}.";
          } else {
            content = "That's helpful! Tell me more about your daily routine.";
          }
        }

        print("💬 [FITLY_AI] FINAL TO USER: $content");

        return AiResponse(text: content, extractedData: extracted);
      } else {
        print("❌ [FITLY_AI] ERROR BODY: ${response.body}");
        throw Exception("API Error: ${response.statusCode}");
      }
    } catch (e) {
      print("🚨 [FITLY_AI] EXCEPTION: $e");
      return AiResponse(
        text:
            "I'm having a bit of trouble focusing. Could you repeat that or tell me more about your goals?",
      );
    }
  }

  Future<String?> generateSummary(List<Map<String, String>> history) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null) return null;

    try {
      final messages = [
        {
          "role": "system",
          "content":
              "Summarize the following conversation history into a single, highly dense paragraph (max 50 words). Focus on: goals, age/gender, diet habits, exercise levels, and schedule. Ignore greetings.",
        },
        {"role": "user", "content": jsonEncode(history)},
      ];

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode({
          "model": AiConfig.model,
          "messages": messages,
          "max_tokens": 100,
          "temperature": 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      }
    } catch (e) {
      print("Summarization failed: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>> getFitnessRecommendations({
    required int age,
    required String gender,
    required double height,
    required double weight,
    String? fitnessGoal,
    String? activityLevel,
  }) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty || apiKey == 'YOUR_API_KEY_HERE') {
      return {};
    }

    try {
      final prompt =
          """
USER DATA:
- Age: $age
- Gender: $gender
- Height: ${height}cm
- Weight: ${weight}kg
- Goal: ${fitnessGoal ?? 'General Health'}
- Activity Level: ${activityLevel ?? 'Not specified'}
""";

      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $apiKey",
            },
            body: jsonEncode({
              "model": AiConfig.model,
              "messages": [
                {"role": "system", "content": AiConfig.recommendationPrompt},
                {"role": "user", "content": prompt},
              ],
              "functions": [
                AiConfig.functions.firstWhere(
                  (f) => f['name'] == 'get_fitness_recommendations',
                ),
              ],
              "function_call": {"name": "get_fitness_recommendations"},
              "max_tokens": 500,
              "temperature": 0.7,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final choice = data['choices'][0]['message'];

        if (choice['function_call'] != null) {
          return jsonDecode(choice['function_call']['arguments']);
        }
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  Future<UserConfig> generatePlan(ExtractedUserData userData) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty || apiKey == 'YOUR_API_KEY_HERE') {
      throw Exception('API Key not found');
    }

    try {
      final prompt =
          "I have collected the following user details: ${jsonEncode(userData.toJson())}. Please generate a complete, structured fitness and wellness plan for them.";

      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $apiKey",
            },
            body: jsonEncode({
              "model": AiConfig.model,
              "messages": [
                {
                  "role": "system",
                  "content":
                      "You are Fitly, a world-class Health & Fitness expert. Generate a detailed, personalized plan based on user data.",
                },
                {"role": "user", "content": prompt},
              ],
              "functions": [
                AiConfig.functions.firstWhere(
                  (f) => f['name'] == 'generate_plan',
                ),
              ],
              "function_call": {"name": "generate_plan"},
              "max_tokens": 1500,
              "temperature": 0.7,
            }),
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final choice = data['choices'][0]['message'];

        if (choice['function_call'] != null) {
          final args = jsonDecode(choice['function_call']['arguments']);
          // Merge with physical metrics from userData
          args['age'] = userData.age;
          args['weight'] = userData.weight;
          args['height'] = userData.height;
          args['gender'] = userData.gender;

          // Attempt to map FitnessGoal and ActivityLevel if not provided
          // (They might be missing in args but present in userData)
          // For now we assume generate_plan provides a good enough config.

          return UserConfig.fromMap(args);
        }
      }
      throw Exception('Failed to generate plan: ${response.body}');
    } catch (e) {
      rethrow;
    }
  }
}
