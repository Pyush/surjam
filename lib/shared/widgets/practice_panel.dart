import 'package:flutter/material.dart';
import '../../core/learn/practice_session.dart';
import '../../core/theme/app_colors.dart';

/// Progress of a guitar or tabla lesson: score, progress and the next target, then the result.
class PracticePanel extends StatelessWidget {
  final PracticeSession session;
  final VoidCallback onRestart;
  final VoidCallback onClose;

  const PracticePanel({
    super.key,
    required this.session,
    required this.onRestart,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final complete = session.isComplete;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.learnGreen.withValues(alpha: 0.3), AppColors.darkCard]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.learnGreen),
      ),
      child: Row(
        children: [
          Icon(
            complete ? Icons.emoji_events_rounded : Icons.school_rounded,
            color: complete ? AppColors.pianoGold : AppColors.learnGreen,
            size: 22,
          ),
          const SizedBox(width: 10),
          Text(
            'Score: ${session.score}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: complete
                ? Text(
                    'Complete! Best: ${session.bestScore} · Mistakes: ${session.mistakes}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.pianoGold, fontWeight: FontWeight.bold, fontSize: 13),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: session.progress,
                          backgroundColor: Colors.white12,
                          color: AppColors.learnGreen,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Next: ${session.target}  (${session.step + 1}/${session.targets.length})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
          ),
          if (complete)
            IconButton(
              tooltip: 'Try again',
              icon: const Icon(Icons.replay_rounded, color: AppColors.learnGreen, size: 20),
              onPressed: onRestart,
            ),
          IconButton(
            tooltip: 'End lesson',
            icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}
