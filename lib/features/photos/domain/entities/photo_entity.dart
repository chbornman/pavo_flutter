/// Domain entity following Clean Architecture principles
/// This is pure Dart with no dependencies on external packages
/// Represents the core business logic of what a Photo is in our app
class PhotoEntity {
  final String id;
  final String? thumbnailUrl;
  final String? originalUrl;
  final String? fileName;
  final DateTime? createdAt;
  final DateTime? modifiedAt;
  final int? width;
  final int? height;
  final int? fileSize;
  final String? mimeType;
  final PhotoType type;
  final bool isFavorite;
  final String? checksum;
  final Duration? duration; // For videos
  final Map<String, dynamic>? exifData;

  const PhotoEntity({
    required this.id,
    this.thumbnailUrl,
    this.originalUrl,
    this.fileName,
    this.createdAt,
    this.modifiedAt,
    this.width,
    this.height,
    this.fileSize,
    this.mimeType,
    this.type = PhotoType.image,
    this.isFavorite = false,
    this.checksum,
    this.duration,
    this.exifData,
  });

  /// Business logic: Check if this is a video
  bool get isVideo => type == PhotoType.video;

  /// Business logic: Check if this is an image
  bool get isImage => type == PhotoType.image;

  /// Business logic: Get display name
  String get displayName => fileName ?? 'Untitled';

  /// Business logic: Get aspect ratio if dimensions are available
  double? get aspectRatio {
    if (width != null && height != null && height! > 0) {
      return width! / height!;
    }
    return null;
  }

  /// Business logic: Format file size for display
  String get formattedFileSize {
    if (fileSize == null) return '';
    
    const units = ['B', 'KB', 'MB', 'GB'];
    var size = fileSize!.toDouble();
    var unitIndex = 0;
    
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    
    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  /// Business logic: Format duration for videos
  String get formattedDuration {
    if (duration == null) return '';
    
    final hours = duration!.inHours;
    final minutes = duration!.inMinutes.remainder(60);
    final seconds = duration!.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
             '${minutes.toString().padLeft(2, '0')}:'
             '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
           '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PhotoEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Enum for photo types
enum PhotoType {
  image,
  video,
  unknown,
}

/// Extension to parse PhotoType from string
extension PhotoTypeExtension on PhotoType {
  static PhotoType fromString(String? type) {
    switch (type?.toLowerCase()) {
      case 'image':
      case 'photo':
        return PhotoType.image;
      case 'video':
        return PhotoType.video;
      default:
        return PhotoType.unknown;
    }
  }

  String toDisplayString() {
    switch (this) {
      case PhotoType.image:
        return 'Photo';
      case PhotoType.video:
        return 'Video';
      case PhotoType.unknown:
        return 'Unknown';
    }
  }
}