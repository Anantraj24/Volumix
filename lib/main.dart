import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'repositories/volume_repository.dart';
import 'screens/main_navigation_scaffold.dart';
import 'services/preferences_service.dart';
import 'services/volume_platform_service.dart';
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

  await settingsController.init();
  await volumeController.init();

  runApp(VolumixApp(
    volumeController: volumeController,
    settingsController: settingsController,
  ));
}

class VolumixApp extends StatelessWidget {
  final VolumeController volumeController;
  final SettingsController settingsController;

  const VolumixApp({
    super.key,
    required this.volumeController,
    required this.settingsController,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([volumeController, settingsController]),
      builder: (context, _) {
        return MaterialApp(
          title: 'Volumix',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getTheme(isAmoled: settingsController.isAmoledMode),
          home: MainNavigationScaffold(
            volumeController: volumeController,
            settingsController: settingsController,
          ),
        );
      },
    );
  }
}
