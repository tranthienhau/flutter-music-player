import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/song.dart';
import '../../theme/colors.dart';
import '../../widgets/song_tile.dart';
import '../equalizer/equalizer_screen.dart';
import '../library/library_screen.dart';
import '../player/mini_player.dart';
import '../player/now_playing_screen.dart';
import '../player/player_provider.dart';
import '../playlist/playlist_screen.dart';
import 'home_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _currentTab,
                children: const [
                  _HomeContent(),
                  LibraryScreen(),
                  PlaylistScreen(),
                  EqualizerScreen(embedded: true),
                ],
              ),
            ),
            const MiniPlayer(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (i) => setState(() => _currentTab = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music_rounded),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.playlist_play_rounded),
            label: 'Playlists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.equalizer_rounded),
            label: 'Equalizer',
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demoSongs = ref.watch(demoSongsProvider);
    final handler = ref.watch(audioHandlerProvider);
    final featured = demoSongs.take(5).toList();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Brand bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.graphic_eq_rounded,
                        color: AppColors.primary,
                        size: 26,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'VibeTune',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.search_rounded,
                    color: AppColors.textPrimary,
                    size: 26,
                  ),
                ],
              ),
            ),
          ),

          // Greeting
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good ${_getGreeting()}',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'What do you want to listen to?',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),

          // Search field
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppColors.softShadow,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: AppColors.textTertiary,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Search artists, songs, or podcasts...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Quick play cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _QuickPlayCard(
                      icon: Icons.shuffle_rounded,
                      title: 'Shuffle All',
                      subtitle: '${demoSongs.length} Songs',
                      gradient: AppColors.primaryGradient,
                      onTap: () async {
                        await handler.loadPlaylist(demoSongs);
                        await handler.setShuffleModeCustom(true);
                        await handler.play();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _QuickPlayCard(
                      icon: Icons.radio_rounded,
                      title: 'Streaming',
                      subtitle: 'Online Radio',
                      gradient: null, // light gray card
                      onTap: () async {
                        await handler.loadPlaylist(demoSongs);
                        await handler.play();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Featured Tracks
          SliverToBoxAdapter(
            child: _SectionHeader(title: 'Featured Tracks', onViewAll: () {}),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 236,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: featured.length,
                itemBuilder: (context, index) {
                  final song = featured[index];
                  return _FeaturedCard(
                    song: song,
                    onTap: () async {
                      await handler.loadPlaylist(featured, initialIndex: index);
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
          ),

          // Local Library
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Local Library',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Icon(
                    Icons.tune_rounded,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final song = demoSongs[index];
              return SongTile(
                song: song,
                onTap: () async {
                  await handler.loadPlaylist(demoSongs, initialIndex: index);
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
            }, childCount: demoSongs.length),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;

  const _SectionHeader({required this.title, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: const Text(
                'View All',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickPlayCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient? gradient;
  final VoidCallback onTap;

  const _QuickPlayCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isGradient = gradient != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 112,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: gradient,
          color: isGradient ? null : AppColors.surfaceVariant,
          boxShadow: isGradient
              ? AppColors.glow(AppColors.primary, alpha: 0.28)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              icon,
              color: isGradient ? Colors.white : AppColors.textPrimary,
              size: 28,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isGradient ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isGradient
                        ? Colors.white.withValues(alpha: 0.85)
                        : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const _FeaturedCard({required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 172,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 172,
              height: 172,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: AppColors.albumGradient(song.id),
                boxShadow: AppColors.softShadow,
              ),
              child: Stack(
                children: [
                  const Positioned(
                    top: 16,
                    left: 16,
                    child: Icon(
                      Icons.music_note_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Text(
                      song.album.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              song.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              song.artist,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
