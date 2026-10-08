class TaalBeat {
  final String bol;
  final bool isSam;   // First beat of Taal (x)
  final bool isKhali; // Unstressed beat (o)
  final int division; // Vibhag section index

  const TaalBeat({
    required this.bol,
    this.isSam = false,
    this.isKhali = false,
    this.division = 1,
  });
}

class TaalModel {
  final String id;
  final String name;
  final int totalBeats;
  final String timeSignature;
  final List<TaalBeat> beats;

  const TaalModel({
    required this.id,
    required this.name,
    required this.totalBeats,
    required this.timeSignature,
    required this.beats,
  });

  static const List<TaalModel> preloadedTaals = [
    TaalModel(
      id: 'teentaal',
      name: 'Teentaal (16 Beats)',
      totalBeats: 16,
      timeSignature: '4/4',
      beats: [
        TaalBeat(bol: 'Dha', isSam: true, division: 1),
        TaalBeat(bol: 'Dhin', division: 1),
        TaalBeat(bol: 'Dhin', division: 1),
        TaalBeat(bol: 'Dha', division: 1),
        TaalBeat(bol: 'Dha', division: 2),
        TaalBeat(bol: 'Dhin', division: 2),
        TaalBeat(bol: 'Dhin', division: 2),
        TaalBeat(bol: 'Dha', division: 2),
        TaalBeat(bol: 'Dha', isKhali: true, division: 3),
        TaalBeat(bol: 'Tin', division: 3),
        TaalBeat(bol: 'Tin', division: 3),
        TaalBeat(bol: 'Ta', division: 3),
        TaalBeat(bol: 'Ta', division: 4),
        TaalBeat(bol: 'Dhin', division: 4),
        TaalBeat(bol: 'Dhin', division: 4),
        TaalBeat(bol: 'Dha', division: 4),
      ],
    ),
    TaalModel(
      id: 'dadra',
      name: 'Dadra (6 Beats)',
      totalBeats: 6,
      timeSignature: '3/4',
      beats: [
        TaalBeat(bol: 'Dha', isSam: true, division: 1),
        TaalBeat(bol: 'Dhin', division: 1),
        TaalBeat(bol: 'Na', division: 1),
        TaalBeat(bol: 'Dha', isKhali: true, division: 2),
        TaalBeat(bol: 'Tin', division: 2),
        TaalBeat(bol: 'Na', division: 2),
      ],
    ),
    TaalModel(
      id: 'keharwa',
      name: 'Keharwa (8 Beats)',
      totalBeats: 8,
      timeSignature: '4/4',
      beats: [
        TaalBeat(bol: 'Dha', isSam: true, division: 1),
        TaalBeat(bol: 'Ge', division: 1),
        TaalBeat(bol: 'Na', division: 1),
        TaalBeat(bol: 'Tin', division: 1),
        TaalBeat(bol: 'Na', isKhali: true, division: 2),
        TaalBeat(bol: 'Ke', division: 2),
        TaalBeat(bol: 'Dhin', division: 2),
        TaalBeat(bol: 'Na', division: 2),
      ],
    ),
    TaalModel(
      id: 'roopak',
      name: 'Roopak (7 Beats)',
      totalBeats: 7,
      timeSignature: '3+2+2',
      beats: [
        TaalBeat(bol: 'Tin', isSam: true, isKhali: true, division: 1),
        TaalBeat(bol: 'Tin', division: 1),
        TaalBeat(bol: 'Na', division: 1),
        TaalBeat(bol: 'Dhin', division: 2),
        TaalBeat(bol: 'Na', division: 2),
        TaalBeat(bol: 'Dhin', division: 3),
        TaalBeat(bol: 'Na', division: 3),
      ],
    ),
    TaalModel(
      id: 'jhaptal',
      name: 'Jhaptal (10 Beats)',
      totalBeats: 10,
      timeSignature: '2+3+2+3',
      beats: [
        TaalBeat(bol: 'Dhin', isSam: true, division: 1),
        TaalBeat(bol: 'Na', division: 1),
        TaalBeat(bol: 'Dhin', division: 2),
        TaalBeat(bol: 'Dhin', division: 2),
        TaalBeat(bol: 'Na', division: 2),
        TaalBeat(bol: 'Tin', isKhali: true, division: 3),
        TaalBeat(bol: 'Na', division: 3),
        TaalBeat(bol: 'Dhin', division: 4),
        TaalBeat(bol: 'Dhin', division: 4),
        TaalBeat(bol: 'Na', division: 4),
      ],
    ),
  ];
}
