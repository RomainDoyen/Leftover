// lib/presentation/screens/home/widgets/ingredient_chip.dart
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class IngredientChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const IngredientChip({
    super.key,
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRemove,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.secondaryContainer,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.close, size: 16, color: AppColors.onSecondaryContainer),
          ],
        ),
      ),
    );
  }
}
