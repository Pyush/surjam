import 'dart:math';
import 'dart:typed_data';

class SoundSynthesizer {
  static const int sampleRate = 44100;

  /// Generates Bamboo Bansuri & Flute PCM WAV bytes with breath noise and vibrato
  static Uint8List generateFluteWav(double frequency, {double durationSeconds = 1.4, double vibratoAmount = 0.0}) {
    final int numSamples = (sampleRate * durationSeconds).toInt();
    final ByteData data = ByteData(44 + numSamples * 2);
    _writeWavHeader(data, numSamples, sampleRate);

    final Random rng = Random(42);

    for (int i = 0; i < numSamples; i++) {
      double t = i / sampleRate;
      double envelope = exp(-1.5 * t);
      if (t < 0.06) envelope *= (t / 0.06); // Gentle breath attack

      // Soft vibrato frequency modulation (5.5 Hz pitch wobble)
      double modFreq = frequency + (vibratoAmount * 8.0 * sin(2 * pi * 5.5 * t));

      // Airflow breath noise
      double breathNoise = (rng.nextDouble() * 2 - 1) * 0.06 * exp(-1.0 * t);

      double wave = 0.8 * sin(2 * pi * modFreq * t) +
                    0.15 * sin(2 * pi * modFreq * 2 * t) +
                    0.05 * sin(2 * pi * modFreq * 3 * t) +
                    breathNoise;

      double sampleValue = (wave * envelope * 0.85).clamp(-1.0, 1.0);
      data.setInt16(44 + i * 2, (sampleValue * 32767).toInt(), Endian.little);
    }
    return data.buffer.asUint8List();
  }

  /// Generates Sitar Plucked String PCM WAV bytes with Javari buzz overtones
  static Uint8List generateSitarWav(double frequency, {double durationSeconds = 1.4}) {
    final int numSamples = (sampleRate * durationSeconds).toInt();
    final ByteData data = ByteData(44 + numSamples * 2);
    _writeWavHeader(data, numSamples, sampleRate);

    final Random rng = Random(42);

    for (int i = 0; i < numSamples; i++) {
      double t = i / sampleRate;
      double envelope = exp(-2.2 * t);
      if (t < 0.015) envelope *= (t / 0.015); // Metallic attack

      // Javari bridge buzzing modulation (subtle high-frequency buzz)
      double javariBuzz = sin(2 * pi * frequency * 5 * t) * 0.15 * exp(-1.5 * t);
      double metallicPluck = (t < 0.02) ? (rng.nextDouble() * 2 - 1) * (1.0 - t / 0.02) * 0.35 : 0.0;

      double wave = 0.65 * sin(2 * pi * frequency * t) +
                    0.25 * sin(2 * pi * frequency * 2 * t) +
                    0.15 * sin(2 * pi * frequency * 3 * t) +
                    javariBuzz +
                    metallicPluck;

      double sampleValue = (wave * envelope * 0.85).clamp(-1.0, 1.0);
      data.setInt16(44 + i * 2, (sampleValue * 32767).toInt(), Endian.little);
    }
    return data.buffer.asUint8List();
  }

  /// Generates Ukulele Nylon Plucked String PCM WAV bytes
  static Uint8List generateUkuleleWav(double frequency, {double durationSeconds = 1.0}) {
    final int numSamples = (sampleRate * durationSeconds).toInt();
    final ByteData data = ByteData(44 + numSamples * 2);
    _writeWavHeader(data, numSamples, sampleRate);

    final Random rng = Random(42);

    for (int i = 0; i < numSamples; i++) {
      double t = i / sampleRate;
      double envelope = exp(-3.2 * t);
      double nylonPluck = (t < 0.015) ? (rng.nextDouble() * 2 - 1) * (1.0 - t / 0.015) * 0.45 : 0.0;

      double wave = 0.75 * sin(2 * pi * frequency * t) +
                    0.18 * sin(2 * pi * frequency * 2 * t) +
                    0.07 * sin(2 * pi * frequency * 3 * t) +
                    nylonPluck;

      double sampleValue = (wave * envelope * 0.85).clamp(-1.0, 1.0);
      data.setInt16(44 + i * 2, (sampleValue * 32767).toInt(), Endian.little);
    }
    return data.buffer.asUint8List();
  }

