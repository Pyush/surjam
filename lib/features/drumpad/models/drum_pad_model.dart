import 'package:flutter/material.dart';

class DrumPadModel {
  final int id;
  final String label;
  final String soundKey;
  final Color color;

  const DrumPadModel({
    required this.id,
    required this.label,
    required this.soundKey,
    required this.color,
  });

  static const List<DrumPadModel> defaultPads = [
    // Row 1: High Percussion & FX
    DrumPadModel(id: 0, label: 'CRASH', soundKey: 'crash', color: Color(0xFFE53170)),
    DrumPadModel(id: 1, label: 'CLAP', soundKey: 'clap', color: Color(0xFFE53170)),
    DrumPadModel(id: 2, label: 'HI-HAT (O)', soundKey: 'hihat_open', color: Color(0xFF7F5AF0)),
    DrumPadModel(id: 3, label: 'HI-HAT (C)', soundKey: 'hihat_close', color: Color(0xFF7F5AF0)),

    // Row 2: Toms & Percussion
    DrumPadModel(id: 4, label: 'TOM 1', soundKey: 'tom', color: Color(0xFF00E5FF)),
    DrumPadModel(id: 5, label: 'TOM 2', soundKey: 'tom', color: Color(0xFF00E5FF)),
    DrumPadModel(id: 6, label: 'PERC 1', soundKey: 'na', color: Color(0xFF2CB67D)),
    DrumPadModel(id: 7, label: 'PERC 2', soundKey: 'tin', color: Color(0xFF2CB67D)),

    // Row 3: Snares & Percussion
    DrumPadModel(id: 8, label: 'SNARE 1', soundKey: 'snare', color: Color(0xFFFFB703)),
    DrumPadModel(id: 9, label: 'SNARE 2', soundKey: 'snare', color: Color(0xFFFFB703)),
    DrumPadModel(id: 10, label: 'SHAKER', soundKey: 'ke', color: Color(0xFF2CB67D)),
    DrumPadModel(id: 11, label: 'RIMSHOT', soundKey: 'ta', color: Color(0xFF2CB67D)),

    // Row 4: Kicks & Bass
    DrumPadModel(id: 12, label: 'KICK 1', soundKey: 'kick', color: Color(0xFFFF8906)),
    DrumPadModel(id: 13, label: 'KICK 2', soundKey: 'kick', color: Color(0xFFFF8906)),
    DrumPadModel(id: 14, label: 'SUB KICK', soundKey: 'ge', color: Color(0xFFFF8906)),
    DrumPadModel(id: 15, label: 'BASS DROP', soundKey: 'dha', color: Color(0xFFFF8906)),
  ];
}
