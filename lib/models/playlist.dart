import 'song.dart';

class Playlist {
  final String id;
  final String name;
  final String? coverArtUri;
  final List<Song> songs;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Playlist({
    required this.id,
    required this.name,
    this.coverArtUri,
    required this.songs,
    required this.createdAt,
    required this.updatedAt,
  });

  Playlist copyWith({
    String? id,
    String? name,
    String? coverArtUri,
    List<Song>? songs,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      coverArtUri: coverArtUri ?? this.coverArtUri,
      songs: songs ?? this.songs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int get songCount => songs.length;

  Duration get totalDuration =>
      songs.fold(Duration.zero, (total, song) => total + song.duration);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'coverArtUri': coverArtUri,
      'songs': songs.map((s) => s.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String,
      coverArtUri: json['coverArtUri'] as String?,
      songs: (json['songs'] as List)
          .map((s) => Song.fromJson(s as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
