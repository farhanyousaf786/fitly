import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/common/custom_button.dart';

class PlanSummaryScreen extends StatelessWidget {
  const PlanSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<OnboardingProvider>(
        builder: (context, provider, child) {
          if (provider.userConfig == null) {
            return const Center(child: Text('No plan generated yet'));
          }

          final config = provider.userConfig!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Success icon
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 50,
                      color: AppColors.success,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                Text(
                  'Your Plan is Ready!',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  'Here\'s what we created just for you',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Goal Card
                _buildGoalCard(config),

                const SizedBox(height: 24),

                // Diet Preview
                _buildSectionTitle('Your Diet Plan'),
                const SizedBox(height: 12),
                _buildDietPreview(config),

                const SizedBox(height: 24),

                // Exercise Preview
                _buildSectionTitle('Your Workout Plan'),
                const SizedBox(height: 12),
                _buildExercisePreview(config),

                const SizedBox(height: 32),

                // CTA Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.primary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        size: 40,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Sign up to save your plan!',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create an account to access your personalized plan, track progress, and achieve your goals',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Signup button
                CustomButton(
                  text: 'Create Account',
                  onPressed: () {
                    Navigator.of(context).pushNamed('/signup');
                  },
                  fullWidth: true,
                ),

                const SizedBox(height: 12),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/login');
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Sign In',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGoalCard(dynamic config) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Your Goal',
                style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            config.goalTitle ?? 'Fitness Goal',
            style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            config.targetDescription ?? 'Achieve your fitness goals',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
    );
  }

  Widget _buildDietPreview(dynamic config) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPreviewItem(Icons.restaurant, 'Personalized meal plan'),
          const SizedBox(height: 12),
          _buildPreviewItem(Icons.schedule, 'Meal timing optimized for you'),
          const SizedBox(height: 12),
          _buildPreviewItem(
            Icons.lightbulb_outline,
            'Nutrition tips & recipes',
          ),
        ],
      ),
    );
  }

  Widget _buildExercisePreview(dynamic config) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPreviewItem(Icons.fitness_center, 'Custom workout routine'),
          const SizedBox(height: 12),
          _buildPreviewItem(
            Icons.play_circle_outline,
            'Exercise videos & guides',
          ),
          const SizedBox(height: 12),
          _buildPreviewItem(Icons.trending_up, 'Progressive difficulty'),
        ],
      ),
    );
  }

  Widget _buildPreviewItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const Icon(Icons.check_circle, size: 20, color: AppColors.success),
      ],
    );
  }
}
