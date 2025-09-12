import '../../domain/entities/audiobook_entity.dart';
import '../../domain/entities/chapter_entity.dart';
import 'chapter_model.dart';

class AudiobookModel extends AudiobookEntity {
  const AudiobookModel({
    required super.id,
    required super.title,
    required super.author,
    required super.narrator,
    super.description,
    super.coverUrl,
    required super.duration,
    super.currentTime = 0,
    super.progress = 0.0,
    super.isFinished = false,
    super.genres = const [],
    super.publisher,
    super.publishedDate,
    super.isbn,
    super.chapters = const [],
    required super.lastUpdate,
  });

  factory AudiobookModel.fromJson(Map<String, dynamic> json) {
    final media = json['media'] ?? {};
    final metadata = media['metadata'] ?? {};
    final userMediaProgress = json['userMediaProgress'];
    
    // Extract chapters
    final List<ChapterEntity> chapters = [];
    if (media['chapters'] != null && media['chapters'] is List) {
      chapters.addAll(
        (media['chapters'] as List)
            .map((chapter) => ChapterModel.fromJson(chapter).toEntity())
            .toList(),
      );
    }

    // Extract genres
    final List<String> genres = [];
    if (metadata['genres'] != null && metadata['genres'] is List) {
      genres.addAll((metadata['genres'] as List).cast<String>());
    }

    // Calculate progress
    final currentTime = userMediaProgress?['currentTime']?.toInt() ?? 0;
    final duration = (media['duration'] as num?)?.toInt() ?? 1;
    final progress = duration > 0 ? (currentTime / duration).clamp(0.0, 1.0) : 0.0;

    return AudiobookModel(
      id: json['id']?.toString() ?? '',
      title: metadata['title']?.toString() ?? 'Unknown Title',
      author: metadata['authorName']?.toString() ?? 'Unknown Author',
      narrator: metadata['narratorName']?.toString() ?? 'Unknown Narrator',
      description: metadata['description']?.toString(),
      coverUrl: json['media']?['coverPath']?.toString(),
      duration: duration,
      currentTime: currentTime,
      progress: progress,
      isFinished: userMediaProgress?['isFinished'] == true,
      genres: genres,
      publisher: metadata['publisher']?.toString(),
      publishedDate: metadata['publishedYear']?.toString(),
      isbn: metadata['isbn']?.toString(),
      chapters: chapters,
      lastUpdate: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'media': {
        'metadata': {
          'title': title,
          'authorName': author,
          'narratorName': narrator,
          'description': description,
          'publisher': publisher,
          'publishedYear': publishedDate,
          'isbn': isbn,
          'genres': genres,
        },
        'duration': duration,
        'coverPath': coverUrl,
        'chapters': chapters.map((c) => ChapterModel.fromEntity(c).toJson()).toList(),
      },
      'userMediaProgress': {
        'currentTime': currentTime,
        'isFinished': isFinished,
      },
      'updatedAt': lastUpdate.toIso8601String(),
    };
  }

  factory AudiobookModel.fromEntity(AudiobookEntity entity) {
    return AudiobookModel(
      id: entity.id,
      title: entity.title,
      author: entity.author,
      narrator: entity.narrator,
      description: entity.description,
      coverUrl: entity.coverUrl,
      duration: entity.duration,
      currentTime: entity.currentTime,
      progress: entity.progress,
      isFinished: entity.isFinished,
      genres: entity.genres,
      publisher: entity.publisher,
      publishedDate: entity.publishedDate,
      isbn: entity.isbn,
      chapters: entity.chapters,
      lastUpdate: entity.lastUpdate,
    );
  }

  AudiobookEntity toEntity() {
    return AudiobookEntity(
      id: id,
      title: title,
      author: author,
      narrator: narrator,
      description: description,
      coverUrl: coverUrl,
      duration: duration,
      currentTime: currentTime,
      progress: progress,
      isFinished: isFinished,
      genres: genres,
      publisher: publisher,
      publishedDate: publishedDate,
      isbn: isbn,
      chapters: chapters,
      lastUpdate: lastUpdate,
    );
  }
}