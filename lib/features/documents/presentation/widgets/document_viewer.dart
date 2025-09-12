import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/document.dart';

class DocumentViewer extends StatefulWidget {
  final List<Document> documents;
  final int initialIndex;
  final String? Function(int) getPreviewUrl;
  final String? Function(int) getDownloadUrl;
  final Map<String, String> headers;
  final VoidCallback onClose;

  const DocumentViewer({
    super.key,
    required this.documents,
    required this.initialIndex,
    required this.getPreviewUrl,
    required this.getDownloadUrl,
    required this.headers,
    required this.onClose,
  });

  @override
  State<DocumentViewer> createState() => _DocumentViewerState();
}

class _DocumentViewerState extends State<DocumentViewer> {
  late int _currentIndex;
  late PageController _pageController;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handlePrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleNext() {
    if (_currentIndex < widget.documents.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _handleDownload() async {
    final document = widget.documents[_currentIndex];
    final downloadUrl = widget.getDownloadUrl(document.id);
    if (downloadUrl != null) {
      final uri = Uri.parse(downloadUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final document = widget.documents[_currentIndex];
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Document viewer
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                _scale = 1.0;
              });
            },
            itemCount: widget.documents.length,
            itemBuilder: (context, index) {
              final doc = widget.documents[index];
              final previewUrl = widget.getPreviewUrl(doc.id);
              
              if (previewUrl == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Preview not available',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _handleDownload,
                        icon: const Icon(Icons.download),
                        label: const Text('Download Document'),
                      ),
                    ],
                  ),
                );
              }
              
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: doc.isImage
                      ? CachedNetworkImage(
                          imageUrl: previewUrl,
                          httpHeaders: widget.headers,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.white.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Failed to load image',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        )
                      : _buildPdfViewer(previewUrl),
                ),
              );
            },
          ),
          
          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Document info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.documents.length > 1)
                              Text(
                                'Document ${_currentIndex + 1} / ${widget.documents.length}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            Text(
                              document.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (document.pageCount != null)
                              Text(
                                '${document.pageCount} pages',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      // Action buttons
                      Row(
                        children: [
                          IconButton(
                            onPressed: _handleDownload,
                            icon: const Icon(Icons.download),
                            color: Colors.white,
                            tooltip: 'Download',
                          ),
                          IconButton(
                            onPressed: widget.onClose,
                            icon: const Icon(Icons.close),
                            color: Colors.white,
                            tooltip: 'Close',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Navigation buttons
          if (widget.documents.length > 1) ...[
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _currentIndex > 0 ? 1.0 : 0.3,
                  duration: const Duration(milliseconds: 200),
                  child: IconButton(
                    onPressed: _currentIndex > 0 ? _handlePrevious : null,
                    icon: const Icon(Icons.chevron_left),
                    iconSize: 48,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _currentIndex < widget.documents.length - 1 ? 1.0 : 0.3,
                  duration: const Duration(milliseconds: 200),
                  child: IconButton(
                    onPressed: _currentIndex < widget.documents.length - 1 
                        ? _handleNext 
                        : null,
                    icon: const Icon(Icons.chevron_right),
                    iconSize: 48,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
          
          // Bottom info bar
          if (document.correspondent != null || document.created != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        if (document.correspondent != null)
                          Text(
                            'From: ${document.correspondent}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        if (document.correspondent != null && document.created != null)
                          Text(
                            ' • ',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        if (document.created != null)
                          Text(
                            document.displayDate,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPdfViewer(String previewUrl) {
    // For now, we'll display a message and download button for PDFs
    // In a production app, you'd use a PDF viewer package like syncfusion_flutter_pdfviewer
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.picture_as_pdf,
            size: 96,
            color: Colors.red.shade600,
          ),
          const SizedBox(height: 24),
          const Text(
            'PDF Preview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap download to view the full PDF',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _handleDownload,
            icon: const Icon(Icons.download),
            label: const Text('Download PDF'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}