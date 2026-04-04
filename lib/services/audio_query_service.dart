import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../models/song.dart';

class AudioQueryService {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  Future<bool> requestPermission() async {
    return await _audioQuery.permissionsStatus() ||
        await _audioQuery.permissionsRequest();
  }

  Future<List<Song>> queryLocalSongs() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return [];

    final songModels = await _audioQuery.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
    );

    return songModels
        .where((s) => s.duration != null && s.duration! > 0)
        .map(
          (s) => Song(
            id: s.id.toString(),
            title: s.title,
            artist: s.artist ?? 'Unknown Artist',
            album: s.album ?? 'Unknown Album',
            duration: Duration(milliseconds: s.duration ?? 0),
            uri: s.uri ?? s.data,
          ),
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>> queryAlbums() async {
    final albums = await _audioQuery.queryAlbums(
      sortType: AlbumSortType.ALBUM,
      orderType: OrderType.ASC_OR_SMALLER,
    );

    return albums
        .map(
          (a) => {
            'id': a.id,
            'name': a.album,
            'artist': a.artist ?? 'Unknown Artist',
            'numSongs': a.numOfSongs,
          },
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>> queryArtists() async {
    final artists = await _audioQuery.queryArtists(
      sortType: ArtistSortType.ARTIST,
      orderType: OrderType.ASC_OR_SMALLER,
    );

    return artists
        .map(
          (a) => {
            'id': a.id,
            'name': a.artist,
            'numTracks': a.numberOfTracks ?? 0,
            'numAlbums': a.numberOfAlbums ?? 0,
          },
        )
        .toList();
  }
}

final audioQueryServiceProvider = Provider<AudioQueryService>((ref) {
  return AudioQueryService();
});
