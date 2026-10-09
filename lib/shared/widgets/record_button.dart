import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/recording/jam_recorder.dart';
import '../../core/storage/storage_service.dart';
import '../../core/theme/app_colors.dart';

/// REC / STOP control for any instrument screen. Everything played while it is on, including
/// loops and sequencers, is saved to Jam Recordings.
///
/// [compact] gives an app-bar icon; otherwise a labelled button with the running time.
class RecordButton extends StatefulWidget {
  final String instrument;
  final bool compact;

  const RecordButton({super.key, required this.instrument, this.compact = false});

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  final JamRecorder _recorder = JamRecorder.instance;
  Timer? _clockTick;

  bool get _recordingHere => _recorder.isRecording && _recorder.instrument == widget.instrument;

  @override
  void initState() {
    super.initState();
    _recorder.addListener(_onRecorderChanged);
    _syncClock();
  }

  @override
  void dispose() {
    _recorder.removeListener(_onRecorderChanged);
    _clockTick?.cancel();
    // Leaving the screen mid-recording keeps the take instead of losing it.
    if (_recordingHere) {
      _recorder.stopAndSave(StorageService.autoSavedRecordingTitle('${widget.instrument} jam'));
    }
    super.dispose();
  }

  void _onRecorderChanged() {
    _syncClock();
    if (mounted) setState(() {});
  }

  /// While recording on this screen, refresh the running time once a second.
  void _syncClock() {
    _clockTick?.cancel();
    _clockTick = _recordingHere
        ? Timer.periodic(const Duration(seconds: 1), (_) {
            if (mounted) setState(() {});
          })
        : null;
  }

  Future<void> _onPressed() async {
    if (!_recordingHere) {
      _recorder.start(widget.instrument);
      return;
    }
    final take = _recorder.stop();
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (take == null) {
      messenger?.showSnackBar(const SnackBar(content: Text('Nothing was played, so nothing was saved.')));
      return;
    }
    final title = await _askForTitle();
    if (title == null) {
      messenger?.showSnackBar(const SnackBar(content: Text('Recording discarded.')));
      return;
    }
    final saved = await _recorder.save(take, title);
    messenger?.showSnackBar(SnackBar(content: Text('Saved "${saved.title}" to Jam Recordings.')));
  }

  /// Returns the chosen title, or null to discard.
  Future<String?> _askForTitle() => showDialog<String>(
        context: context,
        builder: (context) => _SaveRecordingDialog(
          initialTitle: StorageService.autoSavedRecordingTitle('${widget.instrument} jam'),
        ),
      );

  String get _elapsedLabel {
    final seconds = _recorder.elapsed.inSeconds;
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final recording = _recordingHere;

    if (widget.compact) {
      return IconButton(
        tooltip: recording ? 'Stop recording ($_elapsedLabel)' : 'Record',
        icon: Icon(
          recording ? Icons.stop_circle_rounded : Icons.fiber_manual_record_rounded,
          color: recording ? AppColors.recordRed : Colors.redAccent,
          size: recording ? 28 : 24,
        ),
        onPressed: _onPressed,
      );
    }

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: recording ? AppColors.recordRed : Colors.white10,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Icon(
        recording ? Icons.stop_circle_rounded : Icons.fiber_manual_record_rounded,
        color: recording ? Colors.white : Colors.redAccent,
        size: 20,
      ),
      label: Text(
        recording ? 'STOP $_elapsedLabel' : 'REC',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
      onPressed: _onPressed,
    );
  }
}

/// Owns its text controller so it is disposed only after the dialog's closing animation,
/// when the text field is really gone.
class _SaveRecordingDialog extends StatefulWidget {
  final String initialTitle;

  const _SaveRecordingDialog({required this.initialTitle});

  @override
  State<_SaveRecordingDialog> createState() => _SaveRecordingDialogState();
}

class _SaveRecordingDialogState extends State<_SaveRecordingDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialTitle);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save Recording'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Discard'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
