import 'package:flutter/foundation.dart';
import '../models/volume_preset.dart';
import '../repositories/volume_repository.dart';
import 'volume_controller.dart';

class PresetsController extends ChangeNotifier {
  final VolumeRepository _repository;
  final VolumeController _volumeController;

  List<VolumePreset> _customPresets = [];
  bool _isLoading = false;

  PresetsController({
    required VolumeRepository repository,
    required VolumeController volumeController,
  })  : _repository = repository,
        _volumeController = volumeController;

  List<VolumePreset> get builtInPresets => VolumePreset.builtInPresets;
  List<VolumePreset> get customPresets => List.unmodifiable(_customPresets);
  List<VolumePreset> get allPresets => [...builtInPresets, ..._customPresets];
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _customPresets = _repository.getCustomPresets();
    } catch (_) {
      _customPresets = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPreset({
    required String name,
    required int mediaPercentage,
    required int ringPercentage,
    required int alarmPercentage,
    required int callPercentage,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return false;

    final id = 'preset_${DateTime.now().millisecondsSinceEpoch}';
    final newPreset = VolumePreset(
      id: id,
      name: trimmedName,
      mediaPercentage: mediaPercentage.clamp(0, 100),
      ringPercentage: ringPercentage.clamp(0, 100),
      alarmPercentage: alarmPercentage.clamp(0, 100),
      callPercentage: callPercentage.clamp(0, 100),
      isBuiltIn: false,
    );

    _customPresets.add(newPreset);
    notifyListeners();
    await _repository.saveCustomPresets(_customPresets);
    return true;
  }

  Future<bool> updatePreset(VolumePreset updatedPreset) async {
    if (updatedPreset.isBuiltIn) return false;

    final index = _customPresets.indexWhere((p) => p.id == updatedPreset.id);
    if (index == -1) return false;

    _customPresets[index] = updatedPreset;
    notifyListeners();
    await _repository.saveCustomPresets(_customPresets);
    return true;
  }

  Future<bool> deletePreset(String presetId) async {
    final index = _customPresets.indexWhere((p) => p.id == presetId);
    if (index == -1) return false;

    if (_customPresets[index].isBuiltIn) return false;

    _customPresets.removeAt(index);
    notifyListeners();
    await _repository.saveCustomPresets(_customPresets);
    return true;
  }

  Future<bool> applyPreset(VolumePreset preset) async {
    return await _volumeController.applyPreset(preset);
  }
}
