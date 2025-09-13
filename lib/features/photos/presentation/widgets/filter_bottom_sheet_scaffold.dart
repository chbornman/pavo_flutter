import 'package:flutter/material.dart';

/// Reusable scaffold for filter bottom sheets
/// Provides consistent UI with title, search/clear buttons, and content area
class FilterBottomSheetScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onSearch;
  final VoidCallback? onClear;
  final bool expanded;

  const FilterBottomSheetScaffold({
    super.key,
    required this.title,
    required this.child,
    this.onSearch,
    this.onClear,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with title and actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (onClear != null)
                  TextButton(
                    onPressed: onClear,
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (onSearch != null)
                  ElevatedButton(
                    onPressed: onSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Search'),
                  ),
              ],
            ),
          ),

          // Content area
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}