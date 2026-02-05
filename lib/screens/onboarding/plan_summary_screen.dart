import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../models/user_config.dart';
import '../../models/meal.dart';
import '../../models/exercise.dart';
import '../../models/mental_health_practice.dart';
import '../../models/reminder.dart';

class PlanSummaryScreen extends StatelessWidget {
  const PlanSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        final config = provider.userConfig;

        if (config == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context, config),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildGoalCard(config),
                    const SizedBox(height: 24),
                    if (config.dietPlan != null &&
                        config.dietPlan!.isNotEmpty) ...[
                      _buildSectionHeader("Diet Plan", Icons.restaurant),
                      const SizedBox(height: 12),
                      _buildDietPlan(config.dietPlan!),
                      const SizedBox(height: 24),
                    ],
                    if (config.exercisePlan != null &&
                        config.exercisePlan!.isNotEmpty) ...[
                      _buildSectionHeader(
                        "Exercise Plan",
                        Icons.fitness_center,
                      ),
                      const SizedBox(height: 12),
                      _buildExercisePlan(config.exercisePlan!),
                      const SizedBox(height: 24),
                    ],
                    if (config.mentalHealthPractices != null &&
                        config.mentalHealthPractices!.isNotEmpty) ...[
                      _buildSectionHeader(
                        "Mindfulness",
                        Icons.self_improvement,
                      ),
                      const SizedBox(height: 12),
                      _buildMentalHealthPlan(config.mentalHealthPractices!),
                      const SizedBox(height: 24),
                    ],
                    if (config.sleepSchedule != null) ...[
                      _buildSectionHeader("Sleep Schedule", Icons.bedtime),
                      const SizedBox(height: 12),
                      _buildSleepCard(config.sleepSchedule!),
                      const SizedBox(height: 24),
                    ],
                    if (config.waterGoal != null) ...[
                      _buildSectionHeader("Daily Hydration", Icons.water_drop),
                      const SizedBox(height: 12),
                      _buildWaterCard(config.waterGoal!),
                      const SizedBox(height: 24),
                    ],
                    _buildSectionHeader("Daily Reminders", Icons.notifications),
                    const SizedBox(height: 12),
                    _buildRemindersTimeline(config.reminders),
                    const SizedBox(height: 32),
                    _buildCTA(context),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, UserConfig config) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          "Your Personal Plan",
          style: AppTextStyles.h4.copyWith(color: Colors.white),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      config.goalType.replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    config.goalTitle,
                    style: AppTextStyles.h2.copyWith(color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildGoalCard(UserConfig config) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "The Foundation",
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            config.targetDescription,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    config.motivationalMessage,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietPlan(Map<String, Meal> dietPlan) {
    return Column(
      children: dietPlan.entries.map((entry) {
        final meal = entry.value;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.withOpacity(0.1)),
          ),
          child: ExpansionTile(
            leading: _getMealIcon(entry.key),
            title: Text(meal.name, style: AppTextStyles.h4),
            subtitle: Text(meal.time, style: AppTextStyles.bodySmall),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Recommended",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children: meal.foods
                          .map(
                            (f) => Chip(
                              label: Text(
                                f,
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Colors.green.withOpacity(0.1),
                              side: BorderSide.none,
                            ),
                          )
                          .toList(),
                    ),
                    if (meal.avoid.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        "Avoid",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: meal.avoid
                            .map(
                              (f) => Chip(
                                label: Text(
                                  f,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: Colors.red.withOpacity(0.1),
                                side: BorderSide.none,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(meal.instructions, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExercisePlan(Map<String, List<Exercise>> exercisePlan) {
    return Column(
      children: exercisePlan.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                entry.key.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            ...entry.value.map(
              (ex) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow, color: Colors.orange),
                  ),
                  title: Text(ex.name, style: AppTextStyles.h4),
                  subtitle: Text(
                    "${ex.sets ?? ''} ${ex.reps ?? ''} ${ex.duration ?? ''} • ${ex.difficulty}",
                    style: AppTextStyles.bodySmall,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Show instructions dialog
                  },
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildMentalHealthPlan(List<MentalHealthPractice> practices) {
    return Column(
      children: practices
          .map(
            (p) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.withOpacity(0.1)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getMentalHealthIcon(p.type),
                    color: Colors.purple,
                  ),
                ),
                title: Text(p.name, style: AppTextStyles.h4),
                subtitle: Text(
                  "${p.durationMinutes} min • ${p.time}",
                  style: AppTextStyles.bodySmall,
                ),
                trailing: const Icon(Icons.mic, color: Colors.purple),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSleepCard(Map<String, String> schedule) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTimeInfo(
            "Sleep",
            schedule['target_sleep'] ?? "23:00",
            Icons.nights_stay,
          ),
          Container(height: 40, width: 1, color: Colors.white24),
          _buildTimeInfo(
            "Wake Up",
            schedule['target_wake'] ?? "07:00",
            Icons.wb_sunny,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(String label, String time, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 20),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWaterCard(int amount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade700],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_drink, color: Colors.white, size: 40),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Daily Water Goal",
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
              ),
              Text(
                "$amount Glasses",
                style: AppTextStyles.h3.copyWith(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersTimeline(List<Reminder> reminders) {
    return Column(
      children: reminders
          .map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      r.time,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Icon(Icons.circle, size: 10, color: AppColors.primary),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      ),
                      child: Text(r.title),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCTA(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Ready to start your journey?",
            style: AppTextStyles.h3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "Create an account to save your personalized plan and start tracking your progress today.",
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: "Create Account & Start 🚀",
            fullWidth: true,
            onPressed: () {
              Navigator.pushNamed(context, '/signup');
            },
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            child: RichText(
              text: TextSpan(
                text: "Already have an account? ",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                children: [
                  TextSpan(
                    text: "Login",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getMealIcon(String mealType) {
    final type = mealType.toLowerCase();
    IconData icon;
    Color color;

    if (type.contains('breakfast')) {
      icon = Icons.wb_twilight;
      color = Colors.orange;
    } else if (type.contains('lunch')) {
      icon = Icons.wb_sunny;
      color = Colors.blue;
    } else if (type.contains('dinner')) {
      icon = Icons.nights_stay;
      color = Colors.indigo;
    } else {
      icon = Icons.apple;
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  IconData _getMentalHealthIcon(String type) {
    switch (type.toLowerCase()) {
      case 'meditation':
        return Icons.spa;
      case 'journaling':
        return Icons.edit_note;
      case 'breathing':
        return Icons.air;
      default:
        return Icons.self_improvement;
    }
  }
}
