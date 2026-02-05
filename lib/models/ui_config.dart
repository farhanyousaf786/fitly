class UIConfig {
  final bool showCalorieTracking;
  final bool showProteinTracking;
  final bool showMentalHealthTab;
  final bool showMeditationTimer;
  final bool showSleepTracker;
  final List<String> emphasizedSections;
  final String dashboardLayout;

  UIConfig({
    required this.showCalorieTracking,
    required this.showProteinTracking,
    required this.showMentalHealthTab,
    required this.showMeditationTimer,
    required this.showSleepTracker,
    required this.emphasizedSections,
    required this.dashboardLayout,
  });

  Map<String, dynamic> toMap() {
    return {
      'showCalorieTracking': showCalorieTracking,
      'showProteinTracking': showProteinTracking,
      'showMentalHealthTab': showMentalHealthTab,
      'showMeditationTimer': showMeditationTimer,
      'showSleepTracker': showSleepTracker,
      'emphasizedSections': emphasizedSections,
      'dashboardLayout': dashboardLayout,
    };
  }

  factory UIConfig.fromMap(Map<String, dynamic> map) {
    return UIConfig(
      showCalorieTracking: map['showCalorieTracking'] ?? false,
      showProteinTracking: map['showProteinTracking'] ?? false,
      showMentalHealthTab: map['showMentalHealthTab'] ?? false,
      showMeditationTimer: map['showMeditationTimer'] ?? false,
      showSleepTracker: map['showSleepTracker'] ?? false,
      emphasizedSections: List<String>.from(map['emphasizedSections'] ?? []),
      dashboardLayout: map['dashboardLayout'] ?? 'balanced',
    );
  }
}
