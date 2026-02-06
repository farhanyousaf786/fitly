import 'package:flutter/foundation.dart';
import '../models/user_config.dart';
import '../models/chat_message.dart';
import '../models/extracted_user_data.dart';
import 'user_provider.dart';
import '../services/api/ai_service.dart';
import '../services/api/conversation_manager.dart';

class OnboardingProvider extends ChangeNotifier {
  final UserProvider _userProvider;
  final AiService _aiService;
  final ConversationManager _conversationManager;

  OnboardingProvider({
    required UserProvider userProvider,
    required AiService aiService,
    required ConversationManager conversationManager,
  }) : _userProvider = userProvider,
       _aiService = aiService,
       _conversationManager = conversationManager;

  // State
  bool _isLoading = false;
  String? _errorMessage;
  bool _isChatLoading = false;
  String? _chatError;
  UserConfig? _tempUserConfig;
  String _loadingMessage = "Thinking...";

  // Getters
  bool get isLoading => _isLoading || _isChatLoading;
  String? get errorMessage => _errorMessage ?? _chatError;
  bool get isChatLoading => _isChatLoading;
  String? get chatError => _chatError;
  String get loadingMessage => _loadingMessage;
  UserConfig? get userConfig => _tempUserConfig;
  List<ChatMessage> get chatMessages => _conversationManager.messages;
  ExtractedUserData get extractedData {
    final data = _conversationManager.userData;
    print("🔗 [PROVIDER_GETTER] extractedData requested:");
    print("   Object: $data");
    print("   Data Map: ${data.toJson()}");
    print("   Goal: ${data.goal}");
    print("   Age: ${data.age}");
    print("   Weight: ${data.weight}");
    return data;
  }
  double get totalCost => _conversationManager.estimatedCost;
  ConversationState get conversationState => _conversationManager.state;
  double get dataCompleteness => _conversationManager.getCompleteness();

  void applyLocalExtraction(Map<String, dynamic> fields) {
    if (fields.isEmpty) return;
    print("🧩 [PROVIDER] LOCAL EXTRACTION APPLIED: $fields");
    _conversationManager.updateUserData(fields);
    notifyListeners();
  }

  void addMessage({required String text, required bool isUser}) {
    final message = ChatMessage(
      text: text,
      isUser: isUser,
      timestamp: DateTime.now(),
    );
    _conversationManager.addMessage(message);
    notifyListeners();
  }