  /// Generates Xylophone Wooden Bar Mallet Strike PCM WAV bytes
  static Uint8List generateXylophoneWav(double frequency, {double durationSeconds = 0.8}) {
    final int numSamples = (sampleRate * durationSeconds).toInt();
    final ByteData data = ByteData(44 + numSamples * 2);
    _writeWavHeader(data, numSamples, sampleRate);

    final Random rng = Random(42);

    for (int i = 0; i < numSamples; i++) {
      double t = i / sampleRate;
      double envelope = exp(-4.5 * t);
      if (t < 0.005) envelope *= (t / 0.005); // Sharp percussive mallet strike

      double malletClick = (t < 0.01) ? (rng.nextDouble() * 2 - 1) * (1.0 - t / 0.01) * 0.5 : 0.0;

      double wave = 0.85 * sin(2 * pi * frequency * t) +
                    0.15 * sin(2 * pi * frequency * 3 * t) +
                    malletClick;

      double sampleValue = (wave * envelope * 0.9).clamp(-1.0, 1.0);
      data.setInt16(44 + i * 2, (sampleValue * 32767).toInt(), Endian.little);
    }
    return data.buffer.asUint8List();
  }

  /// Generates Piano PCM WAV bytes
  static Uint8List generatePianoWav(double frequency, {double durationSeconds = 1.0}) {
    final int numSamples = (sampleRate * durationSeconds).toInt();
    final ByteData data = ByteData(44 + numSamples * 2);
    _writeWavHeader(data, numSamples, sampleRate);

    for (int i = 0; i < numSamples; i++) {
      double t = i / sampleRate;
      double envelope = exp(-3.5 * t);
      if (t < 0.01) envelope *= (t / 0.01);

      double wave = 0.6 * sin(2 * pi * frequency * t) +
                    0.25 * sin(2 * pi * frequency * 2 * t) +
                    0.15 * sin(2 * pi * frequency * 3 * t);
      
      double sampleValue = (wave * envelope * 0.85).clamp(-1.0, 1.0);
      data.setInt16(44 + i * 2, (sampleValue * 32767).toInt(), Endian.little);
    }
    return data.buffer.asUint8List();
  }

  /// Generates Acoustic Guitar Plucked String PCM WAV bytes
  static Uint8List generateGuitarWav(double frequency, {double durationSeconds = 1.2}) {
    final int numSamples = (sampleRate * durationSeconds).toInt();
    final ByteData data = ByteData(44 + numSamples * 2);
    _writeWavHeader(data, numSamples, sampleRate);

    final Random rng = Random(42);

    for (int i = 0; i < numSamples; i++) {
      double t = i / sampleRate;
      double envelope = exp(-2.8 * t);
      double pluckNoise = (t < 0.02) ? (rng.nextDouble() * 2 - 1) * (1.0 - t / 0.02) * 0.4 : 0.0;

      double wave = 0.7 * sin(2 * pi * frequency * t) +
                    0.2 * sin(2 * pi * frequency * 2 * t) +
                    0.1 * sin(2 * pi * frequency * 4 * t) +
                    pluckNoise;

      double sampleValue = (wave * envelope * 0.85).clamp(-1.0, 1.0);
      data.setInt16(44 + i * 2, (sampleValue * 32767).toInt(), Endian.little);
    }
    return data.buffer.asUint8List();
  }

  /// Generates Harmonium Reed PCM WAV bytes
  static Uint8List generateHarmoniumWav(double frequency, {double durationSeconds = 1.5}) {
    final int numSamples = (sampleRate * durationSeconds).toInt();
    final ByteData data = ByteData(44 + numSamples * 2);
    _writeWavHeader(data, numSamples, sampleRate);

    for (int i = 0; i < numSamples; i++) {
      double t = i / sampleRate;
      double envelope = exp(-1.2 * t);
      if (t < 0.04) envelope *= (t / 0.04);

      double wave = 0.5 * sin(2 * pi * frequency * t) +
                    0.3 * sin(2 * pi * frequency * 2 * t) +
                    0.2 * sin(2 * pi * frequency * 3 * t) +
                    0.1 * sin(2 * pi * frequency * 5 * t);

      double sampleValue = (wave * envelope * 0.85).clamp(-1.0, 1.0);
      data.setInt16(44 + i * 2, (sampleValue * 32767).toInt(), Endian.little);
    }
    return data.buffer.asUint8List();
  }

  /// Generates Violin Bowed String PCM WAV bytes
  static Uint8List generateViolinWav(double frequency, {double durationSeconds = 1.2}) {
    final int numSamples = (sampleRate * durationSeconds).toInt();
    final ByteData data = ByteData(44 + numSamples * 2);
    _writeWavHeader(data, numSamples, sampleRate);

    for (int i = 0; i < numSamples; i++) {
      double t = i / sampleRate;
      double envelope = exp(-2.0 * t);
      if (t < 0.08) envelope *= (t / 0.08);

      double wave = 0.4 * sin(2 * pi * frequency * t) +
                    0.3 * sin(2 * pi * frequency * 2 * t) +
                    0.2 * sin(2 * pi * frequency * 3 * t) +
                    0.1 * sin(2 * pi * frequency * 4 * t);

      double sampleValue = (wave * envelope * 0.85).clamp(-1.0, 1.0);
      data.setInt16(44 + i * 2, (sampleValue * 32767).toInt(), Endian.little);
    }
    return data.buffer.asUint8List();
  }

