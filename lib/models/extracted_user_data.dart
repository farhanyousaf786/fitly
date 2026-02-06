class ExtractedUserData {
  final Map<String, dynamic> data;

  ExtractedUserData({Map<String, dynamic>? data}) : data = data ?? {};

  // Physical metrics getters
  String? get goal => data['goal'];
  String? get goalDescription => data['goalDescription'];
  int? get age => data['age'];
  String? get gender => data['gender'];
  double? get weight => data['weight']?.toDouble();
  double? get height => data['height']?.toDouble();

  // Physical health getters
  String? get currentSituation => data['currentSituation'];
  String? get schedule => data['schedule'];
  String? get intensity => data['intensity'];
  String? get lifestyle => data['lifestyle'];

  // Mental health getters
  String? get mentalHealthConcerns => data['mentalHealthConcerns'];
  String? get stressLevel => data['stressLevel'];
  String? get sleepQuality => data['sleepQuality'];
  String? get moodPatterns => data['moodPatterns'];
  String? get anxietyLevel => data['anxietyLevel'];

  // Combined health getters
  String? get healthIssues => data['healthIssues'];
  String? get injuries => data['injuries'];
  String? get allergies => data['allergies'];

  // Flexible setter
  void updateField(String key, dynamic value) {
    if (value != null) {
      data[key] = value;
    }
  }

  // Check if we have enough info to generate a comprehensive plan
  bool hasRequiredInfo() {
    // Check if goal is collected (minimum requirement)
    return data['goal'] != null;
  }

  Map<String, dynamic> toJson() => data;

  factory ExtractedUserData.fromJson(Map<String, dynamic> json) {
    return ExtractedUserData(data: Map<String, dynamic>.from(json));
  }

  Map<String, String> getExtractionStatus() {
    return {
      "🎯 Goal": data['goal'] != null ? "✓ Extracted" : "○ Not mentioned",
      "👤 Personal Info": (data['age'] != null && data['gender'] != null)
          ? "✓ Extracted"
          : "○ Not mentioned",
      "📏 Physical Metrics": (data['weight'] != null && data['height'] != null)
          ? "✓ Extracted"
          : "○ Not mentioned",
      "💼 Lifestyle": data['lifestyle'] != null
          ? "✓ Extracted"
          : "○ Not mentioned",
      "� Fitness Level": data['intensity'] != null
          ? "✓ Extracted"
          : "○ Not mentioned",
      "🍽️ Diet & Nutrition": data['currentSituation'] != null
          ? "✓ Extracted"
          : "○ Not mentioned",
      "⏰ Schedule": data['schedule'] != null ? "✓ Extracted" : "○ Not mentioned",
      "🧠 Mental Health": (data['mentalHealthConcerns'] != null ||
              data['stressLevel'] != null ||
              data['sleepQuality'] != null)
          ? "✓ Extracted"
          : "○ Not mentioned",
      "😴 Sleep Quality": data['sleepQuality'] != null
          ? "✓ Extracted"
          : "○ Not mentioned",
      "⚠️ Health Issues": data['healthIssues'] != null
          ? "✓ Extracted"
          : "○ Not mentioned",
    };
  }

  Map<String, bool> getCollectedFields() {
    final allFields = {
      "🎯 Goal": data['goal'] != null,
      "👤 Personal Info": data['age'] != null && data['gender'] != null,
      "📏 Physical Metrics": data['weight'] != null && data['height'] != null,
      "💼 Lifestyle": data['lifestyle'] != null,
      "🏃 Fitness Level": data['intensity'] != null,
      "🍽️ Diet & Nutrition": data['currentSituation'] != null,
      "⏰ Schedule": data['schedule'] != null,
      "🧠 Mental Health": data['mentalHealthConcerns'] != null ||
          data['stressLevel'] != null ||
          data['sleepQuality'] != null,
      "😴 Sleep Quality": data['sleepQuality'] != null,
      "⚠️ Health Issues": data['healthIssues'] != null,
    };
    
    // Filter by goal-specific requirements
    return _filterFieldsByGoal(allFields);
  }

  Map<String, bool> _filterFieldsByGoal(Map<String, bool> allFields) {
    final goalLower = goal?.toLowerCase() ?? '';
    
    // Weight Loss / Muscle Gain
    if (goalLower.contains('weight') || goalLower.contains('muscle') || 
        goalLower.contains('lose') || goalLower.contains('gain') ||
        goalLower.contains('bulk') || goalLower.contains('strength')) {
      return {
        "🎯 Goal": allFields["🎯 Goal"] ?? false,
        "👤 Personal Info": allFields["👤 Personal Info"] ?? false,
        "📏 Physical Metrics": allFields["📏 Physical Metrics"] ?? false,
        "💼 Lifestyle": allFields["💼 Lifestyle"] ?? false,
        "🏃 Fitness Level": allFields["🏃 Fitness Level"] ?? false,
      };
    }
    // Mental Health / Stress / Anxiety / Depression
    else if (goalLower.contains('mental') || goalLower.contains('stress') || 
             goalLower.contains('anxiety') || goalLower.contains('depression') ||
             goalLower.contains('mood') || goalLower.contains('calm')) {
      return {
        "🎯 Goal": allFields["🎯 Goal"] ?? false,
        "👤 Personal Info": allFields["👤 Personal Info"] ?? false,
        "🧠 Mental Health": allFields["🧠 Mental Health"] ?? false,
        "😴 Sleep Quality": allFields["😴 Sleep Quality"] ?? false,
      };
    }
    // Sleep Better
    else if (goalLower.contains('sleep') || goalLower.contains('rest') || 
             goalLower.contains('insomnia') || goalLower.contains('fatigue')) {
      return {
        "🎯 Goal": allFields["🎯 Goal"] ?? false,
        "👤 Personal Info": allFields["👤 Personal Info"] ?? false,
        "😴 Sleep Quality": allFields["😴 Sleep Quality"] ?? false,
        "⏰ Schedule": allFields["⏰ Schedule"] ?? false,
      };
    }
    // Nutrition / Diet
    else if (goalLower.contains('nutrition') || goalLower.contains('diet') || 
             goalLower.contains('eat') || goalLower.contains('food')) {
      return {
        "🎯 Goal": allFields["🎯 Goal"] ?? false,
        "👤 Personal Info": allFields["👤 Personal Info"] ?? false,
        "📏 Physical Metrics": allFields["📏 Physical Metrics"] ?? false,
        "🍽️ Diet & Nutrition": allFields["🍽️ Diet & Nutrition"] ?? false,
      };
    }
    // General Wellness (default)
    else {
      return {
        "🎯 Goal": allFields["🎯 Goal"] ?? false,
        "👤 Personal Info": allFields["👤 Personal Info"] ?? false,
        "📏 Physical Metrics": allFields["📏 Physical Metrics"] ?? false,
        "💼 Lifestyle": allFields["💼 Lifestyle"] ?? false,
      };
    }
  }

  int getCollectedFieldsCount() {
    return getCollectedFields().values.where((v) => v).length;
  }

  int getTotalFields() {
    return getCollectedFields().length;
  }

  // Categorized field organization
  Map<String, Map<String, bool>> getCategorizedFields() {
    final collected = getCollectedFields();
    
    return {
      "🎯 Goal": {
        "Goal": collected["🎯 Goal"] ?? false,
      },
      "👤 Personal Data": {
        "Age": data['age'] != null,
        "Gender": data['gender'] != null,
      },
      "📏 Physical Data": {
        "Weight": data['weight'] != null,
        "Height": data['height'] != null,
      },
      "💼 Lifestyle": {
        "Lifestyle": collected["💼 Lifestyle"] ?? false,
      },
      "🏃 Fitness Level": {
        "Intensity": collected["🏃 Fitness Level"] ?? false,
      },
      "🧠 Mental Health": {
        "Mental Health": collected["🧠 Mental Health"] ?? false,
      },
      "😴 Sleep": {
        "Sleep Quality": collected["😴 Sleep Quality"] ?? false,
      },
      "🍽️ Nutrition": {
        "Diet & Nutrition": collected["🍽️ Diet & Nutrition"] ?? false,
      },
      "⏰ Schedule": {
        "Schedule": collected["⏰ Schedule"] ?? false,
      },
      "⚠️ Health": {
        "Health Issues": collected["⚠️ Health Issues"] ?? false,
      },
    };
  }

  // Field collection tracking
  Map<String, dynamic> getNextFieldWithPrompt() {
    final goalLower = goal?.toLowerCase() ?? '';
    
    // Define field collection sequence with prompts
    final fieldSequence = _getFieldSequenceForGoal(goalLower);
    
    // Find first uncollected field
    for (var field in fieldSequence) {
      final fieldKey = field['fieldKey'] as String;
      final isCollected = _isFieldCollected(fieldKey);
      
      if (!isCollected) {
        return {
          'category': field['category'],
          'fieldName': field['fieldName'],
          'fieldKey': fieldKey,
          'prompt': field['prompt'],
          'isCollected': false,
        };
      }
    }
    
    // All fields collected
    return {
      'category': null,
      'fieldName': null,
      'fieldKey': null,
      'prompt': null,
      'isCollected': true,
    };
  }

  List<Map<String, dynamic>> _getFieldSequenceForGoal(String goalLower) {
    // Weight Loss / Muscle Gain
    if (goalLower.contains('weight') || goalLower.contains('muscle') || 
        goalLower.contains('lose') || goalLower.contains('gain') ||
        goalLower.contains('bulk') || goalLower.contains('strength')) {
      return [
        {
          'category': '👤 Personal Data',
          'fieldName': 'Age',
          'fieldKey': 'age',
          'prompt': 'extractPersonalDataPrompt',
        },
        {
          'category': '👤 Personal Data',
          'fieldName': 'Gender',
          'fieldKey': 'gender',
          'prompt': 'extractPersonalDataPrompt',
        },
        {
          'category': '📏 Physical Data',
          'fieldName': 'Weight',
          'fieldKey': 'weight',
          'prompt': 'extractPhysicalDataPrompt',
        },
        {
          'category': '📏 Physical Data',
          'fieldName': 'Height',
          'fieldKey': 'height',
          'prompt': 'extractPhysicalDataPrompt',
        },
        {
          'category': '💼 Lifestyle',
          'fieldName': 'Lifestyle',
          'fieldKey': 'lifestyle',
          'prompt': 'extractLifestylePrompt',
        },
        {
          'category': '🏃 Fitness Level',
          'fieldName': 'Intensity',
          'fieldKey': 'intensity',
          'prompt': 'extractFitnessLevelPrompt',
        },
      ];
    }
    // Mental Health
    else if (goalLower.contains('mental') || goalLower.contains('stress') || 
             goalLower.contains('anxiety') || goalLower.contains('depression')) {
      return [
        {
          'category': '👤 Personal Data',
          'fieldName': 'Age',
          'fieldKey': 'age',
          'prompt': 'extractPersonalDataPrompt',
        },
        {
          'category': '👤 Personal Data',
          'fieldName': 'Gender',
          'fieldKey': 'gender',
          'prompt': 'extractPersonalDataPrompt',
        },
        {
          'category': '🧠 Mental Health',
          'fieldName': 'Mental Health Concerns',
          'fieldKey': 'mentalHealthConcerns',
          'prompt': 'extractMentalHealthPrompt',
        },
        {
          'category': '😴 Sleep',
          'fieldName': 'Sleep Quality',
          'fieldKey': 'sleepQuality',
          'prompt': 'extractSleepPrompt',
        },
      ];
    }
    // Sleep Better
    else if (goalLower.contains('sleep') || goalLower.contains('rest')) {
      return [
        {
          'category': '👤 Personal Data',
          'fieldName': 'Age',
          'fieldKey': 'age',
          'prompt': 'extractPersonalDataPrompt',
        },
        {
          'category': '👤 Personal Data',
          'fieldName': 'Gender',
          'fieldKey': 'gender',
          'prompt': 'extractPersonalDataPrompt',
        },
        {
          'category': '😴 Sleep',
          'fieldName': 'Sleep Quality',
          'fieldKey': 'sleepQuality',
          'prompt': 'extractSleepPrompt',
        },
        {
          'category': '⏰ Schedule',
          'fieldName': 'Schedule',
          'fieldKey': 'schedule',
          'prompt': 'extractSchedulePrompt',
        },
      ];
    }
    // Nutrition
    else if (goalLower.contains('nutrition') || goalLower.contains('diet')) {
      return [
        {
          'category': '👤 Personal Data',
          'fieldName': 'Age',
          'fieldKey': 'age',
          'prompt': 'extractPersonalDataPrompt',
        },
        {
          'category': '👤 Personal Data',
          'fieldName': 'Gender',
          'fieldKey': 'gender',
          'prompt': 'extractPersonalDataPrompt',
        },
        {
          'category': '📏 Physical Data',
          'fieldName': 'Weight',
          'fieldKey': 'weight',
          'prompt': 'extractPhysicalDataPrompt',
        },
        {
          'category': '📏 Physical Data',
          'fieldName': 'Height',
          'fieldKey': 'height',
          'prompt': 'extractPhysicalDataPrompt',
        },
        {
          'category': '🍽️ Nutrition',
          'fieldName': 'Diet & Nutrition',
          'fieldKey': 'currentSituation',
          'prompt': 'extractNutritionPrompt',
        },
      ];
    }
    
    // Default: General Wellness
    return [
      {
        'category': '👤 Personal Data',
        'fieldName': 'Age',
        'fieldKey': 'age',
        'prompt': 'extractPersonalDataPrompt',
      },
      {
        'category': '👤 Personal Data',
        'fieldName': 'Gender',
        'fieldKey': 'gender',
        'prompt': 'extractPersonalDataPrompt',
      },
      {
        'category': '📏 Physical Data',
        'fieldName': 'Weight',
        'fieldKey': 'weight',
        'prompt': 'extractPhysicalDataPrompt',
      },
      {
        'category': '📏 Physical Data',
        'fieldName': 'Height',
        'fieldKey': 'height',
        'prompt': 'extractPhysicalDataPrompt',
      },
      {
        'category': '💼 Lifestyle',
        'fieldName': 'Lifestyle',
        'fieldKey': 'lifestyle',
        'prompt': 'extractLifestylePrompt',
      },
    ];
  }

  bool _isFieldCollected(String fieldKey) {
    switch (fieldKey) {
      case 'age':
        return age != null;
      case 'gender':
        return gender != null;
      case 'weight':
        return weight != null;
      case 'height':
        return height != null;
      case 'lifestyle':
        return lifestyle != null;
      case 'intensity':
        return intensity != null;
      case 'mentalHealthConcerns':
        return mentalHealthConcerns != null;
      case 'sleepQuality':
        return sleepQuality != null;
      case 'schedule':
        return schedule != null;
      case 'currentSituation':
        return currentSituation != null;
      default:
        return false;
    }
  }

  @override
  String toString() => data.toString();
}
