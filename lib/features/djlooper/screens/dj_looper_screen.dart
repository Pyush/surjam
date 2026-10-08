import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dj_looper_model.dart';
import '../providers/dj_looper_provider.dart';
import '../widgets/dj_loop_matrix_widget.dart';
import '../../../core/theme/app_colors.dart';

class DJLooperScreen extends StatelessWidget {
  const DJLooperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DJLooperProvider(),
      child: Consumer<DJLooperProvider>(
        builder: (context, provider, child) {
          final pack = provider.selectedPack;

          return Scaffold(
            appBar: AppBar(
              title: const Text('🎛 DJ Loop Launcher & FX'),
              centerTitle: true,
              actions: [
                PopupMenuButton<DJSoundPack>(
                  icon: const Icon(Icons.graphic_eq_rounded, color: AppColors.primaryCyan),
                  tooltip: 'Select Sound Pack',
                  initialValue: pack,
                  onSelected: (selected) => provider.setSoundPack(selected),
                  itemBuilder: (context) => DJSoundPack.soundPacks.map((p) {
                    return PopupMenuItem<DJSoundPack>(
                      value: p,
                      child: Row(
                        children: [
                          Icon(
                            p.id == pack.id ? Icons.check_circle : Icons.circle_outlined,
                            color: p.id == pack.id ? AppColors.primaryCyan : Colors.grey,
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
                  // 1. MASTER CONTROL & BPM HEADER
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primaryCyan.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        // Stop All Button
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.recordRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onPressed: () => provider.stopAll(),
                          icon: const Icon(Icons.stop_rounded, size: 18),
                          label: const Text('Stop All'),
                        ),

                        const SizedBox(width: 12),

                        // Master Tempo Slider
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                    pack.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.primaryCyan,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${provider.masterBpm} BPM',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                              Slider(
                                value: provider.masterBpm.toDouble(),
                                min: 90.0,
                                max: 160.0,
                                activeColor: AppColors.primaryCyan,
                                onChanged: (val) => provider.setMasterBpm(val.toInt()),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. MAIN 8-TRACK DJ LOOP MATRIX SURFACE
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: DJLoopMatrixWidget(),
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
