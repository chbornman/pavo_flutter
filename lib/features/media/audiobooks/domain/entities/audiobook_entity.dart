import 'chapter_entity.dart';

class AudiobookEntity {
  final String id;
  final String title;
  final String author;
  final String narrator;
  final String? description;
  final String? coverUrl;
  final int duration;
  final int currentTime;
  final double progress;
  final bool isFinished;
  final List<String> genres;
  final String? publisher;
  final String? publishedDate;
  final String? isbn;
  final List<ChapterEntity> chapters;
  final DateTime lastUpdate;

  const AudiobookEntity({
    required this.id,
    required this.title,
    required this.author,
    required this.narrator,
    this.description,
    this.coverUrl,
    required this.duration,
    this.currentTime = 0,
    this.progress = 0.0,
    this.isFinished = false,
    this.genres = const [],
    this.publisher,
    this.publishedDate,
    this.isbn,
    this.chapters = const [],
    required this.lastUpdate,
  });

  bool get hasProgress => progress > 0.0;
  bool get isInProgress => progress > 0.0 && !isFinished;

  String get formattedDuration {
    final totalSeconds = duration ~/ 1000;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String get formattedCurrentTime {
    final totalSeconds = currentTime ~/ 1000;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  ChapterEntity? getCurrentChapter() {
    if (chapters.isEmpty) return null;
    
    for (final chapter in chapters) {
      if (currentTime >= chapter.start && currentTime <= chapter.end) {
        return chapter;
      }
    }
    return null;
  }

  AudiobookEntity copyWith({
    String? id,
    String? title,
    String? author,
    String? narrator,
    String? description,
    String? coverUrl,
    int? duration,
    int? currentTime,
    double? progress,
    bool? isFinished,
    List<String>? genres,
    String? publisher,
    String? publishedDate,
    String? isbn,
    List<ChapterEntity>? chapters,
    DateTime? lastUpdate,
  }) {
    return AudiobookEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      narrator: narrator ?? this.narrator,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      duration: duration ?? this.duration,
      currentTime: currentTime ?? this.currentTime,
      progress: progress ?? this.progress,
      isFinished: isFinished ?? this.isFinished,
      genres: genres ?? this.genres,
      publisher: publisher ?? this.publisher,
      publishedDate: publishedDate ?? this.publishedDate,
      isbn: isbn ?? this.isbn,
      chapters: chapters ?? this.chapters,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudiobookEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}