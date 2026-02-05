import 'package:flutter/foundation.dart';
import '../models/user_config.dart';
import '../models/chat_message.dart';
import '../models/extracted_user_data.dart';
import '../providers/user_provider.dart';
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

  // Getters
  bool get isLoading => _isLoading || _isChatLoading;
  String? get errorMessage => _errorMessage ?? _chatError;
  bool get isChatLoading => _isChatLoading;
  String? get chatError => _chatError;
  UserConfig? get userConfig => _tempUserConfig;
  List<ChatMessage> get chatMessages => _conversationManager.messages;
  ExtractedUserData get extractedData => _conversationManager.userData;

  // Chat Methods
  Future<void> initChat() async {
    await _conversationManager.init();
    if (chatMessages.isEmpty) {
      _conversationManager.addMessage(
        ChatMessage(
          text:
              "Hi! I'm Fitly, your AI health coach 👋. I'm excited to help you reach your goals! What's on your mind today? Do you want to lose weight, build muscle, or just feel more energetic?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    }
    notifyListeners();
  }

  Future<void> sendChatMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _conversationManager.addMessage(userMessage);

    _isChatLoading = true;
    _chatError = null;
    notifyListeners();

    if (chatMessages.length >= 15) {
      _chatError = "I have enough info for now! Let's generate your plan.";
      notifyListeners();
      await generatePlanFromChat();
      return;
    }

    try {
      final response = await _aiService.getResponse(
        history: _conversationManager.getCompactHistory(10),
        currentData: extractedData.toJson(),
      );

      final aiMessage = ChatMessage(
        text: response.text,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _conversationManager.addMessage(aiMessage);

      if (response.extractedData != null) {
        _conversationManager.updateUserData(response.extractedData!);
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

  Future<void> generatePlanFromChat() async {
    _isChatLoading = true;
    notifyListeners();

    try {
      final config = await _aiService.generatePlan(extractedData);
      _tempUserConfig = config;

      // Save to SharedPreferences as backup
      await _conversationManager.savePlanLocally(config.toMap());
    } catch (e) {
      _chatError = "Failed to generate your plan. Let's talk a bit more.";
    } finally {
      _isChatLoading = false;
      notifyListeners();
    }
  }

  void resetChat() {
    _conversationManager.reset();
    _tempUserConfig = null;
    notifyListeners();
  }

  int get infoCollectedCount {
    int count = 0;
    final data = extractedData.data;
    if (data['goal'] != null) count++;
    if (data['currentSituation'] != null) count++;
    if (data['lifestyle'] != null) count++;
    if (data['schedule'] != null) count++;
    if (data['age'] != null || data['gender'] != null) count++;
    if (data['weight'] != null || data['height'] != null) count++;
    return count;
  }

  Future<bool> completeOnboarding() async {
    if (_tempUserConfig == null) return false;
    try {
      _isLoading = true;
      notifyListeners();
      final success = await _userProvider.createUserConfig(_tempUserConfig!);
      if (success) {
        resetChat();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to complete onboarding: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void saveTempConfig(UserConfig config) {
    _tempUserConfig = config;
    notifyListeners();
  }

  void clearTempConfig() {
    _tempUserConfig = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _chatError = null;
    notifyListeners();
  }
}
