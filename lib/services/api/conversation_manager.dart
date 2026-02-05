import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/chat_message.dart';
import '../../models/extracted_user_data.dart';

class ConversationManager {
  static const String _keyHistory = 'chat_history';
  static const String _keyUserData = 'extracted_user_data';
  static const String _keyPlan = 'generated_plan';

  List<ChatMessage> _messages = [];
  ExtractedUserData _userData = ExtractedUserData();

  List<ChatMessage> get messages => _messages;
  ExtractedUserData get userData => _userData;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // Load history
    final historyJson = prefs.getString(_keyHistory);
    if (historyJson != null) {
      final List<dynamic> decoded = jsonDecode(historyJson);
      _messages = decoded.map((m) => ChatMessage.fromMap(m)).toList();
    }

    // Load extracted data
    final dataJson = prefs.getString(_keyUserData);
    if (dataJson != null) {
      _userData = ExtractedUserData.fromJson(jsonDecode(dataJson));
    }
  }

  void addMessage(ChatMessage message) {
    _messages.add(message);
    _save();
  }

  void updateUserData(Map<String, dynamic> newData) {
    newData.forEach((key, value) {
      _userData.updateField(key, value);
    });
    _save();
  }

  Future<void> savePlanLocally(Map<String, dynamic> plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPlan, jsonEncode(plan));
  }

  Future<Map<String, dynamic>?> getSavedPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final planJson = prefs.getString(_keyPlan);
    if (planJson != null) {
      return jsonDecode(planJson);
    }
    return null;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      _keyHistory,
      jsonEncode(_messages.map((m) => m.toMap()).toList()),
    );
    prefs.setString(_keyUserData, jsonEncode(_userData.toJson()));
  }

  List<Map<String, String>> getCompactHistory(int limit) {
    // Return last X messages in OpenAI format
    final recent = _messages.length > limit
        ? _messages.sublist(_messages.length - limit)
        : _messages;

    return recent
        .map(
          (m) => {"role": m.isUser ? "user" : "assistant", "content": m.text},
        )
        .toList();
  }

  bool isReadyForPlan() {
    return _userData.hasRequiredInfo() || _messages.length >= 12;
  }

  void reset() async {
    _messages = [];
    _userData = ExtractedUserData();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHistory);
    await prefs.remove(_keyUserData);
  }
}
