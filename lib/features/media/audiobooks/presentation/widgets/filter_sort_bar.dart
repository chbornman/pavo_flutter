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
                  child: Text('All Books'),
                ),
                DropdownMenuItem(
                  value: AudiobookFilter.inProgress,
                  child: Text('In Progress'),
                ),
                DropdownMenuItem(
                  value: AudiobookFilter.notStarted,
                  child: Text('Not Started'),
                ),
                DropdownMenuItem(
                  value: AudiobookFilter.finished,
                  child: Text('Finished'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  onFilterChanged(value);
                }
              },
            ),
          ),
          
          const SizedBox(width: AppConstants.padding),
          
          // Sort dropdown
          Expanded(
            child: DropdownButtonFormField<AudiobookSort>(
              value: currentSort,
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
                  child: Text('Title A-Z'),
                ),
                DropdownMenuItem(
                  value: AudiobookSort.dateDesc,
                  child: Text('Recently Added'),
                ),
                DropdownMenuItem(
                  value: AudiobookSort.dateAsc,
                  child: Text('Oldest First'),
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