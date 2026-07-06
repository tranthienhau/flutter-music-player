import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/colors.dart';
import 'playlist_detail_screen.dart';
import 'playlist_provider.dart';

class PlaylistScreen extends ConsumerWidget {
  const PlaylistScreen({super.key});

  static const List<_SamplePlaylist> _samples = [
    _SamplePlaylist('Daily High', '24 Tracks - Liked', 0),
    _SamplePlaylist('Deep Focus', '128 Tracks - Work', 1),
    _SamplePlaylist('Weekend Vibe', '42 Tracks - Fun', 2),
    _SamplePlaylist('Custom Mix', 'Create new', 3),
  ];

  static const List<String> _forYou = [
    'Recently Played',
    'Most Streamed',
    'Party Mix',
    'Chill',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistListProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Brand bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.graphic_eq_rounded,
                    color: AppColors.primary,
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'VibeTune',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.search_rounded,
                    color: AppColors.textPrimary,
                    size: 26,
                  ),
                ],
              ),
            ),
          ),

          // Heading + Create button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'COLLECTION',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textTertiary,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Playlists',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _showCreatePlaylistDialog(context, ref),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: AppColors.glow(AppColors.primary, alpha: 0.3),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Create Playlist',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
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

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Grid of playlists (real, else sample) + Add-more card
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.78,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                if (playlists.isEmpty) {
                  // Sample cards + a dashed "Add more" tile at the end.
                  if (index == _samples.length) {
                    return _AddMoreCard(
                      onTap: () => _showCreatePlaylistDialog(context, ref),
                    );
                  }
                  final s = _samples[index];
                  return _PlaylistCard(
                    name: s.name,
                    subtitle: s.subtitle,
                    seed: s.seed,
                    onTap: () => _showCreatePlaylistDialog(context, ref),
                  );
                }
                if (index == playlists.length) {
                  return _AddMoreCard(
                    onTap: () => _showCreatePlaylistDialog(context, ref),
                  );
                }
                final playlist = playlists[index];
                return _PlaylistCard(
                  name: playlist.name,
                  subtitle: '${playlist.songCount} Tracks',
                  seed: index,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlaylistDetailScreen(playlist: playlist),
                      ),
                    );
                  },
                  onLongPress: () => _showDeleteDialog(
                    context,
                    ref,
                    playlist.id,
                    playlist.name,
                  ),
                );
              }, childCount: (playlists.isEmpty ? _samples.length : playlists.length) + 1),
            ),
          ),

          // For You
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
              child: Text(
                'For You',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _forYou.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final selected = index == 0;
                  return Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      _forYou[index],
                      style: TextStyle(
                        color: selected ? Colors.white : AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Playlist name',
            filled: true,
            fillColor: AppColors.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(playlistListProvider.notifier)
                    .createPlaylist(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    String id,
    String name,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Playlist'),
        content: Text(
          'Are you sure you want to delete "$name"?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(playlistListProvider.notifier).deletePlaylist(id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SamplePlaylist {
  final String name;
  final String subtitle;
  final int seed;
  const _SamplePlaylist(this.name, this.subtitle, this.seed);
}

class _PlaylistCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final int seed;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _PlaylistCard({
    required this.name,
    required this.subtitle,
    required this.seed,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2x2 collage
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  children: List.generate(4, (i) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.albumGradient('$name-$seed-$i'),
                      ),
                      child: Icon(
                        Icons.music_note_rounded,
                        color: Colors.white.withValues(alpha: 0.85),
                        size: 20,
                      ),
                    );
                  }),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddMoreCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AddMoreCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorderBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Add more',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rounded card with a dashed border.
class DottedBorderBox extends StatelessWidget {
  final Widget child;
  const DottedBorderBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: Center(child: child),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textTertiary.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(24),
    );
    final path = Path()..addRRect(rrect);
    const dash = 6.0;
    const gap = 5.0;
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        canvas.drawPath(
          metric.extractPath(dist, dist + dash),
          paint,
        );
        dist += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
