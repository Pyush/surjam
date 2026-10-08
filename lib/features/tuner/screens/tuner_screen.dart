import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tuner_model.dart';
import '../providers/tuner_provider.dart';
import '../widgets/needle_meter_widget.dart';
import '../widgets/vocal_pitch_graph_widget.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/banner_ad_widget.dart';

class TunerScreen extends StatelessWidget {
  const TunerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TunerProvider()..startListening(),
      child: Consumer<TunerProvider>(
        builder: (context, provider, child) {
          final preset = provider.selectedPreset;
          final targetNote = provider.selectedTargetNote;

          return Scaffold(
            appBar: AppBar(
              title: const Text('🎯 Chromatic Tuner & Vocal Pitch'),
              centerTitle: true,
              actions: [
                PopupMenuButton<TunerPreset>(
                  icon: const Icon(Icons.tune_rounded, color: AppColors.pianoGold),
                  tooltip: 'Select Instrument Preset',
                  initialValue: preset,
                  onSelected: (selected) => provider.setPreset(selected),
                  itemBuilder: (context) => TunerPreset.preloadedPresets.map((p) {
                    return PopupMenuItem<TunerPreset>(
                      value: p,
                      child: Row(
                        children: [
                          Icon(
                            p.id == preset.id ? Icons.check_circle : Icons.circle_outlined,
                            color: p.id == preset.id ? AppColors.pianoGold : Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                  // Scrolls on short screens and in landscape; the ad stays pinned below.
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // 1. INSTRUMENT PRESET & TARGET NOTE CHIPS BAR
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.darkCard,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        preset.name,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.pianoGold,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.pianoGold,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      ),
                                      onPressed: () => provider.playReferenceTone(),
                                      icon: const Icon(Icons.volume_up_rounded, size: 16),
                                      label: const Text('Reference Tone'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: preset.targetNotes.map((note) {
                                      bool isSel = note.midiNote == targetNote.midiNote;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 3),
                                        child: ActionChip(
                                          backgroundColor: isSel ? AppColors.pianoGold : Colors.white10,
                                          labelStyle: TextStyle(
                                            color: isSel ? Colors.black : Colors.white70,
                                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                          ),
                                          label: Text(note.label),
                                          onPressed: () => provider.setTargetNote(note),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 2. MAIN NEEDLE METER VISUALIZER
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: NeedleMeterWidget(),
                          ),

                          const SizedBox(height: 6),

                          // 3. MICROPHONE CONTROLS
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.darkCard,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => provider.isTuningActive ? provider.stopListening() : provider.startListening(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: provider.isTuningActive ? AppColors.recordRed : const Color(0xFF2CB67D),
                                    foregroundColor: provider.isTuningActive ? Colors.white : Colors.black,
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                  ),
                                  icon: Icon(provider.isTuningActive ? Icons.mic_off_rounded : Icons.mic_rounded, size: 16),
                                  label: Text(
                                    provider.isTuningActive ? 'Stop Listening' : 'Start Listening',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Auto string',
                                      style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                    Switch(
                                      value: provider.autoSelectTarget,
                                      activeTrackColor: AppColors.pianoGold,
                                      onChanged: provider.setAutoSelectTarget,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 6),

                          // 4. REAL-TIME VOCAL PITCH GRAPH MONITOR
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: VocalPitchGraphWidget(),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),

                  // 5. ADMOB BANNER
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
