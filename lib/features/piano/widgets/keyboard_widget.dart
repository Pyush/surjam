import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/piano_key_model.dart';
import '../models/chord_scale_data.dart';
import '../providers/piano_provider.dart';
import '../../../core/theme/app_colors.dart';

class KeyboardWidget extends StatefulWidget {
  const KeyboardWidget({super.key});

  @override
  State<KeyboardWidget> createState() => _KeyboardWidgetState();
}

class _KeyboardWidgetState extends State<KeyboardWidget> {
  static const double _minWhiteKeyWidth = 44.0;
  static const double _borderWidth = 1.5;

  final ScrollController _scrollController = ScrollController();
  int? _scrolledLearnTarget;

  // Keeps the next learn-mode note on screen when the keyboard is wider than the view.
  void _scrollToLearnTarget(PianoProvider provider, List<PianoKeyModel> whiteKeys, double whiteKeyWidth, double viewWidth) {
    // Follow the "Listen" demo while it plays, otherwise the next note to press.
    final target = provider.demoNote ?? provider.targetLearnMidiNote;
    if (target == null || target == _scrolledLearnTarget) return;
    _scrolledLearnTarget = target;

    // A black key sits on the boundary after its lower white neighbour.
    final whiteIndex = whiteKeys.lastIndexWhere((k) => k.midiNote <= target);
    if (whiteIndex < 0) return;
    final keyCenter = (whiteIndex + (whiteKeys[whiteIndex].midiNote == target ? 0.5 : 1.0)) * whiteKeyWidth;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final position = _scrollController.position;
      final visibleStart = position.pixels;
      final margin = whiteKeyWidth;
      if (keyCenter < visibleStart + margin || keyCenter > visibleStart + viewWidth - margin) {
        _scrollController.animateTo(
          (keyCenter - viewWidth / 2).clamp(0.0, position.maxScrollExtent),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PianoProvider>();
    // Octave 4 starts at C4 (MIDI 60). Render 2 full octaves (24 keys: 14 white + 10 black)
    final startMidi = provider.octave * 12 + 12;

    final List<PianoKeyModel> allKeys = List.generate(
      24,
      (i) => PianoKeyModel.fromMidi(startMidi + i),
    );

    final whiteKeys = allKeys.where((k) => !k.isBlack).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        // The keys live inside the border, so size them from the inner width.
        final double containerWidth = constraints.maxWidth - 2 * _borderWidth;
        final double containerHeight = constraints.maxHeight;

        // Both octaves fit when keys can be at least the minimum touch width (landscape);
        // on narrow portrait screens keys keep that width and the keyboard scrolls.
        final double whiteKeyWidth = (containerWidth / whiteKeys.length).clamp(_minWhiteKeyWidth, 64.0);
        _scrollToLearnTarget(provider, whiteKeys, whiteKeyWidth, containerWidth);

        final double blackKeyWidth = whiteKeyWidth * 0.62;
        final double blackKeyHeight = containerHeight * 0.60;

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF12111A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.darkCardBorder, width: _borderWidth),
            boxShadow: const [
              BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: SizedBox(
                width: whiteKeyWidth * whiteKeys.length,
                height: containerHeight,
                child: Stack(
                  children: [
                    // 1. White Keys Layer (Left to Right)
                    Row(
                      children: whiteKeys.map((key) {
                        return SizedBox(
                          width: whiteKeyWidth,
                          height: containerHeight,
                          child: _buildWhiteKey(context, provider, key),
                        );
                      }).toList(),
                    ),

                    // 2. Black Keys Layer (Positioned over white key borders)
                    ..._buildBlackKeys(
                      context,
                      provider,
                      allKeys,
                      whiteKeyWidth,
                      blackKeyWidth,
                      blackKeyHeight,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWhiteKey(BuildContext context, PianoProvider provider, PianoKeyModel key) {
    final isPressed = provider.activePressedKeys.contains(key.midiNote) || provider.demoNote == key.midiNote;
    final isLearnTarget = provider.targetLearnMidiNote == key.midiNote;
    final isHighlighted = _isNoteHighlighted(provider, key.midiNote);

    Color keyColor = isPressed
        ? AppColors.whiteKeyPressed
        : (isLearnTarget ? AppColors.whiteKeyHighlight : AppColors.whiteKeyNormal);

    return Listener(
      onPointerDown: (_) => provider.onNoteDown(key.midiNote),
      onPointerUp: (_) => provider.onNoteUp(key.midiNote),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        margin: const EdgeInsets.symmetric(horizontal: 0.8),
        decoration: BoxDecoration(
          color: keyColor,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
          gradient: isPressed
              ? null
              : LinearGradient(
                  colors: isLearnTarget
                      ? [AppColors.learnGreen.withValues(alpha: 0.9), AppColors.whiteKeyHighlight]
                      : [Colors.white, const Color(0xFFE2E4E9)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
          boxShadow: isLearnTarget
              ? [BoxShadow(color: AppColors.learnGreen.withValues(alpha: 0.9), blurRadius: 14, spreadRadius: 3)]
              : [const BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 2))],
          border: Border.all(
            color: isHighlighted ? AppColors.primaryNeon : const Color(0xFFC0C4CC),
            width: isHighlighted ? 2.5 : 0.8,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (isHighlighted)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(bottom: 6),
                decoration: const BoxDecoration(
                  color: AppColors.primaryNeon,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.primaryNeon, blurRadius: 6)],
                ),
              ),
            Text(
              _getLabel(key, provider.keyLabelMode),
              style: TextStyle(
                color: isPressed ? Colors.black : Colors.grey.shade900,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBlackKeys(
    BuildContext context,
    PianoProvider provider,
    List<PianoKeyModel> allKeys,
    double whiteKeyWidth,
    double blackKeyWidth,
    double blackKeyHeight,
  ) {
    final List<Widget> widgets = [];
    int whiteIndex = 0;

    for (int i = 0; i < allKeys.length; i++) {
      final key = allKeys[i];
      if (!key.isBlack) {
        whiteIndex++;
      } else {
        double left = (whiteIndex * whiteKeyWidth) - (blackKeyWidth / 2);

        final isPressed = provider.activePressedKeys.contains(key.midiNote) || provider.demoNote == key.midiNote;
        final isLearnTarget = provider.targetLearnMidiNote == key.midiNote;
        final isHighlighted = _isNoteHighlighted(provider, key.midiNote);

        Color keyColor = isPressed
            ? AppColors.blackKeyPressed
            : (isLearnTarget ? AppColors.blackKeyHighlight : AppColors.blackKeyNormal);

        widgets.add(
          Positioned(
            left: left,
            top: 0,
            width: blackKeyWidth,
            height: blackKeyHeight,
            child: Listener(
              onPointerDown: (_) => provider.onNoteDown(key.midiNote),
              onPointerUp: (_) => provider.onNoteUp(key.midiNote),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 50),
                decoration: BoxDecoration(
                  color: keyColor,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
                  gradient: isPressed
                      ? null
                      : LinearGradient(
                          colors: isLearnTarget
                              ? [AppColors.learnGreen, AppColors.blackKeyHighlight]
                              : [const Color(0xFF2B2A36), const Color(0xFF14131A)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                  boxShadow: isLearnTarget
                      ? [BoxShadow(color: AppColors.learnGreen.withValues(alpha: 0.9), blurRadius: 14, spreadRadius: 3)]
                      : [const BoxShadow(color: Colors.black87, blurRadius: 4, offset: Offset(2, 3))],
                  border: Border.all(
                    color: isHighlighted ? AppColors.primaryNeon : Colors.black,
                    width: isHighlighted ? 2.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isHighlighted)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryNeon,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Text(
                      _getLabel(key, provider.keyLabelMode),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }

  bool _isNoteHighlighted(PianoProvider provider, int midiNote) {
    if (provider.selectedScale != null) {
      final scaleIntervals = MusicTheoryData.scales[provider.selectedScale];
      if (scaleIntervals != null) {
        int index = midiNote % 12;
        return scaleIntervals.contains(index);
      }
    }
    if (provider.selectedChord != null) {
      final chordMidis = MusicTheoryData.chords[provider.selectedChord];
      if (chordMidis != null) {
        return chordMidis.contains(midiNote);
      }
    }
    return false;
  }

  String _getLabel(PianoKeyModel key, String mode) {
    if (mode == 'sargam') return key.sargamLabel;
    if (mode == 'none') return '';
    return key.noteName;
  }
}
