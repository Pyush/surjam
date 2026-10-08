import 'package:flutter/material.dart';

class DJTrackModel {
  final String id;
  final String name;
  final String category;
  final Color padColor;

  const DJTrackModel({
    required this.id,
    required this.name,
    required this.category,
    required this.padColor,
  });

  static const List<DJTrackModel> defaultTracks = [
    DJTrackModel(id: 'drums', name: 'Electro Drums', category: 'Drums', padColor: Color(0xFF00E5FF)),
    DJTrackModel(id: 'bass', name: 'Deep Sub Bass', category: 'Bass', padColor: Color(0xFFE53170)),
    DJTrackModel(id: 'chords', name: 'Synth Chords', category: 'Chords', padColor: Color(0xFFFFB703)),
    DJTrackModel(id: 'lead', name: 'Arp Lead', category: 'Lead', padColor: Color(0xFF7F5AF0)),
    DJTrackModel(id: 'vocal', name: 'Vocal Chops', category: 'Vocal', padColor: Color(0xFFB5179E)),
    DJTrackModel(id: 'percussion', name: 'Hi-Hat Groove', category: 'Percussion', padColor: Color(0xFF2CB67D)),
    DJTrackModel(id: 'piano_stab', name: 'House Piano', category: 'Keys', padColor: Color(0xFFFF9F1C)),
    DJTrackModel(id: 'fx_riser', name: 'FX Riser Sweep', category: 'FX', padColor: Color(0xFF00F5D4)),
  ];
}

class DJSoundPack {
  final String id;
  final String name;
  final int defaultBpm;

  const DJSoundPack({
    required this.id,
    required this.name,
    required this.defaultBpm,
  });

  static const List<DJSoundPack> soundPacks = [
    DJSoundPack(id: 'electro_house', name: 'Electro House Pack (124 BPM)', defaultBpm: 124),
    DJSoundPack(id: 'synthwave_retro', name: 'Synthwave Retro Pack (118 BPM)', defaultBpm: 118),
    DJSoundPack(id: 'indian_fusion', name: 'Indian Fusion Beat Pack (128 BPM)', defaultBpm: 128),
  ];
}
