import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../services/api/ai_config.dart';
import '../../services/api/ai_service.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/chat/chat_message_bubble.dart';
import '../../widgets/chat/typing_indicator.dart';
import '../../widgets/chat/quick_suggestion_chips.dart';
import '../../widgets/chat/compact_data_tracker.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late stt.SpeechToText _speech;
  bool _isSpeaking = false;
  late AnimationController _pulseController;
  int _voiceWordCount = 0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Initialize chat session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OnboardingProvider>().initChat();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _toggleVoiceInput() async {
    if (_isSpeaking) {
      // Stop recording
      await _stopVoiceInput();
    } else {
      // Start recording
      await _startVoiceInput();
    }
  }

  Future<void> _startVoiceInput() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) return;

    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isSpeaking = true;
        _voiceWordCount = 0;
        _messageController.clear();
      });
      _speech.listen(
        onResult: (result) {
          setState(() {
            _messageController.text = result.recognizedWords;
            
            // Count words and auto-stop after 6 words
            final wordCount = result.recognizedWords.trim().split(RegExp(r'\s+')).length;
            _voiceWordCount = wordCount;
            
            if (wordCount >= 6 && result.finalResult) {
              _stopVoiceInput();
            }
          });
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(milliseconds: 500),
      );
    }
  }

  Future<void> _stopVoiceInput() async {
    await _speech.stop();
    setState(() => _isSpeaking = false);
    if (_messageController.text.isNotEmpty) {
      _sendMessage();
    }
  }

  void _sendMessage() async {
    final text = _messageController.text;
    if (text.trim().isEmpty) return;

    final provider = context.read<OnboardingProvider>();
    
    // Add user message to chat
    provider.addMessage(
      text: text,
      isUser: true,
    );
    _messageController.clear();
    _scrollToBottom();
    
    // STEP 1: Collect Goal + Description first
    if (provider.extractedData.goal == null) {
      print("🎯 [CHAT_SCREEN] STEP 1: Collecting Goal + Description");
      print("📝 [CHAT_SCREEN] USER INPUT: $text");
      
      try {
        final aiService = AiService();
        final response = await aiService.getResponse(
          history: [
            {"role": "user", "content": text}
          ],
          currentData: provider.extractedData.toJson(),
          extractionStatus: {},
          customSystemPrompt: AiConfig.extractGoalPrompt,
        );
        
        print("✅ [CHAT_SCREEN] AI RESPONSE: ${response.text}");
        print("📊 [CHAT_SCREEN] EXTRACTED DATA: ${response.extractedData}");
        
        // Save goal and description
        if (response.extractedData != null) {
          provider.extractedData.updateField('goal', response.extractedData!['goal']);
          provider.extractedData.updateField('goalDescription', response.extractedData!['goalDescription']);
          print("💾 [CHAT_SCREEN] Goal and Description saved");
        }
        
        // Add AI response to chat
        provider.addMessage(
          text: response.text,
          isUser: false,
        );
        _scrollToBottom();
        
        // Show dynamic prompt asking for all missing fields
        final dynamicPrompt = _generateDynamicPrompt(provider);
        provider.addMessage(
          text: dynamicPrompt,
          isUser: false,
        );
        _scrollToBottom();
      } catch (e) {
        print("❌ [CHAT_SCREEN] ERROR: $e");
        provider.addMessage(
          text: "Sorry, I had trouble processing that. Could you try again?",
          isUser: false,
        );
      }
      return;
    }
    
    // STEP 2: Collect other fields one-by-one based on goal
    print("📋 [CHAT_SCREEN] STEP 2: Collecting fields based on goal");
    final nextField = provider.extractedData.getNextFieldWithPrompt();
    
    if (nextField['isCollected']) {
      print("✅ [CHAT_SCREEN] All fields collected!");
      provider.addMessage(
        text: "Great! I've collected all the information I need. Let me create your personalized plan...",
        isUser: false,
      );
      _scrollToBottom();
      return;
    }
    
    print("🔍 [CHAT_SCREEN] Next field: ${nextField['fieldName']} (${nextField['fieldKey']})");
    print("📝 [CHAT_SCREEN] USER INPUT: $text");
    
    try {
      final aiService = AiService();
      
      // Get the prompt based on field type
      final promptName = nextField['prompt'] as String;
      final prompt = _getPromptByName(promptName);
      
      final response = await aiService.getResponse(
        history: [
          {"role": "user", "content": text}
        ],
        currentData: provider.extractedData.toJson(),
        extractionStatus: {},
        customSystemPrompt: prompt,
      );
      
      print("✅ [CHAT_SCREEN] AI RESPONSE: ${response.text}");
      print("📊 [CHAT_SCREEN] EXTRACTED DATA: ${response.extractedData}");
      
      // Save the field data
      if (response.extractedData != null) {
        response.extractedData!.forEach((key, value) {
          provider.extractedData.updateField(key, value);
        });
        print("💾 [CHAT_SCREEN] Field ${nextField['fieldName']} saved");
      }
      
      // Add AI response to chat
      provider.addMessage(
        text: response.text,
        isUser: false,
      );
      _scrollToBottom();
      
      // Show dynamic prompt asking for remaining missing fields
      final dynamicPrompt = _generateDynamicPrompt(provider);
      provider.addMessage(
        text: dynamicPrompt,
        isUser: false,
      );
      _scrollToBottom();
    } catch (e) {
      print("❌ [CHAT_SCREEN] ERROR: $e");
      provider.addMessage(
        text: "Sorry, I had trouble processing that. Could you try again?",
        isUser: false,
      );
    }
  }
  
  String _generateDynamicPrompt(OnboardingProvider provider) {
    final goalLower = provider.extractedData.goal?.toLowerCase() ?? '';
    final missingFieldsList = <String>[];
    
    // Weight Loss / Muscle Gain
    if (goalLower.contains('weight') || goalLower.contains('muscle') || 
        goalLower.contains('lose') || goalLower.contains('gain') ||
        goalLower.contains('bulk') || goalLower.contains('strength')) {
      if (provider.extractedData.age == null) missingFieldsList.add('age');
      if (provider.extractedData.gender == null) missingFieldsList.add('gender');
      if (provider.extractedData.weight == null) missingFieldsList.add('weight (in kg)');
      if (provider.extractedData.height == null) missingFieldsList.add('height (in cm)');
      if (provider.extractedData.lifestyle == null) missingFieldsList.add('lifestyle');
      if (provider.extractedData.intensity == null) missingFieldsList.add('preferred workout intensity');
    }
    // Mental Health
    else if (goalLower.contains('mental') || goalLower.contains('stress') || 
             goalLower.contains('anxiety') || goalLower.contains('depression')) {
      if (provider.extractedData.age == null) missingFieldsList.add('age');
      if (provider.extractedData.gender == null) missingFieldsList.add('gender');
      if (provider.extractedData.mentalHealthConcerns == null) missingFieldsList.add('mental health concerns');
      if (provider.extractedData.sleepQuality == null) missingFieldsList.add('sleep quality');
    }
    // Sleep Better
    else if (goalLower.contains('sleep') || goalLower.contains('rest')) {
      if (provider.extractedData.age == null) missingFieldsList.add('age');
      if (provider.extractedData.gender == null) missingFieldsList.add('gender');
      if (provider.extractedData.sleepQuality == null) missingFieldsList.add('sleep quality');
      if (provider.extractedData.schedule == null) missingFieldsList.add('daily schedule');
    }
    // Nutrition
    else if (goalLower.contains('nutrition') || goalLower.contains('diet')) {
      if (provider.extractedData.age == null) missingFieldsList.add('age');
      if (provider.extractedData.gender == null) missingFieldsList.add('gender');
      if (provider.extractedData.weight == null) missingFieldsList.add('weight (in kg)');
      if (provider.extractedData.height == null) missingFieldsList.add('height (in cm)');
      if (provider.extractedData.currentSituation == null) missingFieldsList.add('current diet habits');
    }
    
    if (missingFieldsList.isEmpty) {
      return "Perfect! I have all the information I need. Let me create your personalized plan...";
    }
    
    if (missingFieldsList.length == 1) {
      return "To help you better, could you please share your ${missingFieldsList[0]}?";
    }
    
    final fieldList = missingFieldsList.join(", ");
    return "To create the best plan for you, I need to know your $fieldList. Could you share these details?";
  }

  String _getPromptByName(String promptName) {
    switch (promptName) {
      case 'extractGoalPrompt':
        return AiConfig.extractGoalPrompt;
      case 'extractPersonalDataPrompt':
        return AiConfig.extractPersonalDataPrompt;
      case 'extractPhysicalDataPrompt':
        return AiConfig.extractPhysicalDataPrompt;
      case 'extractLifestylePrompt':
        return AiConfig.extractLifestylePrompt;
      case 'extractFitnessLevelPrompt':
        return AiConfig.extractFitnessLevelPrompt;
      default:
        return AiConfig.extractPersonalDataPrompt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        // Auto-scroll on new messages
        if (provider.chatMessages.isNotEmpty) {
          _scrollToBottom();
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(provider),
                _buildCollectedInfoTracker(provider),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount:
                        provider.chatMessages.length +
                        (provider.isChatLoading ? 1 : 0) +
                        1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 40, bottom: 20),
                          child: _buildWelcomeHero(),
                        );
                      }

                      final messageIndex = index - 1;
                      if (messageIndex < provider.chatMessages.length) {
                        return ChatMessageBubble(
                          message: provider.chatMessages[messageIndex],
                        );
                      } else {
                        return const TypingIndicator();
                      }
                    },
                  ),
                ),
                // Show suggestions initially or after first AI message
                if ((provider.chatMessages.isEmpty ||
                        (provider.chatMessages.length == 1 &&
                            !provider.chatMessages[0].isUser)) &&
                    !provider.isChatLoading)
                  QuickSuggestionChips(
                    suggestions: const [
                      "Weight Loss ⚖️",
                      "Depression/Stress 🧘",
                      "Muscle Gain 💪",
                      "Sleep Better 😴",
                      "Healthy Diet 🥗",
                    ],
                    onSelected: (text) {
                      final provider = context.read<OnboardingProvider>();
                      final normalized = text
                          .replaceAll(RegExp(r'[\u{1F300}-\u{1FAFF}]', unicode: true), '')
                          .replaceAll(RegExp(r'[^A-Za-z0-9\s/\-]'), '')
                          .replaceAll(RegExp(r'\s+'), ' ')
                          .trim();
                      provider.applyLocalExtraction({"goal": normalized});
                      _messageController.text = text;
                      _sendMessage();
                    },
                  ),
                _buildInputArea(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeHero() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 1),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Text(
              "Hi, I am Fitly 👋",
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary.withOpacity(0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1200),
            curve: Curves.elasticOut,
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.5 + (0.5 * value),
                  child: child,
                ),
              );
            },
            child: Text(
              "Tell Me\nYour Story",
              textAlign: TextAlign.center,
              style: AppTextStyles.h1.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 48,
                height: 1.0,
                letterSpacing: -2,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader(OnboardingProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () {
              // Basic exit handling
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Exit Chat?"),
                  content: const Text(
                    "Your progress is saved! You can come back and finish your plan anytime.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Stay"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text("Save & Exit"),
                    ),
                  ],
                ),
              );
            },
          ),
          const CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Text(
              'F',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Fitly AI Coach", style: AppTextStyles.h4),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Online",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: "Reset all data",
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Reset All Data?"),
                  content: const Text(
                    "This will clear all collected information. Are you sure?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        provider.resetAllData();
                        Navigator.pop(context);
                        print("🔄 [CHAT_SCREEN] ALL DATA RESET");
                      },
                      child: const Text(
                        "Reset",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (provider.userConfig != null)
            TextButton(
              onPressed: () {
                print("👁️ [SEE_PLAN_BUTTON] CLICKED");
                print("   Has Plan: ${provider.userConfig != null}");
                print("   Plan Name: ${provider.userConfig?.goalTitle ?? 'N/A'}");
                print("   Plan Type: ${provider.userConfig?.goalType ?? 'N/A'}");
                print("   User Age: ${provider.userConfig?.age ?? 'N/A'}");
                print("   User Weight: ${provider.userConfig?.weight ?? 'N/A'}");
                print("   User Height: ${provider.userConfig?.height ?? 'N/A'}");
                print("   Fitness Goal: ${provider.userConfig?.fitnessGoal ?? 'N/A'}");
                Navigator.pushNamed(context, '/plan-summary');
              },
              child: const Text(
                "See Plan 🚀",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCollectedInfoTracker(OnboardingProvider provider) {
    // Only show tracker after user provides first message
    final hasUserMessage = provider.chatMessages.any((msg) => msg.isUser);
    
    if (!hasUserMessage) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Force rebuild by using a unique key based on extracted data
        CompactDataTracker(
          key: ValueKey(provider.extractedData.toJson().toString()),
          extractedData: provider.extractedData,
        ),
        if (kDebugMode)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.amber.withOpacity(0.3), width: 0.5),
              ),
              child: Text(
                "Cost: \$${provider.totalCost.toStringAsFixed(4)}",
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInputArea() {
    return Column(
      children: [
        if (_isSpeaking)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Listening... $_voiceWordCount/6 words",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (_voiceWordCount >= 6)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "Auto-stopping...",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF10B981),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: _isSpeaking ? "Recording..." : "Talk to Fitly...",
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _toggleVoiceInput,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isSpeaking ? Colors.red : AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: _isSpeaking
                            ? [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.4),
                                  blurRadius: 10 * _pulseController.value,
                                  spreadRadius: 5 * _pulseController.value,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        _isSpeaking ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: AppColors.primary),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
