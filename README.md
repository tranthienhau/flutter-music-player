# flutter_music_player

A Flutter music player POC built with Riverpod, demonstrating audio playback, a browsable song library, playlist management, a multi-band equalizer, and background audio via audio_service. It plays both local files (on_audio_query) and streaming demo tracks (just_audio).

## Demo

These are real captures from the iOS Simulator, taken by an integration-test driver (no mockups). See [FLOW.md](FLOW.md) for how they are generated.

| Home | Library | Playlists | Equalizer |
| --- | --- | --- | --- |
| ![Home](screenshots/01-home.png) | ![Library](screenshots/02-library.png) | ![Playlists](screenshots/03-playlists.png) | ![Equalizer](screenshots/04-equalizer.png) |

![Demo](screenshots/demo.gif)

## Features

- Browse and play a song library (streaming demo tracks + local files).
- Now Playing screen with album art, seek bar, shuffle, and loop controls.
- Playlist management - create, view, and organize playlists.
- Multi-band equalizer with presets (Flat, Pop, Rock, Jazz, Classical, Bass Boost, Treble Boost) and custom bands.
- Background audio with lock-screen / notification controls via audio_service.
- Local persistence with Hive (recently played, playlists, equalizer state).

## Stack

- Flutter + Riverpod (state management)
- just_audio + audio_service + audio_session (playback + background audio)
- on_audio_query (local media library)
- Hive (local storage)
- rxdart (stream composition)

## Run

```bash
flutter pub get
flutter run
```
