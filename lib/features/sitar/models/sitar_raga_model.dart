class SitarRagaModel {
  final String id;
  final String name;
  final String thaat;
  final String description;
  final List<int> intervals;

  const SitarRagaModel({
    required this.id,
    required this.name,
    required this.thaat,
    required this.description,
    required this.intervals,
  });

  static const List<SitarRagaModel> preloadedRagas = [
    SitarRagaModel(
      id: 'yaman',
      name: 'Raag Yaman',
      thaat: 'Kalyan',
      description: 'Serene evening Raga featuring Teevra Ma (#4)',
      intervals: [0, 2, 4, 6, 7, 9, 11], // Sa Re Ga MA Pa Dha Ni
    ),
    SitarRagaModel(
      id: 'bhairavi',
      name: 'Raag Bhairavi',
      thaat: 'Bhairavi',
      description: 'Morning Queen Raga with all 4 Komal Swaras (re, ga, dha, ni)',
      intervals: [0, 1, 3, 5, 7, 8, 10], // Sa re ga Ma Pa dha ni
    ),
    SitarRagaModel(
      id: 'kafi',
      name: 'Raag Kafi',
      thaat: 'Kafi',
      description: 'Melodic spring Raga with Komal ga and ni',
      intervals: [0, 2, 3, 5, 7, 9, 10], // Sa Re ga Ma Pa Dha ni
    ),
    SitarRagaModel(
      id: 'bhairav',
      name: 'Raag Bhairav',
      thaat: 'Bhairav',
      description: 'Majestic dawn Raga with Komal re and dha',
      intervals: [0, 1, 4, 5, 7, 8, 11], // Sa re Ga Ma Pa dha Ni
    ),
  ];
}
