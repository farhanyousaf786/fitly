class AppConstants {
  // App Info
  static const String appName = 'Fitly';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'https://api.fitly.app';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userProfileKey = 'user_profile';
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String onboardingCompletedKey = 'onboarding_completed';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String workoutsCollection = 'workouts';
  static const String mealsCollection = 'meals';
  static const String remindersCollection = 'reminders';
  
  // Screen Names
  static const String splashScreen = '/splash';
  static const String loginScreen = '/login';
  static const String signupScreen = '/signup';
  static const String onboardingScreen = '/onboarding';
  static const String homeScreen = '/home';
  static const String profileScreen = '/profile';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxUsernameLength = 30;
  static const int maxBioLength = 150;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const double defaultSpacing = 8.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Notification Settings
  static const String workoutReminderChannel = 'workout_reminders';
  static const String mealReminderChannel = 'meal_reminders';
  static const String hydrationReminderChannel = 'hydration_reminders';
}
