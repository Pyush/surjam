import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Instrument Key Labels Mode ('english', 'sargam', 'solfege')
  String getKeyLabelMode() {
    return _prefs?.getString('key_label_mode') ?? 'english';
  }

  Future<void> setKeyLabelMode(String mode) async {
    await _prefs?.setString('key_label_mode', mode);
  }

  // Vibration on drum and pad taps
  bool getHapticsEnabled() {
    return _prefs?.getBool('haptics_enabled') ?? true;
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    await _prefs?.setBool('haptics_enabled', enabled);
  }

  // Saved Recordings
  List<Map<String, dynamic>> getSavedRecordings() {
    final String? raw = _prefs?.getString('saved_recordings');
    if (raw == null || raw.isEmpty) return [];
    try {
      final List decoded = jsonDecode(raw);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveRecording(Map<String, dynamic> recording) async {
    final list = getSavedRecordings();
    list.insert(0, recording);
    await _prefs?.setString('saved_recordings', jsonEncode(list));
  }

  Future<void> deleteRecording(String id) async {
    final list = getSavedRecordings();
    list.removeWhere((item) => item['id'] == id);
    await _prefs?.setString('saved_recordings', jsonEncode(list));
  }

  // High Scores for Learn Mode Exercises
  int getExerciseScore(String exerciseId) {
    return _prefs?.getInt('score_$exerciseId') ?? 0;
  }

  Future<void> saveExerciseScore(String exerciseId, int score) async {
    int current = getExerciseScore(exerciseId);
    if (score > current) {
      await _prefs?.setInt('score_$exerciseId', score);
    }
  }
}
