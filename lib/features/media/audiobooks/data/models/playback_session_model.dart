import '../../domain/entities/playback_session_entity.dart';
import '../../domain/entities/audiobook_entity.dart';
import '../../domain/entities/chapter_entity.dart';
import 'audiobook_model.dart';
import 'chapter_model.dart';

class PlaybackSessionModel extends PlaybackSessionEntity {
  const PlaybackSessionModel({
    required super.id,
    required super.audiobookId,
    required super.audioUrl,
    required super.currentTime,
    required super.progress,
    required super.chapters,
    required super.audiobook,
    required super.createdAt,
  });

  factory PlaybackSessionModel.fromJson(Map<String, dynamic> json) {
    final List<ChapterEntity> chapters = [];
    if (json['chapters'] != null && json['chapters'] is List) {
      chapters.addAll(
        (json['chapters'] as List)
            .map((chapter) => ChapterModel.fromJson(chapter).toEntity())
            .toList(),
      );
    }

    final audiobook = json['libraryItem'] != null 
        ? AudiobookModel.fromJson(json['libraryItem']).toEntity()
        : AudiobookEntity(
            id: json['libraryItemId']?.toString() ?? '',
            title: 'Unknown Title',
            author: 'Unknown Author',
            narrator: 'Unknown Narrator',
            duration: 0,
            lastUpdate: DateTime.now(),
          );

    return PlaybackSessionModel(
      id: json['id']?.toString() ?? '',
      audiobookId: json['libraryItemId']?.toString() ?? '',
      audioUrl: json['audioTracks']?[0]?['contentUrl']?.toString() ?? '',
      currentTime: (json['currentTime'] as num?)?.toInt() ?? 0,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      chapters: chapters,
      audiobook: audiobook,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'libraryItemId': audiobookId,
      'audioTracks': [
        {
          'contentUrl': audioUrl,
        }
      ],
      'currentTime': currentTime,
      'progress': progress,
      'chapters': chapters.map((c) => ChapterModel.fromEntity(c).toJson()).toList(),
      'libraryItem': AudiobookModel.fromEntity(audiobook).toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PlaybackSessionModel.fromEntity(PlaybackSessionEntity entity) {
    return PlaybackSessionModel(
      id: entity.id,
      audiobookId: entity.audiobookId,
      audioUrl: entity.audioUrl,
      currentTime: entity.currentTime,
      progress: entity.progress,
      chapters: entity.chapters,
      audiobook: entity.audiobook,
      createdAt: entity.createdAt,
    );
  }

  PlaybackSessionEntity toEntity() {
    return PlaybackSessionEntity(
      id: id,
      audiobookId: audiobookId,
      audioUrl: audioUrl,
      currentTime: currentTime,
      progress: progress,
      chapters: chapters,
      audiobook: audiobook,
      createdAt: createdAt,
    );
  }
}