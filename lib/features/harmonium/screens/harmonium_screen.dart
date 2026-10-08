import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/harmonium_provider.dart';
import '../widgets/harmonium_keyboard_widget.dart';
import '../../../core/theme/app_colors.dart';

class HarmoniumScreen extends StatelessWidget {
  const HarmoniumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HarmoniumProvider(),
      child: Consumer<HarmoniumProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('🪕 Harmonium Studio'),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.tune_rounded, color: AppColors.pianoGold),
                  onPressed: () {
                    int nextOct = (provider.octave == 5) ? 3 : provider.octave + 1;
                    provider.setOctave(nextOct);
                  },
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Scale Changer Octave:',
                          style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Octave C${provider.octave}',
                          style: const TextStyle(color: AppColors.pianoGold, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),

                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: HarmoniumKeyboardWidget(),
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