  /// Generates DJ Loop Launcher Track PCM WAV bytes with audio filter control
  static Uint8List generateDJLoopWav(String trackId, {double filterCutoff = 1.0, double durationSeconds = 1.93}) {
    final int numSamples = (sampleRate * durationSeconds).toInt();
    final ByteData data = ByteData(44 + numSamples * 2);
    _writeWavHeader(data, numSamples, sampleRate);

    final Random rng = Random(42);

    for (int i = 0; i < numSamples; i++) {
      double t = i / sampleRate;
      double sampleValue = 0.0;

      switch (trackId.toLowerCase()) {
        case 'drums':
          double kick = (t % 0.48 < 0.1) ? sin(2 * pi * (120 - 90 * ((t % 0.48) / 0.1)) * t) * exp(-8.0 * (t % 0.48)) * 0.9 : 0.0;
          double snare = (t % 0.96 > 0.46 && t % 0.96 < 0.56) ? (rng.nextDouble() * 2 - 1) * exp(-15.0 * ((t % 0.96) - 0.46)) * 0.6 : 0.0;
          sampleValue = kick + snare;
          break;

        case 'bass':
          double bassFreq = (t < 0.96) ? 55.0 : 65.41;
          double sub = sin(2 * pi * bassFreq * t) * 0.7 + 0.3 * sin(2 * pi * bassFreq * 2 * t);
          sampleValue = sub * exp(-0.5 * (t % 0.24));
          break;

        case 'chords':
          double c = sin(2 * pi * 261.63 * t);
          double e = sin(2 * pi * 329.63 * t);
          double g = sin(2 * pi * 392.00 * t);
          sampleValue = (c + e + g) * 0.28 * exp(-2.0 * (t % 0.48));
          break;

        case 'lead':
          double step = (t * 8).floor() % 4;
          double freq = 440.0 + step * 110.0;
          sampleValue = sin(2 * pi * freq * t) * 0.5 * exp(-4.0 * (t % 0.12));
          break;

        case 'vocal':
          double chopEnv = exp(-3.0 * (t % 0.48));
          double vox = sin(2 * pi * 523.25 * t) + 0.5 * sin(2 * pi * 659.25 * t);
          sampleValue = vox * chopEnv * 0.45;
          break;

        case 'percussion':
          double hat = (t % 0.24 > 0.10 && t % 0.24 < 0.18) ? (rng.nextDouble() * 2 - 1) * exp(-30.0 * ((t % 0.24) - 0.10)) * 0.4 : 0.0;
          sampleValue = hat;
          break;

        case 'piano_stab':
          double p1 = sin(2 * pi * 329.63 * t);
          double p2 = sin(2 * pi * 440.00 * t);
          sampleValue = (p1 + p2) * 0.4 * exp(-3.5 * (t % 0.96));
          break;

        case 'fx_riser':
        default:
          double sweepFreq = 200.0 + (t / durationSeconds) * 1200.0;
          double noise = (rng.nextDouble() * 2 - 1) * 0.15;
          sampleValue = (sin(2 * pi * sweepFreq * t) + noise) * (t / durationSeconds) * 0.5;
          break;
      }

      // Apply Low-Pass Filter simulation based on filterCutoff (0.0 to 1.0)
      if (filterCutoff < 1.0) {
        sampleValue *= (0.2 + 0.8 * filterCutoff);
      }

      sampleValue = sampleValue.clamp(-1.0, 1.0);
      data.setInt16(44 + i * 2, (sampleValue * 32767).toInt(), Endian.little);
    }
    return data.buffer.asUint8List();
  }

