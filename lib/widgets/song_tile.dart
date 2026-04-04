import 'package:flutter/material.dart';

import '../models/song.dart';
import '../theme/colors.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;
  final bool isPlaying;
  final bool showDuration;
  final Widget? trailing;
  final Widget? leading;

  const SongTile({
    super.key,
    required this.song,
    this.onTap,
    this.onMoreTap,
    this.isPlaying = false,
    this.showDuration = true,
    this.trailing,
    this.leading,
  });

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading:
          leading ??
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: isPlaying ? AppColors.primaryGradient : null,
              color: isPlaying ? null : AppColors.surfaceLight,
            ),
            child: Icon(
              isPlaying ? Icons.equalizer_rounded : Icons.music_note_rounded,
              color: isPlaying ? Colors.white : AppColors.textTertiary,
              size: 24,
            ),
          ),
      title: Text(
        song.title,
        style: TextStyle(
          color: isPlaying ? AppColors.primary : AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              song.artist,
              style: TextStyle(
                color: isPlaying
                    ? AppColors.primaryLight
                    : AppColors.textSecondary,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showDuration) ...[
            const SizedBox(width: 8),
            Text(
              _formatDuration(song.duration),
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
      trailing:
          trailing ??
          IconButton(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: AppColors.textTertiary,
              size: 20,
            ),
            onPressed: onMoreTap,
          ),
      onTap: onTap,
    );
  }
}
