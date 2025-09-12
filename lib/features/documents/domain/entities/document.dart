class Document {
  final int id;
  final String title;
  final DateTime? created;
  final DateTime? modified;
  final DateTime? added;
  final String? correspondent;
  final String? documentType;
  final String? storagePath;
  final String? originalFileName;
  final String? archivedFileName;
  final String? originalMimeType;
  final int? pageCount;
  final List<int> tags;
  final String? content;

  const Document({
    required this.id,
    required this.title,
    this.created,
    this.modified,
    this.added,
    this.correspondent,
    this.documentType,
    this.storagePath,
    this.originalFileName,
    this.archivedFileName,
    this.originalMimeType,
    this.pageCount,
    this.tags = const [],
    this.content,
  });

  String get displayDate {
    if (created != null) {
      return '${created!.month}/${created!.day}/${created!.year}';
    }
    return '';
  }

  bool get isPdf {
    final mimeType = originalMimeType ?? '';
    final fileName = originalFileName ?? title;
    return mimeType.contains('pdf') || fileName.toLowerCase().endsWith('.pdf');
  }

  bool get isImage {
    final mimeType = originalMimeType ?? '';
    final fileName = originalFileName ?? title;
    return mimeType.startsWith('image/') ||
        RegExp(r'\.(jpg|jpeg|png|gif|webp|svg|bmp)$', caseSensitive: false)
            .hasMatch(fileName);
  }
}