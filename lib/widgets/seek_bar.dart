import 'package:flutter/material.dart';

import '../theme/colors.dart';

class SeekBar extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final Duration bufferedPosition;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;
  final bool showLabels;

  const SeekBar({
    super.key,
    required this.position,
    required this.duration,
    this.bufferedPosition = Duration.zero,
    this.onChanged,
    this.onChangeEnd,
    this.showLabels = true,
  });

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _dragValue;

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      final hours = duration.inHours.toString();
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final totalMs = widget.duration.inMilliseconds.toDouble();
    final posMs = widget.position.inMilliseconds.toDouble();
    final bufMs = widget.bufferedPosition.inMilliseconds.toDouble();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            // Buffered position track
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape: SliderComponentShape.noThumb,
                activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
                inactiveTrackColor: AppColors.surfaceVariant,
                trackHeight: 3,
                overlayShape: SliderComponentShape.noOverlay,
              ),
              child: Slider(
                min: 0,
                max: totalMs > 0 ? totalMs : 1,
                value: (bufMs).clamp(0, totalMs > 0 ? totalMs : 1),
                onChanged: (_) {},
              ),
            ),
            // Active position track
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: Colors.transparent,
                thumbColor: AppColors.primary,
                overlayColor: AppColors.primary.withValues(alpha: 0.2),
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                min: 0,
                max: totalMs > 0 ? totalMs : 1,
                value: (_dragValue ?? posMs).clamp(
                  0,
                  totalMs > 0 ? totalMs : 1,
                ),
                onChanged: (value) {
                  setState(() => _dragValue = value);
                  widget.onChanged?.call(Duration(milliseconds: value.round()));
                },
                onChangeEnd: (value) {
                  widget.onChangeEnd?.call(
                    Duration(milliseconds: value.round()),
                  );
                  setState(() => _dragValue = null);
                },
              ),
            ),
          ],
        ),
        if (widget.showLabels)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(widget.position),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(
                  _formatDuration(widget.duration),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
