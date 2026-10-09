import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shehnai_provider.dart';
import '../widgets/shehnai_keys_widget.dart';
import '../../../core/music/thaat.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/record_button.dart';

class ShehnaiScreen extends StatelessWidget {
  const ShehnaiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShehnaiProvider(),
      child: Consumer<ShehnaiProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('🎺 Shehnai Studio'),
              centerTitle: true,
              actions: [
                const RecordButton(instrument: 'Shehnai', compact: true),
                IconButton(
                  tooltip: provider.showSargam ? 'Show note names' : 'Show sargam',
                  icon: Text(
                    provider.showSargam ? 'C' : 'Sa',
                    style: const TextStyle(color: AppColors.pianoGold, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  onPressed: provider.toggleLabels,
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        for (final thaat in Thaat.all)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(thaat.name),
                              selected: provider.thaat.id == thaat.id,
                              selectedColor: AppColors.pianoGold,
                              backgroundColor: AppColors.darkCard,
                              labelStyle: TextStyle(
                                color: provider.thaat.id == thaat.id ? Colors.black : Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                              onSelected: (_) => provider.setThaat(thaat),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        FilterChip(
                          label: const Text('Gamak (vibrato)'),
                          selected: provider.vibrato,
                          selectedColor: AppColors.learnGreen,
                          checkmarkColor: Colors.black,
                          labelStyle: TextStyle(color: provider.vibrato ? Colors.black : Colors.white70, fontWeight: FontWeight.bold),
                          onSelected: provider.setVibrato,
                        ),
                        FilterChip(
                          label: const Text('Sur drone'),
                          selected: provider.surDrone,
                          selectedColor: AppColors.learnGreen,
                          checkmarkColor: Colors.black,
                          labelStyle: TextStyle(color: provider.surDrone ? Colors.black : Colors.white70, fontWeight: FontWeight.bold),
                          onSelected: (_) => provider.toggleSurDrone(),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Text(
                      'Hold a key to play · slide for meend',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: ShehnaiKeysWidget(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
