import 'package:flutter/material.dart';
import '../../piano/models/chord_scale_data.dart';
import '../../../core/audio/audio_engine.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/banner_ad_widget.dart';

class ScaleEncyclopediaScreen extends StatelessWidget {
  const ScaleEncyclopediaScreen({super.key});

  void _playScaleAudio(List<int> intervals) {
    for (int i = 0; i < intervals.length; i++) {
      Future.delayed(Duration(milliseconds: i * 220), () {
        AudioEngine().playPianoNote(60 + intervals[i]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scalesMap = MusicTheoryData.scales;

    return Scaffold(
      appBar: AppBar(
        title: const Text('📖 Scale & Raga Encyclopedia'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: scalesMap.length,
                itemBuilder: (context, index) {
                  final name = scalesMap.keys.elementAt(index);
                  final intervals = scalesMap[name]!;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryCyan.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.menu_book_rounded, color: AppColors.primaryCyan),
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(
                        'Intervals: ${intervals.join(", ")}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.volume_up_rounded, color: AppColors.pianoGold, size: 28),
                        onPressed: () => _playScaleAudio(intervals),
                      ),
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
