import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/playlist.dart';
import '../models/song.dart';

class PlaylistService {
  static const String _boxName = 'playlists';
  static const String _recentlyPlayedKey = 'recently_played';
  late Box<String> _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  List<Playlist> getPlaylists() {
    final keys = _box.keys.where((k) => k != _recentlyPlayedKey).toList();
    return keys.map((key) {
      final json = jsonDecode(_box.get(key)!) as Map<String, dynamic>;
      return Playlist.fromJson(json);
    }).toList();
  }

  Future<void> savePlaylist(Playlist playlist) async {
    await _box.put(playlist.id, jsonEncode(playlist.toJson()));
  }

  Future<void> deletePlaylist(String id) async {
    await _box.delete(id);
  }

  Playlist? getPlaylist(String id) {
    final data = _box.get(id);
    if (data == null) return null;
    return Playlist.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  Future<void> addSongToPlaylist(String playlistId, Song song) async {
    final playlist = getPlaylist(playlistId);
    if (playlist == null) return;

    final updatedSongs = List<Song>.from(playlist.songs)..add(song);
    final updated = playlist.copyWith(
      songs: updatedSongs,
      updatedAt: DateTime.now(),
    );
    await savePlaylist(updated);
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final playlist = getPlaylist(playlistId);
    if (playlist == null) return;

    final updatedSongs = playlist.songs.where((s) => s.id != songId).toList();
    final updated = playlist.copyWith(
      songs: updatedSongs,
      updatedAt: DateTime.now(),
    );
    await savePlaylist(updated);
  }

  Future<void> reorderSongs(
    String playlistId,
    int oldIndex,
    int newIndex,
  ) async {
    final playlist = getPlaylist(playlistId);
    if (playlist == null) return;

    final songs = List<Song>.from(playlist.songs);
    final song = songs.removeAt(oldIndex);
    songs.insert(newIndex, song);

    final updated = playlist.copyWith(songs: songs, updatedAt: DateTime.now());
    await savePlaylist(updated);
  }

  // Recently played
  List<Song> getRecentlyPlayed() {
    final data = _box.get(_recentlyPlayedKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list
        .map((item) => Song.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> addToRecentlyPlayed(Song song) async {
    final recent = getRecentlyPlayed();
    recent.removeWhere((s) => s.id == song.id);
    recent.insert(0, song);
    // Keep only last 20
    final trimmed = recent.take(20).toList();
    await _box.put(
      _recentlyPlayedKey,
      jsonEncode(trimmed.map((s) => s.toJson()).toList()),
    );
  }
}
