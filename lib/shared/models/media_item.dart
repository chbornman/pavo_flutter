enum MediaType { movie, tvShow, music, audiobook }

class UserData {
  final double? playedPercentage;
  final bool? played;

  UserData({
    this.playedPercentage,
    this.played,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      playedPercentage: json['PlayedPercentage']?.toDouble(),
      played: json['Played'] as bool?,
    );
  }
}

class MediaItem {
  final String id;
  final String name;
  final MediaType type;
  final String? overview;
  final DateTime? premiereDate;
  final DateTime? endDate;
  final int? runtime;
  final String? imagePath;
  final double? rating;
  final List<String> genres;
  final String? artist;
  final String? album;
  final int? trackNumber;
  final UserData? userData;

  MediaItem({
    required this.id,
    required this.name,
    required this.type,
    this.overview,
    this.premiereDate,
    this.endDate,
    this.runtime,
    this.imagePath,
    this.rating,
    required this.genres,
    this.artist,
    this.album,
    this.trackNumber,
    this.userData,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    MediaType type;
    switch (json['Type']) {
      case 'Movie':
        type = MediaType.movie;
        break;
      case 'Series':
        type = MediaType.tvShow;
        break;
      case 'Audio':
        type = MediaType.music;
        break;
      case 'AudioBook':
        type = MediaType.audiobook;
        break;
      default:
        type = MediaType.movie;
    }

    return MediaItem(
      id: json['Id'],
      name: json['Name'],
      type: type,
      overview: json['Overview'],
      premiereDate: json['PremiereDate'] != null 
          ? DateTime.parse(json['PremiereDate']) 
          : null,
      endDate: json['EndDate'] != null 
          ? DateTime.parse(json['EndDate']) 
          : null,
      runtime: json['RunTimeTicks'] != null 
          ? (json['RunTimeTicks'] / 10000000).round() 
          : null,
      imagePath: json['ImagePath'],
      rating: json['CommunityRating']?.toDouble(),
      genres: List<String>.from(json['Genres'] ?? []),
      artist: json['AlbumArtist'] ?? json['Artists']?.first,
      album: json['Album'],
      trackNumber: json['IndexNumber'],
      userData: json['UserData'] != null 
          ? UserData.fromJson(json['UserData'])
          : null,
    );
  }
}