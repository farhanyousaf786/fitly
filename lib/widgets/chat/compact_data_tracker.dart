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
    final requiredFields = extractedData.getRequiredFields();
    final optionalFields = extractedData.getOptionalFields();
    final isReadyForPlan = extractedData.hasRequiredInfo();

    // Get collected and needed required fields
    final collectedRequired = requiredFields.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    final neededRequired = requiredFields.entries
        .where((e) => !e.value)
        .map((e) => e.key)
        .toList();

    // Get collected and needed optional fields
    final collectedOptional = optionalFields.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    final neededOptional = optionalFields.entries
        .where((e) => !e.value)
        .map((e) => e.key)
        .toList();

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
          // Row 1: Required Fields
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '⭐ Required',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${collectedRequired.length}/${requiredFields.length}',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: neededRequired.isEmpty
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    ...collectedRequired.map((field) => _buildFieldTag(
                          field,
                          isCollected: true,
                        )),
                    ...neededRequired.map((field) => _buildFieldTag(
                          field,
                          isCollected: false,
                          isRequired: true,
                        )),
                  ],
                ),
              ],
            ),
          ),

          // Divider
          Container(
            height: 0.5,
            color: AppColors.textSecondary.withOpacity(0.1),
          ),

          // Row 2: Optional Fields + Status
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '✨ Optional',
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
                          '${collectedOptional.length}/${optionalFields.length}',
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
                            isReadyForPlan ? '✓ Ready' : 'Building',
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
                if (collectedOptional.isNotEmpty || neededOptional.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        ...collectedOptional.map((field) => _buildFieldTag(
                              field,
                              isCollected: true,
                            )),
                        ...neededOptional.map((field) => _buildFieldTag(
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
