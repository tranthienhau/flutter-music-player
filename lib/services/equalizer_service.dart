import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';

import '../models/equalizer_preset.dart';

class EqualizerService {
  static const String _boxName = 'equalizer';
  static const String _enabledKey = 'enabled';
  static const String _presetKey = 'current_preset';
  static const String _customPresetsKey = 'custom_presets';

  late Box<String> _box;
  AndroidEqualizer? _equalizer;

  Future<void> init(AudioPlayer player) async {
    _box = await Hive.openBox<String>(_boxName);
    // AndroidEqualizer is only available on Android
    // On iOS we simulate the EQ values in UI only
  }

  bool get isEnabled {
    final data = _box.get(_enabledKey);
    return data == 'true';
  }

  Future<void> setEnabled(bool enabled) async {
    await _box.put(_enabledKey, enabled.toString());
    _equalizer?.setEnabled(enabled);
  }

  EqualizerPreset getCurrentPreset() {
    final data = _box.get(_presetKey);
    if (data == null) return EqualizerPreset.flat;
    return EqualizerPreset.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  Future<void> setPreset(EqualizerPreset preset) async {
    await _box.put(_presetKey, jsonEncode(preset.toJson()));
    _applyPreset(preset);
  }

  void _applyPreset(EqualizerPreset preset) {
    // In a real implementation, this would apply EQ band values
    // to the Android equalizer or an iOS audio processing pipeline.
    // For this POC, we store the values and display them in the UI.
  }

  Future<void> setBandValue(int bandIndex, double value) async {
    final current = getCurrentPreset();
    final newValues = List<double>.from(current.bandValues);
    newValues[bandIndex] = value;
    final updated = EqualizerPreset(
      name: 'Custom',
      bandValues: newValues,
      isCustom: true,
    );
    await setPreset(updated);
  }

  List<EqualizerPreset> getCustomPresets() {
    final data = _box.get(_customPresetsKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list
        .map((item) => EqualizerPreset.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCustomPreset(EqualizerPreset preset) async {
    final presets = getCustomPresets();
    presets.removeWhere((p) => p.name == preset.name);
    presets.add(preset);
    await _box.put(
      _customPresetsKey,
      jsonEncode(presets.map((p) => p.toJson()).toList()),
    );
  }

  Future<void> deleteCustomPreset(String name) async {
    final presets = getCustomPresets();
    presets.removeWhere((p) => p.name == name);
    await _box.put(
      _customPresetsKey,
      jsonEncode(presets.map((p) => p.toJson()).toList()),
    );
  }
}
