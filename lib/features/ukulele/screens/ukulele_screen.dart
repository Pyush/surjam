import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ukulele_model.dart';
import '../providers/ukulele_provider.dart';
import '../widgets/ukulele_fretboard_widget.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/record_button.dart';

class UkuleleScreen extends StatelessWidget {
  const UkuleleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UkuleleProvider(),
      child: Consumer<UkuleleProvider>(
        builder: (context, provider, child) {
          final activeChord = provider.selectedChord;

          return Scaffold(
            appBar: AppBar(
              title: const Text('🪕 Ukulele Studio'),
              centerTitle: true,
              actions: [
                RecordButton(instrument: 'Ukulele', compact: true),
                IconButton(
                  icon: const Icon(Icons.music_note, color: AppColors.pianoGold),
                  onPressed: () => provider.strumChord(),
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // 1. CHORD SELECTOR PALETTE BAR
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                            Text(
                              'Active Chord: ${activeChord.name}',
                              style: const TextStyle(
                                color: AppColors.pianoGold,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.pianoGold,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              ),
                              onPressed: () => provider.strumChord(),
                              icon: const Icon(Icons.volume_up_rounded, size: 16),
                              label: const Text('Strum Chord'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: UkuleleChord.popularChords.map((chord) {
                              bool isSel = chord.id == activeChord.id;
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: ActionChip(
                                  backgroundColor: isSel ? AppColors.pianoGold : Colors.white10,
                                  labelStyle: TextStyle(
                                    color: isSel ? Colors.black : Colors.white70,
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  label: Text(chord.name),
                                  onPressed: () => provider.selectChord(chord),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. MAIN UKULELE FRETBOARD SURFACE
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: UkuleleFretboardWidget(),
                    ),
                  ),

                  const SizedBox(height: 4),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
