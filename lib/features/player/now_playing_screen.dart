import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../theme/colors.dart';
import '../../widgets/album_art.dart';
import '../../widgets/seek_bar.dart';
import '../equalizer/equalizer_screen.dart';
import 'player_provider.dart';

class NowPlayingScreen extends ConsumerWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final handler = ref.watch(audioHandlerProvider);
    final song = ref.watch(currentSongProvider);
    final positionAsync = ref.watch(positionDataProvider);
    final isPlaying = ref.watch(playingProvider).valueOrNull ?? false;
    final shuffleEnabled = ref.watch(shuffleModeProvider).valueOrNull ?? false;
    final loopMode = ref.watch(loopModeProvider).valueOrNull ?? LoopMode.off;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 28,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'NOW PLAYING',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert_rounded, size: 24),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EqualizerScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Album art inside a floating white card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: AppColors.floatingShadow,
                ),
                child: AlbumArt(
                  artUri: song?.artUri,
                  size: MediaQuery.of(context).size.width * 0.62,
                  showShadow: false,
                ),
              ),

              const Spacer(),

              // Song info + heart
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song?.title ?? 'No Song Selected',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontSize: 24),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            song?.artist ?? 'Unknown Artist',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.favorite_border_rounded,
                      color: AppColors.textSecondary,
                      size: 26,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Seek bar
              positionAsync.when(
                data: (data) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SeekBar(
                    position: data.position,
                    duration: data.duration,
                    bufferedPosition: data.bufferedPosition,
                    onChangeEnd: (newPosition) {
                      handler.seek(newPosition);
                    },
                  ),
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SeekBar(
                    position: Duration.zero,
                    duration: Duration.zero,
                  ),
                ),
                error: (e, s) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 12),

              // Primary controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.shuffle_rounded,
                        color: shuffleEnabled
                            ? AppColors.primary
                            : AppColors.textTertiary,
                        size: 24,
                      ),
                      onPressed: () {
                        handler.setShuffleModeCustom(!shuffleEnabled);
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.skip_previous_rounded,
                        color: AppColors.textPrimary,
                        size: 40,
                      ),
                      onPressed: () => handler.skipToPrevious(),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (isPlaying) {
                          handler.pause();
                        } else {
                          handler.play();
                        }
                      },
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                          boxShadow: AppColors.glow(AppColors.primary),
                        ),
                        child: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.skip_next_rounded,
                        color: AppColors.textPrimary,
                        size: 40,
                      ),
                      onPressed: () => handler.skipToNext(),
                    ),
                    IconButton(
                      icon: Icon(
                        loopMode == LoopMode.one
                            ? Icons.repeat_one_rounded
                            : Icons.repeat_rounded,
                        color: loopMode != LoopMode.off
                            ? AppColors.primary
                            : AppColors.textTertiary,
                        size: 24,
                      ),
                      onPressed: () {
                        final next =
                            LoopMode.values[(loopMode.index + 1) %
                                LoopMode.values.length];
                        handler.setLoopMode(next);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Secondary controls
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 60),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.ios_share_rounded,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                    Icon(
                      Icons.queue_music_rounded,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                    Icon(
                      Icons.cast_rounded,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Up Next bar
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColors.softShadow,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.playlist_play_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Up Next: ${_upNextTitle(ref)}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _upNextTitle(WidgetRef ref) {
    final handler = ref.watch(audioHandlerProvider);
    final songs = handler.songs;
    final index = ref.watch(currentIndexProvider).valueOrNull;
    if (index != null && index + 1 < songs.length) {
      return songs[index + 1].title;
    }
    return 'End of queue';
  }
}
