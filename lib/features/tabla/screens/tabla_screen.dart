import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tabla_provider.dart';
import '../models/taal_model.dart';
import '../widgets/tabla_surface_widget.dart';
import '../widgets/taal_step_sequencer_widget.dart';
import '../../../core/theme/app_colors.dart';

class TablaScreen extends StatelessWidget {
  const TablaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TablaProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🪘 Tabla Studio'),
        centerTitle: true,
        actions: [
          // Play/Stop Taal Loop Button
          IconButton(
            icon: Icon(
              provider.isPlayingTaal ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
              color: provider.isPlayingTaal ? AppColors.tablaAmber : AppColors.primaryCyan,
              size: 30,
            ),
            tooltip: provider.isPlayingTaal ? 'Pause Taal Loop' : 'Play Taal Loop',
            onPressed: () => provider.toggleTaalPlayer(),
          ),

          // BPM Control Dialog Button
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
            // 1. Taal Selector Toolbar & Record Button
            _buildTaalToolbar(context, provider),

            // 2. Step Sequencer Rhythm Visualizer
            const TaalStepSequencerWidget(),

            // 3. 3D Tabla Surface Stage
            const Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: TablaSurfaceWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaalToolbar(BuildContext context, TablaProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkCardBorder),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Taal Selector Dropdown
          Flexible(
            child: DropdownButton<TaalModel>(
            isExpanded: true,
            dropdownColor: AppColors.darkCard,
            value: provider.selectedTaal,
            style: const TextStyle(color: AppColors.tablaAmber, fontWeight: FontWeight.bold, fontSize: 15),
            underline: const SizedBox.shrink(),
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.tablaAmber),
            onChanged: (taal) {
              if (taal != null) provider.selectTaal(taal);
            },
            items: TaalModel.preloadedTaals.map((taal) {
              return DropdownMenuItem(
                value: taal,
                child: Text(taal.name, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            ),
          ),
          const SizedBox(width: 8),

          // Record Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: provider.isRecording ? AppColors.recordRed : Colors.white10,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: Icon(
              provider.isRecording ? Icons.stop_circle_rounded : Icons.fiber_manual_record_rounded,
              color: provider.isRecording ? Colors.white : Colors.redAccent,
              size: 20,
            ),
            label: Text(
              provider.isRecording ? 'STOP' : 'REC',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            onPressed: () {
              if (provider.isRecording) {
                _showSaveRecordingDialog(context, provider);
              } else {
                provider.startRecording();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showBpmDialog(BuildContext context, TablaProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🥁 Taal Speed (BPM)'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${provider.bpm} BPM',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.tablaAmber),
                ),
                Slider(
                  value: provider.bpm.toDouble(),
                  min: 40,
                  max: 240,
                  divisions: 200,
                  activeColor: AppColors.tablaAmber,
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

  void _showSaveRecordingDialog(BuildContext context, TablaProvider provider) {
    final textController = TextEditingController(text: 'My Tabla Rhythm');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Tabla Recording'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(labelText: 'Recording Title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.stopRecordingAndSave(textController.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
