class TunerTargetNote {
  final String label;
  final int midiNote;

  const TunerTargetNote({
    required this.label,
    required this.midiNote,
  });
}

class TunerPreset {
  final String id;
  final String name;
  final List<TunerTargetNote> targetNotes;

  const TunerPreset({
    required this.id,
    required this.name,
    required this.targetNotes,
  });

  static const List<TunerPreset> preloadedPresets = [
    TunerPreset(
      id: 'guitar',
      name: 'Standard Guitar (E2-E4)',
      targetNotes: [
        TunerTargetNote(label: '6-E2', midiNote: 40),
        TunerTargetNote(label: '5-A2', midiNote: 45),
        TunerTargetNote(label: '4-D3', midiNote: 50),
        TunerTargetNote(label: '3-G3', midiNote: 55),
        TunerTargetNote(label: '2-B3', midiNote: 59),
        TunerTargetNote(label: '1-E4', midiNote: 64),
      ],
    ),
    TunerPreset(
      id: 'ukulele',
      name: 'Ukulele (G4 C4 E4 A4)',
      targetNotes: [
        TunerTargetNote(label: '4-G4', midiNote: 67),
        TunerTargetNote(label: '3-C4', midiNote: 60),
        TunerTargetNote(label: '2-E4', midiNote: 64),
        TunerTargetNote(label: '1-A4', midiNote: 69),
      ],
    ),
    TunerPreset(
      id: 'sitar',
      name: 'Sitar Main Strings (C3/Sa)',
      targetNotes: [
        TunerTargetNote(label: 'Baj (Ma)', midiNote: 53),
        TunerTargetNote(label: 'Jori (Sa)', midiNote: 48),
        TunerTargetNote(label: 'Laraj (Pa)', midiNote: 43),
        TunerTargetNote(label: 'Chikari (Sa)', midiNote: 72),
      ],
    ),
    TunerPreset(
      id: 'violin',
      name: 'Violin (G3 D4 A4 E5)',
      targetNotes: [
        TunerTargetNote(label: '4-G3', midiNote: 55),
        TunerTargetNote(label: '3-D4', midiNote: 62),
        TunerTargetNote(label: '2-A4', midiNote: 69),
        TunerTargetNote(label: '1-E5', midiNote: 76),
      ],
    ),
    TunerPreset(
      id: 'vocal_chromatic',
      name: 'Vocal Singing Practice',
      targetNotes: [
        TunerTargetNote(label: 'Sa (C4)', midiNote: 60),
        TunerTargetNote(label: 'Re (D4)', midiNote: 62),
        TunerTargetNote(label: 'Ga (E4)', midiNote: 64),
        TunerTargetNote(label: 'Ma (F4)', midiNote: 65),
        TunerTargetNote(label: 'Pa (G4)', midiNote: 67),
        TunerTargetNote(label: 'Dha (A4)', midiNote: 69),
        TunerTargetNote(label: 'Ni (B4)', midiNote: 71),
        TunerTargetNote(label: 'Sa\' (C5)', midiNote: 72),
      ],
    ),
  ];
}
