class ExtractedUserData {
  final Map<String, dynamic> data;

  ExtractedUserData({Map<String, dynamic>? data}) : data = data ?? {};

  // Physical metrics getters
  String? get goal => data['goal'];
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
    // ALL required fields must be collected: goal, age, gender, weight, height, lifestyle
    final requiredFields = getRequiredFields();
    final allRequiredCollected = requiredFields.values.every((v) => v);

    return allRequiredCollected;
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

  Map<String, bool> getRequiredFields() {
    return {
      "🎯 Goal": data['goal'] != null,
      "👤 Personal Info": data['age'] != null && data['gender'] != null,
      "📏 Physical Metrics": data['weight'] != null && data['height'] != null,
      "💼 Lifestyle": data['lifestyle'] != null,
    };
  }

  Map<String, bool> getOptionalFields() {
    return {
      "🏃 Fitness Level": data['intensity'] != null,
      "🍽️ Diet & Nutrition": data['currentSituation'] != null,
      "⏰ Schedule": data['schedule'] != null,
      "🧠 Mental Health": data['mentalHealthConcerns'] != null ||
          data['stressLevel'] != null ||
          data['sleepQuality'] != null,
      "😴 Sleep Quality": data['sleepQuality'] != null,
      "⚠️ Health Issues": data['healthIssues'] != null,
    };
  }

  int getRequiredFieldsCount() {
    return getRequiredFields().values.where((v) => v).length;
  }

  int getTotalRequiredFields() {
    return getRequiredFields().length;
  }

  int getOptionalFieldsCount() {
    return getOptionalFields().values.where((v) => v).length;
  }

  int getTotalOptionalFields() {
    return getOptionalFields().length;
  }

  @override
  String toString() => data.toString();
}
