import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/song.dart';
import '../../services/playlist_service.dart';

final playlistServiceProvider = Provider<PlaylistService>((ref) {
  return PlaylistService();
});

final recentlyPlayedProvider =
    StateNotifierProvider<RecentlyPlayedNotifier, List<Song>>((ref) {
      final service = ref.watch(playlistServiceProvider);
      return RecentlyPlayedNotifier(service);
    });

class RecentlyPlayedNotifier extends StateNotifier<List<Song>> {
  final PlaylistService _service;

  RecentlyPlayedNotifier(this._service) : super([]) {
    _load();
  }

  void _load() {
    state = _service.getRecentlyPlayed();
  }

  Future<void> addSong(Song song) async {
    await _service.addToRecentlyPlayed(song);
    _load();
  }
}

/// Demo songs for the POC - streaming URLs from free sources.
final demoSongsProvider = Provider<List<Song>>((ref) {
  return [
    const Song(
      id: 'demo_1',
      title: 'Acoustic Breeze',
      artist: 'Benjamin Tissot',
      album: 'Bensound Collection',
      duration: Duration(minutes: 2, seconds: 37),
      uri:
          'https://www.bensound.com/bensound-music/bensound-acousticbreeze.mp3',
      isLocal: false,
    ),
    const Song(
      id: 'demo_2',
      title: 'Creative Minds',
      artist: 'Benjamin Tissot',
      album: 'Bensound Collection',
      duration: Duration(minutes: 2, seconds: 27),
      uri: 'https://www.bensound.com/bensound-music/bensound-creativeminds.mp3',
      isLocal: false,
    ),
    const Song(
      id: 'demo_3',
      title: 'Sunny',
      artist: 'Benjamin Tissot',
      album: 'Bensound Collection',
      duration: Duration(minutes: 2, seconds: 20),
      uri: 'https://www.bensound.com/bensound-music/bensound-sunny.mp3',
      isLocal: false,
    ),
    const Song(
      id: 'demo_4',
      title: 'Tenderness',
      artist: 'Benjamin Tissot',
      album: 'Bensound Collection',
      duration: Duration(minutes: 2, seconds: 3),
      uri: 'https://www.bensound.com/bensound-music/bensound-tenderness.mp3',
      isLocal: false,
    ),
    const Song(
      id: 'demo_5',
      title: 'Once Again',
      artist: 'Benjamin Tissot',
      album: 'Bensound Collection',
      duration: Duration(minutes: 3, seconds: 51),
      uri: 'https://www.bensound.com/bensound-music/bensound-onceagain.mp3',
      isLocal: false,
    ),
    const Song(
      id: 'demo_6',
      title: 'Sweet',
      artist: 'Benjamin Tissot',
      album: 'Bensound Collection',
      duration: Duration(minutes: 2, seconds: 7),
      uri: 'https://www.bensound.com/bensound-music/bensound-sweet.mp3',
      isLocal: false,
    ),
    const Song(
      id: 'demo_7',
      title: 'Love',
      artist: 'Benjamin Tissot',
      album: 'Bensound Collection',
      duration: Duration(minutes: 2, seconds: 12),
      uri: 'https://www.bensound.com/bensound-music/bensound-love.mp3',
      isLocal: false,
    ),
    const Song(
      id: 'demo_8',
      title: 'Dreams',
      artist: 'Benjamin Tissot',
      album: 'Bensound Collection',
      duration: Duration(minutes: 3, seconds: 30),
      uri: 'https://www.bensound.com/bensound-music/bensound-dreams.mp3',
      isLocal: false,
    ),
  ];
});
