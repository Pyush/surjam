import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dj_looper_model.dart';
import '../providers/dj_looper_provider.dart';
import '../../../core/theme/app_colors.dart';

class DJLoopMatrixWidget extends StatelessWidget {
  const DJLoopMatrixWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DJLooperProvider>();
    final activeTracks = provider.activeTrackIds;
    final tracks = DJTrackModel.defaultTracks;

    return Column(
      children: [
        // 1. REAL-TIME AUDIO FILTER FX CONTROL SLIDER
        _buildFilterFxSlider(provider),

        const SizedBox(height: 10),

        // 2. 8-TRACK LIVE LOOP PAD MATRIX GRID (2 rows x 4 cols)
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF14121E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12, width: 1.5),
              boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: tracks.length,
              itemBuilder: (context, idx) {
                final track = tracks[idx];
                bool isActive = activeTracks.contains(track.id);

                return GestureDetector(
                  onTap: () => provider.toggleTrack(track.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        colors: isActive
                            ? [track.padColor, track.padColor.withValues(alpha: 0.7)]
                            : [const Color(0xFF262338), const Color(0xFF1B192A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: isActive ? Colors.white : track.padColor.withValues(alpha: 0.4),
                        width: isActive ? 2.5 : 1,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: track.padColor.withValues(alpha: 0.8),
                                blurRadius: 14,
                                spreadRadius: 1,
                              ),
                            ]
                          : [const BoxShadow(color: Colors.black45, blurRadius: 4)],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // LED Pulse Indicator
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive
                                ? (provider.pulseIndex % 2 == 0 ? Colors.white : track.padColor)
                                : Colors.white24,
                            boxShadow: isActive
                                ? [BoxShadow(color: Colors.white, blurRadius: 6)]
                                : [],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          track.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isActive ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          track.category,
                          style: TextStyle(
                            color: isActive ? Colors.black87 : AppColors.textSecondary,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterFxSlider(DJLooperProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryCyan.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.tune, color: AppColors.primaryCyan, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Low-Pass Audio Filter Cutoff',
                style: TextStyle(color: AppColors.primaryCyan, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              Text(
                'Cutoff: ${(provider.filterCutoff * 100).toInt()}%',
                style: const TextStyle(color: Colors.white60, fontSize: 10),
              ),
            ],
          ),
          Expanded(
            child: Slider(
              value: provider.filterCutoff,
              min: 0.1,
              max: 1.0,
              activeColor: AppColors.primaryCyan,
              onChanged: (val) => provider.setFilterCutoff(val),
            ),
          ),
        ],
      ),
    );
  }
}
