import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'repositories/volume_repository.dart';
import 'screens/main_navigation_scaffold.dart';
import 'services/preferences_service.dart';
import 'services/volume_platform_service.dart';
import 'state/presets_controller.dart';
import 'state/settings_controller.dart';
import 'state/volume_controller.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge-to-edge system navigation & status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final preferencesService = await PreferencesService.init();
  final volumePlatformService = VolumePlatformService();

  final volumeRepository = VolumeRepository(
    platformService: volumePlatformService,
    preferencesService: preferencesService,
  );

  final volumeController = VolumeController(volumeRepository);
  final settingsController = SettingsController(volumeRepository);
  final presetsController = PresetsController(
    repository: volumeRepository,
    volumeController: volumeController,
  );

  await settingsController.init();
  await volumeController.init();
  await presetsController.init();

  runApp(VolumixApp(
    volumeController: volumeController,
    settingsController: settingsController,
    presetsController: presetsController,
  ));
}

class VolumixApp extends StatelessWidget {
  final VolumeController volumeController;
  final SettingsController settingsController;
  final PresetsController presetsController;

  const VolumixApp({
    super.key,
    required this.volumeController,
    required this.settingsController,
    required this.presetsController,
  });

  @override
  Widget build(BuildContext context) {
    // Only listen to settingsController for theme changes (AMOLED mode)
    // Avoid rebuilding MaterialApp on volume changes
    return ListenableBuilder(
      listenable: settingsController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Volumix',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getTheme(isAmoled: settingsController.isAmoledMode),
          home: MainNavigationScaffold(
            volumeController: volumeController,
            settingsController: settingsController,
            presetsController: presetsController,
          ),
        );
      },
    );
  }
}
