import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../models/volume_preset.dart';
import '../state/presets_controller.dart';
import '../state/volume_controller.dart';

class PresetsScreen extends StatelessWidget {
  final PresetsController presetsController;
  final VolumeController volumeController;

  const PresetsScreen({
    super.key,
    required this.presetsController,
    required this.volumeController,
  });

  void _applyPreset(BuildContext context, VolumePreset preset) async {
    await presetsController.applyPreset(preset);
    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.cyan, size: 20),
              const SizedBox(width: 10),
              Text(
                '${preset.name} preset applied',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: AppColors.darkSurfaceContainerHigh,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showCreatePresetSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _PresetFormSheet(
        onSave: (name, media, ring, alarm, call) async {
          await presetsController.createPreset(
            name: name,
            mediaPercentage: media,
            ringPercentage: ring,
            alarmPercentage: alarm,
            callPercentage: call,
          );
        },
      ),
    );
  }

  void _showEditPresetSheet(BuildContext context, VolumePreset preset) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _PresetFormSheet(
        initialPreset: preset,
        onSave: (name, media, ring, alarm, call) async {
          await presetsController.updatePreset(
            preset.copyWith(
              name: name,
              mediaPercentage: media,
              ringPercentage: ring,
              alarmPercentage: alarm,
              callPercentage: call,
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, VolumePreset preset) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: Text(
          'Delete "${preset.name}"?',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this custom preset? This action cannot be undone.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await presetsController.deletePreset(preset.id);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: presetsController,
      builder: (context, _) {
        final builtIns = presetsController.builtInPresets;
        final customs = presetsController.customPresets;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.tune_rounded,
                color: AppColors.cyan,
                size: 26,
              ),
              tooltip: 'Presets',
            ),
            title: Text(
              'Presets',
              style: AppTypography.headlineLarge.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Presets Header
                _buildSectionHeader('Quick Presets'),
                const SizedBox(height: 8),

                // Quick Presets Grid
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: builtIns.map((preset) {
                    return _buildQuickPresetCard(context, preset);
                  }).toList(),
                ),

                const SizedBox(height: 28),

                // Custom Presets Header + Add Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionHeader('Custom Presets'),
                    TextButton.icon(
                      onPressed: () => _showCreatePresetSheet(context),
                      icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.cyan),
                      label: Text(
                        'Create',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.cyan,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (customs.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.bookmark_border_rounded,
                          size: 40,
                          color: AppColors.outline,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No Custom Presets Yet',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Create custom volume profiles like Gaming, Night, or Study.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => _showCreatePresetSheet(context),
                          icon: const Icon(Icons.add, size: 16, color: AppColors.cyan),
                          label: const Text('Create Custom Preset',
                              style: TextStyle(color: AppColors.cyan)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.cyan),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: customs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final preset = customs[index];
                      return _buildCustomPresetCard(context, preset);
                    },
                  ),

                if (customs.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showCreatePresetSheet(context),
                      icon: const Icon(Icons.add, size: 18, color: AppColors.cyan),
                      label: const Text(
                        '+ Create Custom Preset',
                        style: TextStyle(color: AppColors.cyan, fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.cyan, width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.titleMedium.copyWith(
        color: AppColors.cyanDim,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildQuickPresetCard(BuildContext context, VolumePreset preset) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _applyPreset(context, preset),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder, width: 1.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.azureContainer.withValues(alpha: 0.25),
                ),
                child: const Icon(
                  Icons.volume_up_rounded,
                  color: AppColors.cyan,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      preset.name,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'All Streams',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.play_arrow_rounded,
                color: AppColors.cyan,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomPresetCard(BuildContext context, VolumePreset preset) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.violetContainer.withValues(alpha: 0.25),
                ),
                child: const Icon(
                  Icons.bookmark_rounded,
                  color: AppColors.onTertiaryContainer,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  preset.name,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _showEditPresetSheet(context, preset),
                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.onSurfaceVariant),
                tooltip: 'Edit',
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: () => _showDeleteDialog(context, preset),
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                tooltip: 'Delete',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Media ${preset.mediaPercentage}% • Ring ${preset.ringPercentage}% • Alarm ${preset.alarmPercentage}% • Call ${preset.callPercentage}%',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: () => _applyPreset(context, preset),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.darkSurfaceContainerHigh,
                foregroundColor: AppColors.cyan,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.check_rounded, size: 16),
              label: const Text('Apply Preset', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetFormSheet extends StatefulWidget {
  final VolumePreset? initialPreset;
  final Future<void> Function(String name, int media, int ring, int alarm, int call) onSave;

  const _PresetFormSheet({
    this.initialPreset,
    required this.onSave,
  });

  @override
  State<_PresetFormSheet> createState() => _PresetFormSheetState();
}

class _PresetFormSheetState extends State<_PresetFormSheet> {
  late TextEditingController _nameController;
  late int _mediaPct;
  late int _ringPct;
  late int _alarmPct;
  late int _callPct;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialPreset?.name ?? '');
    _mediaPct = widget.initialPreset?.mediaPercentage ?? 70;
    _ringPct = widget.initialPreset?.ringPercentage ?? 50;
    _alarmPct = widget.initialPreset?.alarmPercentage ?? 60;
    _callPct = widget.initialPreset?.callPercentage ?? 60;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialPreset != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEditing ? 'Edit Custom Preset' : 'Create Custom Preset',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _nameController,
            autofocus: !isEditing,
            decoration: InputDecoration(
              labelText: 'Preset Name',
              hintText: 'e.g. Night, Gaming, Study, Travel',
              filled: true,
              fillColor: AppColors.darkSurfaceContainer,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.cyan),
              ),
            ),
          ),
          const SizedBox(height: 20),

          _buildStreamSlider('Media', _mediaPct, AppColors.azureLight, (val) {
            setState(() => _mediaPct = val);
          }),
          _buildStreamSlider('Ring', _ringPct, AppColors.cyan, (val) {
            setState(() => _ringPct = val);
          }),
          _buildStreamSlider('Alarm', _alarmPct, AppColors.violetContainer, (val) {
            setState(() => _alarmPct = val);
          }),
          _buildStreamSlider('Call', _callPct, AppColors.onSurfaceVariant, (val) {
            setState(() => _callPct = val);
          }),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                if (name.isEmpty) return;

                await widget.onSave(name, _mediaPct, _ringPct, _alarmPct, _callPct);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.cyan,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isEditing ? 'Save Changes' : 'Save Preset',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamSlider(
    String label,
    int value,
    Color color,
    ValueChanged<int> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 55,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: color,
                inactiveTrackColor: AppColors.darkSurfaceContainerHigh,
                thumbColor: color,
                overlayColor: color.withValues(alpha: 0.2),
                trackHeight: 6,
              ),
              child: Slider(
                value: value.toDouble(),
                min: 0,
                max: 100,
                divisions: 100,
                onChanged: (v) => onChanged(v.round()),
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '$value%',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: color,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
