import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Stars for a lesson's best score: 3 for a perfect run, 2 for at least 80% of the
/// maximum (a few mistakes), 1 for any completion, 0 if never completed.
int lessonStars(int bestScore, int targetCount) {
  if (bestScore <= 0 || targetCount <= 0) return 0;
  final maxScore = targetCount * 100;
  if (bestScore >= maxScore) return 3;
  if (bestScore >= maxScore * 0.8) return 2;
  return 1;
}

class LessonStars extends StatelessWidget {
  final int stars;

  const LessonStars(this.stars, {super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$stars of 3 stars',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < 3; i++)
              Icon(
                i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 15,
                color: i < stars ? AppColors.pianoGold : AppColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}
