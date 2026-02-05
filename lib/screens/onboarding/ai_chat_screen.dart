import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/chat/chat_message_bubble.dart';
import '../../widgets/chat/typing_indicator.dart';
import '../../widgets/chat/quick_suggestion_chips.dart';

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

  Future<void> _handleVoiceInput() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) return;

    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isSpeaking = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _messageController.text = result.recognizedWords;
          });
        },
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

  void _sendMessage() {
    final text = _messageController.text;
    if (text.trim().isEmpty) return;

    context.read<OnboardingProvider>().sendChatMessage(text);
    _messageController.clear();
    _scrollToBottom();
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
                    padding: const EdgeInsets.all(20),
                    itemCount:
                        provider.chatMessages.length +
                        (provider.isChatLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < provider.chatMessages.length) {
                        return ChatMessageBubble(
                          message: provider.chatMessages[index],
                        );
                      } else {
                        return const TypingIndicator();
                      }
                    },
                  ),
                ),
                if (provider.chatMessages.length == 1 &&
                    !provider.isChatLoading)
                  QuickSuggestionChips(
                    suggestions: const [
                      "Lose belly fat",
                      "Build muscle",
                      "Get healthier",
                      "Better sleep",
                      "More energy",
                    ],
                    onSelected: (text) {
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
          if (provider.userConfig != null)
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/plan-summary'),
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
    final count = provider.infoCollectedCount;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Collected Info: $count/6",
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                width: 100,
                child: LinearProgressIndicator(
                  value: count / 6,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
          if (count >= 1) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildInfoTag("✓ Goal"),
                if (provider.extractedData.currentSituation != null)
                  _buildInfoTag("✓ Habits"),
                if (provider.extractedData.lifestyle != null)
                  _buildInfoTag("✓ Lifestyle"),
                if (provider.extractedData.schedule != null)
                  _buildInfoTag("✓ Schedule"),
                if (provider.extractedData.age != null)
                  _buildInfoTag("✓ Stats"),
                if (provider.extractedData.healthIssues != null)
                  _buildInfoTag("✓ Health"),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, color: AppColors.primary),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
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
                decoration: const InputDecoration(
                  hintText: "Talk to Fitly...",
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onLongPress: _handleVoiceInput,
            onLongPressUp: _stopVoiceInput,
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
    );
  }
}
