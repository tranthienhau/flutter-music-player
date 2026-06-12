import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';
import 'package:just_audio/just_audio.dart';

import 'package:flutter_music_player/features/equalizer/equalizer_provider.dart';
import 'package:flutter_music_player/features/equalizer/equalizer_screen.dart';
import 'package:flutter_music_player/features/home/home_provider.dart';
import 'package:flutter_music_player/features/home/home_screen.dart';
import 'package:flutter_music_player/features/player/player_provider.dart';
import 'package:flutter_music_player/models/equalizer_preset.dart';
import 'package:flutter_music_player/services/audio_player_service.dart';
import 'package:flutter_music_player/services/equalizer_service.dart';
import 'package:flutter_music_player/services/playlist_service.dart';
import 'package:flutter_music_player/theme/app_theme.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> shoot(WidgetTester tester, String name) async {
    await binding.convertFlutterSurfaceToImage();
    await tester.pump(const Duration(milliseconds: 400));
    await binding.takeScreenshot(name);
  }

  // Real handler: its constructor just creates an AudioPlayer (no AudioService
  // platform init needed), so the screens that read it can render.
  late MusicPlayerHandler handler;
  late EqualizerService equalizerService;
  late PlaylistService playlistService;

  setUpAll(() async {
    await Hive.initFlutter();
    handler = MusicPlayerHandler();

    equalizerService = EqualizerService();
    await equalizerService.init(AudioPlayer());
    await equalizerService.setEnabled(true);
    await equalizerService.setPreset(EqualizerPreset.presets.firstWhere(
      (p) => p.name == 'Rock',
      orElse: () => EqualizerPreset.presets.first,
    ));

    playlistService = PlaylistService();
    await playlistService.init();
  });

  List<Override> overrides() => [
        audioHandlerProvider.overrideWithValue(handler),
        equalizerServiceProvider.overrideWithValue(equalizerService),
        playlistServiceProvider.overrideWithValue(playlistService),
      ];

  testWidgets('capture music player flow', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await shoot(tester, '01-home');

    // Library tab (demo song list).
    await tester.tap(find.text('Library'));
    await tester.pump(const Duration(milliseconds: 600));
    await shoot(tester, '02-library');

    // Playlists tab (empty-state create UI is still meaningful content).
    await tester.tap(find.text('Playlists'));
    await tester.pump(const Duration(milliseconds: 600));
    await shoot(tester, '03-playlists');

    // Equalizer screen pumped directly with the same overrides.
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const EqualizerScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await shoot(tester, '04-equalizer');
  });
}
