import 'album.dart';

class Artist {
  final String id;
  final String name;
  final String? imageUrl;
  final String? overview;
  final int? albumCount;
  final int? songCount;
  final List<Album> albums;

  const Artist({
    required this.id,
    required this.name,
    this.imageUrl,
    this.overview,
    this.albumCount,
    this.songCount,
    this.albums = const [],
  });

  Artist copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? overview,
    int? albumCount,
    int? songCount,
    List<Album>? albums,
  }) {
    return Artist(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      overview: overview ?? this.overview,
      albumCount: albumCount ?? this.albumCount,
      songCount: songCount ?? this.songCount,
      albums: albums ?? this.albums,
    );
  }
}