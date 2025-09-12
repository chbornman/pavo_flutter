import '../../domain/entities/document.dart';

class DocumentModel extends Document {
  const DocumentModel({
    required super.id,
    required super.title,
    super.created,
    super.modified,
    super.added,
    super.correspondent,
    super.documentType,
    super.storagePath,
    super.originalFileName,
    super.archivedFileName,
    super.originalMimeType,
    super.pageCount,
    super.tags,
    super.content,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as int,
      title: json['title'] as String,
      created: json['created'] != null ? DateTime.parse(json['created']) : null,
      modified: json['modified'] != null ? DateTime.parse(json['modified']) : null,
      added: json['added'] != null ? DateTime.parse(json['added']) : null,
      correspondent: json['correspondent'] as String?,
      documentType: json['document_type'] as String?,
      storagePath: json['storage_path'] as String?,
      originalFileName: json['original_file_name'] as String?,
      archivedFileName: json['archived_file_name'] as String?,
      originalMimeType: json['original_mime_type'] as String?,
      pageCount: json['page_count'] as int?,
      tags: (json['tags'] as List<dynamic>?)?.cast<int>() ?? const [],
      content: json['content'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'created': created?.toIso8601String(),
      'modified': modified?.toIso8601String(),
      'added': added?.toIso8601String(),
      'correspondent': correspondent,
      'document_type': documentType,
      'storage_path': storagePath,
      'original_file_name': originalFileName,
      'archived_file_name': archivedFileName,
      'original_mime_type': originalMimeType,
      'page_count': pageCount,
      'tags': tags,
      'content': content,
    };
  }
}