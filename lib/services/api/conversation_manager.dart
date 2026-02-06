import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../models/chat_message.dart';
import '../../models/extracted_user_data.dart';

enum ConversationState {
  initial, // Just started
  collecting, // Gathering info
  clarifying, // Following up on unclear answers
  complete, // Have all needed info
  generating, // Creating plan
  done, // Plan created
}

class ConversationManager {
  static const String _keyHistory = 'chat_history';
  static const String _keyUserData = 'extracted_user_data';
  static const String _keyPlan = 'generated_plan';
  static const String _keySessionMeta = 'session_metadata';

  List<ChatMessage> _messages = [];
  ExtractedUserData _userData = ExtractedUserData();
  String? _summary;
  String _sessionId = const Uuid().v4();
  DateTime _startTime = DateTime.now();
  DateTime _lastMessageTime = DateTime.now();
  ConversationState _state = ConversationState.initial;
  double _totalEstimatedCost = 0.0;

  List<ChatMessage> get messages => _messages;
  ExtractedUserData get userData => _userData;
  ConversationState get state => _state;
  String? get summary => _summary;
  String get sessionId => _sessionId;
  double get estimatedCost => _totalEstimatedCost;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // Load session metadata
    final metaJson = prefs.getString(_keySessionMeta);
    if (metaJson != null) {
      final meta = jsonDecode(metaJson);
      _sessionId = meta['sessionId'] ?? const Uuid().v4();
      _startTime = DateTime.parse(
        meta['startTime'] ?? DateTime.now().toIso8601String(),
      );
      _lastMessageTime = DateTime.parse(
        meta['lastMessageTime'] ?? DateTime.now().toIso8601String(),
      );
      _summary = meta['summary'];
      _state = ConversationState.values.firstWhere(
        (e) => e.toString() == meta['state'],
        orElse: () => ConversationState.initial,
      );
      _totalEstimatedCost = meta['estimatedCost'] ?? 0.0;
    }

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
    _lastMessageTime = DateTime.now();

    // Update state based on message count and data
    if (_state == ConversationState.initial && _messages.length > 1) {
      _state = ConversationState.collecting;
    }

    // Estimate cost (very rough: ~4 chars per token)
    _addTokenCost(message.text.length ~/ 4, isInput: message.isUser);

    _save();
  }

  void updateState(ConversationState newState) {
    _state = newState;
    _save();
  }

  void updateUserData(Map<String, dynamic> newData) {
    print("💾 [FITLY_AI] DATA SAVED: $newData");
    newData.forEach((key, value) {
      _userData.updateField(key, value);
    });

    if (_userData.hasRequiredInfo()) {
      print("🎯 [FITLY_AI] ALL CORE INFO COLLECTED!");
      _state = ConversationState.complete;
    }

    _save();
  }

  void setSummary(String summary) {
    _summary = summary;
    _save();
  }

  void _addTokenCost(int tokens, {required bool isInput}) {
    // gpt-4o-mini costs: $0.00015 / 1K input, $0.0006 / 1K output
    final rate = isInput ? 0.00015 : 0.0006;
    _totalEstimatedCost += (tokens / 1000) * rate;
  }

  Future<void> savePlanLocally(Map<String, dynamic> plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPlan, jsonEncode(plan));
    _state = ConversationState.done;
    _save();
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

    // Save metadata
    final meta = {
      'sessionId': _sessionId,
      'startTime': _startTime.toIso8601String(),
      'lastMessageTime': _lastMessageTime.toIso8601String(),
      'summary': _summary,
      'state': _state.toString(),
      'estimatedCost': _totalEstimatedCost,
    };
    prefs.setString(_keySessionMeta, jsonEncode(meta));

    // Save history
    prefs.setString(
      _keyHistory,
      jsonEncode(_messages.map((m) => m.toMap()).toList()),
    );

    // Save extracted data
    prefs.setString(_keyUserData, jsonEncode(_userData.toJson()));
  }

  /// Optimized context for AI API calls (Cost Optimization)
  List<Map<String, String>> getContextForAI({int limit = 6}) {
    List<Map<String, String>> context = [];

    // 1. Add Summary if exists
    if (_summary != null) {
      context.add({
        "role": "system",
        "content": "PREVIOUS CONVERSATION SUMMARY: $_summary",
      });
    }

    // 2. Add recent messages
    final recent = _messages.length > limit
        ? _messages.sublist(_messages.length - limit)
        : _messages;

    context.addAll(
      recent.map(
        (m) => {"role": m.isUser ? "user" : "assistant", "content": m.text},
      ),
    );

    return context;
  }

  bool isReadyForPlan() {
    // Ready when: has all required info OR has collected enough messages with good detail
    final hasRequiredInfo = _userData.hasRequiredInfo();
    final hasEnoughMessages = _messages.length >= 12;
    
    return hasRequiredInfo || hasEnoughMessages;
  }

  double getCompleteness() {
    final status = _userData.getExtractionStatus();
    final count = status.values.where((v) => v.contains('✓')).length;
    return count / status.length;
  }

  Future<void> reset() async {
    _messages = [];
    _userData = ExtractedUserData();
    _summary = null;
    _sessionId = const Uuid().v4();
    _startTime = DateTime.now();
    _lastMessageTime = DateTime.now();
    _state = ConversationState.initial;
    _totalEstimatedCost = 0.0;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHistory);
    await prefs.remove(_keyUserData);
    await prefs.remove(_keySessionMeta);
  }
}
