import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bansuri_model.dart';
import '../providers/bansuri_provider.dart';
import '../widgets/bansuri_flute_widget.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/record_button.dart';

class BansuriScreen extends StatelessWidget {
  const BansuriScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BansuriProvider(),
      child: Consumer<BansuriProvider>(
        builder: (context, provider, child) {
          final preset = provider.selectedPreset;

          return Scaffold(
            appBar: AppBar(
              title: const Text('🪈 Bansuri & Flute Studio'),
              centerTitle: true,
              actions: [
                RecordButton(instrument: 'Bansuri', compact: true),
                PopupMenuButton<BansuriPreset>(
                  icon: const Icon(Icons.music_note, color: AppColors.pianoGold),
                  tooltip: 'Select Flute Scale',
                  initialValue: preset,
                  onSelected: (selected) => provider.setPreset(selected),
                  itemBuilder: (context) => BansuriPreset.preloadedPresets.map((p) {
                    return PopupMenuItem<BansuriPreset>(
                      value: p,
                      child: Row(
                        children: [
                          Icon(
                            p.id == preset.id ? Icons.check_circle : Icons.circle_outlined,
                            color: p.id == preset.id ? AppColors.pianoGold : Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(p.description, style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
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
                  // 1. REGISTER TOGGLE & EXPRESSION CONTROLS
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        // Register Selector
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Blowing Register (Octave):',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  _buildRegisterBtn(provider, 0, 'Mandra (Low)'),
                                  const SizedBox(width: 4),
                                  _buildRegisterBtn(provider, 1, 'Madhya (Mid)'),
                                  const SizedBox(width: 4),
                                  _buildRegisterBtn(provider, 2, 'Taar (High)'),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Active Note Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                provider.activeSwaraName,
                                style: const TextStyle(
                                  color: AppColors.primaryNeon,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                'MIDI ${provider.activeMidiNote}',
                                style: const TextStyle(color: Colors.white60, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. VIBRATO EXPRESSION CONTROL SLIDER
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.waves, color: AppColors.pianoGold, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'Breath Vibrato:',
                          style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Slider(
                            value: provider.vibratoAmount,
                            min: 0.0,
                            max: 1.0,
                            activeColor: AppColors.pianoGold,
                            onChanged: (val) => provider.setVibratoAmount(val),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. MAIN BANSURI FLUTE INTERACTIVE SURFACE
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: BansuriFluteWidget(),
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

  Widget _buildRegisterBtn(BansuriProvider provider, int regIdx, String label) {
    bool isSel = provider.octaveRegister == regIdx;
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setRegister(regIdx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSel ? AppColors.pianoGold : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isSel ? AppColors.pianoGold : Colors.white24),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSel ? Colors.black : Colors.white70,
                fontSize: 10,
                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
