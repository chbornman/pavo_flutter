import 'package:flutter/material.dart';

/// Filter chip for search filters
/// Displays icon, label, and current filter value
class SearchFilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? currentFilter;

  const SearchFilterChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.currentFilter,
  });

  @override
  Widget build(BuildContext context) {
    final hasActiveFilter = currentFilter != null;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: Icon(
          icon,
          size: 18,
          color: hasActiveFilter
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: hasActiveFilter
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: hasActiveFilter ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            if (hasActiveFilter) ...[
              const SizedBox(width: 4),
              Container(
                constraints: const BoxConstraints(maxWidth: 80),
                child: DefaultTextStyle(
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  child: currentFilter!,
                ),
              ),
            ],
          ],
        ),
        selected: hasActiveFilter,
        onSelected: (_) => onTap(),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        selectedColor: Theme.of(context).colorScheme.primaryContainer,
        checkmarkColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: hasActiveFilter
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
    );
  }
}