import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../../shared/services/jellyfin_service.dart';
import '../../../../../core/config/env_config.dart';
import '../../domain/entities/artist.dart';
import '../../domain/entities/album.dart';
import '../../domain/entities/track.dart';

part 'music_library_provider.g.dart';

@riverpod
JellyfinService jellyfinMusicService(JellyfinMusicServiceRef ref) {
  return JellyfinService();
}

@riverpod
Future<List<Artist>> musicArtists(MusicArtistsRef ref) async {
  final service = ref.watch(jellyfinMusicServiceProvider);
  final artistsData = await service.getMusicArtists();
  
  final artists = <Artist>[];
  for (final artistData in artistsData) {
    artists.add(Artist(
      id: artistData['Id'],
      name: artistData['Name'] ?? 'Unknown Artist',
      imageUrl: artistData['ImageTags']?['Primary'] != null
          ? service.getImageUrl(artistData['Id'])
          : null,
      overview: artistData['Overview'],
      albumCount: artistData['AlbumCount'],
      songCount: artistData['SongCount'],
    ));
  }
  
  return artists;
}

@riverpod
Future<Artist> artistWithAlbums(ArtistWithAlbumsRef ref, String artistId) async {
  final service = ref.watch(jellyfinMusicServiceProvider);
  
  // Get artist info from the artists list
  final artists = await ref.watch(musicArtistsProvider.future);
  final artist = artists.firstWhere((a) => a.id == artistId);
  
  // Get albums for this artist
  final albumsData = await service.getArtistAlbums(artistId);
  
  final albums = <Album>[];
  for (final albumData in albumsData) {
    // Get tracks for each album
    final tracksData = await service.getAlbumTracks(albumData['Id']);
    
    final tracks = tracksData.map<Track>((trackData) {
      final runTimeTicks = trackData['RunTimeTicks'] as int?;
      return Track(
        id: trackData['Id'],
        name: trackData['Name'] ?? 'Unknown Track',
        album: albumData['Name'],
        albumId: albumData['Id'],
        artists: trackData['Artists'] != null 
            ? List<String>.from(trackData['Artists']) 
            : [],
        albumArtist: trackData['AlbumArtist'],
        duration: runTimeTicks != null 
            ? Duration(microseconds: runTimeTicks ~/ 10)
            : null,
        indexNumber: trackData['IndexNumber'],
        imageUrl: albumData['ImageTags']?['Primary'] != null
            ? service.getImageUrl(albumData['Id'])
            : null,
        streamUrl: service.getAudioStreamUrl(trackData['Id']),
      );
    }).toList();
    
    final albumRunTimeTicks = albumData['RunTimeTicks'] as int?;
    albums.add(Album(
      id: albumData['Id'],
      name: albumData['Name'] ?? 'Unknown Album',
      artistName: artist.name,
      artistId: artist.id,
      year: albumData['ProductionYear'],
      imageUrl: albumData['ImageTags']?['Primary'] != null
          ? service.getImageUrl(albumData['Id'])
          : null,
      tracks: tracks,
      totalDuration: albumRunTimeTicks != null 
          ? Duration(microseconds: albumRunTimeTicks ~/ 10)
          : null,
      overview: albumData['Overview'],
    ));
  }
  
  return artist.copyWith(albums: albums);
}

@riverpod
Future<Album> albumDetails(AlbumDetailsRef ref, String albumId) async {
  final service = ref.watch(jellyfinMusicServiceProvider);
  
  // Get album details
  final albumData = await service.getAlbumDetails(albumId);
  
  // Get tracks for the album
  final tracksData = await service.getAlbumTracks(albumId);
  
  final tracks = tracksData.map<Track>((trackData) {
    final runTimeTicks = trackData['RunTimeTicks'] as int?;
    return Track(
      id: trackData['Id'],
      name: trackData['Name'] ?? 'Unknown Track',
      album: albumData['Name'],
      albumId: albumId,
      artists: trackData['Artists'] != null 
          ? List<String>.from(trackData['Artists']) 
          : [],
      albumArtist: trackData['AlbumArtist'],
      duration: runTimeTicks != null 
          ? Duration(microseconds: runTimeTicks ~/ 10)
          : null,
      indexNumber: trackData['IndexNumber'],
      imageUrl: albumData['ImageTags']?['Primary'] != null
          ? service.getImageUrl(albumId)
          : null,
      streamUrl: service.getAudioStreamUrl(trackData['Id']),
    );
  }).toList();
  
  final albumRunTimeTicks = albumData['RunTimeTicks'] as int?;
  return Album(
    id: albumId,
    name: albumData['Name'] ?? 'Unknown Album',
    artistName: albumData['AlbumArtist'] ?? albumData['Artists']?.first ?? 'Unknown Artist',
    artistId: albumData['AlbumArtistId'],
    year: albumData['ProductionYear'],
    imageUrl: albumData['ImageTags']?['Primary'] != null
        ? service.getImageUrl(albumId)
        : null,
    tracks: tracks,
    totalDuration: albumRunTimeTicks != null 
        ? Duration(microseconds: albumRunTimeTicks ~/ 10)
        : null,
    overview: albumData['Overview'],
  );
}

// Search provider
@riverpod
Future<List<Track>> searchMusic(SearchMusicRef ref, String query) async {
  if (query.isEmpty) return [];
  
  final service = ref.watch(jellyfinMusicServiceProvider);
  
  // Search for audio items
  final data = await service.handleRequest<Map<String, dynamic>>(
    () => service.dio.get('/Users/${EnvConfig.jellyfinUserId}/Items', queryParameters: {
      'searchTerm': query,
      'includeItemTypes': 'Audio',
      'recursive': true,
      'limit': 50,
    }),
  );
  
  final items = data['Items'] as List;
  
  return items.map((trackData) {
    final runTimeTicks = trackData['RunTimeTicks'] as int?;
    return Track(
      id: trackData['Id'],
      name: trackData['Name'] ?? 'Unknown Track',
      album: trackData['Album'],
      albumId: trackData['AlbumId'],
      artists: trackData['Artists'] != null 
          ? List<String>.from(trackData['Artists']) 
          : [],
      albumArtist: trackData['AlbumArtist'],
      duration: runTimeTicks != null 
          ? Duration(microseconds: runTimeTicks ~/ 10)
          : null,
      indexNumber: trackData['IndexNumber'],
      imageUrl: trackData['AlbumId'] != null && trackData['AlbumPrimaryImageTag'] != null
          ? service.getImageUrl(trackData['AlbumId'])
          : null,
      streamUrl: service.getAudioStreamUrl(trackData['Id']),
    );
  }).toList();
}