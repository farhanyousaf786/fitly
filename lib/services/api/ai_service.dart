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
  final String _baseUrl = "https://api.openai.com/v1/chat/completions";

  Future<AiResponse> getResponse({
    required List<Map<String, String>> history,
    required Map<String, dynamic> currentData,
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
              "${AiConfig.systemPrompt}\n\nCURRENT EXTRACTED DATA: ${jsonEncode(currentData)}",
        },
        ...history,
      ];

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
              "max_tokens": AiConfig.maxTokens,
              "temperature": AiConfig.temperature,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final choice = data['choices'][0]['message'];

        String content = choice['content'] ?? "";
        Map<String, dynamic>? extracted;

        if (choice['function_call'] != null) {
          final functionName = choice['function_call']['name'];
          if (functionName == 'extract_user_info') {
            extracted = jsonDecode(choice['function_call']['arguments']);
          }
        }

        // If GPT only returned function call, it hasn't said anything yet.
        // In a real app, you might want a second call, but for speed/cost,
        // we'll handle empty content gracefully.
        if (content.isEmpty && extracted != null) {
          content =
              "Thanks for sharing that! Tell me a bit more about your daily schedule?";
        }

        return AiResponse(text: content, extractedData: extracted);
      } else {
        return AiResponse(
          text:
              "Sorry, I'm having a bit of trouble connecting right now. Let's try again in a moment!",
        );
      }
    } catch (e) {
      return AiResponse(
        text:
            "I encountered a network hiccup 🌐. Please check your connection!",
      );
    }
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
