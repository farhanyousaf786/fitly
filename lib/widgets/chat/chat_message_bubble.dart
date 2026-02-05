import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../models/chat_message.dart';
import 'package:intl/intl.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[_buildAvatar('🤖'), const SizedBox(width: 8)],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primary : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isUser ? Colors.white : AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm').format(message.timestamp),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary.withOpacity(0.6),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[const SizedBox(width: 8), _buildAvatar('👤')],
        ],
      ),
    );
  }

  Widget _buildAvatar(String icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(icon, style: const TextStyle(fontSize: 18)),
    );
  }
}
