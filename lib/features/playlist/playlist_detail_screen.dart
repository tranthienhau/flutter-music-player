import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/playlist.dart';
import '../../theme/colors.dart';
import '../../widgets/song_tile.dart';
import '../player/now_playing_screen.dart';
import '../player/player_provider.dart';
import 'playlist_provider.dart';

class PlaylistDetailScreen extends ConsumerWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the latest version of the playlist from the provider
    final playlists = ref.watch(playlistListProvider);
    final currentPlaylist = playlists.firstWhere(
      (p) => p.id == playlist.id,
      orElse: () => playlist,
    );
    final handler = ref.watch(audioHandlerProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: CustomScrollView(
          slivers: [
            // App bar
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppColors.surface,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  currentPlaylist.name,
                  style: const TextStyle(fontSize: 16),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.3),
                        AppColors.background,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.queue_music_rounded,
                      size: 64,
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),

            // Play all button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      '${currentPlaylist.songCount} songs',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    if (currentPlaylist.songs.isNotEmpty)
                      GestureDetector(
                        onTap: () async {
                          await handler.loadPlaylist(currentPlaylist.songs);
                          await handler.play();
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NowPlayingScreen(),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Play All',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Songs list with reorder support
            if (currentPlaylist.songs.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.music_off_rounded,
                        color: AppColors.textTertiary,
                        size: 48,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No songs in this playlist',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (currentPlaylist.songs.isNotEmpty)
              SliverReorderableList(
                itemCount: currentPlaylist.songs.length,
                onReorder: (oldIndex, newIndex) {
                  if (newIndex > oldIndex) newIndex--;
                  ref
                      .read(playlistListProvider.notifier)
                      .reorderSongs(currentPlaylist.id, oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final song = currentPlaylist.songs[index];
                  return ReorderableDragStartListener(
                    key: ValueKey(song.id),
                    index: index,
                    child: SongTile(
                      song: song,
                      onTap: () async {
                        await handler.loadPlaylist(
                          currentPlaylist.songs,
                          initialIndex: index,
                        );
                        await handler.play();
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NowPlayingScreen(),
                            ),
                          );
                        }
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline_rounded,
                              color: AppColors.error,
                              size: 20,
                            ),
                            onPressed: () {
                              ref
                                  .read(playlistListProvider.notifier)
                                  .removeSongFromPlaylist(
                                    currentPlaylist.id,
                                    song.id,
                                  );
                            },
                          ),
                          const Icon(
                            Icons.drag_handle_rounded,
                            color: AppColors.textTertiary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
