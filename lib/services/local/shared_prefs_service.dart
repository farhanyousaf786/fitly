import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class SharedPrefsService {
  static SharedPreferences? _prefs;

  // Initialize shared preferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Ensure preferences are initialized
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('SharedPrefsService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Generic methods
  static Future<void> setString(String key, String value) async {
    await prefs.setString(key, value);
  }

  static String? getString(String key) {
    return prefs.getString(key);
  }

  static Future<void> setInt(String key, int value) async {
    await prefs.setInt(key, value);
  }

  static int? getInt(String key) {
    return prefs.getInt(key);
  }

  static Future<void> setDouble(String key, double value) async {
    await prefs.setDouble(key, value);
  }

  static double? getDouble(String key) {
    return prefs.getDouble(key);
  }

  static Future<void> setBool(String key, bool value) async {
    await prefs.setBool(key, value);
  }

  static bool? getBool(String key) {
    return prefs.getBool(key);
  }

  static Future<void> setStringList(String key, List<String> value) async {
    await prefs.setStringList(key, value);
  }

  static List<String>? getStringList(String key) {
    return prefs.getStringList(key);
  }

  static Future<void> remove(String key) async {
    await prefs.remove(key);
  }

  static Future<void> clear() async {
    await prefs.clear();
  }

  static Future<bool> containsKey(String key) async {
    return prefs.containsKey(key);
  }

  // App specific methods
  static Future<void> setUserToken(String token) async {
    await setString(AppConstants.userTokenKey, token);
  }

  static String? getUserToken() {
    return getString(AppConstants.userTokenKey);
  }

  static Future<void> clearUserToken() async {
    await remove(AppConstants.userTokenKey);
  }

  static Future<void> setIsFirstLaunch(bool isFirstLaunch) async {
    await setBool(AppConstants.isFirstLaunchKey, isFirstLaunch);
  }

  static bool getIsFirstLaunch() {
    return getBool(AppConstants.isFirstLaunchKey) ?? true;
  }

  static Future<void> setOnboardingCompleted(bool completed) async {
    await setBool(AppConstants.onboardingCompletedKey, completed);
  }

  static bool getOnboardingCompleted() {
    return getBool(AppConstants.onboardingCompletedKey) ?? false;
  }

  static Future<void> setUserProfile(String userProfileJson) async {
    await setString(AppConstants.userProfileKey, userProfileJson);
  }

  static String? getUserProfile() {
    return getString(AppConstants.userProfileKey);
  }

  static Future<void> clearUserProfile() async {
    await remove(AppConstants.userProfileKey);
  }

  // Theme preferences
  static Future<void> setThemeMode(String themeMode) async {
    await setString('theme_mode', themeMode);
  }

  static String? getThemeMode() {
    return getString('theme_mode');
  }

  static Future<void> setDarkMode(bool isDarkMode) async {
    await setBool('dark_mode', isDarkMode);
  }

  static bool getDarkMode() {
    return getBool('dark_mode') ?? false;
  }

  // Language preferences
  static Future<void> setLanguage(String languageCode) async {
    await setString('language', languageCode);
  }

  static String? getLanguage() {
    return getString('language');
  }

  // Notification preferences
  static Future<void> setNotificationEnabled(bool enabled) async {
    await setBool('notifications_enabled', enabled);
  }

  static bool getNotificationEnabled() {
    return getBool('notifications_enabled') ?? true;
  }

  static Future<void> setWorkoutReminders(bool enabled) async {
    await setBool('workout_reminders', enabled);
  }

  static bool getWorkoutReminders() {
    return getBool('workout_reminders') ?? true;
  }

  static Future<void> setMealReminders(bool enabled) async {
    await setBool('meal_reminders', enabled);
  }

  static bool getMealReminders() {
    return getBool('meal_reminders') ?? true;
  }

  static Future<void> setHydrationReminders(bool enabled) async {
    await setBool('hydration_reminders', enabled);
  }

  static bool getHydrationReminders() {
    return getBool('hydration_reminders') ?? true;
  }

  // Workout preferences
  static Future<void> setDefaultWorkoutDuration(int duration) async {
    await setInt('default_workout_duration', duration);
  }

  static int getDefaultWorkoutDuration() {
    return getInt('default_workout_duration') ?? 30;
  }

  static Future<void> setDefaultWorkoutDays(List<String> days) async {
    await setStringList('default_workout_days', days);
  }

  static List<String> getDefaultWorkoutDays() {
    return getStringList('default_workout_days') ?? ['Monday', 'Wednesday', 'Friday'];
  }

  static Future<void> setPreferredWorkoutTypes(List<String> types) async {
    await setStringList('preferred_workout_types', types);
  }

  static List<String> getPreferredWorkoutTypes() {
    return getStringList('preferred_workout_types') ?? [];
  }

  // Nutrition preferences
  static Future<void> setDietaryRestrictions(List<String> restrictions) async {
    await setStringList('dietary_restrictions', restrictions);
  }

  static List<String> getDietaryRestrictions() {
    return getStringList('dietary_restrictions') ?? [];
  }

  static Future<void> setAllergies(List<String> allergies) async {
    await setStringList('allergies', allergies);
  }

  static List<String> getAllergies() {
    return getStringList('allergies') ?? [];
  }

  static Future<void> setDailyCalorieGoal(int calories) async {
    await setInt('daily_calorie_goal', calories);
  }

  static int getDailyCalorieGoal() {
    return getInt('daily_calorie_goal') ?? 2000;
  }

  static Future<void> setDailyWaterGoal(int ounces) async {
    await setInt('daily_water_goal', ounces);
  }

  static int getDailyWaterGoal() {
    return getInt('daily_water_goal') ?? 64;
  }

  // User metrics
  static Future<void> setUserAge(int age) async {
    await setInt('user_age', age);
  }

  static int? getUserAge() {
    return getInt('user_age');
  }

  static Future<void> setUserHeight(double height) async {
    await setDouble('user_height', height);
  }

  static double? getUserHeight() {
    return getDouble('user_height');
  }

  static Future<void> setUserWeight(double weight) async {
    await setDouble('user_weight', weight);
  }

  static double? getUserWeight() {
    return getDouble('user_weight');
  }

  static Future<void> setUserGender(String gender) async {
    await setString('user_gender', gender);
  }

  static String? getUserGender() {
    return getString('user_gender');
  }

  static Future<void> setFitnessGoal(String goal) async {
    await setString('fitness_goal', goal);
  }

  static String? getFitnessGoal() {
    return getString('fitness_goal');
  }

  static Future<void> setActivityLevel(String level) async {
    await setString('activity_level', level);
  }

  static String? getActivityLevel() {
    return getString('activity_level');
  }

  // App settings
  static Future<void> setAutoStartWorkout(bool autoStart) async {
    await setBool('auto_start_workout', autoStart);
  }

  static bool getAutoStartWorkout() {
    return getBool('auto_start_workout') ?? false;
  }

  static Future<void> setPlaySounds(bool playSounds) async {
    await setBool('play_sounds', playSounds);
  }

  static bool getPlaySounds() {
    return getBool('play_sounds') ?? true;
  }

  static Future<void> setVibration(bool vibration) async {
    await setBool('vibration', vibration);
  }

  static bool getVibration() {
    return getBool('vibration') ?? true;
  }

  static Future<void> setKeepScreenOn(bool keepOn) async {
    await setBool('keep_screen_on', keepOn);
  }

  static bool getKeepScreenOn() {
    return getBool('keep_screen_on') ?? false;
  }

  // Cache management
  static Future<void> setCachedData(String key, String data, {Duration? expiration}) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final expirationTime = expiration != null 
        ? timestamp + expiration.inMilliseconds 
        : null;
    
    await setString('${key}_data', data);
    if (expirationTime != null) {
      await setInt('${key}_expiration', expirationTime);
    }
  }

  static String? getCachedData(String key) {
    final expirationTime = getInt('${key}_expiration');
    if (expirationTime != null) {
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      if (currentTime > expirationTime) {
        // Data has expired
        remove('${key}_data');
        remove('${key}_expiration');
        return null;
      }
    }
    return getString('${key}_data');
  }

  static Future<void> clearCachedData(String key) async {
    await remove('${key}_data');
    await remove('${key}_expiration');
  }

  static Future<void> clearAllCache() async {
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.endsWith('_data') || key.endsWith('_expiration')) {
        await remove(key);
      }
    }
  }

  // Debug methods
  static Future<void> printAllPreferences() async {
    final keys = prefs.getKeys();
    print('=== Shared Preferences ===');
    for (final key in keys) {
      final value = prefs.get(key);
      print('$key: $value');
    }
    print('========================');
  }

  static Future<void> resetApp() async {
    await clear();
    await setIsFirstLaunch(true);
    await setOnboardingCompleted(false);
  }
}
