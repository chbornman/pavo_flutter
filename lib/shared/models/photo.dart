class Photo {
  final String id;
  final String fileName;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String? description;
  final int width;
  final int height;
  final String thumbnailPath;
  final String originalPath;

  Photo({
    required this.id,
    required this.fileName,
    required this.createdAt,
    required this.modifiedAt,
    this.description,
    required this.width,
    required this.height,
    required this.thumbnailPath,
    required this.originalPath,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      fileName: json['originalFileName'] ?? json['fileName'] ?? 'Unknown',
      createdAt: DateTime.parse(json['createdAt']),
      modifiedAt: DateTime.parse(json['modifiedAt']),
      description: json['description'],
      width: json['exifInfo']?['imageWidth'] ?? 0,
      height: json['exifInfo']?['imageHeight'] ?? 0,
      thumbnailPath: json['thumbnailPath'] ?? '',
      originalPath: json['originalPath'] ?? '',
    );
  }
}