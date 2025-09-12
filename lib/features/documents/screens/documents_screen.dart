import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/document.dart';
import '../presentation/providers/documents_provider.dart';
import '../presentation/widgets/document_grid.dart';
import '../presentation/widgets/document_viewer.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = '';
  String _selectedSort = 'date_desc';

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
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final notifier = ref.read(documentsNotifierProvider.notifier);
      if (notifier.hasMore) {
        notifier.loadMore();
      }
    }
  }

  void _showDocumentViewer(Document document, int index) {
    final documents = ref.read(documentsNotifierProvider).valueOrNull ?? [];
    final notifier = ref.read(documentsNotifierProvider.notifier);
    
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => DocumentViewer(
          documents: documents,
          initialIndex: index,
          getPreviewUrl: notifier.getPreviewUrl,
          getDownloadUrl: notifier.getDownloadUrl,
          headers: notifier.authHeaders,
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final documentsAsync = ref.watch(documentsNotifierProvider);
    final notifier = ref.read(documentsNotifierProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
      ),
      body: Column(
        children: [
          // Header with document count and filters
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Document count
                if (documentsAsync.hasValue)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      '${notifier.totalCount} documents',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                // Filter and sort row
                Row(
                  children: [
                    // Filter dropdown
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        setState(() {
                          _selectedFilter = value;
                        });
                        notifier.setFilter(value.isEmpty ? null : value);
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: '',
                          child: Text('All Documents'),
                        ),
                        const PopupMenuItem(
                          value: 'year',
                          child: Text('This Year'),
                        ),
                        const PopupMenuItem(
                          value: 'month',
                          child: Text('This Month'),
                        ),
                      ],
                      child: Chip(
                        label: Text(
                          _selectedFilter.isEmpty 
                              ? 'All' 
                              : _selectedFilter == 'year' 
                                  ? 'This Year' 
                                  : 'This Month',
                          style: const TextStyle(fontSize: 12),
                        ),
                        deleteIcon: _selectedFilter.isNotEmpty 
                            ? const Icon(Icons.close, size: 16) 
                            : null,
                        onDeleted: _selectedFilter.isNotEmpty
                            ? () {
                                setState(() {
                                  _selectedFilter = '';
                                });
                                notifier.setFilter(null);
                              }
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Sort dropdown
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        setState(() {
                          _selectedSort = value;
                        });
                        notifier.setSortBy(value);
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'date_desc',
                          child: Text('Newest'),
                        ),
                        const PopupMenuItem(
                          value: 'date_asc',
                          child: Text('Oldest'),
                        ),
                        const PopupMenuItem(
                          value: 'name_asc',
                          child: Text('Name'),
                        ),
                      ],
                      child: Chip(
                        label: Text(
                          _selectedSort == 'date_desc' 
                              ? 'Newest' 
                              : _selectedSort == 'date_asc' 
                                  ? 'Oldest' 
                                  : 'Name',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: documentsAsync.when(
              data: (documents) {
                if (documents.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 96,
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No documents found',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Documents will appear here once added to Paperless',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                      ],
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
              error: (error, stack) => Center(
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
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
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
        ],
      ),
    );
  }
}