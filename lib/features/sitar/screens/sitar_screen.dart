import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sitar_raga_model.dart';
import '../providers/sitar_provider.dart';
import '../widgets/sitar_fretboard_widget.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/banner_ad_widget.dart';

class SitarScreen extends StatelessWidget {
  const SitarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SitarProvider(),
      child: Consumer<SitarProvider>(
        builder: (context, provider, child) {
          final raga = provider.selectedRaga;

          return Scaffold(
            appBar: AppBar(
              title: const Text('🪕 Sitar Studio'),
              centerTitle: true,
              actions: [
                PopupMenuButton<SitarRagaModel>(
                  icon: const Icon(Icons.music_note, color: AppColors.pianoGold),
                  tooltip: 'Select Raag',
                  initialValue: raga,
                  onSelected: (selected) => provider.setRaga(selected),
                  itemBuilder: (context) => SitarRagaModel.preloadedRagas.map((r) {
                    return PopupMenuItem<SitarRagaModel>(
                      value: r,
                      child: Row(
                        children: [
                          Icon(
                            r.id == raga.id ? Icons.check_circle : Icons.circle_outlined,
                            color: r.id == raga.id ? AppColors.pianoGold : Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(r.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('Thaat: ${r.thaat}', style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
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
                  // RAGA & PLAYING INFO HEADER CARD
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        // Raga badge
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    raga.name,
                                    style: const TextStyle(
                                      color: AppColors.pianoGold,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Thaat: ${raga.thaat}',
                                      style: const TextStyle(color: AppColors.pianoGold, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                raga.description,
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Active note & meend display
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primaryCyan.withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                provider.activeNoteName,
                                style: const TextStyle(
                                  color: AppColors.primaryCyan,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              if (provider.bendSemitones > 0)
                                Text(
                                  'Meend +${provider.bendSemitones}',
                                  style: const TextStyle(color: Colors.amber, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // MAIN INTERACTIVE SITAR FRETBOARD
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: SitarFretboardWidget(),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // BOTTOM ADMOB BANNER
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
