import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/colors.dart';
import '../../widgets/song_tile.dart';
import '../home/home_provider.dart';
import '../player/now_playing_screen.dart';
import '../player/player_provider.dart';
import 'library_provider.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger loading local songs when screen is first shown
    Future.microtask(() {
      ref.read(localSongsProvider.notifier).loadSongs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localSongs = ref.watch(localSongsProvider);
    final currentTab = ref.watch(libraryTabProvider);
    final handler = ref.watch(audioHandlerProvider);
    final demoSongs = ref.watch(demoSongsProvider);

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Text(
                  'Library',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    ref.read(localSongsProvider.notifier).loadSongs();
                  },
                ),
              ],
            ),
          ),

          // Tab chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: LibraryTab.values.map((tab) {
                final isSelected = currentTab == tab;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      ref.read(libraryTabProvider.notifier).state = tab;
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surfaceLight,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surfaceVariant,
                        ),
                      ),
                      child: Text(
                        tab.name[0].toUpperCase() + tab.name.substring(1),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Content
          Expanded(
            child: localSongs.when(
              data: (songs) {
                if (songs.isEmpty) {
                  // Show demo songs as fallback
                  return _buildSongsList(
                    context,
                    demoSongs,
                    handler,
                    ref,
                    isDemo: true,
                  );
                }
                return _buildSongsList(context, songs, handler, ref);
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (error, _) => _buildSongsList(
                context,
                demoSongs,
                handler,
                ref,
                isDemo: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongsList(
    BuildContext context,
    List songs,
    dynamic handler,
    WidgetRef ref, {
    bool isDemo = false,
  }) {
    return Column(
      children: [
        if (isDemo)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Showing demo songs. Grant storage permission to browse local files.',
                    style: TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        // Sort info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            children: [
              Text(
                '${songs.length} songs',
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.sort_rounded,
                color: AppColors.textTertiary,
                size: 18,
              ),
              const SizedBox(width: 4),
              const Text(
                'Title',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return SongTile(
                song: song,
                onTap: () async {
                  await handler.loadPlaylist(songs, initialIndex: index);
                  await handler.play();
                  ref.read(recentlyPlayedProvider.notifier).addSong(song);
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NowPlayingScreen(),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
