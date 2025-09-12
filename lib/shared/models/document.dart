class Document {
  final int id;
  final String title;
  final DateTime created;
  final DateTime modified;
  final DateTime? added;
  final String? content;
  final int? correspondent;
  final int? documentType;
  final List<int> tags;
  final String? archiveSerialNumber;
  final String? originalFileName;
  final String? archivedFileName;

  Document({
    required this.id,
    required this.title,
    required this.created,
    required this.modified,
    this.added,
    this.content,
    this.correspondent,
    this.documentType,
    required this.tags,
    this.archiveSerialNumber,
    this.originalFileName,
    this.archivedFileName,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      title: json['title'],
      created: DateTime.parse(json['created']),
      modified: DateTime.parse(json['modified']),
      added: json['added'] != null ? DateTime.parse(json['added']) : null,
      content: json['content'],
      correspondent: json['correspondent'],
      documentType: json['document_type'],
      tags: List<int>.from(json['tags'] ?? []),
      archiveSerialNumber: json['archive_serial_number'],
      originalFileName: json['original_file_name'],
      archivedFileName: json['archived_file_name'],
    );
  }
}