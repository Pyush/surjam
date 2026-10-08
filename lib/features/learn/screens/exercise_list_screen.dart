import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exercise_model.dart';
import '../../piano/providers/piano_provider.dart';
import '../../piano/screens/piano_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/storage/storage_service.dart';
import '../../../shared/widgets/banner_ad_widget.dart';

class ExerciseListScreen extends StatelessWidget {
  const ExerciseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exercises = ExerciseModel.preloadedExercises;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎓 Learn & Practice Hub'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accentPurple, AppColors.darkCard],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accentPurple.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.stars_rounded, color: AppColors.pianoGold, size: 28),
                      SizedBox(width: 8),
                      Text(
                        'Interactive Note Highlights',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Select an exercise below. The piano keyboard will highlight target keys and wait for you to press them.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),

            // Exercise Cards List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final ex = exercises[index];
                  int highScore = StorageService().getExerciseScore(ex.id);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.learnGreen.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.music_note_rounded, color: AppColors.learnGreen),
                      ),
                      title: Text(
                        ex.title,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(ex.subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  ex.difficulty,
                                  style: const TextStyle(color: AppColors.primaryCyan, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (highScore > 0) ...[
                                const SizedBox(width: 12),
                                Icon(Icons.workspace_premium_rounded, color: AppColors.pianoGold, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  'High Score: $highScore',
                                  style: const TextStyle(color: AppColors.pianoGold, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 18),
                      onTap: () {
                        final provider = context.read<PianoProvider>();
                        provider.startLearnExercise(ex.midiSequence);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PianoScreen()),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }
}
