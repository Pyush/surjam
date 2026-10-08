import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/piano_provider.dart';
import '../models/chord_scale_data.dart';
import '../widgets/keyboard_widget.dart';
import '../widgets/piano_minimap_widget.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/audio/metronome_service.dart';
import '../../../shared/widgets/banner_ad_widget.dart';

class PianoScreen extends StatelessWidget {
  const PianoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PianoProvider>();
    final metronome = context.watch<MetronomeService>();

    String? currentDropdownValue;
    if (provider.selectedScale != null) {
      currentDropdownValue = 'scale:${provider.selectedScale}';
    } else if (provider.selectedChord != null) {
      currentDropdownValue = 'chord:${provider.selectedChord}';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎹 Piano Studio'),
        centerTitle: true,
        actions: [
          // Sustain Toggle
          IconButton(
            icon: Icon(
              Icons.pedal_bike_rounded,
              color: provider.sustain ? AppColors.pianoGold : Colors.white60,
            ),
            tooltip: 'Sustain Pedal',
            onPressed: () => provider.toggleSustain(),
          ),

          // Metronome Toggle
          IconButton(
            icon: Icon(
              Icons.timer_outlined,
              color: metronome.isPlaying ? AppColors.primaryCyan : Colors.white60,
            ),
            tooltip: 'Metronome (${metronome.bpm} BPM)',
            onPressed: () => _showMetronomeDialog(context, metronome),
          ),

          // Key Label Mode Switcher
          PopupMenuButton<String>(
            icon: const Icon(Icons.subtitles_rounded, color: Colors.white70),
            onSelected: (mode) => provider.setKeyLabelMode(mode),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'english', child: Text('English (C, D, E)')),
              PopupMenuItem(value: 'sargam', child: Text('Sargam (Sa, Re, Ga)')),
              PopupMenuItem(value: 'none', child: Text('Hide Labels')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Sleek Floating Toolbar
            _buildControlBar(context, provider, currentDropdownValue),

            // 2. 88-Key Mini-Map Navigator Strip
            const PianoMinimapWidget(),

            // 3. Learn Mode Banner (if active)
            if (provider.isLearnMode) _buildLearnModeBanner(context, provider),

            // 4. Scale/Chord Info Bar (if active)
            if (!provider.isLearnMode) _buildInfoStage(provider),

            // 5. Main 3D Piano Keyboard
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                child: const KeyboardWidget(),
              ),
            ),

            // 6. AdMob Banner Ad
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildControlBar(BuildContext context, PianoProvider provider, String? currentDropdownValue) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkCardBorder),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
      ),
      // Wraps onto a second line on narrow screens so every control (including REC) stays visible.
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
            // Octave Selector
            Row(
              children: [
                const Text('Octave: ', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13)),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: AppColors.primaryCyan, size: 22),
                  onPressed: provider.octave > 2 ? () => provider.setOctave(provider.octave - 1) : null,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryCyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryCyan),
                  ),
                  child: Text(
                    'C${provider.octave}',
                    style: const TextStyle(color: AppColors.primaryCyan, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryCyan, size: 22),
                  onPressed: provider.octave < 6 ? () => provider.setOctave(provider.octave + 1) : null,
                ),
              ],
            ),

            // Scale & Chord Finder Dropdown
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: DropdownButton<String>(
              isExpanded: true,
              dropdownColor: AppColors.darkCard,
              value: currentDropdownValue,
              hint: const Text('Scale / Chord', style: TextStyle(color: Colors.white70, fontSize: 13)),
              style: const TextStyle(color: AppColors.pianoGold, fontWeight: FontWeight.bold, fontSize: 14),
              underline: const SizedBox.shrink(),
              icon: const Icon(Icons.music_note_rounded, color: AppColors.pianoGold, size: 20),
              onChanged: (val) {
                if (val == null || val == 'none') {
                  provider.clearHighlights();
                } else if (val.startsWith('scale:')) {
                  provider.selectScale(val.substring(6));
                } else if (val.startsWith('chord:')) {
                  provider.selectChord(val.substring(6));
                }
              },
              items: [
                const DropdownMenuItem(value: 'none', child: Text('Clear Highlights')),
                ...MusicTheoryData.scales.keys.map((s) => DropdownMenuItem(value: 'scale:$s', child: Text('Scale: $s', overflow: TextOverflow.ellipsis))),
                ...MusicTheoryData.chords.keys.map((c) => DropdownMenuItem(value: 'chord:$c', child: Text('Chord: $c', overflow: TextOverflow.ellipsis))),
              ],
              ),
            ),

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

  Widget _buildInfoStage(PianoProvider provider) {
    if (provider.selectedScale == null && provider.selectedChord == null) {
      return const SizedBox.shrink();
    }

    String title = provider.selectedScale != null
        ? 'Scale: ${provider.selectedScale}'
        : 'Chord: ${provider.selectedChord}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.pianoGold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.pianoGold.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.stars_rounded, color: AppColors.pianoGold, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(color: AppColors.pianoGold, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
            onPressed: () => provider.clearHighlights(),
          ),
        ],
      ),
    );
  }

  Widget _buildLearnModeBanner(BuildContext context, PianoProvider provider) {
    double progress = provider.totalLearnSteps > 0
        ? (provider.currentLearnStep / provider.totalLearnSteps).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.learnGreen.withValues(alpha: 0.3), AppColors.darkCard],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.learnGreen),
      ),
      child: Row(
        children: [
          Icon(
            provider.isLearnComplete ? Icons.emoji_events_rounded : Icons.school_rounded,
            color: provider.isLearnComplete ? AppColors.pianoGold : AppColors.learnGreen,
            size: 22,
          ),
          const SizedBox(width: 10),
          Text(
            'Score: ${provider.learnScore}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(width: 16),
          if (provider.isLearnComplete) ...[
            Expanded(
              child: Text(
                'Complete! Best: ${provider.learnBestScore} · Mistakes: ${provider.learnMistakes}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.pianoGold, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            IconButton(
              tooltip: 'Try again',
              icon: const Icon(Icons.replay_rounded, color: AppColors.learnGreen, size: 20),
              onPressed: () => provider.restartLearnExercise(),
            ),
          ] else
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white12,
                  color: AppColors.learnGreen,
                  minHeight: 8,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
            onPressed: () => provider.stopLearnExercise(),
          ),
        ],
      ),
    );
  }

  void _showMetronomeDialog(BuildContext context, MetronomeService metronome) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⏱ Metronome Settings'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${metronome.bpm} BPM',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryCyan),
                ),
                Slider(
                  value: metronome.bpm.toDouble(),
                  min: 40,
                  max: 240,
                  divisions: 200,
                  activeColor: AppColors.primaryCyan,
                  onChanged: (val) {
                    metronome.setBpm(val.toInt());
                    setState(() {});
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              metronome.toggle();
              Navigator.pop(context);
            },
            child: Text(metronome.isPlaying ? 'STOP' : 'START', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSaveRecordingDialog(BuildContext context, PianoProvider provider) {
    final textController = TextEditingController(text: 'My Piano Jam');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Recording'),
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
