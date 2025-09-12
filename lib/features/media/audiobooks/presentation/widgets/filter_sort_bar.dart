import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../data/services/audiobookshelf_service.dart';

class FilterSortBar extends StatelessWidget {
  final AudiobookFilter currentFilter;
  final AudiobookSort currentSort;
  final Function(AudiobookFilter) onFilterChanged;
  final Function(AudiobookSort) onSortChanged;

  const FilterSortBar({
    super.key,
    required this.currentFilter,
    required this.currentSort,
    required this.onFilterChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.padding,
        vertical: AppConstants.paddingSmall,
      ),
      child: Row(
        children: [
          // Filter dropdown
          Expanded(
            child: DropdownButtonFormField<AudiobookFilter>(
              value: currentFilter,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Filter',
                prefixIcon: const Icon(Icons.filter_list),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingSmall,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: [
                DropdownMenuItem(
                  value: AudiobookFilter.all,
                  child: Text(
                    'All Books',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownMenuItem(
                  value: AudiobookFilter.inProgress,
                  child: Text(
                    isSmallScreen ? 'In Progress' : 'In Progress',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownMenuItem(
                  value: AudiobookFilter.notStarted,
                  child: Text(
                    isSmallScreen ? 'Unstarted' : 'Not Started',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownMenuItem(
                  value: AudiobookFilter.finished,
                  child: Text(
                    'Finished',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  onFilterChanged(value);
                }
              },
            ),
          ),
          
          const SizedBox(width: AppConstants.paddingSmall),
          
          // Sort dropdown
          Expanded(
            child: DropdownButtonFormField<AudiobookSort>(
              value: currentSort,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Sort',
                prefixIcon: const Icon(Icons.sort),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingSmall,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: [
                DropdownMenuItem(
                  value: AudiobookSort.nameAsc,
                  child: Text(
                    isSmallScreen ? 'A-Z' : 'Title A-Z',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownMenuItem(
                  value: AudiobookSort.dateDesc,
                  child: Text(
                    isSmallScreen ? 'Recent' : 'Recently Added',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownMenuItem(
                  value: AudiobookSort.dateAsc,
                  child: Text(
                    isSmallScreen ? 'Oldest' : 'Oldest First',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  onSortChanged(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}