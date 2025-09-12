import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/document.dart';

class DocumentGridItem extends StatelessWidget {
  final Document document;
  final String? thumbnailUrl;
  final Map<String, String> headers;
  final VoidCallback? onTap;

  const DocumentGridItem({
    super.key,
    required this.document,
    this.thumbnailUrl,
    required this.headers,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (thumbnailUrl != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: thumbnailUrl!,
                          httpHeaders: headers,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: _buildDocumentIcon(theme),
                          ),
                          errorWidget: (context, url, error) => Center(
                            child: _buildDocumentIcon(theme),
                          ),
                        ),
                      )
                    else
                      Center(
                        child: _buildDocumentIcon(theme),
                      ),
                    
                    // Page count badge
                    if (document.pageCount != null && document.pageCount! > 1)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${document.pageCount} pages',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Document info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (document.correspondent != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      document.correspondent!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (document.created != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      document.displayDate,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentIcon(ThemeData theme) {
    if (document.isPdf) {
      return Icon(
        Icons.picture_as_pdf,
        size: 48,
        color: Colors.red.shade600,
      );
    } else if (document.isImage) {
      return Icon(
        Icons.image,
        size: 48,
        color: theme.colorScheme.primary.withOpacity(0.6),
      );
    } else {
      return Icon(
        Icons.description,
        size: 48,
        color: theme.colorScheme.onSurface.withOpacity(0.4),
      );
    }
  }
}