  /// Generates Drum Pad Sample
  static Uint8List generateDrumPadWav(String padType, {double durationSeconds = 0.6}) {
    final int numSamples = (sampleRate * durationSeconds).toInt();
    final ByteData data = ByteData(44 + numSamples * 2);
    _writeWavHeader(data, numSamples, sampleRate);

    final Random rng = Random(42);

    for (int i = 0; i < numSamples; i++) {
      double t = i / sampleRate;
      double sampleValue = 0.0;

      switch (padType.toLowerCase()) {
        case 'kick':
          double freq = 120.0 - (90.0 * (t / durationSeconds));
          double env = exp(-8.0 * t);
          sampleValue = sin(2 * pi * freq * t) * env * 0.95;
          break;

        case 'snare':
          double toneEnv = exp(-15.0 * t);
          double noiseEnv = exp(-12.0 * t);
          double tone = sin(2 * pi * 180.0 * t) * toneEnv * 0.5;
          double noise = (rng.nextDouble() * 2 - 1) * noiseEnv * 0.5;
          sampleValue = tone + noise;
          break;

        case 'hihat':
        case 'hihat_close':
          double env = exp(-40.0 * t);
          sampleValue = (rng.nextDouble() * 2 - 1) * env * 0.7;
          break;

        case 'hihat_open':
          double env = exp(-8.0 * t);
          sampleValue = (rng.nextDouble() * 2 - 1) * env * 0.7;
          break;

        case 'clap':
          double env = exp(-18.0 * t);
          double noise = (rng.nextDouble() * 2 - 1) * env;
          sampleValue = noise * 0.8;
          break;

        case 'tom':
          double freq = 150.0 - (40.0 * (t / durationSeconds));
          double env = exp(-7.0 * t);
          sampleValue = sin(2 * pi * freq * t) * env * 0.85;
          break;

        case 'crash':
          double env = exp(-4.0 * t);
          sampleValue = (rng.nextDouble() * 2 - 1) * env * 0.75;
          break;

        default:
          double env = exp(-20.0 * t);
          sampleValue = sin(2 * pi * 440.0 * t) * env * 0.6;
          break;
      }

      sampleValue = sampleValue.clamp(-1.0, 1.0);
      data.setInt16(44 + i * 2, (sampleValue * 32767).toInt(), Endian.little);
    }
    return data.buffer.asUint8List();
  }

  /// Generates Dholak Folk Percussion PCM WAV bytes
  static Uint8List generateDholakWav(String stroke, {double durationSeconds = 0.65}) {
    final int numSamples = (sampleRate * durationSeconds).toInt();
    final ByteData data = ByteData(44 + numSamples * 2);
    _writeWavHeader(data, numSamples, sampleRate);

    final Random rng = Random(42);

    for (int i = 0; i < numSamples; i++) {
      double t = i / sampleRate;
      double sampleValue = 0.0;

      switch (stroke.toLowerCase()) {
        case 'taash':
        case 'ta':
          double freq = 420.0;
          double envelope = exp(-15.0 * t);
          double ring = sin(2 * pi * freq * t) + 0.35 * sin(2 * pi * freq * 1.6 * t);
          double snap = (t < 0.01) ? (rng.nextDouble() * 2 - 1) * 0.4 : 0.0;
          sampleValue = (ring * envelope * 0.85) + snap;
          break;

        case 'ti':
          double freq = 360.0;
          double envelope = exp(-10.0 * t);
          sampleValue = sin(2 * pi * freq * t) * envelope * 0.8;
          break;

        case 'dagga':
        case 'ge':
          double freq = 100.0 - (45.0 * (t / durationSeconds));
          double envelope = exp(-4.5 * t);
          sampleValue = sin(2 * pi * freq * t) * envelope * 0.95;
          break;

        case 'ghe':
          double freq = 115.0 - (65.0 * (t / durationSeconds));
          double envelope = exp(-3.8 * t);
          sampleValue = sin(2 * pi * freq * t) * envelope * 0.95;
          break;

        case 'ka':
          double envelope = exp(-30.0 * t);
          sampleValue = (rng.nextDouble() * 2 - 1) * envelope * 0.65;
          break;

        case 'dha':
          double geFreq = 100.0 - (40.0 * (t / durationSeconds));
          double geEnv = exp(-4.5 * t);
          double gePart = sin(2 * pi * geFreq * t) * geEnv * 0.65;

          double taEnv = exp(-14.0 * t);
          double taPart = sin(2 * pi * 420.0 * t) * taEnv * 0.6;

          sampleValue = gePart + taPart;
          break;

        case 'dhin':
          double geFreq = 95.0 - (35.0 * (t / durationSeconds));
          double geEnv = exp(-4.5 * t);
          double gePart = sin(2 * pi * geFreq * t) * geEnv * 0.65;

          double tiEnv = exp(-10.0 * t);
          double tiPart = sin(2 * pi * 360.0 * t) * tiEnv * 0.55;

          sampleValue = gePart + tiPart;
          break;

        case 'dhabba':
        default:
          double freq = 80.0 - (50.0 * (t / durationSeconds));
          double env = exp(-5.0 * t);
          double noise = (t < 0.02) ? (rng.nextDouble() * 2 - 1) * 0.4 : 0.0;
          sampleValue = (sin(2 * pi * freq * t) * env * 0.85) + noise;
          break;
      }

      sampleValue = sampleValue.clamp(-1.0, 1.0);
      data.setInt16(44 + i * 2, (sampleValue * 32767).toInt(), Endian.little);
    }
    return data.buffer.asUint8List();
  }

