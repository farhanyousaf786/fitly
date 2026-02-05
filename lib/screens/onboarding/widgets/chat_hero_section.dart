import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import 'voice_button.dart';

class ChatHeroSection extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onVoiceTap;
  final AnimationController pulseController;

  const ChatHeroSection({
    super.key,
    required this.isRecording,
    required this.onVoiceTap,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // AI Icon
          _buildAiIcon(),

          const SizedBox(height: 32),

          // Catchy Headline
          Text(
            'Tell Me Your Story',
            style: AppTextStyles.h1.copyWith(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Text(
            'Share your fitness goals, lifestyle, and dreams.\nI\'ll create a personalized plan just for you.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 48),

          // Big Voice Button
          VoiceButton(
            isRecording: isRecording,
            onTap: onVoiceTap,
            size: 160,
            pulseController: pulseController,
          ),

          const SizedBox(height: 24),

          Text(
            isRecording ? 'Listening...' : 'Tap to speak',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 48),

          // Or divider
          _buildDivider(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAiIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(
        Icons.psychology_rounded,
        color: Colors.white,
        size: 50,
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(color: AppColors.textSecondary.withOpacity(0.3)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or type below',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: AppColors.textSecondary.withOpacity(0.3)),
        ),
      ],
    );
  }
}
