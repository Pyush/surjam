import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dholak_model.dart';
import '../providers/dholak_provider.dart';
import '../widgets/dholak_surface_widget.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/banner_ad_widget.dart';

class DholakScreen extends StatelessWidget {
  const DholakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DholakProvider(),
      child: Consumer<DholakProvider>(
        builder: (context, provider, child) {
          final pattern = provider.selectedPattern ?? DholakFolkPattern.preloadedPatterns[0];

          return Scaffold(
            appBar: AppBar(
              title: const Text('🥁 Dholak & Dhol Studio'),
              centerTitle: true,
              actions: [
                PopupMenuButton<DholakFolkPattern>(
                  icon: const Icon(Icons.music_note, color: AppColors.tablaAmber),
                  tooltip: 'Select Folk Rhythm Loop',
                  initialValue: pattern,
                  onSelected: (selected) => provider.setPattern(selected),
                  itemBuilder: (context) => DholakFolkPattern.preloadedPatterns.map((p) {
                    return PopupMenuItem<DholakFolkPattern>(
                      value: p,
                      child: Row(
                        children: [
                          Icon(
                            p.id == pattern.id ? Icons.check_circle : Icons.circle_outlined,
                            color: p.id == pattern.id ? AppColors.tablaAmber : Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('Default Tempo: ${p.defaultBpm} BPM', style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // 1. RHYTHM LOOP & TEMPO HEADER
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.tablaAmber.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Play/Pause Rhythm Loop Toggle Button
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: provider.isLoopPlaying ? AppColors.recordRed : AppColors.tablaAmber,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              ),
                              onPressed: () => provider.toggleLoop(),
                              icon: Icon(provider.isLoopPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded),
                              label: Text(provider.isLoopPlaying ? 'Stop Beat' : 'Play Beat'),
                            ),

                            const SizedBox(width: 12),

                            // Beat Pattern info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pattern.name,
                                    style: const TextStyle(
                                      color: AppColors.tablaAmber,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${pattern.timeSignature} Rhythm Loop • ${provider.bpm} BPM',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Beat Sequence Step LEDs
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(pattern.sequence.length, (idx) {
                            bool isActiveBeat = provider.isLoopPlaying && (provider.currentBeatIndex % pattern.sequence.length) == idx;
                            String strokeBol = pattern.sequence[idx];

                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: isActiveBeat ? AppColors.tablaAmber : Colors.black38,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isActiveBeat ? AppColors.pianoGold : Colors.white12,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    strokeBol,
                                    style: TextStyle(
                                      color: isActiveBeat ? Colors.black : Colors.white70,
                                      fontSize: 10,
                                      fontWeight: isActiveBeat ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  // 2. TEMPO BPM SLIDER
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.speed, color: AppColors.tablaAmber, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Tempo (${provider.bpm} BPM):',
                          style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Slider(
                            value: provider.bpm.toDouble(),
                            min: 60.0,
                            max: 240.0,
                            activeColor: AppColors.tablaAmber,
                            onChanged: (val) => provider.setBpm(val.toInt()),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. MAIN DUAL-HEAD DHOLAK SURFACE
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: DholakSurfaceWidget(),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // 4. ADMOB BANNER
                  const BannerAdWidget(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
