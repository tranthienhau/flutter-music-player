import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/playlist.dart';
import '../../models/song.dart';
import '../home/home_provider.dart';

final playlistListProvider =
    StateNotifierProvider<PlaylistListNotifier, List<Playlist>>((ref) {
      final service = ref.watch(playlistServiceProvider);
      return PlaylistListNotifier(service);
    });

class PlaylistListNotifier extends StateNotifier<List<Playlist>> {
  final dynamic _service;

  PlaylistListNotifier(this._service) : super([]) {
    _load();
  }

  void _load() {
    state = _service.getPlaylists();
  }

  Future<void> createPlaylist(String name) async {
    final playlist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      songs: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _service.savePlaylist(playlist);
    _load();
  }

  Future<void> deletePlaylist(String id) async {
    await _service.deletePlaylist(id);
    _load();
  }

  Future<void> addSongToPlaylist(String playlistId, Song song) async {
    await _service.addSongToPlaylist(playlistId, song);
    _load();
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    await _service.removeSongFromPlaylist(playlistId, songId);
    _load();
  }

  Future<void> reorderSongs(
    String playlistId,
    int oldIndex,
    int newIndex,
  ) async {
    await _service.reorderSongs(playlistId, oldIndex, newIndex);
    _load();
  }
}
