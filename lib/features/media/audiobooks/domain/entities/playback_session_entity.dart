import 'audiobook_entity.dart';
import 'chapter_entity.dart';

class PlaybackSessionEntity {
  final String id;
  final String audiobookId;
  final String audioUrl;
  final int currentTime;
  final double progress;
  final List<ChapterEntity> chapters;
  final AudiobookEntity audiobook;
  final DateTime createdAt;

  const PlaybackSessionEntity({
    required this.id,
    required this.audiobookId,
    required this.audioUrl,
    required this.currentTime,
    required this.progress,
    required this.chapters,
    required this.audiobook,
    required this.createdAt,
  });

  ChapterEntity? getCurrentChapter() {
    if (chapters.isEmpty) return null;
    
    for (final chapter in chapters) {
      if (currentTime >= chapter.start && currentTime <= chapter.end) {
        return chapter;
      }
    }
    return null;
  }

  PlaybackSessionEntity copyWith({
    String? id,
    String? audiobookId,
    String? audioUrl,
    int? currentTime,
    double? progress,
    List<ChapterEntity>? chapters,
    AudiobookEntity? audiobook,
    DateTime? createdAt,
  }) {
    return PlaybackSessionEntity(
      id: id ?? this.id,
      audiobookId: audiobookId ?? this.audiobookId,
      audioUrl: audioUrl ?? this.audioUrl,
      currentTime: currentTime ?? this.currentTime,
      progress: progress ?? this.progress,
      chapters: chapters ?? this.chapters,
      audiobook: audiobook ?? this.audiobook,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaybackSessionEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}