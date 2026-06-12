# Screenshot capture flow

Real captures from the iOS Simulator via an integration-test driver (no mockups).

## Steps

1. Boot the simulator (already booted here - assigned UDID):
   ```bash
   xcrun simctl boot "iPhone 17 Pro"
   open -a Simulator
   ```
2. Scaffold the iOS platform folder if missing, then get dependencies:
   ```bash
   flutter create . --platforms=ios --project-name flutter_music_player
   flutter pub get
   ```
3. Drive the screenshot test:
   ```bash
   flutter drive \
     --driver test_driver/integration_test.dart \
     --target integration_test/screenshot_test.dart \
     -d "889A2E50-D60F-4785-84BD-5700F9048279"
   ```
4. Build the demo GIF from the PNGs:
   ```bash
   cd screenshots
   ffmpeg -y -framerate 1 -pattern_type glob -i '*.png' \
     -vf "scale=320:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
     -loop 0 demo.gif
   ```

PNGs + `demo.gif` are written to `screenshots/` and embedded in `README.md`.

## How it works

- `test_driver/integration_test.dart` - `integrationDriver(onScreenshot:)` writes each PNG to `screenshots/<name>.png`.
- `integration_test/screenshot_test.dart` - the test avoids the heavy `main()` init (no `AudioService.init`). In `setUpAll` it calls `Hive.initFlutter`, constructs a real `MusicPlayerHandler` (its constructor only creates an `AudioPlayer`), and initializes `EqualizerService` (seeded enabled + Rock preset) and `PlaylistService`. These are injected via `ProviderScope(overrides: [...])` so the screens render real-looking content.
- The test pumps `HomeScreen` and captures the home browse list (`01-home`), taps the `Library` bottom-nav tab (`02-library`) and the `Playlists` tab (`03-playlists`), then pumps `EqualizerScreen` directly to capture the bands view with the Rock preset (`04-equalizer`).
- Each shot calls `binding.convertFlutterSurfaceToImage()` + `binding.takeScreenshot('NN-name')`. Screens use `tester.pump(const Duration(milliseconds: 400))` instead of `pumpAndSettle` to avoid hanging on the always-animating gradients/sliders.
