import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../models/extracted_user_data.dart';

class CompactDataTracker extends StatelessWidget {
  final ExtractedUserData extractedData;

  const CompactDataTracker({
    required this.extractedData,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final collectedFields = extractedData.getCollectedFields();
    final isReadyForPlan = extractedData.hasRequiredInfo();

    // Log tracker UI state
    print("🎨 [TRACKER_UI] DISPLAY STATE:");
    print("   Extracted Data Object: $extractedData");
    print("   Extracted Data Map: ${extractedData.toJson()}");
    print("   Collected Fields: $collectedFields");
    print("   Is Ready For Plan: $isReadyForPlan");
    print("   Goal: ${extractedData.goal}");
    print("   Age: ${extractedData.age}");
    print("   Gender: ${extractedData.gender}");
    print("   Weight: ${extractedData.weight}");
    print("   Height: ${extractedData.height}");
    print("   Lifestyle: ${extractedData.lifestyle}");

    // Get collected and needed fields
    final collected = collectedFields.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    final needed = collectedFields.entries
        .where((e) => !e.value)
        .map((e) => e.key)
        .toList();
    
    print("   Collected Fields: $collected");
    print("   Needed Fields: $needed");

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isReadyForPlan
            ? const Color(0xFF10B981).withOpacity(0.08)
            : AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isReadyForPlan
              ? const Color(0xFF10B981).withOpacity(0.2)
              : AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Collected Fields
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '📊 Collected Data',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${collected.length}/${collectedFields.length}',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF3B82F6),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isReadyForPlan
                                ? const Color(0xFF10B981).withOpacity(0.15)
                                : const Color(0xFFF59E0B).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            isReadyForPlan ? '✓ Ready' : 'Collecting',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isReadyForPlan
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (collected.isNotEmpty || needed.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        ...collected.map((field) => _buildFieldTag(
                              field,
                              isCollected: true,
                            )),
                        ...needed.map((field) => _buildFieldTag(
                              field,
                              isCollected: false,
                            )),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldTag(
    String fieldName, {
    required bool isCollected,
    bool isRequired = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isCollected
            ? const Color(0xFF10B981).withOpacity(0.15)
            : isRequired
                ? const Color(0xFFEF4444).withOpacity(0.1)
                : AppColors.textSecondary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isCollected
              ? const Color(0xFF10B981).withOpacity(0.3)
              : isRequired
                  ? const Color(0xFFEF4444).withOpacity(0.2)
                  : AppColors.textSecondary.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: Text(
        '${isCollected ? '✓' : '○'} $fieldName',
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: 9,
          fontWeight: isCollected ? FontWeight.w600 : FontWeight.w500,
          color: isCollected
              ? const Color(0xFF10B981)
              : isRequired
                  ? const Color(0xFFEF4444).withOpacity(0.7)
                  : AppColors.textSecondary.withOpacity(0.6),
        ),
      ),
    );
  }
}
