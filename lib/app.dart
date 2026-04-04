import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'theme/app_theme.dart';

final onboardingCompleteProvider = StateProvider<bool>((ref) => false);

class MusicPlayerApp extends ConsumerWidget {
  const MusicPlayerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingComplete = ref.watch(onboardingCompleteProvider);

    return MaterialApp(
      title: 'Flutter Music Player',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: onboardingComplete
          ? const HomeScreen()
          : OnboardingScreen(
              onComplete: () {
                ref.read(onboardingCompleteProvider.notifier).state = true;
                _saveOnboardingComplete();
              },
            ),
    );
  }

  Future<void> _saveOnboardingComplete() async {
    final box = await Hive.openBox<bool>('settings');
    await box.put('onboarding_complete', true);
  }
}
