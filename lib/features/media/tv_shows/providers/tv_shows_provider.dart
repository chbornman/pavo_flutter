import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pavo_flutter/shared/models/media_item.dart';
import 'package:pavo_flutter/shared/services/jellyfin_service.dart';

part 'tv_shows_provider.g.dart';

@Riverpod(keepAlive: true)
Future<List<MediaItem>> tvShows(TvShowsRef ref) async {
  final service = JellyfinService();
  try {
    final shows = await service.getTVShows();
    print('Successfully loaded ${shows.length} TV shows');
    return shows;
  } catch (e) {
    print('Error loading TV shows: $e');
    rethrow;
  }
}

@riverpod
Future<MediaItem> tvShowById(TvShowByIdRef ref, String showId) async {
  final service = JellyfinService();
  return service.getTVShowById(showId);
}

@riverpod
Future<List<Season>> tvShowSeasons(TvShowSeasonsRef ref, String showId) async {
  final service = JellyfinService();
  final seasonsData = await service.getTVShowSeasons(showId);
  return seasonsData.map((json) => Season.fromJson(json as Map<String, dynamic>)).toList();
}

@riverpod
Future<List<Episode>> seasonEpisodes(SeasonEpisodesRef ref, String showId, String seasonId) async {
  final service = JellyfinService();
  final episodesData = await service.getSeasonEpisodes(showId, seasonId);
  return episodesData.map((json) => Episode.fromJson(json as Map<String, dynamic>)).toList();
}

class Season {
  final String id;
  final String name;
  final int? indexNumber;
  final String? imageTag;

  Season({
    required this.id,
    required this.name,
    this.indexNumber,
    this.imageTag,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['Id'] as String,
      name: json['Name'] as String,
      indexNumber: json['IndexNumber'] as int?,
      imageTag: json['ImageTags']?['Primary'] as String?,
    );
  }
}

class Episode {
  final String id;
  final String name;
  final int? indexNumber;
  final String? seasonId;
  final String? overview;
  final int? runtime;
  final String? imageTag;
  final double? playedPercentage;

  Episode({
    required this.id,
    required this.name,
    this.indexNumber,
    this.seasonId,
    this.overview,
    this.runtime,
    this.imageTag,
    this.playedPercentage,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['Id'] as String,
      name: json['Name'] as String,
      indexNumber: json['IndexNumber'] as int?,
      seasonId: json['SeasonId'] as String?,
      overview: json['Overview'] as String?,
      runtime: json['RunTimeTicks'] != null ? (json['RunTimeTicks'] as int) ~/ 10000000 : null,
      imageTag: json['ImageTags']?['Primary'] as String?,
      playedPercentage: json['UserData']?['PlayedPercentage'] as double?,
    );
  }
}