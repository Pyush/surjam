import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/guitar_provider.dart';
import '../models/guitar_chord_model.dart';
import '../widgets/fretboard_widget.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/banner_ad_widget.dart';

class GuitarScreen extends StatelessWidget {
  const GuitarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GuitarProvider(),
      child: Consumer<GuitarProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('🎸 Guitar Studio'),
              centerTitle: true,
              actions: [
                // Auto Strum Loop Toggle
                IconButton(
                  icon: Icon(
                    provider.isAutoStrumming ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                    color: provider.isAutoStrumming ? AppColors.primaryNeon : AppColors.primaryCyan,
                    size: 28,
                  ),
                  tooltip: provider.isAutoStrumming ? 'Pause Strum Loop' : 'Auto Strum',
                  onPressed: () => provider.toggleAutoStrum(),
                ),

                // BPM Control Dialog
                IconButton(
                  icon: const Icon(Icons.speed_rounded, color: Colors.white70),
                  tooltip: 'BPM Speed (${provider.bpm})',
                  onPressed: () => _showBpmDialog(context, provider),
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // 1. Chord Selector Palette
                  _buildChordPalette(context, provider),

                  // 2. Main Fretboard View
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: FretboardWidget(),
                    ),
                  ),

                  // 3. Strum Action Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryNeon,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            icon: const Icon(Icons.music_note_rounded),
                            label: const Text('STRUM DOWN 👇', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () => provider.strumChord(isDownStrum: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryCyan,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            icon: const Icon(Icons.music_note_rounded),
                            label: const Text('STRUM UP 👆', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () => provider.strumChord(isDownStrum: false),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 4. AdMob Banner Ad
                  const BannerAdWidget(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChordPalette(BuildContext context, GuitarProvider provider) {
    final chords = GuitarChordModel.preloadedChords;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkCardBorder),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: chords.map((chord) {
            bool isSelected = provider.selectedChord.name == chord.name;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text(chord.name),
                selected: isSelected,
                selectedColor: AppColors.primaryNeon,
                backgroundColor: AppColors.darkCardBorder,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (_) => provider.selectChord(chord),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showBpmDialog(BuildContext context, GuitarProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎸 Strum Tempo (BPM)'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${provider.bpm} BPM',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryNeon),
                ),
                Slider(
                  value: provider.bpm.toDouble(),
                  min: 40,
                  max: 200,
                  divisions: 160,
                  activeColor: AppColors.primaryNeon,
                  onChanged: (val) {
                    provider.setBpm(val.toInt());
                    setState(() {});
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