  /// Generates Tabla Bol WAV PCM audio bytes
  static Uint8List generateTablaBolWav(String bol, {double durationSeconds = 0.6}) {
    final int numSamples = (sampleRate * durationSeconds).toInt();
    final ByteData data = ByteData(44 + numSamples * 2);
    _writeWavHeader(data, numSamples, sampleRate);

    final Random rng = Random(42);

    for (int i = 0; i < numSamples; i++) {
      double t = i / sampleRate;
      double sampleValue = 0.0;

      switch (bol.toLowerCase()) {
        case 'ge':
        case 'ghe':
          double freq = 90.0 - (35.0 * (t / durationSeconds));
          double envelope = exp(-5.0 * t);
          sampleValue = sin(2 * pi * freq * t) * envelope * 0.95;
          break;

        case 'na':
        case 'ta':
          double freq = 340.0;
          double envelope = exp(-12.0 * t);
          double metallicRing = sin(2 * pi * freq * t) + 0.3 * sin(2 * pi * freq * 1.5 * t);
          sampleValue = metallicRing * envelope * 0.9;
          break;

        case 'tin':
        case 'tun':
          double freq = 270.0;
          double envelope = exp(-7.0 * t);
          sampleValue = sin(2 * pi * freq * t) * envelope * 0.85;
          break;

        case 'ke':
        case 'ka':
          double envelope = exp(-35.0 * t);
          sampleValue = (rng.nextDouble() * 2 - 1) * envelope * 0.7;
          break;

        case 'dha':
          double geFreq = 90.0 - (30.0 * (t / durationSeconds));
          double geEnv = exp(-5.0 * t);
          double gePart = sin(2 * pi * geFreq * t) * geEnv * 0.65;

          double naEnv = exp(-12.0 * t);
          double naPart = sin(2 * pi * 340.0 * t) * naEnv * 0.55;

          sampleValue = gePart + naPart;
          break;

        case 'dhin':
          double geFreq = 85.0 - (25.0 * (t / durationSeconds));
          double geEnv = exp(-5.0 * t);
          double gePart = sin(2 * pi * geFreq * t) * geEnv * 0.65;

          double tinEnv = exp(-7.0 * t);
          double tinPart = sin(2 * pi * 270.0 * t) * tinEnv * 0.55;

          sampleValue = gePart + tinPart;
          break;

        default:
          double envelope = exp(-20.0 * t);
          sampleValue = sin(2 * pi * 440.0 * t) * envelope * 0.6;
          break;
      }

      sampleValue = sampleValue.clamp(-1.0, 1.0);
      data.setInt16(44 + i * 2, (sampleValue * 32767).toInt(), Endian.little);
    }
    return data.buffer.asUint8List();
  }

  static void _writeWavHeader(ByteData data, int numSamples, int sampleRate) {
    int subChunk2Size = numSamples * 2;
    int chunkSize = 36 + subChunk2Size;

    data.setUint8(0, 0x52); data.setUint8(1, 0x49); data.setUint8(2, 0x46); data.setUint8(3, 0x46);
    data.setUint32(4, chunkSize, Endian.little);
    data.setUint8(8, 0x57); data.setUint8(9, 0x41); data.setUint8(10, 0x56); data.setUint8(11, 0x45);

    data.setUint8(12, 0x66); data.setUint8(13, 0x6D); data.setUint8(14, 0x74); data.setUint8(15, 0x20);
    data.setUint32(16, 16, Endian.little);
    data.setUint16(20, 1, Endian.little);
    data.setUint16(22, 1, Endian.little);
    data.setUint32(24, sampleRate, Endian.little);
    data.setUint32(28, sampleRate * 2, Endian.little);
    data.setUint16(32, 2, Endian.little);
    data.setUint16(34, 16, Endian.little);

    data.setUint8(36, 0x64); data.setUint8(37, 0x61); data.setUint8(38, 0x74); data.setUint8(39, 0x61);
    data.setUint32(40, subChunk2Size, Endian.little);
  }

  static double midiToFrequency(int midiNote) {
    return 440.0 * pow(2.0, (midiNote - 69) / 12.0);
  }
}
