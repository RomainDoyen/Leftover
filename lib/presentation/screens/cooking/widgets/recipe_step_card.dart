import 'package:flutter/material.dart';
import '../../../../domain/entities/recipe.dart';
import '../../../theme/app_colors.dart';

class RecipeStepCard extends StatelessWidget {
  final RecipeStep step;
  final bool isActive;

  const RecipeStepCard({super.key, required this.step, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                )
              ],
        border: isActive
            ? Border.all(
                color: AppColors.primary.withValues(alpha: 0.2), width: 1.5)
            : null,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -8,
            right: -8,
            child: Text(
              '${step.order}',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 72,
                height: 1,
                color: AppColors.surfaceContainerHigh
                    .withValues(alpha: isActive ? 0.5 : 0.9),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.title,
                style: TextStyle(
                  color: isActive ? AppColors.primary : AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                step.description,
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  height: 1.6,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.timer_outlined,
                      size: 16, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    '${step.durationMinutes} min',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
