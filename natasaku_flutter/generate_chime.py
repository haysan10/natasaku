import wave
import struct
import math

def generate_chime(filename, duration=2.0, sample_rate=44100):
    # Frequencies for a C major chord: C5, E5, G5, C6
    freqs = [523.25, 659.25, 783.99, 1046.50]
    
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        
        for i in range(int(sample_rate * duration)):
            t = float(i) / sample_rate
            # Additive synthesis
            sample = 0
            for f in freqs:
                # Envelope: sharp attack, exponential decay
                envelope = math.exp(-3.0 * t) 
                sample += math.sin(2 * math.pi * f * t) * envelope
            
            # Normalize and scale to 16-bit
            sample = sample / len(freqs) * 32767 * 0.5
            wav_file.writeframes(struct.pack('h', int(sample)))

generate_chime('assets/sounds/splash.wav')
