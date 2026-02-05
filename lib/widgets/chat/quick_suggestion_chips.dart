import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';

class QuickSuggestionChips extends StatelessWidget {
  final List<String> suggestions;
  final Function(String) onSelected;

  const QuickSuggestionChips({
    super.key,
    required this.suggestions,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(suggestion),
              onPressed: () => onSelected(suggestion),
              backgroundColor: Colors.white,
              labelStyle: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
              ),
              elevation: 0,
              pressElevation: 2,
            ),
          );
        },
      ),
    );
  }
}
