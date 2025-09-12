import 'track.dart';

class Album {
  final String id;
  final String name;
  final String? artistName;
  final String? artistId;
  final int? year;
  final String? imageUrl;
  final List<Track> tracks;
  final Duration? totalDuration;
  final String? overview;

  const Album({
    required this.id,
    required this.name,
    this.artistName,
    this.artistId,
    this.year,
    this.imageUrl,
    this.tracks = const [],
    this.totalDuration,
    this.overview,
  });

  Album copyWith({
    String? id,
    String? name,
    String? artistName,
    String? artistId,
    int? year,
    String? imageUrl,
    List<Track>? tracks,
    Duration? totalDuration,
    String? overview,
  }) {
    return Album(
      id: id ?? this.id,
      name: name ?? this.name,
      artistName: artistName ?? this.artistName,
      artistId: artistId ?? this.artistId,
      year: year ?? this.year,
      imageUrl: imageUrl ?? this.imageUrl,
      tracks: tracks ?? this.tracks,
      totalDuration: totalDuration ?? this.totalDuration,
      overview: overview ?? this.overview,
    );
  }
}