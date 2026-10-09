import 'dart:typed_data';
import 'sound_synthesizer.dart';

/// Kinds of sound a [SoundEvent] can describe (its `type`).
class SoundType {
  SoundType._();

  static const String piano = 'piano';
  static const String flute = 'flute';
  static const String ukulele = 'ukulele';
  static const String xylophone = 'xylophone';
  static const String sitar = 'sitar';
  static const String guitar = 'guitar';
  static const String harmonium = 'harmonium';
  static const String violin = 'violin';
  static const String drum = 'drum';
  static const String tabla = 'tabla';
  static const String dholak = 'dholak';
  static const String djLoop = 'dj';

  /// A held harmonium drone; it sounds until the matching [droneStop].
  static const String droneStart = 'drone_start';
  static const String droneStop = 'drone_stop';

  static const List<String> noteTypes = [piano, flute, ukulele, xylophone, sitar, guitar, harmonium, violin];

}

/// One sound the app can make, described as data so it can be played, recorded, saved as
/// JSON, replayed later and rendered into an audio file.
class SoundEvent {
  final String type;
  final int? midi;

  /// Tabla bol, dholak stroke, drum pad or DJ track.
  final String? name;

  /// Drum kit or DJ sound pack.
  final String? kit;

  /// Flute vibrato (0-1, in 10% steps) or DJ filter cutoff (0.1-1, in 10% steps).
  final double? amount;

  /// DJ loop tempo.
  final int? bpm;

  const SoundEvent._(this.type, {this.midi, this.name, this.kit, this.amount, this.bpm});

  /// A pitched note on one of the melodic instruments.
  factory SoundEvent.note(String instrument, int midi) {
    assert(SoundType.noteTypes.contains(instrument), 'Not a note instrument: $instrument');
    return SoundEvent._(instrument, midi: midi);
  }

  factory SoundEvent.flute(int midi, {double vibrato = 0.0}) =>
      SoundEvent._(SoundType.flute, midi: midi, amount: (vibrato.clamp(0.0, 1.0) * 10).round() / 10);

  factory SoundEvent.drum(String pad, {String kit = 'classic'}) =>
      SoundEvent._(SoundType.drum, name: pad.toLowerCase(), kit: kit);

  factory SoundEvent.tabla(String bol) => SoundEvent._(SoundType.tabla, name: bol.toLowerCase());

  factory SoundEvent.dholak(String stroke) => SoundEvent._(SoundType.dholak, name: stroke.toLowerCase());

  factory SoundEvent.djLoop(String track, {double filterCutoff = 1.0, int bpm = 124, String pack = 'electro_house'}) =>
      SoundEvent._(SoundType.djLoop, name: track.toLowerCase(), amount: (filterCutoff * 10).round() / 10, bpm: bpm, kit: pack);

  factory SoundEvent.droneStart(int midi) => SoundEvent._(SoundType.droneStart, midi: midi);

  static const SoundEvent droneStopEvent = SoundEvent._(SoundType.droneStop);

  bool get isDroneStart => type == SoundType.droneStart;
  bool get isDroneStop => type == SoundType.droneStop;

  /// Identifies the generated audio, so identical sounds share one generated file.
  String get cacheKey {
    switch (type) {
      case SoundType.flute:
        return 'flute_${midi}_v${(amount! * 10).round()}';
      case SoundType.drum:
        return 'drum_${kit}_$name';
      case SoundType.tabla:
      case SoundType.dholak:
        return '${type}_$name';
      case SoundType.djLoop:
        return 'dj_${kit}_${bpm}_${name}_${(amount! * 10).round()}';
      case SoundType.droneStart:
        return 'drone_$midi';
      case SoundType.droneStop:
        return 'drone_stop';
      default:
        return '${type}_$midi';
    }
  }

  /// The WAV audio for this sound. A drone start returns one seamless loop cycle.
  Uint8List generate() {
    double freq() => SoundSynthesizer.midiToFrequency(midi!);
    switch (type) {
      case SoundType.piano:
        return SoundSynthesizer.generatePianoWav(freq());
      case SoundType.flute:
        return SoundSynthesizer.generateFluteWav(freq(), vibratoAmount: amount!);
      case SoundType.ukulele:
        return SoundSynthesizer.generateUkuleleWav(freq());
      case SoundType.xylophone:
        return SoundSynthesizer.generateXylophoneWav(freq());
      case SoundType.sitar:
        return SoundSynthesizer.generateSitarWav(freq());
      case SoundType.guitar:
        return SoundSynthesizer.generateGuitarWav(freq());
      case SoundType.harmonium:
        return SoundSynthesizer.generateHarmoniumWav(freq());
      case SoundType.violin:
        return SoundSynthesizer.generateViolinWav(freq());
      case SoundType.drum:
        return SoundSynthesizer.generateDrumPadWav(name!, kit: kit!);
      case SoundType.tabla:
        return SoundSynthesizer.generateTablaBolWav(name!);
      case SoundType.dholak:
        return SoundSynthesizer.generateDholakWav(name!);
      case SoundType.djLoop:
        return SoundSynthesizer.generateDJLoopWav(name!, filterCutoff: amount!, bpm: bpm!, packId: kit!);
      case SoundType.droneStart:
        return SoundSynthesizer.generateHarmoniumDroneWav(freq());
      default:
        throw StateError('$type has no audio');
    }
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        if (midi != null) 'midi': midi,
        if (name != null) 'name': name,
        if (kit != null) 'kit': kit,
        if (amount != null) 'amount': amount,
        if (bpm != null) 'bpm': bpm,
      };

  factory SoundEvent.fromJson(Map<String, dynamic> json) => SoundEvent._(
        json['type'] as String,
        midi: json['midi'] as int?,
        name: json['name'] as String?,
        kit: json['kit'] as String?,
        amount: (json['amount'] as num?)?.toDouble(),
        bpm: json['bpm'] as int?,
      );

  @override
  bool operator ==(Object other) => other is SoundEvent && other.cacheKey == cacheKey && other.type == type;

  @override
  int get hashCode => Object.hash(type, cacheKey);

  @override
  String toString() => 'SoundEvent($cacheKey)';
}
