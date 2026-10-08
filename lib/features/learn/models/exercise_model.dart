class ExerciseModel {
  static const String warmUps = 'Warm-ups';
  static const String scales = 'Scales';
  static const String chords = 'Chords & Arpeggios';
  static const String sargam = 'Sargam Alankars';
  static const String songs = 'Songs';
  static const List<String> categories = [warmUps, scales, chords, sargam, songs];

  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String difficulty;
  final List<int> midiSequence;

  /// Right-hand finger for each note (1 = thumb ... 5 = little finger), where a standard
  /// fingering exists. Null when the lesson has no fixed fingering.
  final List<int>? fingers;

  /// Length of each note in beats for the "Listen" demo. Null means every note is one beat.
  final List<double>? beats;

  /// Demo tempo in beats per minute.
  final int bpm;

  const ExerciseModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.difficulty,
    required this.midiSequence,
    this.fingers,
    this.beats,
    this.bpm = 90,
  });

  static List<ExerciseModel> inCategory(String category) =>
      preloadedExercises.where((e) => e.category == category).toList();

  // Every lesson stays within C4 (MIDI 60) to B5 (MIDI 83), the two octaves the keyboard shows.
  // Melodies are public-domain traditional tunes and classical works.
  static const List<ExerciseModel> preloadedExercises = [
    // ---------------------------------------------------------------- Warm-ups
    ExerciseModel(
      id: 'ex_five_finger_c',
      title: 'Five-Finger Warm-up',
      subtitle: 'One finger per key from C to G and back. Keep your hand still.',
      category: warmUps,
      difficulty: 'Beginner',
      midiSequence: [60, 62, 64, 65, 67, 65, 64, 62, 60],
      fingers: [1, 2, 3, 4, 5, 4, 3, 2, 1],
    ),
    ExerciseModel(
      id: 'ex_black_keys',
      title: 'Black Key Explorer',
      subtitle: 'Find the groups of two and three black keys.',
      category: warmUps,
      difficulty: 'Beginner',
      midiSequence: [61, 63, 66, 68, 70, 68, 66, 63, 61],
      fingers: [2, 3, 2, 3, 4, 3, 2, 3, 2],
    ),
    ExerciseModel(
      id: 'ex_chromatic',
      title: 'Chromatic Climb',
      subtitle: 'Every white and black key from C4 to C5 and back down.',
      category: warmUps,
      difficulty: 'Intermediate',
      midiSequence: [60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 71, 70, 69, 68, 67, 66, 65, 64, 63, 62, 61, 60],
      // White keys with the thumb, black keys with finger 3; E-F and B-C use 1-2.
      fingers: [1, 3, 1, 3, 1, 2, 3, 1, 3, 1, 3, 1, 2, 1, 3, 1, 3, 1, 3, 2, 1, 3, 1, 3, 1],
    ),

    // ---------------------------------------------------------------- Scales
    ExerciseModel(
      id: 'ex_c_major',
      title: 'C Major Scale (Ascending)',
      subtitle: 'Thumb tucks under after E so finger 1 lands on F.',
      category: scales,
      difficulty: 'Beginner',
      midiSequence: [60, 62, 64, 65, 67, 69, 71, 72],
      fingers: [1, 2, 3, 1, 2, 3, 4, 5],
    ),
    ExerciseModel(
      id: 'ex_c_major_updown',
      title: 'C Major Scale Up & Down',
      subtitle: 'Coming down, finger 3 crosses over the thumb onto E.',
      category: scales,
      difficulty: 'Beginner',
      midiSequence: [60, 62, 64, 65, 67, 69, 71, 72, 71, 69, 67, 65, 64, 62, 60],
      fingers: [1, 2, 3, 1, 2, 3, 4, 5, 4, 3, 2, 1, 3, 2, 1],
    ),
    ExerciseModel(
      id: 'ex_g_major',
      title: 'G Major Scale',
      subtitle: 'One sharp: F#. Same fingering as C major.',
      category: scales,
      difficulty: 'Intermediate',
      midiSequence: [67, 69, 71, 72, 74, 76, 78, 79],
      fingers: [1, 2, 3, 1, 2, 3, 4, 5],
    ),
    ExerciseModel(
      id: 'ex_d_major',
      title: 'D Major Scale',
      subtitle: 'Two sharps: F# and C#.',
      category: scales,
      difficulty: 'Intermediate',
      midiSequence: [62, 64, 66, 67, 69, 71, 73, 74],
      fingers: [1, 2, 3, 1, 2, 3, 4, 5],
    ),
    ExerciseModel(
      id: 'ex_f_major',
      title: 'F Major Scale',
      subtitle: 'One flat: Bb. Finger 4 plays Bb, then the thumb tucks under to C.',
      category: scales,
      difficulty: 'Intermediate',
      midiSequence: [65, 67, 69, 70, 72, 74, 76, 77],
      fingers: [1, 2, 3, 4, 1, 2, 3, 4],
    ),
    ExerciseModel(
      id: 'ex_a_minor',
      title: 'A Natural Minor Scale',
      subtitle: 'All white keys from A. Notice the darker, sadder sound.',
      category: scales,
      difficulty: 'Intermediate',
      midiSequence: [69, 71, 72, 74, 76, 77, 79, 81],
      fingers: [1, 2, 3, 1, 2, 3, 4, 5],
    ),

    // ---------------------------------------------------------------- Chords & arpeggios
    ExerciseModel(
      id: 'ex_arpeggio',
      title: 'C Major Arpeggio Wave',
      subtitle: 'Smooth broken chord movement up and down',
      category: chords,
      difficulty: 'Beginner',
      midiSequence: [60, 64, 67, 72, 67, 64, 60],
      fingers: [1, 2, 3, 5, 3, 2, 1],
    ),
    ExerciseModel(
      id: 'ex_a_minor_arpeggio',
      title: 'A Minor Arpeggio',
      subtitle: 'The minor version of the arpeggio wave.',
      category: chords,
      difficulty: 'Beginner',
      midiSequence: [69, 72, 76, 81, 76, 72, 69],
      fingers: [1, 2, 3, 5, 3, 2, 1],
    ),
    ExerciseModel(
      id: 'ex_chords',
      title: 'Primary Chords Progression',
      subtitle: 'Master C Major, F Major, and G Major chord triads',
      category: chords,
      difficulty: 'Intermediate',
      midiSequence: [60, 64, 67, 65, 69, 72, 67, 71, 74],
      fingers: [1, 3, 5, 1, 3, 5, 1, 3, 5],
    ),
    ExerciseModel(
      id: 'ex_pop_progression',
      title: 'Pop Progression (C G Am F)',
      subtitle: 'The four chords behind countless songs, played as broken chords.',
      category: chords,
      difficulty: 'Intermediate',
      midiSequence: [60, 64, 67, 67, 71, 74, 69, 72, 76, 65, 69, 72],
      fingers: [1, 3, 5, 1, 3, 5, 1, 3, 5, 1, 3, 5],
    ),

    // ---------------------------------------------------------------- Sargam alankars (Sa = C4)
    ExerciseModel(
      id: 'ex_sargam',
      title: 'Indian Sargam (Aroh & Avroh)',
      subtitle: 'Climb Sa Re Ga Ma Pa Dha Ni Sa\' and come back down',
      category: sargam,
      difficulty: 'Beginner',
      midiSequence: [60, 62, 64, 65, 67, 69, 71, 72, 71, 69, 67, 65, 64, 62, 60],
      fingers: [1, 2, 3, 1, 2, 3, 4, 5, 4, 3, 2, 1, 3, 2, 1],
    ),
    ExerciseModel(
      id: 'ex_alankar_pairs',
      title: 'Alankar: Pairs (SR RG GM ...)',
      subtitle: 'Each swara joins the next: SR RG GM MP PD DN NS\' and back.',
      category: sargam,
      difficulty: 'Beginner',
      midiSequence: [
        60, 62, 62, 64, 64, 65, 65, 67, 67, 69, 69, 71, 71, 72,
        72, 71, 71, 69, 69, 67, 67, 65, 65, 64, 64, 62, 62, 60,
      ],
    ),
    ExerciseModel(
      id: 'ex_alankar_triplets',
      title: 'Alankar: Threes (SRG RGM ...)',
      subtitle: 'Groups of three swaras: SRG RGM GMP MPD PDN DNS\' and back.',
      category: sargam,
      difficulty: 'Intermediate',
      midiSequence: [
        60, 62, 64, 62, 64, 65, 64, 65, 67, 65, 67, 69, 67, 69, 71, 69, 71, 72,
        72, 71, 69, 71, 69, 67, 69, 67, 65, 67, 65, 64, 65, 64, 62, 64, 62, 60,
      ],
    ),
    ExerciseModel(
      id: 'ex_alankar_skips',
      title: 'Alankar: Skips (SG RM GP ...)',
      subtitle: 'Jump over one swara each time: SG RM GP MD PN DS\' and back.',
      category: sargam,
      difficulty: 'Intermediate',
      midiSequence: [
        60, 64, 62, 65, 64, 67, 65, 69, 67, 71, 69, 72,
        72, 69, 71, 67, 69, 65, 67, 64, 65, 62, 64, 60,
      ],
    ),
    ExerciseModel(
      id: 'ex_alankar_fours',
      title: 'Alankar: Fours (SRGM RGMP ...)',
      subtitle: 'Groups of four swaras up to Sa\' and back down.',
      category: sargam,
      difficulty: 'Advanced',
      midiSequence: [
        60, 62, 64, 65, 62, 64, 65, 67, 64, 65, 67, 69, 65, 67, 69, 71, 67, 69, 71, 72,
        72, 71, 69, 67, 71, 69, 67, 65, 69, 67, 65, 64, 67, 65, 64, 62, 65, 64, 62, 60,
      ],
    ),

    // ---------------------------------------------------------------- Songs (public domain)
    ExerciseModel(
      id: 'song_twinkle',
      title: 'Twinkle Twinkle Little Star',
      subtitle: 'Traditional. Uses only the white keys from C to A.',
      category: songs,
      difficulty: 'Beginner',
      midiSequence: [
        60, 60, 67, 67, 69, 69, 67, 65, 65, 64, 64, 62, 62, 60,
        67, 67, 65, 65, 64, 64, 62, 67, 67, 65, 65, 64, 64, 62,
        60, 60, 67, 67, 69, 69, 67, 65, 65, 64, 64, 62, 62, 60,
      ],
      beats: [
        1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2,
        1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2,
        1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2,
      ],
      bpm: 100,
    ),
    ExerciseModel(
      id: 'song_mary',
      title: 'Mary Had a Little Lamb',
      subtitle: 'Traditional. Three notes for most of the song: E, D and C.',
      category: songs,
      difficulty: 'Beginner',
      midiSequence: [
        64, 62, 60, 62, 64, 64, 64, 62, 62, 62, 64, 67, 67,
        64, 62, 60, 62, 64, 64, 64, 64, 62, 62, 64, 62, 60,
      ],
      beats: [
        1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 1, 1, 2,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 4,
      ],
      bpm: 110,
    ),
    ExerciseModel(
      id: 'song_ode_to_joy',
      title: 'Ode to Joy',
      subtitle: 'Beethoven, Symphony No. 9. Moves step by step.',
      category: songs,
      difficulty: 'Beginner',
      midiSequence: [
        64, 64, 65, 67, 67, 65, 64, 62, 60, 60, 62, 64, 64, 62, 62,
        64, 64, 65, 67, 67, 65, 64, 62, 60, 60, 62, 64, 62, 60, 60,
      ],
      beats: [
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1.5, 0.5, 2,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1.5, 0.5, 2,
      ],
      bpm: 110,
    ),
    ExerciseModel(
      id: 'song_london_bridge',
      title: 'London Bridge Is Falling Down',
      subtitle: 'Traditional. Practise the step pattern G A G F.',
      category: songs,
      difficulty: 'Beginner',
      midiSequence: [
        67, 69, 67, 65, 64, 65, 67, 62, 64, 65, 64, 65, 67,
        67, 69, 67, 65, 64, 65, 67, 62, 67, 64, 60,
      ],
      beats: [
        1.5, 0.5, 1, 1, 1, 1, 2, 1, 1, 2, 1, 1, 2,
        1.5, 0.5, 1, 1, 1, 1, 2, 2, 2, 1, 3,
      ],
      bpm: 110,
    ),
    ExerciseModel(
      id: 'song_frere_jacques',
      title: 'Frère Jacques',
      subtitle: 'Traditional round, played in the higher octave (C5).',
      category: songs,
      difficulty: 'Intermediate',
      midiSequence: [
        72, 74, 76, 72, 72, 74, 76, 72,
        76, 77, 79, 76, 77, 79,
        79, 81, 79, 77, 76, 72, 79, 81, 79, 77, 76, 72,
        72, 67, 72, 72, 67, 72,
      ],
      beats: [
        1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 2, 1, 1, 2,
        0.5, 0.5, 0.5, 0.5, 1, 1, 0.5, 0.5, 0.5, 0.5, 1, 1,
        1, 1, 2, 1, 1, 2,
      ],
      bpm: 110,
    ),
    ExerciseModel(
      id: 'song_jingle_bells',
      title: 'Jingle Bells (Chorus)',
      subtitle: 'James Lord Pierpont, 1857. Lots of repeated E notes.',
      category: songs,
      difficulty: 'Intermediate',
      midiSequence: [
        64, 64, 64, 64, 64, 64, 64, 67, 60, 62, 64,
        65, 65, 65, 65, 65, 64, 64, 64, 64, 64, 62, 62, 64, 62, 67,
      ],
      beats: [
        1, 1, 2, 1, 1, 2, 1, 1, 1.5, 0.5, 4,
        1, 1, 1.5, 0.5, 1, 1, 1, 0.5, 0.5, 1, 1, 1, 1, 2, 2,
      ],
      bpm: 120,
    ),
    ExerciseModel(
      id: 'song_row_your_boat',
      title: 'Row, Row, Row Your Boat',
      subtitle: 'Traditional. Climbs to high C and steps back down.',
      category: songs,
      difficulty: 'Intermediate',
      midiSequence: [
        60, 60, 60, 62, 64, 64, 62, 64, 65, 67,
        72, 72, 72, 67, 67, 67, 64, 64, 64, 60, 60, 60,
        67, 65, 64, 62, 60,
      ],
      beats: [
        1.5, 1.5, 1, 0.5, 1.5, 1, 0.5, 1, 0.5, 3,
        0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5,
        1, 0.5, 1, 0.5, 3,
      ],
      bpm: 100,
    ),
  ];
}
