import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'features/player/player_provider.dart';
import 'services/audio_player_service.dart';
import 'services/playlist_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize audio handler for background playback
  final audioHandler = await AudioService.init<MusicPlayerHandler>(
    builder: () => MusicPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId:
          'com.tranthienhau.flutter_music_player.audio',
      androidNotificationChannelName: 'Music Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

  // Initialize playlist service
  final playlistService = PlaylistService();
  await playlistService.init();

  // Check if onboarding was completed previously
  final settingsBox = await Hive.openBox<bool>('settings');
  final onboardingDone = settingsBox.get(
    'onboarding_complete',
    defaultValue: false,
  )!;

  runApp(
    ProviderScope(
      overrides: [audioHandlerProvider.overrideWithValue(audioHandler)],
      child: Consumer(
        builder: (context, ref, child) {
          // Set initial onboarding state
          Future.microtask(() {
            ref.read(onboardingCompleteProvider.notifier).state =
                onboardingDone;
          });
          return const MusicPlayerApp();
        },
      ),
    ),
  );
}
