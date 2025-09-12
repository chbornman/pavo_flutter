class Track {
  final String id;
  final String name;
  final String? album;
  final String? albumId;
  final List<String> artists;
  final String? albumArtist;
  final Duration? duration;
  final int? indexNumber;
  final String? imageUrl;
  final String streamUrl;

  const Track({
    required this.id,
    required this.name,
    required this.streamUrl,
    this.album,
    this.albumId,
    this.artists = const [],
    this.albumArtist,
    this.duration,
    this.indexNumber,
    this.imageUrl,
  });

  String get displayArtist {
    if (albumArtist != null && albumArtist!.isNotEmpty) {
      return albumArtist!;
    }
    if (artists.isNotEmpty) {
      return artists.join(', ');
    }
    return 'Unknown Artist';
  }

  Track copyWith({
    String? id,
    String? name,
    String? album,
    String? albumId,
    List<String>? artists,
    String? albumArtist,
    Duration? duration,
    int? indexNumber,
    String? imageUrl,
    String? streamUrl,
  }) {
    return Track(
      id: id ?? this.id,
      name: name ?? this.name,
      album: album ?? this.album,
      albumId: albumId ?? this.albumId,
      artists: artists ?? this.artists,
      albumArtist: albumArtist ?? this.albumArtist,
      duration: duration ?? this.duration,
      indexNumber: indexNumber ?? this.indexNumber,
      imageUrl: imageUrl ?? this.imageUrl,
      streamUrl: streamUrl ?? this.streamUrl,
    );
  }
}