import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/equalizer_preset.dart';
import '../../services/equalizer_service.dart';

final equalizerServiceProvider = Provider<EqualizerService>((ref) {
  return EqualizerService();
});

final equalizerEnabledProvider =
    StateNotifierProvider<EqualizerEnabledNotifier, bool>((ref) {
      final service = ref.watch(equalizerServiceProvider);
      return EqualizerEnabledNotifier(service);
    });

class EqualizerEnabledNotifier extends StateNotifier<bool> {
  final EqualizerService _service;

  EqualizerEnabledNotifier(this._service) : super(false) {
    state = _service.isEnabled;
  }

  Future<void> toggle() async {
    state = !state;
    await _service.setEnabled(state);
  }
}

final currentPresetProvider =
    StateNotifierProvider<CurrentPresetNotifier, EqualizerPreset>((ref) {
      final service = ref.watch(equalizerServiceProvider);
      return CurrentPresetNotifier(service);
    });

class CurrentPresetNotifier extends StateNotifier<EqualizerPreset> {
  final EqualizerService _service;

  CurrentPresetNotifier(this._service) : super(EqualizerPreset.flat) {
    state = _service.getCurrentPreset();
  }

  Future<void> setPreset(EqualizerPreset preset) async {
    state = preset;
    await _service.setPreset(preset);
  }

  Future<void> setBandValue(int index, double value) async {
    final newValues = List<double>.from(state.bandValues);
    newValues[index] = value;
    state = EqualizerPreset(
      name: 'Custom',
      bandValues: newValues,
      isCustom: true,
    );
    await _service.setPreset(state);
  }
}

final customPresetsProvider =
    StateNotifierProvider<CustomPresetsNotifier, List<EqualizerPreset>>((ref) {
      final service = ref.watch(equalizerServiceProvider);
      return CustomPresetsNotifier(service);
    });

class CustomPresetsNotifier extends StateNotifier<List<EqualizerPreset>> {
  final EqualizerService _service;

  CustomPresetsNotifier(this._service) : super([]) {
    state = _service.getCustomPresets();
  }

  Future<void> savePreset(EqualizerPreset preset) async {
    await _service.saveCustomPreset(preset);
    state = _service.getCustomPresets();
  }

  Future<void> deletePreset(String name) async {
    await _service.deleteCustomPreset(name);
    state = _service.getCustomPresets();
  }
}
