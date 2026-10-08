import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/guitar_provider.dart';
import '../models/guitar_chord_model.dart';
import '../widgets/fretboard_widget.dart';
import '../../../core/theme/app_colors.dart';

class GuitarScreen extends StatelessWidget {
  const GuitarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GuitarProvider(),
      child: Consumer<GuitarProvider>(
        builder: (context, provider, child) {
          final isLandscape = MediaQuery.orientationOf(context) == Orientation.landscape;
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

                  // 2. Main Fretboard View, with the strum buttons beside it in landscape
                  // so the six strings keep enough height to tap.
                  if (isLandscape)
                    Expanded(
                      child: Row(
                        children: [
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: FretboardWidget(),
                            ),
                          ),
                          SizedBox(
                            width: 200,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 8, 12, 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(child: _buildStrumButton(provider, isDown: true)),
                                  const SizedBox(height: 12),
                                  Expanded(child: _buildStrumButton(provider, isDown: false)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
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
                          Expanded(child: _buildStrumButton(provider, isDown: true)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStrumButton(provider, isDown: false)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStrumButton(GuitarProvider provider, {required bool isDown}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDown ? AppColors.primaryNeon : AppColors.primaryCyan,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      icon: const Icon(Icons.music_note_rounded),
      label: Text(isDown ? 'STRUM DOWN 👇' : 'STRUM UP 👆', style: const TextStyle(fontWeight: FontWeight.bold)),
      onPressed: () => provider.strumChord(isDownStrum: isDown),
    );
  }

  Widget _buildChordPalette(BuildContext context, GuitarProvider provider) {
    final chords = provider.chordsInCategory;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: GuitarChordModel.categories.map((category) {
                final isActive = provider.chordCategory == category;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isActive,
                    visualDensity: VisualDensity.compact,
                    selectedColor: AppColors.primaryCyan,
                    backgroundColor: Colors.transparent,
                    side: BorderSide(color: isActive ? AppColors.primaryCyan : AppColors.darkCardBorder),
                    labelStyle: TextStyle(
                      color: isActive ? Colors.black : Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (_) => provider.setChordCategory(category),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
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
        ],
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
