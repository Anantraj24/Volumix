import 'package:flutter_test/flutter_test.dart';
import 'package:volumix/models/volume_preset.dart';
import 'package:volumix/repositories/volume_repository.dart';
import 'package:volumix/state/presets_controller.dart';
import 'package:volumix/state/volume_controller.dart';
import 'volume_controller_test.dart';

void main() {
  late FakeVolumePlatformService platformService;
  late FakePreferencesService preferencesService;
  late VolumeRepository repository;
  late VolumeController volumeController;
  late PresetsController presetsController;

  setUp(() {
    platformService = FakeVolumePlatformService();
    preferencesService = FakePreferencesService();
    repository = VolumeRepository(
      platformService: platformService,
      preferencesService: preferencesService,
    );
    volumeController = VolumeController(repository);
    presetsController = PresetsController(
      repository: repository,
      volumeController: volumeController,
    );
  });

  test('PresetsController loads built-in presets by default', () async {
    await volumeController.init();
    await presetsController.init();

    expect(presetsController.builtInPresets.length, 4);
    expect(presetsController.customPresets.isEmpty, true);
    expect(presetsController.allPresets.length, 4);
  });

  test('Creates custom preset and persists to storage', () async {
    await volumeController.init();
    await presetsController.init();

    final created = await presetsController.createPreset(
      name: 'Gaming',
      mediaPercentage: 80,
      ringPercentage: 30,
      alarmPercentage: 50,
      callPercentage: 60,
    );

    expect(created, true);
    expect(presetsController.customPresets.length, 1);
    expect(presetsController.customPresets.first.name, 'Gaming');
    expect(presetsController.customPresets.first.mediaPercentage, 80);
    expect(presetsController.customPresets.first.ringPercentage, 30);
    expect(presetsController.allPresets.length, 5);

    // Verify persistence
    final persisted = preferencesService.getCustomPresets();
    expect(persisted.length, 1);
    expect(persisted.first.name, 'Gaming');
  });

  test('Updates existing custom preset', () async {
    await volumeController.init();
    await presetsController.init();

    await presetsController.createPreset(
      name: 'Study',
      mediaPercentage: 40,
      ringPercentage: 10,
      alarmPercentage: 40,
      callPercentage: 50,
    );

    final existing = presetsController.customPresets.first;
    final updated = existing.copyWith(
      name: 'Study Focus',
      mediaPercentage: 30,
    );

    final ok = await presetsController.updatePreset(updated);
    expect(ok, true);
    expect(presetsController.customPresets.first.name, 'Study Focus');
    expect(presetsController.customPresets.first.mediaPercentage, 30);
  });

  test('Deletes custom preset and cannot delete built-in preset', () async {
    await volumeController.init();
    await presetsController.init();

    await presetsController.createPreset(
      name: 'Night',
      mediaPercentage: 10,
      ringPercentage: 0,
      alarmPercentage: 100,
      callPercentage: 20,
    );

    final customId = presetsController.customPresets.first.id;

    // Try deleting built-in
    final deleteBuiltInOk = await presetsController.deletePreset('builtin_25');
    expect(deleteBuiltInOk, false);

    // Delete custom
    final deleteCustomOk = await presetsController.deletePreset(customId);
    expect(deleteCustomOk, true);
    expect(presetsController.customPresets.isEmpty, true);
  });

  test('Applies preset to volume controller', () async {
    await volumeController.init();
    await presetsController.init();

    final preset = VolumePreset.builtInPresets[1]; // 50%
    final ok = await presetsController.applyPreset(preset);

    expect(ok, true);
    expect(volumeController.streams.first.percentage, 50);
  });
}
