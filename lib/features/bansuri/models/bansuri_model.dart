class BansuriPreset {
  final String id;
  final String name;
  final String keyName;
  final int rootMidi;
  final String description;

  const BansuriPreset({
    required this.id,
    required this.name,
    required this.keyName,
    required this.rootMidi,
    required this.description,
  });

  static const List<BansuriPreset> preloadedPresets = [
    BansuriPreset(
      id: 'c_natural',
      name: 'C Natural Bansuri',
      keyName: 'C4',
      rootMidi: 60,
      description: 'Standard medium concert pitch Bansuri (Sa = C4)',
    ),
    BansuriPreset(
      id: 'e_medium',
      name: 'E Medium Bansuri',
      keyName: 'E4',
      rootMidi: 64,
      description: 'Warm medium-toned classical flute (Sa = E4)',
    ),
    BansuriPreset(
      id: 'g_bass',
      name: 'G Bass Bansuri',
      keyName: 'G3',
      rootMidi: 55,
      description: 'Deep resonant low bass Bansuri (Sa = G3)',
    ),
  ];
}

class FingeringPattern {
  final List<double> holeCoverages; // 6 elements, 0.0 (open), 0.5 (half), 1.0 (closed)
  final int semitoneOffsetFromRoot;
  final String swaraName;

  const FingeringPattern({
    required this.holeCoverages,
    required this.semitoneOffsetFromRoot,
    required this.swaraName,
  });

  static const List<FingeringPattern> standardFingerings = [
    FingeringPattern(holeCoverages: [1.0, 1.0, 1.0, 1.0, 1.0, 1.0], semitoneOffsetFromRoot: 0, swaraName: 'Sa'),
    FingeringPattern(holeCoverages: [1.0, 1.0, 1.0, 1.0, 1.0, 0.5], semitoneOffsetFromRoot: 1, swaraName: 're'),
    FingeringPattern(holeCoverages: [1.0, 1.0, 1.0, 1.0, 1.0, 0.0], semitoneOffsetFromRoot: 2, swaraName: 'Re'),
    FingeringPattern(holeCoverages: [1.0, 1.0, 1.0, 1.0, 0.5, 0.0], semitoneOffsetFromRoot: 3, swaraName: 'ga'),
    FingeringPattern(holeCoverages: [1.0, 1.0, 1.0, 1.0, 0.0, 0.0], semitoneOffsetFromRoot: 4, swaraName: 'Ga'),
    FingeringPattern(holeCoverages: [1.0, 1.0, 1.0, 0.0, 0.0, 0.0], semitoneOffsetFromRoot: 5, swaraName: 'Ma'),
    FingeringPattern(holeCoverages: [1.0, 1.0, 0.5, 0.0, 0.0, 0.0], semitoneOffsetFromRoot: 6, swaraName: 'MA'),
    FingeringPattern(holeCoverages: [1.0, 1.0, 0.0, 0.0, 0.0, 0.0], semitoneOffsetFromRoot: 7, swaraName: 'Pa'),
    FingeringPattern(holeCoverages: [1.0, 0.5, 0.0, 0.0, 0.0, 0.0], semitoneOffsetFromRoot: 8, swaraName: 'dha'),
    FingeringPattern(holeCoverages: [1.0, 0.0, 0.0, 0.0, 0.0, 0.0], semitoneOffsetFromRoot: 9, swaraName: 'Dha'),
    FingeringPattern(holeCoverages: [0.5, 0.0, 0.0, 0.0, 0.0, 0.0], semitoneOffsetFromRoot: 10, swaraName: 'ni'),
    FingeringPattern(holeCoverages: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0], semitoneOffsetFromRoot: 11, swaraName: 'Ni'),
  ];
}
