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

  /// Generates a sustained harmonium drone meant to be played on loop. The length is a
  /// whole number of cycles of [frequency] (about 2 seconds) and the gentle bellows swell
  /// completes exactly one cycle, so the loop point is seamless.
  static Uint8List generateHarmoniumDroneWav(double targetFrequency) {
    final int cycles = (2.0 * targetFrequency).round();
    final int numSamples = (sampleRate * cycles / targetFrequency).round();
    final double durationSeconds = numSamples / sampleRate;
    // Retune by a tiny fraction of a cent so the cycles fit the whole-sample length exactly.
    final double frequency = cycles / durationSeconds;
    final ByteData data = ByteData(44 + numSamples * 2);
    _writeWavHeader(data, numSamples, sampleRate);

    for (int i = 0; i < numSamples; i++) {
      double t = i / sampleRate;
      double bellows = 0.9 + 0.1 * sin(2 * pi * t / durationSeconds);

      double wave = 0.5 * sin(2 * pi * frequency * t) +
                    0.3 * sin(2 * pi * frequency * 2 * t) +
                    0.2 * sin(2 * pi * frequency * 3 * t) +
                    0.1 * sin(2 * pi * frequency * 5 * t);

      double sampleValue = (wave * bellows * 0.6).clamp(-1.0, 1.0);
      data.setInt16(44 + i * 2, (sampleValue * 32767).toInt(), Endian.little);
    }
    return data.buffer.asUint8List();
  }

  /// Generates a santoor stroke: a hammered course of three strings tuned a few cents apart,
  /// so the note shimmers as they beat against each other. A short hammer click starts it,
  /// and upper partials fade faster than the fundamental, as on a real struck string.
  static Uint8List generateSantoorWav(double frequency, {double durationSeconds = 2.2}) {
    final int numSamples = (sampleRate * durationSeconds).toInt();
    final ByteData data = ByteData(44 + numSamples * 2);
    _writeWavHeader(data, numSamples, sampleRate);

    final Random rng = Random(42);
    const List<double> detuneCents = [-4.0, 0.0, 3.5];
    const List<double> partialLevels = [1.0, 0.55, 0.3, 0.18, 0.1];
    // Slight stretching of the overtones, as stiff metal strings have.
    const double inharmonicity = 0.0007;

    for (int i = 0; i < numSamples; i++) {
      double t = i / sampleRate;
      double wave = 0.0;
      for (final cents in detuneCents) {
        final double f = frequency * pow(2, cents / 1200);
        for (int k = 0; k < partialLevels.length; k++) {
          final int n = k + 1;
          final double partialFreq = f * n * sqrt(1 + inharmonicity * n * n);
          if (partialFreq > sampleRate / 2) break;
          wave += partialLevels[k] * exp(-(1.4 + 1.1 * k) * t) * sin(2 * pi * partialFreq * t);
        }
      }
      wave /= detuneCents.length;

      // Hammer: a few milliseconds of bright noise at the strike.
      double hammer = t < 0.004 ? (rng.nextDouble() * 2 - 1) * (1 - t / 0.004) * 0.35 : 0.0;
      double attack = min(t / 0.002, 1.0);

      double sampleValue = ((wave * attack + hammer) * 0.55).clamp(-1.0, 1.0);
      data.setInt16(44 + i * 2, (sampleValue * 32767).toInt(), Endian.little);
    }
    return data.buffer.asUint8List();
  }

  /// Generates one seamless loop of a sustained shehnai tone, played on repeat while a key is
  /// held. The loop holds a whole number of waveform cycles and, with [vibrato], a whole number
  /// of vibrato cycles, so it repeats without a seam.
  ///
  /// The double reed is modelled as many harmonics shaped by a nasal resonance around 1.4 kHz,
  /// with a little breath noise.
  static Uint8List generateShehnaiLoopWav(double targetFrequency, {bool vibrato = true}) {
    const double targetSeconds = 1.2;
    final int cycles = (targetSeconds * targetFrequency).round();
    final int numSamples = (sampleRate * cycles / targetFrequency).round();
    final double duration = numSamples / sampleRate;
    // Retuned by a fraction of a cent so the cycles fit the whole-sample length exactly.
    final double frequency = cycles / duration;

    // About 5.5 vibrato wobbles a second, rounded to fit the loop; depth about 15 cents.
    final double vibratoRate = (5.5 * duration).round() / duration;
    final double vibratoDepth = vibrato ? 0.009 : 0.0;
    final double modulationIndex = vibratoDepth * frequency / vibratoRate;

    final int harmonics = min(18, (sampleRate / 2 / (frequency * 1.02)).floor());
    final List<double> levels = [
      for (int n = 1; n <= harmonics; n++)
        pow(n, -0.55) * (0.35 + 1.2 * exp(-pow((n * frequency - 1400) / 750, 2))),
    ];

    final Random rng = Random(7);
    final Float64List samples = Float64List(numSamples);
    double peak = 0;
    double breath = 0;
    for (int i = 0; i < numSamples; i++) {
      final double t = i / sampleRate;
      final double phase = 2 * pi * frequency * t + modulationIndex * sin(2 * pi * vibratoRate * t);
      double wave = 0;
      for (int n = 1; n <= harmonics; n++) {
        wave += levels[n - 1] * sin(n * phase);
      }
      // Softly filtered breath noise, a little louder at the top of each vibrato wobble.
      breath = 0.9 * breath + 0.1 * (rng.nextDouble() * 2 - 1);
      wave += breath * 0.6 * (1 + 0.3 * sin(2 * pi * vibratoRate * t));
      samples[i] = wave;
      if (wave.abs() > peak) peak = wave.abs();
    }

    final ByteData data = ByteData(44 + numSamples * 2);
    _writeWavHeader(data, numSamples, sampleRate);
    final double gain = peak == 0 ? 0 : 0.7 / peak;
    for (int i = 0; i < numSamples; i++) {
      data.setInt16(44 + i * 2, (samples[i] * gain * 32767).round(), Endian.little);
    }
    return data.buffer.asUint8List();
  }

  /// Generates a plucked veena string with the Karplus-Strong string model: a burst of noise
  /// circulates in a delay line one period long, losing its high frequencies on each pass, the
  /// way a real string's tone mellows as it rings. A fractional all-pass delay keeps every note
  /// in tune, and a light soft-clip adds the jivari bridge's buzz.
  static Uint8List generateVeenaWav(double frequency, {double durationSeconds = 3.0}) {
    final int numSamples = (sampleRate * durationSeconds).toInt();

    // Loop delay = string period; the two-point average in the loop adds half a sample.
    final double loopDelay = sampleRate / frequency - 0.5;
    int length = loopDelay.floor();
    double fraction = loopDelay - length;
    if (fraction < 0.1) {
      // Keep the all-pass in its accurate range.
      length -= 1;
      fraction += 1;
    }
    final double allpass = (1 - fraction) / (1 + fraction);
    // Per-pass gain for a long, veena-like ring (about 7 s to fade by 60 dB) at any pitch.
    final double gain = pow(0.001, 1 / (frequency * 7.0)).toDouble();

    // Pluck: noise, softened a little so the attack is a finger, not a pick.
    final Random rng = Random(11);
    final Float64List line = Float64List(length);
    double smooth = 0;
    for (int i = 0; i < length; i++) {
      smooth = 0.6 * smooth + 0.4 * (rng.nextDouble() * 2 - 1);
      line[i] = smooth;
    }

    final Float64List out = Float64List(numSamples);
    int index = 0;
    double previous = 0, apIn = 0, apOut = 0, peak = 0;
    for (int i = 0; i < numSamples; i++) {
      final double current = line[index];
      final double averaged = 0.5 * (current + previous);
      previous = current;
      final double tuned = allpass * (averaged - apOut) + apIn;
      apIn = averaged;
      apOut = tuned;
      line[index] = tuned * gain;
      index = (index + 1) % length;

      // Jivari: gentle soft clipping brightens the tone like the curved veena bridge.
      final double buzzed = current + 0.18 * current * current.abs();
      final double attack = min(i / 40.0, 1.0);
      out[i] = buzzed * attack;
      if (out[i].abs() > peak) peak = out[i].abs();
    }

    final ByteData data = ByteData(44 + numSamples * 2);
    _writeWavHeader(data, numSamples, sampleRate);
    final double scale = peak == 0 ? 0 : 0.8 / peak;
    for (int i = 0; i < numSamples; i++) {
      data.setInt16(44 + i * 2, (out[i] * scale * 32767).round(), Endian.little);
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

  /// Generates one bar (4 beats) of a DJ Loop Launcher track at [bpm], so loops
  /// retriggered once per bar line up seamlessly. [packId] picks the pack's key
  /// and timbre, and [filterCutoff] (0.0 to 1.0) drives a one-pole low-pass filter.
  static Uint8List generateDJLoopWav(String trackId, {double filterCutoff = 1.0, int bpm = 124, String packId = 'electro_house'}) {
    final double beat = 60.0 / bpm;
    final double bar = beat * 4;
    final int numSamples = (sampleRate * bar).toInt();
    final ByteData data = ByteData(44 + numSamples * 2);
    _writeWavHeader(data, numSamples, sampleRate);

    final Random rng = Random(42);
    final bool isSynthwave = packId == 'synthwave_retro';
    final bool isFusion = packId == 'indian_fusion';

    // Cutoff 0.0 -> ~150 Hz, 1.0 -> filter bypassed.
    final double cutoffHz = 150.0 * pow(2, filterCutoff * 7);
    final double filterAlpha = 1 - exp(-2 * pi * cutoffHz / sampleRate);
    double filtered = 0.0;

    for (int i = 0; i < numSamples; i++) {
      double t = i / sampleRate;
      double sampleValue = 0.0;

      switch (trackId.toLowerCase()) {
        case 'drums':
          // Kick on every beat, snare (or tabla "Ta" in the fusion pack) on beats 2 and 4.
          double kt = t % beat;
          double kickDrop = isFusion ? 60.0 : 90.0;
          double kick = (kt < 0.1) ? sin(2 * pi * (120 - kickDrop * (kt / 0.1)) * kt) * exp(-8.0 * kt) * 0.9 : 0.0;
          double st = (t % (2 * beat)) - beat;
          double snare = 0.0;
          if (st >= 0 && st < 0.15) {
            snare = isFusion
                ? sin(2 * pi * 520 * st) * exp(-18.0 * st) * 0.6
                : (rng.nextDouble() * 2 - 1) * exp((isSynthwave ? -8.0 : -15.0) * st) * 0.6;
          }
          sampleValue = kick + snare;
          break;

        case 'bass':
          // Root note changes halfway through the bar.
          final List<double> roots = isSynthwave ? [55.0, 43.65] : (isFusion ? [65.41, 65.41] : [55.0, 65.41]);
          double bassFreq = (t < 2 * beat) ? roots[0] : roots[1];
          if (isFusion && (t % beat) >= beat / 2) bassFreq *= 2; // Octave bounce
          double sub = sin(2 * pi * bassFreq * t) * 0.7 + 0.3 * sin(2 * pi * bassFreq * 2 * t);
          sampleValue = sub * exp(-0.5 * (t % (beat / 2)));
          break;

        case 'chords':
          if (isFusion) {
            // Tanpura-style Sa-Pa-Sa' drone with jawari harmonics.
            double drone = 0.0;
            for (final f in const [130.81, 196.0, 261.63]) {
              drone += sin(2 * pi * f * t) + 0.3 * sin(2 * pi * f * 3 * t) + 0.15 * sin(2 * pi * f * 5 * t);
            }
            sampleValue = drone * 0.17 * exp(-0.6 * (t % (2 * beat)));
          } else if (isSynthwave) {
            // A minor pad swelling in every half bar.
            double pad = sin(2 * pi * 220.0 * t) + sin(2 * pi * 261.63 * t) + sin(2 * pi * 329.63 * t);
            sampleValue = pad * 0.25 * (1 - exp(-3.0 * (t % (2 * beat))));
          } else {
            double c = sin(2 * pi * 261.63 * t);
            double e = sin(2 * pi * 329.63 * t);
            double g = sin(2 * pi * 392.00 * t);
            sampleValue = (c + e + g) * 0.28 * exp(-2.0 * (t % beat));
          }
          break;

        case 'lead':
          // Four-note 16th-note arpeggio.
          int step = (t / (beat / 4)).floor() % 4;
          double env = exp(-4.0 * (t % (beat / 4)));
          if (isFusion) {
            // Sargam pentatonic Sa Re Ga Pa with a sitar-like buzz.
            double freq = const [261.63, 293.66, 329.63, 392.0][step];
            sampleValue = (sin(2 * pi * freq * t) + 0.3 * sin(2 * pi * freq * 2 * t) + 0.15 * sin(2 * pi * freq * 5 * t)) * 0.4 * env;
          } else if (isSynthwave) {
            // Saw-like A minor arpeggio.
            double freq = const [220.0, 261.63, 329.63, 440.0][step];
            sampleValue = (sin(2 * pi * freq * t) + 0.5 * sin(2 * pi * freq * 2 * t) + 0.33 * sin(2 * pi * freq * 3 * t)) * 0.3 * env;
          } else {
            double freq = 440.0 + step * 110.0;
            sampleValue = sin(2 * pi * freq * t) * 0.5 * env;
          }
          break;

        case 'vocal':
          final List<double> voice = isSynthwave ? [440.0, 523.25] : (isFusion ? [523.25, 783.99] : [523.25, 659.25]);
          double chopEnv = exp(-3.0 * (t % beat));
          double vox = sin(2 * pi * voice[0] * t) + 0.5 * sin(2 * pi * voice[1] * t);
          sampleValue = vox * chopEnv * 0.45;
          break;

        case 'percussion':
          // Off-beat 16ths: hi-hats, or tabla "Na" in the fusion pack.
          double ph = (t % (beat / 2)) - beat / 4;
          if (ph >= 0 && ph < 0.08) {
            sampleValue = isFusion
                ? sin(2 * pi * 700 * ph) * exp(-25.0 * ph) * 0.45
                : (rng.nextDouble() * 2 - 1) * exp(-30.0 * ph) * 0.4;
          }
          break;

        case 'piano_stab':
          double env = exp(-3.5 * (t % (2 * beat)));
          if (isFusion) {
            // Harmonium-like reed: odd harmonics on Sa and Pa.
            double reed = 0.0;
            for (final f in const [261.63, 392.0]) {
              reed += sin(2 * pi * f * t) + 0.4 * sin(2 * pi * f * 3 * t) + 0.2 * sin(2 * pi * f * 5 * t);
            }
            sampleValue = reed * 0.25 * env;
          } else {
            final List<double> stab = isSynthwave ? [329.63, 392.0] : [329.63, 440.0];
            sampleValue = (sin(2 * pi * stab[0] * t) + sin(2 * pi * stab[1] * t)) * 0.4 * env;
          }
          break;

        case 'fx_riser':
        default:
          double sweepFreq = 200.0 + (t / bar) * 1200.0;
          double noise = (rng.nextDouble() * 2 - 1) * 0.15;
          sampleValue = (sin(2 * pi * sweepFreq * t) + noise) * (t / bar) * 0.5;
          break;
      }

      if (filterCutoff < 1.0) {
        filtered += filterAlpha * (sampleValue - filtered);
        sampleValue = filtered;
      }

      sampleValue = sampleValue.clamp(-1.0, 1.0);
      data.setInt16(44 + i * 2, (sampleValue * 32767).toInt(), Endian.little);
    }
    return data.buffer.asUint8List();
  }

  /// Generates a drum pad hit. [padType] picks one of the 16 pad voices and [kit]
  /// ('classic', 'hiphop', 'edm') shapes its character: kick tuning, snare body,
  /// hat length, 808 sustain and saturation.
  static Uint8List generateDrumPadWav(String padType, {String kit = 'classic'}) {
    final bool hipHop = kit == 'hiphop';
    final bool edm = kit == 'edm';
    final String voice = padType.toLowerCase();

    final bool longTail = voice == 'sub_kick' || voice == 'bass_drop' || voice == 'crash';
    final double durationSeconds = longTail ? 1.2 : 0.6;
    final int numSamples = (sampleRate * durationSeconds).toInt();
    final ByteData data = ByteData(44 + numSamples * 2);
    _writeWavHeader(data, numSamples, sampleRate);

    final Random rng = Random(42);
    // Hip-hop gets warm tape-style saturation, EDM a little, classic none.
    final double drive = hipHop ? 1.8 : (edm ? 1.3 : 1.0);

    double phase = 0.0;
    double previousNoise = 0.0;

    // Pitch-swept sine drum: frequency glides from [startHz] to [endHz] over [sweepSeconds].
    double sweptSine(double t, double startHz, double endHz, double sweepSeconds) {
      final double progress = min(t / sweepSeconds, 1.0);
      final double freq = startHz * pow(endHz / startHz, progress);
      phase += 2 * pi * freq / sampleRate;
      return sin(phase);
    }

    for (int i = 0; i < numSamples; i++) {
      double t = i / sampleRate;
      double noise = rng.nextDouble() * 2 - 1;
      // First difference of white noise: a crude high-pass for cymbals and hats.
      double brightNoise = (noise - previousNoise) * 0.5;
      previousNoise = noise;
      double sampleValue = 0.0;

      switch (voice) {
        case 'kick':
        case 'kick2':
          final bool alt = voice == 'kick2';
          double startHz = (edm ? 150.0 : (hipHop ? 100.0 : 120.0)) * (alt ? 1.2 : 1.0);
          double endHz = edm ? 48.0 : (hipHop ? 45.0 : 50.0);
          double decay = (edm ? 9.0 : (hipHop ? 6.0 : 8.0)) * (alt ? 1.4 : 1.0);
          double click = (t < 0.004) ? noise * (edm ? 0.5 : (hipHop ? 0.3 : 0.1)) : 0.0;
          sampleValue = sweptSine(t, startHz, endHz, 0.1) * exp(-decay * t) * 0.95 + click;
          break;

        case 'sub_kick':
          // 808-style sub with a long tail.
          double decay = edm ? 2.0 : (hipHop ? 2.5 : 4.0);
          sampleValue = sweptSine(t, 70.0, 45.0, 0.08) * exp(-decay * t) * 0.95;
          break;

        case 'bass_drop':
          // Deep pitch dive.
          sampleValue = sweptSine(t, 220.0, 30.0, 0.9) * exp(-2.0 * t) * 0.9;
          break;

        case 'snare':
        case 'snare2':
          final bool alt = voice == 'snare2';
          double toneHz = (edm ? 220.0 : (hipHop ? 200.0 : 180.0)) * (alt ? 1.3 : 1.0);
          double noiseDecay = (edm ? 14.0 : (hipHop ? 9.0 : 12.0)) * (alt ? 1.5 : 1.0);
          double tone = sin(2 * pi * toneHz * t) * exp(-15.0 * t) * (hipHop ? 0.6 : 0.5);
          sampleValue = tone + noise * exp(-noiseDecay * t) * 0.5;
          if (edm) {
            // EDM snares are layered with a clap.
            sampleValue += _clap(t, noise) * 0.4;
          }
          break;

        case 'clap':
          sampleValue = _clap(t, noise) * (hipHop ? 0.7 : 0.85);
          break;

        case 'rimshot':
          sampleValue = (sin(2 * pi * 1700 * t) * 0.6 + sin(2 * pi * 420 * t) * 0.5 + noise * 0.3) * exp(-60.0 * t);
          break;

        case 'hihat_close':
          sampleValue = brightNoise * exp(-(edm ? 30.0 : (hipHop ? 50.0 : 40.0)) * t) * 1.2;
          break;

        case 'hihat_open':
          sampleValue = brightNoise * exp(-(edm ? 5.0 : (hipHop ? 9.0 : 7.0)) * t) * 1.0;
          break;

        case 'crash':
          double metal = sin(2 * pi * 3150 * t) * 0.15 + sin(2 * pi * 4720 * t) * 0.1;
          sampleValue = (brightNoise * 1.2 + metal) * exp(-(edm ? 2.5 : 3.5) * t) * 0.8;
          break;

        case 'shaker':
          double attack = min(t / 0.015, 1.0);
          sampleValue = brightNoise * attack * exp(-30.0 * t) * 1.1;
          break;

        case 'tom_high':
          sampleValue = sweptSine(t, 220.0, 170.0, 0.3) * exp(-8.0 * t) * 0.85;
          break;

        case 'tom_low':
        case 'tom':
          sampleValue = sweptSine(t, 130.0, 95.0, 0.3) * exp(-7.0 * t) * 0.85;
          break;

        case 'cowbell':
          double square(double hz) => sin(2 * pi * hz * t) >= 0 ? 1.0 : -1.0;
          sampleValue = (square(540) + square(800)) * 0.22 * exp(-15.0 * t);
          break;

        case 'conga':
          sampleValue = sweptSine(t, 340.0, 300.0, 0.05) * exp(-12.0 * t) * 0.8;
          break;

        default:
          double env = exp(-20.0 * t);
          sampleValue = sin(2 * pi * 440.0 * t) * env * 0.6;
          break;
      }

      if (drive > 1.0) {
        sampleValue = _tanh(sampleValue * drive) / _tanh(drive);
      }

      sampleValue = sampleValue.clamp(-1.0, 1.0);
      data.setInt16(44 + i * 2, (sampleValue * 32767).toInt(), Endian.little);
    }
    return data.buffer.asUint8List();
  }

  /// Hand clap: three quick noise bursts followed by a short tail.
  static double _clap(double t, double noise) {
    for (final burst in const [0.0, 0.011, 0.022]) {
      if (t >= burst && t < burst + 0.008) return noise * exp(-200.0 * (t - burst));
    }
    return t >= 0.022 ? noise * exp(-18.0 * (t - 0.022)) : 0.0;
  }

  static double _tanh(double x) {
    final double e2x = exp(2 * x.clamp(-10.0, 10.0));
    return (e2x - 1) / (e2x + 1);
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
