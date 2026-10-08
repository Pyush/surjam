import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/piano_provider.dart';
import '../models/chord_scale_data.dart';
import '../models/piano_key_model.dart';
import '../widgets/keyboard_widget.dart';
import '../widgets/piano_minimap_widget.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/audio/metronome_service.dart';

/// The piano's state is global (Learn and Settings use it), so whatever this screen started is
/// stopped explicitly when it closes.
class PianoScreen extends StatefulWidget {
  const PianoScreen({super.key});

  @override
  State<PianoScreen> createState() => _PianoScreenState();
}

class _PianoScreenState extends State<PianoScreen> {
  late final PianoProvider _piano;
  late final MetronomeService _metronome;

  @override
  void initState() {
    super.initState();
    _piano = context.read<PianoProvider>();
    _metronome = context.read<MetronomeService>();
  }

  @override
  void dispose() {
    final piano = _piano;
    final metronome = _metronome;
    // After the route is torn down, so listeners being removed are not notified mid-unmount.
    Future.microtask(() {
      metronome.stop();
      piano.onScreenClosed();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const _PianoView();
}

class _PianoView extends StatelessWidget {
  const _PianoView();

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
            // 1. Sleek Floating Toolbar. During a lesson the progress panel takes its place in the
            // same space (the toolbar stays laid out underneath), so the keys never change size.
            Stack(
              children: [
                Visibility(
                  visible: !provider.isLearnMode,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: _buildControlBar(context, provider, currentDropdownValue),
                ),
                if (provider.isLearnMode)
                  Positioned.fill(child: _buildLearnModeBanner(context, provider)),
              ],
            ),

            // 2. 88-Key Mini-Map Navigator Strip
            const PianoMinimapWidget(),

            // 4. Main 3D Piano Keyboard
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                child: const KeyboardWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlBar(BuildContext context, PianoProvider provider, String? currentDropdownValue) {
    return Container(
      width: double.infinity,
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
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Octave down',
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
                  tooltip: 'Octave up',
                  icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryCyan, size: 22),
                  onPressed: provider.octave < 6 ? () => provider.setOctave(provider.octave + 1) : null,
                ),
              ],
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

            // Sustain Pedal Toggle
            FilterChip(
              label: const Text('Sustain'),
              selected: provider.sustain,
              tooltip: 'Sustain pedal: keys keep sounding after release',
              selectedColor: AppColors.pianoGold,
              checkmarkColor: Colors.black,
              labelStyle: TextStyle(
                color: provider.sustain ? Colors.black : Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              onSelected: (_) => provider.toggleSustain(),
            ),

            // Scale & Chord Finder Dropdown with its clear button. The button's space is always
            // reserved so selecting a scale or chord never changes the layout or the key size.
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 170),
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
            Visibility(
              visible: currentDropdownValue != null,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: IconButton(
                tooltip: 'Clear highlights',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                onPressed: () => provider.clearHighlights(),
              ),
            ),
              ],
            ),

        ],
      ),
    );
  }

  /// "Next: E4 · Finger 3", using the player's English or Sargam label preference.
  String _nextNoteHint(PianoProvider provider) {
    if (provider.isDemoPlaying) return 'Listen…';
    final target = provider.targetLearnMidiNote;
    if (target == null) return '';
    final key = PianoKeyModel.fromMidi(target);
    final name = provider.keyLabelMode == 'sargam' ? key.sargamLabel : key.noteName;
    final finger = provider.targetLearnFinger;
    return finger == null ? 'Next: $name' : 'Next: $name · Finger $finger';
  }

  Widget _buildLearnModeBanner(BuildContext context, PianoProvider provider) {
    double progress = provider.totalLearnSteps > 0
        ? (provider.currentLearnStep / provider.totalLearnSteps).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      // Same margin and corners as the toolbar card it replaces.
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.learnGreen.withValues(alpha: 0.3), AppColors.darkCard],
        ),
        borderRadius: BorderRadius.circular(16),
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
          ] else ...[
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white12,
                      color: AppColors.learnGreen,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _nextNoteHint(provider),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: provider.isDemoPlaying ? 'Stop demo' : 'Listen first',
              icon: Icon(
                provider.isDemoPlaying ? Icons.stop_circle_rounded : Icons.play_circle_fill_rounded,
                color: AppColors.learnGreen,
                size: 26,
              ),
              onPressed: () => provider.toggleLearnDemo(),
            ),
          ],
          IconButton(
            tooltip: 'End lesson',
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
    ).whenComplete(textController.dispose);
  }
}
