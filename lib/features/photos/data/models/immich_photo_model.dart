import '../../domain/entities/photo_entity.dart';

/// Data model for Immich API responses
/// Flutter best practice: Separate data models from domain entities
/// This handles JSON serialization/deserialization
class ImmichPhotoModel {
  final String id;
  final String deviceAssetId;
  final String ownerId;
  final String? deviceId;
  final String type;
  final String originalPath;
  final String? originalFileName;
  final String? resized;
  final String? thumbhash;
  final String fileCreatedAt;
  final String fileModifiedAt;
  final String updatedAt;
  final bool isFavorite;
  final bool isArchived;
  final bool isExternal;
  final bool isOffline;
  final bool isReadOnly;
  final bool isVisible;
  final String? duration;
  final ExifInfo? exifInfo;
  final SmartInfo? smartInfo;
  final String? livePhotoVideoId;
  final String? stackParentId;
  final int stackCount;
  final String checksum;

  ImmichPhotoModel({
    required this.id,
    required this.deviceAssetId,
    required this.ownerId,
    this.deviceId,
    required this.type,
    required this.originalPath,
    this.originalFileName,
    this.resized,
    this.thumbhash,
    required this.fileCreatedAt,
    required this.fileModifiedAt,
    required this.updatedAt,
    required this.isFavorite,
    required this.isArchived,
    required this.isExternal,
    required this.isOffline,
    required this.isReadOnly,
    required this.isVisible,
    this.duration,
    this.exifInfo,
    this.smartInfo,
    this.livePhotoVideoId,
    this.stackParentId,
    required this.stackCount,
    required this.checksum,
  });

  /// Factory constructor for JSON deserialization
  /// Flutter pattern: Named factory constructors for clarity
  factory ImmichPhotoModel.fromJson(Map<String, dynamic> json) {
    return ImmichPhotoModel(
      id: json['id'] as String,
      deviceAssetId: json['deviceAssetId'] as String,
      ownerId: json['ownerId'] as String,
      deviceId: json['deviceId'] as String?,
      type: json['type'] as String,
      originalPath: json['originalPath'] as String,
      originalFileName: json['originalFileName'] as String?,
      resized: json['resized']?.toString(),
      thumbhash: json['thumbhash'] as String?,
      fileCreatedAt: json['fileCreatedAt'] as String,
      fileModifiedAt: json['fileModifiedAt'] as String,
      updatedAt: json['updatedAt'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
      isExternal: json['isExternal'] as bool? ?? false,
      isOffline: json['isOffline'] as bool? ?? false,
      isReadOnly: json['isReadOnly'] as bool? ?? false,
      isVisible: json['isVisible'] as bool? ?? true,
      duration: json['duration'] as String?,
      exifInfo: json['exifInfo'] != null 
          ? ExifInfo.fromJson(json['exifInfo']) 
          : null,
      smartInfo: json['smartInfo'] != null
          ? SmartInfo.fromJson(json['smartInfo'])
          : null,
      livePhotoVideoId: json['livePhotoVideoId'] as String?,
      stackParentId: json['stackParentId'] as String?,
      stackCount: json['stackCount'] as int? ?? 0,
      checksum: json['checksum'] as String,
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceAssetId': deviceAssetId,
      'ownerId': ownerId,
      'deviceId': deviceId,
      'type': type,
      'originalPath': originalPath,
      'originalFileName': originalFileName,
      'resized': resized,
      'thumbhash': thumbhash,
      'fileCreatedAt': fileCreatedAt,
      'fileModifiedAt': fileModifiedAt,
      'updatedAt': updatedAt,
      'isFavorite': isFavorite,
      'isArchived': isArchived,
      'isExternal': isExternal,
      'isOffline': isOffline,
      'isReadOnly': isReadOnly,
      'isVisible': isVisible,
      'duration': duration,
      'exifInfo': exifInfo?.toJson(),
      'smartInfo': smartInfo?.toJson(),
      'livePhotoVideoId': livePhotoVideoId,
      'stackParentId': stackParentId,
      'stackCount': stackCount,
      'checksum': checksum,
    };
  }

  /// Convert to domain entity
  /// This is the adapter pattern - converting external data to our domain
  PhotoEntity toEntity({required String baseUrl, String? apiKey}) {
    // Build URLs for accessing the asset
    // Immich v1.95+ uses /api/assets/ (with 's') instead of /api/asset/
    final thumbnailUrl = '$baseUrl/api/assets/$id/thumbnail?size=preview';
    final originalUrl = '$baseUrl/api/assets/$id/original';
    
    // Parse duration for videos
    Duration? videoDuration;
    if (duration != null) {
      final parts = duration!.split(':');
      if (parts.length == 3) {
        videoDuration = Duration(
          hours: int.tryParse(parts[0]) ?? 0,
          minutes: int.tryParse(parts[1]) ?? 0,
          seconds: int.tryParse(parts[2].split('.')[0]) ?? 0,
        );
      }
    }

    return PhotoEntity(
      id: id,
      thumbnailUrl: thumbnailUrl,
      originalUrl: originalUrl,
      fileName: originalFileName,
      createdAt: DateTime.tryParse(fileCreatedAt),
      modifiedAt: DateTime.tryParse(fileModifiedAt),
      width: exifInfo?.exifImageWidth,
      height: exifInfo?.exifImageHeight,
      fileSize: exifInfo?.fileSizeInByte,
      mimeType: _getMimeType(type),
      type: type.toLowerCase() == 'video' ? PhotoType.video : PhotoType.image,
      isFavorite: isFavorite,
      checksum: checksum,
      duration: videoDuration,
      exifData: exifInfo?.toJson(),
    );
  }

  String _getMimeType(String type) {
    if (type.toLowerCase() == 'video') {
      return 'video/mp4'; // Default, could be enhanced
    }
    return 'image/jpeg'; // Default, could be enhanced
  }
}

/// EXIF information model
class ExifInfo {
  final String? make;
  final String? model;
  final int? exifImageWidth;
  final int? exifImageHeight;
  final int? fileSizeInByte;
  final String? orientation;
  final String? dateTimeOriginal;
  final String? modifyDate;
  final String? timeZone;
  final String? lensModel;
  final double? fNumber;
  final double? focalLength;
  final int? iso;
  final double? exposureTime;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? state;
  final String? country;
  final String? description;