  String? _inferGoalFromText(String text) {
    final cleaned = text
        .trim()
        .replaceAll(RegExp(r'[^\w\s/\-,:.]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
    final t = cleaned.toLowerCase();

    String? extractAfter(List<String> markers) {
      for (final m in markers) {
        final idx = t.indexOf(m);
        if (idx >= 0) {
          final raw = cleaned.substring(idx + m.length).trim();
          if (raw.isNotEmpty) return raw;
        }
      }
      return null;
    }

    final explicit = extractAfter([
      'goal:',
      'my goal is',
      'my goal:',
      'i want to',
      'i wanna',
      'i would like to',
      'i need to',
    ]);
    if (explicit != null && explicit.length >= 2) {
      return explicit;
    }

    if (t.contains('weight loss') ||
        t.contains('lose weight') ||
        t.contains('loss weight') ||
        t.contains('reduce weight') ||
        t.contains('burn fat')) {
      return 'Weight Loss';
    }
    if (t.contains('muscle') || t.contains('bulk') || t.contains('gain muscle')) {
      return 'Muscle Gain';
    }
    if (t.contains('sleep') || t.contains('insomnia')) {
      return 'Sleep Better';
    }
    if (t.contains('stress') ||
        t.contains('anxiety') ||
        t.contains('depression') ||
        t.contains('panic')) {
      return 'Stress/Mental Wellness';
    }
    if (t.contains('diet') || t.contains('nutrition') || t.contains('eat healthy')) {
      return 'Healthy Diet';
    }

    // If user typed a short goal phrase (even 1 word), treat it as the goal.
    // Examples: "cut", "bulk", "lean", "fitness", "wellness", "weight".
    if (cleaned.isNotEmpty && cleaned.length <= 40 && !t.contains('?')) {
      return cleaned;
    }

    return null;
  }

  // Chat Methods
  Future<void> initChat() async {
    await _conversationManager.init();

    // Check if we already have a generated plan locally
    final savedPlan = await _conversationManager.getSavedPlan();
    if (savedPlan != null) {
      _tempUserConfig = UserConfig.fromMap(savedPlan);
    }

    if (chatMessages.isEmpty) {
      _conversationManager.addMessage(
        ChatMessage(
          text:
              "I will build a personalized plan to take care of your health and fitness concerns.\n\nWhat's on your mind today?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } else if (_conversationManager.state != ConversationState.done) {
      _resumeConversation();
    }
    notifyListeners();
  }

  void _resumeConversation() {
    _conversationManager.addMessage(
      ChatMessage(
        text:
            "Welcome back! Let's continue building your plan. What else can you tell me about your daily routine?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> sendChatMessage(String text) async {
    if (text.trim().isEmpty) return;

    if (extractedData.goal == null) {
      final inferredGoal = _inferGoalFromText(text);
      if (inferredGoal != null) {
        applyLocalExtraction({"goal": inferredGoal});
      }
    }

    final processedText = text.length > 1000
        ? "${text.substring(0, 1000)}... [truncated]"
        : text;

    final userMessage = ChatMessage(
      text: processedText,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _conversationManager.addMessage(userMessage);

    _isChatLoading = true;
    _loadingMessage = "Thinking...";
    _chatError = null;
    notifyListeners();

    if (chatMessages.length > 10 && _conversationManager.summary == null) {
      _summarizeHistory();
    }

    if (_conversationManager.isReadyForPlan() && _tempUserConfig == null) {
      // Don't await this, let it run in background so AI can still reply
      generatePlanFromChat().catchError(
        (e) => print("Background generation failed: $e"),
      );
    }

    try {
      final response = await _aiService.getResponse(
        history: _conversationManager.getContextForAI(limit: 6),
        currentData: extractedData.toJson(),
        extractionStatus: extractedData.getExtractionStatus(),
      );

      final aiMessage = ChatMessage(
        text: response.text,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _conversationManager.addMessage(aiMessage);

      if (response.extractedData != null) {
        print("🔄 [PROVIDER] EXTRACTED DATA FROM AI: ${response.extractedData}");
        _conversationManager.updateUserData(response.extractedData!);
        print("✅ [PROVIDER] NOTIFYING LISTENERS - TRACKER SHOULD UPDATE");
        notifyListeners();
      }

      if (_conversationManager.isReadyForPlan()) {
        await generatePlanFromChat();
      }
    } catch (e) {
      _chatError = "Oops! I hit a snag. Let me try that again.";
    } finally {
      _isChatLoading = false;
      notifyListeners();
    }
  }

  Future<void> _summarizeHistory() async {
    try {
      final summary = await _aiService.generateSummary(
        _conversationManager.getContextForAI(limit: 10),
      );
      if (summary != null) {
        _conversationManager.setSummary(summary);
      }
    } catch (e) {
      debugPrint("Summarization failed: $e");
    }
  }

  Future<void> generatePlanFromChat() async {
    print("🏗️ [FITLY_AI] STARTING PLAN GENERATION...");
    print("📋 [PLAN_GEN] DATA USED FOR PLAN GENERATION:");
    print("   Goal: ${extractedData.goal}");
    print("   Age: ${extractedData.age}");
    print("   Gender: ${extractedData.gender}");
    print("   Weight: ${extractedData.weight}");
    print("   Height: ${extractedData.height}");
    print("   Lifestyle: ${extractedData.lifestyle}");
    print("   Current Situation: ${extractedData.currentSituation}");
    print("   Schedule: ${extractedData.schedule}");
    print("   Intensity: ${extractedData.intensity}");
    print("   Mental Health Concerns: ${extractedData.mentalHealthConcerns}");
    print("   Stress Level: ${extractedData.stressLevel}");
    print("   Sleep Quality: ${extractedData.sleepQuality}");
    print("   Health Issues: ${extractedData.healthIssues}");
    print("   Full Extracted Data: ${extractedData.toJson()}");
    
    _isChatLoading = true;
    _loadingMessage = "Creating your perfect plan...";
    _conversationManager.updateState(ConversationState.generating);
    _conversationManager.addMessage(
      ChatMessage(
        text:
            "I have everything I need! 📝 Hang tight for a few seconds while I craft your personalized plan...",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();

    try {
      final config = await _aiService.generatePlan(extractedData);
      print("✅ [PLAN_GEN] PLAN GENERATED SUCCESSFULLY!");
      print("   Goal Title: ${config.goalTitle}");
      print("   Goal Type: ${config.goalType}");
      print("   Target Description: ${config.targetDescription}");
      print("   User Age: ${config.age}");
      print("   User Gender: ${config.gender}");
      print("   User Weight: ${config.weight}");
      print("   User Height: ${config.height}");
      print("   Fitness Goal: ${config.fitnessGoal}");
      print("   Activity Level: ${config.activityLevel}");
      _tempUserConfig = config;

      await _conversationManager.savePlanLocally(config.toMap());
      _conversationManager.updateState(ConversationState.done);
    } catch (e) {
      _chatError = "Failed to generate your plan. Let's talk a bit more.";
      _conversationManager.updateState(ConversationState.collecting);
    } finally {
      _isChatLoading = false;
      notifyListeners();
    }
  }

  Future<bool> savePlanToFirebase(String userId) async {
    if (_tempUserConfig == null) return false;

    try {
      _isLoading = true;
      _loadingMessage = "Saving your plan...";
      notifyListeners();

      await _userProvider.loadUserProfile(userId);
      final bool success = await _userProvider.createUserConfig(
        _tempUserConfig!,
      );

      if (success) {
        await _conversationManager.reset();
        _tempUserConfig = null;
      }
      return success;
    } catch (e) {
      _errorMessage = "Failed to save plan to cloud: ${e.toString()}";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetChat() async {
    await _conversationManager.reset();
    _tempUserConfig = null;
    notifyListeners();
  }

  void resetAllData() {
    print("🔄 [PROVIDER] RESETTING ALL DATA");
    _conversationManager.resetUserData();
    _tempUserConfig = null;
    _isChatLoading = false;
    _chatError = null;
    notifyListeners();
    print("✅ [PROVIDER] ALL DATA RESET COMPLETE");
  }

  void clearError() {
    _errorMessage = null;
    _chatError = null;
    notifyListeners();
  }
}
