import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/document.dart';
import '../presentation/providers/documents_provider.dart';
import '../presentation/widgets/document_grid.dart';
import '../presentation/widgets/document_viewer.dart';
import '../../photos/presentation/widgets/floating_filter_bar.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // TODO: Implement pagination if needed
  }

  @override
  Widget build(BuildContext context) {
    final documentsAsync = ref.watch(documentsNotifierProvider);
    final notifier = ref.read(documentsNotifierProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          documentsAsync.when(
            data: (documents) {
              if (documents.isEmpty) {
                return Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + kToolbarHeight,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 96,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No documents found',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Documents you add will appear here',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: notifier.refresh,
                child: DocumentGrid(
                  documents: documents,
                  headers: notifier.authHeaders,
                  getThumbnailUrl: notifier.getThumbnailUrl,
                  onDocumentTap: _showDocumentViewer,
                  scrollController: _scrollController,
                  isLoading: documentsAsync.isLoading,
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + kToolbarHeight,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load documents',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: notifier.refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating filter bar
          const FloatingFilterBar(screenType: ScreenType.documents),
        ],
      ),
    );
  }

  void _showDocumentViewer(Document document, int index) {
    final documentsAsync = ref.watch(documentsNotifierProvider);
    documentsAsync.whenData((documents) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DocumentViewer(
            documents: documents,
            initialIndex: index,
            getPreviewUrl: ref.read(documentsNotifierProvider.notifier).getPreviewUrl,
            getDownloadUrl: ref.read(documentsNotifierProvider.notifier).getDownloadUrl,
            headers: ref.read(documentsNotifierProvider.notifier).authHeaders,
            onClose: () => Navigator.of(context).pop(),
          ),
        ),
      );
    });
  }
}