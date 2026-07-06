import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/equalizer_preset.dart';
import '../../theme/colors.dart';
import 'equalizer_provider.dart';

class EqualizerScreen extends ConsumerWidget {
  /// When shown as a bottom-nav tab (inside HomeScreen) we render a VibeTune
  /// brand header instead of a back button.
  final bool embedded;

  const EqualizerScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnabled = ref.watch(equalizerEnabledProvider);
    final currentPreset = ref.watch(currentPresetProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            children: [
              _header(context),
              const SizedBox(height: 20),
              _masterCard(context, ref, isEnabled),
              const SizedBox(height: 24),
              _presetsSection(context, ref, currentPreset, isEnabled),
              const SizedBox(height: 24),
              _bandsCard(context, ref, currentPreset, isEnabled),
              const SizedBox(height: 20),
              _featureCards(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        if (!embedded)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_rounded, size: 24),
            ),
          )
        else
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
          ),
        const SizedBox(width: 10),
        Text(
          'VibeTune',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        const Icon(Icons.search_rounded, color: AppColors.textPrimary, size: 24),
      ],
    );
  }

  Widget _masterCard(BuildContext context, WidgetRef ref, bool isEnabled) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.equalizer_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Equalizer',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 2),
                const Text(
                  'Master your audio experience',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (_) {
              ref.read(equalizerEnabledProvider.notifier).toggle();
            },
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.surfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _presetsSection(
    BuildContext context,
    WidgetRef ref,
    EqualizerPreset currentPreset,
    bool isEnabled,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRESETS',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textTertiary,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: EqualizerPreset.presets.map((preset) {
            final isSelected =
                currentPreset.name == preset.name && !currentPreset.isCustom;
            return GestureDetector(
              onTap: isEnabled
                  ? () => ref
                        .read(currentPresetProvider.notifier)
                        .setPreset(preset)
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textTertiary.withValues(alpha: 0.4),
                  ),
                  boxShadow: isSelected
                      ? AppColors.glow(AppColors.primary, alpha: 0.28)
                      : null,
                ),
                child: Text(
                  preset.name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _bandsCard(
    BuildContext context,
    WidgetRef ref,
    EqualizerPreset currentPreset,
    bool isEnabled,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                EqualizerPreset.bandLabels.length,
                (index) => _BandSlider(
                  label: EqualizerPreset.bandLabels[index],
                  value: currentPreset.bandValues[index],
                  enabled: isEnabled,
                  onChanged: (value) {
                    ref
                        .read(currentPresetProvider.notifier)
                        .setBandValue(index, value);
                  },
                ),
              ),
            ),
          ),
          const Divider(height: 32, color: AppColors.surfaceVariant),
          Row(
            children: [
              const Icon(
                Icons.graphic_eq_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Real-time Spectrum Analysis',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GestureDetector(
                onTap: isEnabled
                    ? () => ref
                          .read(currentPresetProvider.notifier)
                          .setPreset(EqualizerPreset.flat)
                    : null,
                child: const Text(
                  'Reset All',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _featureCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _FeatureTile(
            icon: Icons.surround_sound_rounded,
            title: '3D Audio',
            subtitle: 'Immersive soundstage enabled',
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _FeatureTile(
            icon: Icons.headphones_rounded,
            title: 'Profile',
            subtitle: 'Optimized for: Studio Pro X',
            gradient: const LinearGradient(
              colors: [AppColors.accent, AppColors.accentLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.glow(
          (gradient as LinearGradient).colors.first,
          alpha: 0.28,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BandSlider extends StatelessWidget {
  final String label;
  final double value;
  final bool enabled;
  final ValueChanged<double> onChanged;

  const _BandSlider({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${value > 0 ? '+' : ''}${value.toStringAsFixed(0)}',
          style: TextStyle(
            color: enabled ? AppColors.primary : AppColors.textTertiary,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: RotatedBox(
            quarterTurns: -1,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: enabled
                    ? AppColors.primary
                    : AppColors.textTertiary,
                inactiveTrackColor: AppColors.surfaceVariant,
                trackHeight: 8,
                trackShape: const RoundedRectSliderTrackShape(),
                overlayColor: AppColors.primary.withValues(alpha: 0.12),
                thumbShape: const _RingThumb(radius: 11),
              ),
              child: Slider(
                min: -12,
                max: 12,
                value: value,
                onChanged: enabled ? onChanged : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// White thumb with a violet ring (matches the equalizer design).
class _RingThumb extends SliderComponentShape {
  final double radius;
  const _RingThumb({this.radius = 11});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size.fromRadius(radius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(
      center.translate(0, 1.5),
      radius,
      Paint()
        ..color = AppColors.primary.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(center, radius, Paint()..color = Colors.white);
    canvas.drawCircle(
      center,
      radius - 1,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }
}
