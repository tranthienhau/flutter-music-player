class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final String? artUri;
  final String uri;
  final bool isLocal;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    this.artUri,
    required this.uri,
    this.isLocal = true,
  });

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    Duration? duration,
    String? artUri,
    String? uri,
    bool? isLocal,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      artUri: artUri ?? this.artUri,
      uri: uri ?? this.uri,
      isLocal: isLocal ?? this.isLocal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'duration': duration.inMilliseconds,
      'artUri': artUri,
      'uri': uri,
      'isLocal': isLocal,
    };
  }

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      album: json['album'] as String,
      duration: Duration(milliseconds: json['duration'] as int),
      artUri: json['artUri'] as String?,
      uri: json['uri'] as String,
      isLocal: json['isLocal'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Song && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
