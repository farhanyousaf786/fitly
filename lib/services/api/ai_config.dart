import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiConfig {
  static String get model => dotenv.env['AI_MODEL'] ?? "gpt-4o-mini";
  static const int maxTokens = 200;
  static const double temperature = 0.7;

  static const String extractGoalPrompt = """
You are Fitly, a friendly AI Health Coach specializing in BOTH physical fitness AND mental wellness.

EXTRACTION RULES:
1. Extract ONLY goal and goalDescription from the user's LAST message.
2. Goal: The main health/fitness objective (e.g., "lose weight", "reduce anxiety", "better sleep").
3. Goal Description: A detailed explanation of what they want to achieve (e.g., "lose belly fat and feel more confident", "manage daily stress and anxiety").
4. Respond naturally in 1-2 sentences.
5. ALWAYS end your response with a data extraction line.

MANDATORY OUTPUT FORMAT:
[Your friendly response here - max 1-2 sentences]

FITLY_EXTRACT_JSON: {"goal":"lose weight","goalDescription":"lose belly fat and feel more confident"}

GUIDELINES:
- goal: Keep it short and clear (2-3 words max).
- goalDescription: Provide detailed context of what they want to achieve.
- If goal is not mentioned: FITLY_EXTRACT_JSON: {}
- If goal is mentioned but description is missing, ask for elaboration.
""";

  // Category-specific extraction prompts
  static const String extractPersonalDataPrompt = """
You are Fitly, a friendly AI Health Coach.

Extract ONLY personal information from the user's LAST message:
- age: User's age in years
- gender: male, female, or other

Respond naturally in 1 sentence, then provide extraction.

MANDATORY OUTPUT FORMAT:
[Your friendly response - 1 sentence]

FITLY_EXTRACT_JSON: {"age":30,"gender":"male"}

GUIDELINES:
- If age is not mentioned, ask for it.
- If gender is not mentioned, ask for it.
- If nothing to extract: FITLY_EXTRACT_JSON: {}
""";

  static const String extractPhysicalDataPrompt = """
You are Fitly, a friendly AI Health Coach.

Extract ONLY physical metrics from the user's LAST message:
- weight: in kg (convert if needed)
- height: in cm (convert if needed)

Respond naturally in 1 sentence, then provide extraction.

MANDATORY OUTPUT FORMAT:
[Your friendly response - 1 sentence]

FITLY_EXTRACT_JSON: {"weight":70,"height":175}

GUIDELINES:
- Use numbers only for weight and height.
- If weight is not mentioned, ask for it.
- If height is not mentioned, ask for it.
- If nothing to extract: FITLY_EXTRACT_JSON: {}
""";

  static const String extractLifestylePrompt = """
You are Fitly, a friendly AI Health Coach.

Extract ONLY lifestyle information from the user's LAST message:
- lifestyle: Job type, daily activity level, work schedule (e.g., "office worker, sedentary", "construction worker, very active")

Respond naturally in 1 sentence, then provide extraction.

MANDATORY OUTPUT FORMAT:
[Your friendly response - 1 sentence]

FITLY_EXTRACT_JSON: {"lifestyle":"office worker, sedentary"}

GUIDELINES:
- Describe their typical daily routine and activity level.
- If not mentioned, ask about their job and daily activities.
- If nothing to extract: FITLY_EXTRACT_JSON: {}
""";

  static const String extractFitnessLevelPrompt = """
You are Fitly, a friendly AI Health Coach.

Extract ONLY fitness level from the user's LAST message:
- intensity: Preferred workout intensity (light, moderate, intense, sustainable vs fast)

Respond naturally in 1 sentence, then provide extraction.

MANDATORY OUTPUT FORMAT:
[Your friendly response - 1 sentence]

FITLY_EXTRACT_JSON: {"intensity":"moderate, sustainable"}

GUIDELINES:
- Ask about their preferred workout pace and intensity.
- If not mentioned, ask what intensity they prefer.
- If nothing to extract: FITLY_EXTRACT_JSON: {}
""";



  static const String recommendationPrompt = """
You are Fitly, a world-class Health & Fitness expert. 
Based on the user's physical metrics and goals, provide a high-level fitness recommendation.

Focus on:
1. A catchy, motivating Goal Title.
2. A clear, supportive Target Description of how they will achieve it.
3. Daily calorie and macro guidance (general).
4. A brief summary of the proposed approach.
""";

  static const List<Map<String, dynamic>> functions = [
    {
      "name": "extract_user_info",
      "description":
          "Extracts comprehensive health and fitness information covering both physical and mental wellness.",
      "parameters": {
        "type": "object",
        "properties": {
          "goal": {
            "type": "string",
            "description":
                "Primary goal (e.g., lose 5kg, build muscle, reduce anxiety, better sleep, general wellness)",
          },
          "age": {"type": "integer", "description": "The user's age"},
          "gender": {
            "type": "string",
            "enum": ["male", "female", "other"],
            "description": "The user's gender",
          },
          "weight": {"type": "number", "description": "Current weight in kg"},
          "height": {"type": "number", "description": "Current height in cm"},
          "lifestyle": {
            "type": "string",
            "description": "Job type, daily activity levels, work schedule",
          },
          "currentSituation": {
            "type": "string",
            "description":
                "Current habits: eating patterns, exercise routine, daily activities",
          },
          "schedule": {
            "type": "string",
            "description": "Daily schedule: wake time, work hours, sleep time",
          },
          "intensity": {
            "type": "string",
            "description": "Preferred workout intensity and pace (light, moderate, intense, sustainable vs fast)",
          },
          "mentalHealthConcerns": {
            "type": "string",
            "description":
                "Mental health goals or concerns (e.g., reduce anxiety, manage depression, improve focus)",
          },
          "stressLevel": {
            "type": "string",
            "description": "Current stress level and main stressors (low, moderate, high)",
          },
          "sleepQuality": {
            "type": "string",
            "description": "Sleep quality and patterns (hours per night, sleep issues)",
          },
          "moodPatterns": {
            "type": "string",
            "description": "Mood patterns and emotional state throughout the day",
          },
          "anxietyLevel": {
            "type": "string",
            "description": "Anxiety level and triggers (if applicable)",
          },
          "healthIssues": {
            "type": "string",
            "description": "Any injuries, chronic conditions, or health concerns",
          },
          "injuries": {
            "type": "string",
            "description": "Current or past injuries that affect exercise",
          },
          "allergies": {
            "type": "string",
            "description": "Food allergies or dietary restrictions",
          },
        },
        "required": ["goal", "age", "gender", "weight", "height", "lifestyle"],
      },
    },
    {
      "name": "get_fitness_recommendations",
      "description":
          "Generates personalized fitness recommendations based on user metrics.",
      "parameters": {
        "type": "object",
        "properties": {
          "goalTitle": {
            "type": "string",
            "description": "A motivating title for their fitness goal",
          },
          "targetDescription": {
            "type": "string",
            "description":
                "A detailed explanation of how they will achieve the goal",
          },
          "dailyCalories": {
            "type": "integer",
            "description": "Recommended daily calorie intake",
          },
          "macroSplit": {
            "type": "object",
            "properties": {
              "protein": {
                "type": "integer",
                "description": "Percentage of protein",
              },
              "carbs": {
                "type": "integer",
                "description": "Percentage of carbs",
              },
              "fats": {"type": "integer", "description": "Percentage of fats"},
            },
          },
          "suggestedApproach": {
            "type": "string",
            "description": "Brief summary of the workout and diet strategy",
          },
        },
        "required": [
          "goalTitle",
          "targetDescription",
          "dailyCalories",
          "macroSplit",
          "suggestedApproach",
        ],
      },
    },
    {
      "name": "generate_plan",
      "description":
          "Generates a structured, comprehensive fitness and wellness plan.",
      "parameters": {
        "type": "object",
        "properties": {
          "goalType": {
            "type": "string",
            "enum": [
              "weight_loss",
              "muscle_gain",
              "mental_health",
              "energy",
              "general_wellness",
            ],
          },
          "goalTitle": {"type": "string"},
          "targetDescription": {"type": "string"},
          "dietPlan": {
            "type": "object",
            "additionalProperties": {
              "type": "object",
              "properties": {
                "name": {"type": "string"},
                "time": {"type": "string"},
                "foods": {
                  "type": "array",
                  "items": {"type": "string"},
                },
                "avoid": {
                  "type": "array",
                  "items": {"type": "string"},
                },
                "instructions": {"type": "string"},
              },
            },
          },
          "exercisePlan": {
            "type": "object",
            "additionalProperties": {
              "type": "array",
              "items": {
                "type": "object",
                "properties": {
                  "name": {"type": "string"},
                  "sets": {"type": "string"},
                  "reps": {"type": "string"},
                  "duration": {"type": "string"},
                  "difficulty": {"type": "string"},
                  "instructions": {"type": "string"},
                },
              },
            },
          },
          "waterGoal": {"type": "integer"},
          "sleepSchedule": {
            "type": "object",
            "properties": {
              "target_sleep": {"type": "string"},
              "target_wake": {"type": "string"},
            },
          },
          "mentalHealthPractices": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "name": {"type": "string"},
                "type": {"type": "string"},
                "durationMinutes": {"type": "integer"},
                "time": {"type": "string"},
                "instructions": {"type": "string"},
              },
            },
          },
          "reminders": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "time": {"type": "string"},
                "title": {"type": "string"},
              },
            },
          },
          "uiConfig": {
            "type": "object",
            "properties": {
              "showCalorieTracking": {"type": "boolean"},
              "showProteinTracking": {"type": "boolean"},
              "showMentalHealthTab": {"type": "boolean"},
              "showMeditationTimer": {"type": "boolean"},
              "showSleepTracker": {"type": "boolean"},
              "emphasizedSections": {
                "type": "array",
                "items": {"type": "string"},
              },
              "dashboardLayout": {"type": "string"},
            },
          },
          "motivationalMessage": {"type": "string"},
        },
        "required": [
          "goalType",
          "goalTitle",
          "targetDescription",
          "motivationalMessage",
          "reminders",
          "uiConfig",
        ],
      },
    },
  ];
}
