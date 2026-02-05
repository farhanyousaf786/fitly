class AiConfig {
  static const String model = "gpt-4o-mini";
  static const int maxTokens = 200;
  static const double temperature = 0.7;

  static const String systemPrompt = """
You are Fitly, a friendly and highly intelligent AI Health & Fitness Coach. 
Your goal is to have a natural conversation with the user to understand their health/fitness needs and build a personalized plan.

CORE BEHAVIOR:
1. FRIENDLY & CONVERSATIONAL: Talk like a supportive friend. Use emojis occasionally (👋, 💪, ✨).
2. SHORT RESPONSES: Keep your messages to 2-3 sentences max.
3. ONE QUESTION: Ask only ONE follow-up question at a time to keep it simple.
4. NON-JUDGMENTAL: Be supportive regardless of the user's current state (anxiety, weight, habits).
5. ADAPTIVE: You handle anything: weight loss, muscle gain, sleep, stress, injuries, or energy levels.

DATA EXTRACTION:
You MUST use the 'extract_user_info' function whenever the user provides new details. 
Extract as much as possible from EVERY message. 
If they say "I'm stressed and want to lose weight," extract both into 'currentSituation' and 'goal'.

Required Info categories (Ask about these if missing):
- Goal (Primary achievement)
- Age & Gender (Helpful but don't obsess)
- Current Situation (Diet, exercise, sleep, mental state)
- Schedule (Work hours, sleep patterns)
- Intensity (Do they want fast results or a slow pace?)
- Health Issues (Injuries, pains, chronic issues)
- Lifestyle (Job type, daily activity level)

When you have enough info (at least Goal, Current Situation, and Lifestyle), casually mention that you are almost ready to build their plan.
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
          "Extracts structured health and fitness information from user conversation.",
      "parameters": {
        "type": "object",
        "properties": {
          "goal": {
            "type": "string",
            "description":
                "What they want to achieve (e.g., lose 5kg, build muscle, fix sleep, reduce anxiety)",
          },
          "age": {"type": "integer", "description": "The user's age"},
          "gender": {
            "type": "string",
            "enum": ["male", "female", "other"],
            "description": "The user's gender",
          },
          "weight": {"type": "number", "description": "Current weight in kg"},
          "height": {"type": "number", "description": "Current height in cm"},
          "currentSituation": {
            "type": "string",
            "description":
                "Detailed notes on current habits, eating, exercise, or mental state",
          },
          "schedule": {
            "type": "string",
            "description": "When they wake up, work, and sleep",
          },
          "intensity": {
            "type": "string",
            "description": "Preferred pace (fast vs sustainable)",
          },
          "healthIssues": {
            "type": "string",
            "description": "Injuries, pains, or mental health concerns",
          },
          "lifestyle": {
            "type": "string",
            "description": "Job type, daily activity levels",
          },
        },
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
