import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'nata_sound.dart';

class NataSoundPlayer {
  static final AudioPlayer _player = AudioPlayer();

  static Future<bool> _isSoundEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('sound_enabled') ?? true;
    } catch (_) {
      return true;
    }
  }

  static Future<void> playSuccess() async {
    if (await _isSoundEnabled()) {
      try {
        await _player.play(BytesSource(NataSound.successPing));
      } catch (_) {}
    }
  }

  static Future<void> playWarning() async {
    if (await _isSoundEnabled()) {
      try {
        await _player.play(BytesSource(NataSound.warningTone));
      } catch (_) {}
    }
  }

  static Future<void> playDelete() async {
    if (await _isSoundEnabled()) {
      try {
        await _player.play(BytesSource(NataSound.deleteTone));
      } catch (_) {}
    }
  }

  static Future<void> playAchievement() async {
    if (await _isSoundEnabled()) {
      try {
        await _player.play(BytesSource(NataSound.achievementTone));
      } catch (_) {}
    }
  }
}
