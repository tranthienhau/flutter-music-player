import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/song.dart';
import '../../services/audio_query_service.dart';

final localSongsProvider =
    StateNotifierProvider<LocalSongsNotifier, AsyncValue<List<Song>>>((ref) {
      final queryService = ref.watch(audioQueryServiceProvider);
      return LocalSongsNotifier(queryService);
    });

class LocalSongsNotifier extends StateNotifier<AsyncValue<List<Song>>> {
  final AudioQueryService _queryService;

  LocalSongsNotifier(this._queryService) : super(const AsyncValue.loading());

  Future<void> loadSongs() async {
    state = const AsyncValue.loading();
    try {
      final songs = await _queryService.queryLocalSongs();
      state = AsyncValue.data(songs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

enum LibraryTab { songs, albums, artists }

final libraryTabProvider = StateProvider<LibraryTab>((ref) => LibraryTab.songs);
