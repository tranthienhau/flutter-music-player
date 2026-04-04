import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../models/song.dart';
import '../../services/audio_player_service.dart';

/// Provider for the audio handler (background audio service).
final audioHandlerProvider = Provider<MusicPlayerHandler>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

/// Stream provider for position data (position, buffered, duration).
final positionDataProvider = StreamProvider<PositionData>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.positionDataStream;
});

/// Stream provider for current playing state.
final playingProvider = StreamProvider<bool>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.player.playingStream;
});

/// Stream provider for current song index.
final currentIndexProvider = StreamProvider<int?>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.player.currentIndexStream;
});

/// Stream provider for shuffle mode.
final shuffleModeProvider = StreamProvider<bool>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.player.shuffleModeEnabledStream;
});

/// Stream provider for loop mode.
final loopModeProvider = StreamProvider<LoopMode>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.player.loopModeStream;
});

/// Provider for current song.
final currentSongProvider = Provider<Song?>((ref) {
  final index = ref.watch(currentIndexProvider).valueOrNull;
  final handler = ref.watch(audioHandlerProvider);
  if (index != null && index < handler.songs.length) {
    return handler.songs[index];
  }
  return null;
});

/// Stream provider for processing state.
final processingStateProvider = StreamProvider<ProcessingState>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.player.processingStateStream;
});

/// Stream provider for playback state from audio_service.
final playbackStateProvider = StreamProvider<PlaybackState>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.playbackState;
});
