import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/audio/audio_engine.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/banner_ad_widget.dart';

class RecordingLibraryScreen extends StatefulWidget {
  const RecordingLibraryScreen({super.key});

  @override
  State<RecordingLibraryScreen> createState() => _RecordingLibraryScreenState();
}

class _RecordingLibraryScreenState extends State<RecordingLibraryScreen> {
  List<Map<String, dynamic>> _recordings = [];
  String? _currentlyPlayingId;
  Timer? _playbackTimer;

  @override
  void initState() {
    super.initState();
    _loadRecordings();
  }

  void _loadRecordings() {
    setState(() {
      _recordings = StorageService().getSavedRecordings();
    });
  }

  void _playRecording(Map<String, dynamic> item) {
    _stopPlayback();
    final String id = item['id'];
    final String instrument = item['instrument'] ?? 'Piano';
    final List events = item['events'] ?? [];

    if (events.isEmpty) return;

    setState(() {
      _currentlyPlayingId = id;
    });

    int index = 0;
    DateTime startTime = DateTime.now();

    _playbackTimer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (index >= events.length) {
        _stopPlayback();
        return;
      }

      int elapsed = DateTime.now().difference(startTime).inMilliseconds;
      var event = events[index];
      int targetMs = event['timestampMs'] ?? 0;

      if (elapsed >= targetMs) {
        if (instrument == 'Piano') {
          int midi = event['midiNote'] ?? 60;
          AudioEngine().playPianoNote(midi);
        } else {
          String bol = event['bol'] ?? 'Dha';
          AudioEngine().playTablaBol(bol);
        }
        index++;
      }
    });
  }

  void _stopPlayback() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
    if (mounted) {
      setState(() {
        _currentlyPlayingId = null;
      });
    }
  }

  Future<void> _deleteRecording(String id) async {
    _stopPlayback();
    await StorageService().deleteRecording(id);
    _loadRecordings();
  }

  @override
  void dispose() {
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
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.mic_off_rounded, size: 64, color: AppColors.textMuted),
                          SizedBox(height: 12),
                          Text(
                            'No Offline Recordings Yet',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Tap the Record button while playing Piano or Tabla to save your jams offline.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _recordings.length,
                      itemBuilder: (context, index) {
                        final item = _recordings[index];
                        final isPlaying = _currentlyPlayingId == item['id'];
                        final String title = item['title'] ?? 'Untitled Jam';
                        final String instrument = item['instrument'] ?? 'Piano';
                        final int durationMs = item['durationMs'] ?? 0;
                        final List events = item['events'] ?? [];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: instrument == 'Piano'
                                    ? AppColors.pianoGold.withValues(alpha: 0.15)
                                    : AppColors.tablaAmber.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                instrument == 'Piano' ? '🎹' : '🪘',
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                            title: Text(
                              title,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '$instrument • ${events.length} Notes • ${(durationMs / 1000).toStringAsFixed(1)}s',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                                    color: isPlaying ? AppColors.recordRed : AppColors.primaryCyan,
                                    size: 32,
                                  ),
                                  onPressed: () {
                                    if (isPlaying) {
                                      _stopPlayback();
                                    } else {
                                      _playRecording(item);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.white38),
                                  onPressed: () => _deleteRecording(item['id']),
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
