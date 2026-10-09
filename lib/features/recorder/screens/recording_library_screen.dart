import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/audio/audio_engine.dart';
import '../../../core/audio/sound_event.dart';
import '../../../core/recording/recording.dart';
import '../../../core/recording/recording_sharer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/banner_ad_widget.dart';
import '../../../core/lifecycle/playback_guard.dart';

class RecordingLibraryScreen extends StatefulWidget {
  const RecordingLibraryScreen({super.key});

  @override
  State<RecordingLibraryScreen> createState() => _RecordingLibraryScreenState();
}

class _RecordingLibraryScreenState extends State<RecordingLibraryScreen> {
  static const Map<String, String> _instrumentEmoji = {
    'Piano': '🎹',
    'Tabla': '🪘',
    'Dholak': '🥁',
    'Drum Pad': '🥁',
    'Guitar': '🎸',
    'Ukulele': '🪕',
    'Sitar': '🪕',
    'Violin': '🎻',
    'Bansuri': '🪈',
    'Harmonium': '🎹',
    'Xylophone': '🎼',
    'DJ Looper': '🎛',
  };

  List<Recording> _recordings = [];
  String? _currentlyPlayingId;
  String? _exportingId;
  Timer? _playbackTimer;

  @override
  void initState() {
    super.initState();
    PlaybackGuard.register(this, _stopPlayback);
    _loadRecordings();
  }

  void _loadRecordings() {
    final recordings = <Recording>[];
    for (final json in StorageService().getSavedRecordings()) {
      try {
        recordings.add(Recording.fromJson(json));
      } catch (e) {
        debugPrint('Skipping unreadable recording: $e');
      }
    }
    setState(() => _recordings = recordings);
  }

  void _playRecording(Recording recording) {
    _stopPlayback();
    if (recording.events.isEmpty) return;
    setState(() => _currentlyPlayingId = recording.id);

    int index = 0;
    final clock = Stopwatch()..start();
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      final elapsed = clock.elapsedMilliseconds;
      while (index < recording.events.length && recording.events[index].timeMs <= elapsed) {
        AudioEngine().playWithoutRecording(recording.events[index].sound);
        index++;
      }
      // Runs to the recorded length, so a held drone lasts as long as it did.
      if (index >= recording.events.length && elapsed >= recording.durationMs) {
        _stopPlayback();
      }
    });
  }

  void _stopPlayback() {
    final wasPlaying = _playbackTimer != null;
    _playbackTimer?.cancel();
    _playbackTimer = null;
    if (wasPlaying) AudioEngine().playWithoutRecording(SoundEvent.droneStopEvent);
    if (mounted) {
      setState(() => _currentlyPlayingId = null);
    }
  }

  Future<void> _deleteRecording(Recording recording) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete recording?'),
        content: Text('"${recording.title}" will be deleted. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    if (_currentlyPlayingId == recording.id) _stopPlayback();
    await StorageService().deleteRecording(recording.id);
    _loadRecordings();
  }

  Future<void> _shareRecording(Recording recording) async {
    setState(() => _exportingId = recording.id);
    try {
      await RecordingSharer.share(recording);
    } catch (e) {
      debugPrint('Sharing failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not create the audio file. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _exportingId = null);
    }
  }

  static String _formatDuration(int ms) {
    final seconds = (ms / 1000).round();
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    PlaybackGuard.unregister(this);
    _stopPlayback();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎙 Saved Recordings'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _recordings.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.mic_off_rounded, size: 64, color: AppColors.textMuted),
                            SizedBox(height: 12),
                            Text(
                              'No Recordings Yet',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Tap the red record button on any instrument to save your jams.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _recordings.length,
                      itemBuilder: (context, index) {
                        final recording = _recordings[index];
                        final isPlaying = _currentlyPlayingId == recording.id;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.pianoGold.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                _instrumentEmoji[recording.instrument] ?? '🎵',
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                            title: Text(
                              recording.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${recording.instrument} • ${recording.events.length} sounds • ${_formatDuration(recording.durationMs)}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: isPlaying ? 'Stop' : 'Play',
                                  icon: Icon(
                                    isPlaying ? Icons.stop_circle_rounded : Icons.play_circle_fill_rounded,
                                    color: isPlaying ? AppColors.recordRed : AppColors.primaryCyan,
                                    size: 32,
                                  ),
                                  onPressed: () => isPlaying ? _stopPlayback() : _playRecording(recording),
                                ),
                                _exportingId == recording.id
                                    ? const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primaryCyan),
                                        ),
                                      )
                                    : IconButton(
                                        tooltip: 'Share as audio file',
                                        icon: const Icon(Icons.share_rounded, color: AppColors.primaryCyan),
                                        onPressed: _exportingId == null ? () => _shareRecording(recording) : null,
                                      ),
                                IconButton(
                                  tooltip: 'Delete',
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.white38),
                                  onPressed: () => _deleteRecording(recording),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }
}
