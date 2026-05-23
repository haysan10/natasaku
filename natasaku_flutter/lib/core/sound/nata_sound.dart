import 'dart:typed_data';
import 'dart:math';

class NataSound {
  // Generate a short sine wave as raw PCM bytes
  static Uint8List _generateTone({
    required double frequency,   // Hz
    required double durationSec,
    required double amplitude,   // 0.0 – 1.0
    int sampleRate = 44100,
  }) {
    final sampleCount = (sampleRate * durationSec).round();
    final buffer = ByteData(sampleCount * 2); // 16-bit PCM
    for (int i = 0; i < sampleCount; i++) {
      // Sine wave with linear fade-out envelope
      final envelope = 1.0 - (i / sampleCount);
      final sample = (sin(2 * pi * frequency * i / sampleRate) * amplitude * envelope * 32767).round().clamp(-32768, 32767);
      buffer.setInt16(i * 2, sample, Endian.little);
    }
    return buffer.buffer.asUint8List();
  }

  // Pleasant high ping — for successful save
  static Uint8List get successPing => _generateTone(frequency: 880, durationSec: 0.18, amplitude: 0.35);

  // Soft double-tone — for overbudget warning
  static Uint8List get warningTone => _generateTone(frequency: 440, durationSec: 0.25, amplitude: 0.3);

  // Low soft thud — for delete action
  static Uint8List get deleteTone => _generateTone(frequency: 220, durationSec: 0.12, amplitude: 0.25);

  // Ascending arpeggio — for saving target reached
  static Uint8List get achievementTone => _generateTone(frequency: 1047, durationSec: 0.22, amplitude: 0.4);
}
