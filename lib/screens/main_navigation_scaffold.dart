import 'package:flutter/material.dart';
import '../state/settings_controller.dart';
import '../state/volume_controller.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';
import 'permission_setup_screen.dart';
import 'quick_controls_screen.dart';
import 'settings_screen.dart';

class MainNavigationScaffold extends StatefulWidget {
  final VolumeController volumeController;
  final SettingsController settingsController;

  const MainNavigationScaffold({
    super.key,
    required this.volumeController,
    required this.settingsController,
  });

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Show First-run Permission Setup flow if not completed
    if (!widget.settingsController.isFirstRunCompleted) {
      return PermissionSetupScreen(
        settingsController: widget.settingsController,
        onFinished: () {
          setState(() {});
        },
      );
    }

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            volumeController: widget.volumeController,
            settingsController: widget.settingsController,
            onOpenSettings: () {
              setState(() {
                _currentIndex = 2;
              });
            },
          ),
          QuickControlsScreen(
            volumeController: widget.volumeController,
            settingsController: widget.settingsController,
            onOpenSettings: () {
              setState(() {
                _currentIndex = 2;
              });
            },
          ),
          SettingsScreen(
            settingsController: widget.settingsController,
            volumeController: widget.volumeController,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        isAmoled: widget.settingsController.isAmoledMode,
        onTabSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
