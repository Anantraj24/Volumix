import 'package:flutter_test/flutter_test.dart';
import 'package:volumix/main.dart';
import 'package:volumix/repositories/volume_repository.dart';
import 'package:volumix/state/settings_controller.dart';
import 'package:volumix/state/volume_controller.dart';
import 'volume_controller_test.dart';

void main() {
  testWidgets('VolumixApp renders Home screen with master dial and streams', (tester) async {
    final platformService = FakeVolumePlatformService();
    final preferencesService = FakePreferencesService();
    final repository = VolumeRepository(
      platformService: platformService,
      preferencesService: preferencesService,
    );

    final volumeController = VolumeController(repository);
    final settingsController = SettingsController(repository);

    await settingsController.init();
    await volumeController.init();

    await tester.pumpWidget(
      VolumixApp(
        volumeController: volumeController,
        settingsController: settingsController,
      ),
    );
    await tester.pumpAndSettle();

    // Verify Volumix App Bar title
    expect(find.text('Volumix'), findsOneWidget);

    // Verify Master volume display
    expect(find.text('68%'), findsWidgets);
    expect(find.text('MASTER'), findsOneWidget);

    // Verify Mute All and Restore All buttons
    expect(find.text('Mute All'), findsOneWidget);
    expect(find.text('Restore All'), findsOneWidget);

    // Verify Streams
    expect(find.text('Volume Streams'), findsOneWidget);
    expect(find.text('Media'), findsOneWidget);
    expect(find.text('Ring'), findsOneWidget);

    // Verify Bottom Navigation Bar items
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Quick Controls'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