  ExifInfo({
    this.make,
    this.model,
    this.exifImageWidth,
    this.exifImageHeight,
    this.fileSizeInByte,
    this.orientation,
    this.dateTimeOriginal,
    this.modifyDate,
    this.timeZone,
    this.lensModel,
    this.fNumber,
    this.focalLength,
    this.iso,
    this.exposureTime,
    this.latitude,
    this.longitude,
    this.city,
    this.state,
    this.country,
    this.description,
  });

  factory ExifInfo.fromJson(Map<String, dynamic> json) {
    return ExifInfo(
      make: json['make'] as String?,
      model: json['model'] as String?,
      exifImageWidth: json['exifImageWidth'] as int?,
      exifImageHeight: json['exifImageHeight'] as int?,
      fileSizeInByte: json['fileSizeInByte'] as int?,
      orientation: json['orientation'] as String?,
      dateTimeOriginal: json['dateTimeOriginal'] as String?,
      modifyDate: json['modifyDate'] as String?,
      timeZone: json['timeZone'] as String?,
      lensModel: json['lensModel'] as String?,
      fNumber: json['fNumber'] != null ? double.tryParse(json['fNumber'].toString()) : null,
      focalLength: json['focalLength'] != null ? double.tryParse(json['focalLength'].toString()) : null,
      iso: json['iso'] != null ? int.tryParse(json['iso'].toString()) : null,
      exposureTime: json['exposureTime'] != null ? double.tryParse(json['exposureTime'].toString()) : null,
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'make': make,
      'model': model,
      'exifImageWidth': exifImageWidth,
      'exifImageHeight': exifImageHeight,
      'fileSizeInByte': fileSizeInByte,
      'orientation': orientation,
      'dateTimeOriginal': dateTimeOriginal,
      'modifyDate': modifyDate,
      'timeZone': timeZone,
      'lensModel': lensModel,
      'fNumber': fNumber,
      'focalLength': focalLength,
      'iso': iso,
      'exposureTime': exposureTime,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'state': state,
      'country': country,
      'description': description,
    };
  }
}

/// Smart info (AI-detected information)
class SmartInfo {
  final List<String>? tags;
  final List<String>? objects;

  SmartInfo({
    this.tags,
    this.objects,
  });

  factory SmartInfo.fromJson(Map<String, dynamic> json) {
    return SmartInfo(
      tags: (json['tags'] as List?)?.cast<String>(),
      objects: (json['objects'] as List?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tags': tags,
      'objects': objects,
    };
  }
}