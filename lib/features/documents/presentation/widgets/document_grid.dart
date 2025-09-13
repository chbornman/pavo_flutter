import 'package:flutter/material.dart';
import '../../domain/entities/document.dart';
import 'document_grid_item.dart';

class DocumentGrid extends StatelessWidget {
  final List<Document> documents;
  final Map<String, String> headers;
  final String? Function(int) getThumbnailUrl;
  final Function(Document, int) onDocumentTap;
  final ScrollController? scrollController;
  final bool isLoading;

  const DocumentGrid({
    super.key,
    required this.documents,
    required this.headers,
    required this.getThumbnailUrl,
    required this.onDocumentTap,
    this.scrollController,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = _getCrossAxisCount(screenWidth);
    
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        // Add top spacing for app bar
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.of(context).padding.top,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final document = documents[index];
                return DocumentGridItem(
                  document: document,
                  thumbnailUrl: getThumbnailUrl(document.id),
                  headers: headers,
                  onTap: () => onDocumentTap(document, index),
                );
              },
              childCount: documents.length,
            ),
          ),
        ),
        if (isLoading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }

  int _getCrossAxisCount(double screenWidth) {
    return 3; // Fixed 3 columns
  }
}