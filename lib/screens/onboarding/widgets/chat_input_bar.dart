import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import 'voice_button.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isRecording;
  final VoidCallback onVoiceTap;
  final Function(String) onSend;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.isRecording,
    required this.onVoiceTap,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Voice button
          VoiceButton(isRecording: isRecording, onTap: onVoiceTap, size: 56),

          const SizedBox(width: 12),

          // Text input
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(28),
              ),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: onSend,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Send button
          GestureDetector(
            onTap: () => onSend(controller.text),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
