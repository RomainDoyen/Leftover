import 'package:flutter/material.dart';
import '../../../../domain/entities/ingredient.dart';
import '../../../theme/app_colors.dart';

class IngredientListItem extends StatelessWidget {
  final Ingredient ingredient;
  final bool owned;
  final VoidCallback? onAddToList;

  const IngredientListItem({
    super.key,
    required this.ingredient,
    required this.owned,
    this.onAddToList,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: owned
            ? null
            : Border(
                left: const BorderSide(color: AppColors.primary, width: 4),
                right: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                top: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                bottom: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.4)),
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: owned
                  ? AppColors.secondaryContainer
                  : AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              owned ? Icons.check_circle : Icons.add,
              color: owned
                  ? AppColors.onSecondaryContainer
                  : AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredient.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.onSurface),
                ),
                if (!owned && ingredient.amount.isNotEmpty)
                  Text(
                    ingredient.amount,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          if (!owned && onAddToList != null)
            GestureDetector(
              onTap: onAddToList,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text(
                  'Ajouter',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
