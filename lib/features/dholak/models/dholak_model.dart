class DholakStroke {
  final String id;
  final String name;
  final String bol;
  final bool isTreble;
  final bool isBass;

  const DholakStroke({
    required this.id,
    required this.name,
    required this.bol,
    required this.isTreble,
    required this.isBass,
  });

  static const List<DholakStroke> allStrokes = [
    DholakStroke(id: 'taash', name: 'Taash (Sharp Rim)', bol: 'Ta', isTreble: true, isBass: false),
    DholakStroke(id: 'ti', name: 'Ti (Center Ring)', bol: 'Ti', isTreble: true, isBass: false),
    DholakStroke(id: 'dagga', name: 'Dagga (Open Bass)', bol: 'Ge', isTreble: false, isBass: true),
    DholakStroke(id: 'ghe', name: 'Ghe (Sliding Bass)', bol: 'Ghe', isTreble: false, isBass: true),
    DholakStroke(id: 'ka', name: 'Ka (Muted Slap)', bol: 'Ka', isTreble: false, isBass: true),
    DholakStroke(id: 'dha', name: 'Dha (Treble + Bass)', bol: 'Dha', isTreble: true, isBass: true),
    DholakStroke(id: 'dhin', name: 'Dhin (Ring + Bass)', bol: 'Dhin', isTreble: true, isBass: true),
    DholakStroke(id: 'dhabba', name: 'Dhabba (Bass Slap)', bol: 'Dhabba', isTreble: false, isBass: true),
  ];
}

class DholakFolkPattern {
  final String id;
  final String name;
  final String timeSignature;
  final int defaultBpm;
  final List<String> sequence;

  const DholakFolkPattern({
    required this.id,
    required this.name,
    required this.timeSignature,
    required this.defaultBpm,
    required this.sequence,
  });

  static const List<DholakFolkPattern> preloadedPatterns = [
    DholakFolkPattern(
      id: 'garba',
      name: 'Garba Folk Beat (6/8)',
      timeSignature: '6/8',
      defaultBpm: 150,
      sequence: ['dha', 'taash', 'ti', 'dagga', 'taash', 'ka'],
    ),
    DholakFolkPattern(
      id: 'bhangra',
      name: 'Bhangra Dhol Beat (8/8)',
      timeSignature: '8/8',
      defaultBpm: 135,
      sequence: ['dha', 'taash', 'dagga', 'taash', 'dhin', 'taash', 'ghe', 'ka'],
    ),
    DholakFolkPattern(
      id: 'bhajan',
      name: 'Bhajan Keharwa (8/8)',
      timeSignature: '8/8',
      defaultBpm: 120,
      sequence: ['dha', 'ge', 'na', 'ti', 'na', 'ka', 'dhin', 'na'],
    ),
    DholakFolkPattern(
      id: 'lavani',
      name: 'Lavani Fast Folk (6/8)',
      timeSignature: '6/8',
      defaultBpm: 175,
      sequence: ['dha', 'taash', 'dhabba', 'taash', 'ghe', 'ka'],
    ),
  ];
}
