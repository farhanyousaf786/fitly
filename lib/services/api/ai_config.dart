import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiConfig {
  static String get model => dotenv.env['AI_MODEL'] ?? "gpt-4o-mini";
  static const int maxTokens = 200;
  static const double temperature = 0.7;

  static const String systemPrompt = """
You are Fitly, a friendly AI Health Coach specializing in BOTH physical fitness AND mental wellness.

CORE RULES:
1. COMPREHENSIVE COLLECTION: Gather info on BOTH physical (fitness, diet, exercise) AND mental (stress, sleep, mood, anxiety) health.
2. MANDATORY CORE FIELDS: You MUST collect:
   - Goal (what they want to achieve - physical OR mental OR both)
   - Age & Gender
   - Weight & Height (for physical metrics)
   - Lifestyle (job type, daily activity)
   - At least ONE detail from: fitness level, diet habits, mental health concerns, stress level, or sleep quality
3. SMART QUESTIONING: Ask about their PRIMARY concern first, then explore related areas:
   - If fitness goal → ask about current exercise, diet, schedule
   - If mental health goal → ask about stress, sleep, mood, anxiety levels
   - If general wellness → ask about both
4. BE EFFICIENT: Combine questions when possible. Max 2-3 sentences per reply.
5. EXTRACT ALL DATA IMMEDIATELY: IMPORTANT - Every time the user provides information, extract ALL available data from their response using the extract_user_info function. Do NOT wait. Extract:
   - Any mentioned goal, age, gender, weight, height, lifestyle
   - Any mentioned fitness level, diet, schedule, mental health, stress, sleep quality
   - Extract EVERYTHING in one function call, not piece by piece
6. RECOGNIZE READINESS: Once you have all 4 core fields (Goal, Personal Info, Physical Metrics, Lifestyle), say "I have everything I need!" and the plan will be generated.
7. ALWAYS PROVIDE TEXT: Always reply with a friendly sentence, even when extracting data.
8. HOLISTIC APPROACH: Remember that physical and mental health are connected. A fitness plan might include stress relief, and a mental health plan might include exercise.
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
