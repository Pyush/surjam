import '../audio/sound_event.dart';

/// A sound and when it happened, in milliseconds from the start of the recording.
class TimedSoundEvent {
  final int timeMs;
  final SoundEvent sound;

  const TimedSoundEvent(this.timeMs, this.sound);

  Map<String, dynamic> toJson() => {'t': timeMs, ...sound.toJson()};

  factory TimedSoundEvent.fromJson(Map<String, dynamic> json) =>
      TimedSoundEvent(json['t'] as int, SoundEvent.fromJson(json));
}

/// A saved jam: every sound played on an instrument screen while REC was on.
class Recording {
  static const int formatVersion = 2;

  final String id;
  final String title;
  final String instrument;
  final DateTime createdAt;
  final int durationMs;
  final List<TimedSoundEvent> events;

  const Recording({
    required this.id,
    required this.title,
    required this.instrument,
    required this.createdAt,
    required this.durationMs,
    required this.events,
  });

  Map<String, dynamic> toJson() => {
        'version': formatVersion,
        'id': id,
        'title': title,
        'instrument': instrument,
        'createdAt': createdAt.toIso8601String(),
        'durationMs': durationMs,
        'events': events.map((e) => e.toJson()).toList(),
      };

  /// Also reads recordings saved before version 2, when only the piano (midiNote) and tabla
  /// (bol) could record.
  factory Recording.fromJson(Map<String, dynamic> json) {
    final instrument = json['instrument'] as String? ?? 'Piano';
    final rawEvents = (json['events'] as List? ?? []).cast<Map<String, dynamic>>();
    final events = json['version'] == null
        ? [
            for (final e in rawEvents)
              TimedSoundEvent(
                e['timestampMs'] as int? ?? 0,
                instrument == 'Tabla'
                    ? SoundEvent.tabla(e['bol'] as String? ?? 'dha')
                    : SoundEvent.note(SoundType.piano, e['midiNote'] as int? ?? 60),
              ),
          ]
        : rawEvents.map(TimedSoundEvent.fromJson).toList();
    return Recording(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Untitled jam',
      instrument: instrument,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      durationMs: json['durationMs'] as int? ?? (events.isEmpty ? 0 : events.last.timeMs),
      events: events,
    );
  }
}
