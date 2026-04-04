import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

import '../models/song.dart';

/// Encapsulates position, buffered position, and total duration.
class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  const PositionData({
    required this.position,
    required this.bufferedPosition,
    required this.duration,
  });
}

/// Audio handler for background playback via audio_service.
class MusicPlayerHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  final ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(
    children: [],
  );
  final List<Song> _songs = [];

  AudioPlayer get player => _player;
  List<Song> get songs => List.unmodifiable(_songs);

  MusicPlayerHandler() {
    _init();
  }

  Future<void> _init() async {
    // Broadcast playback state changes
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);

    // Broadcast current media item
    _player.currentIndexStream.listen((index) {
      if (index != null && index < _songs.length) {
        mediaItem.add(_songToMediaItem(_songs[index]));
      }
    });
  }

  MediaItem _songToMediaItem(Song song) {
    return MediaItem(
      id: song.uri,
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration: song.duration,
      artUri: song.artUri != null ? Uri.parse(song.artUri!) : null,
    );
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }

  /// Loads a list of songs into the playlist and starts playing.
  Future<void> loadPlaylist(List<Song> songs, {int initialIndex = 0}) async {
    _songs.clear();
    _songs.addAll(songs);

    final sources = songs.map((song) {
      if (song.isLocal) {
        return AudioSource.file(song.uri, tag: song.id);
      } else {
        return AudioSource.uri(Uri.parse(song.uri), tag: song.id);
      }
    }).toList();

    await _playlist.clear();
    await _playlist.addAll(sources);

    queue.add(songs.map(_songToMediaItem).toList());

    await _player.setAudioSource(_playlist, initialIndex: initialIndex);
  }

  /// Plays a single song.
  Future<void> playSong(Song song) async {
    await loadPlaylist([song]);
    await play();
  }

  /// Plays a song from the current playlist by index.
  Future<void> playAtIndex(int index) async {
    await _player.seek(Duration.zero, index: index);
    await play();
  }

  /// Stream that combines position, buffered position, and duration.
  Stream<PositionData> get positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _player.positionStream,
        _player.bufferedPositionStream,
        _player.durationStream,
        (position, bufferedPosition, duration) => PositionData(
          position: position,
          bufferedPosition: bufferedPosition,
          duration: duration ?? Duration.zero,
        ),
      );

  Song? get currentSong {
    final index = _player.currentIndex;
    if (index != null && index < _songs.length) {
      return _songs[index];
    }
    return null;
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  Future<void> setShuffleModeCustom(bool enabled) async {
    await _player.setShuffleModeEnabled(enabled);
  }

  Future<void> setLoopMode(LoopMode mode) async {
    await _player.setLoopMode(mode);
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
