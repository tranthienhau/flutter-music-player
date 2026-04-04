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
                    const Text(
                      'Now Playing',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.equalizer_rounded, size: 24),
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

              // Album art
              AlbumArt(
                artUri: song?.artUri,
                size: MediaQuery.of(context).size.width * 0.7,
              ),

              const Spacer(),

              // Song info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text(
                      song?.title ?? 'No Song Selected',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      song?.artist ?? 'Unknown Artist',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

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

              const SizedBox(height: 16),

              // Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Shuffle
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
                    // Previous
                    IconButton(
                      icon: const Icon(
                        Icons.skip_previous_rounded,
                        color: AppColors.textPrimary,
                        size: 36,
                      ),
                      onPressed: () => handler.skipToPrevious(),
                    ),
                    // Play/Pause
                    GestureDetector(
                      onTap: () {
                        if (isPlaying) {
                          handler.pause();
                        } else {
                          handler.play();
                        }
                      },
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                    // Next
                    IconButton(
                      icon: const Icon(
                        Icons.skip_next_rounded,
                        color: AppColors.textPrimary,
                        size: 36,
                      ),
                      onPressed: () => handler.skipToNext(),
                    ),
                    // Repeat
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

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
