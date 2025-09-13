import 'package:flutter/material.dart';

/// Display options filter picker widget
/// Allows toggling display options like not in album, archived, favorite
class DisplayOptionsPicker extends StatefulWidget {
  final Function(Map<String, bool>) onSelect;
  final Map<String, bool> initialFilter;

  const DisplayOptionsPicker({
    super.key,
    required this.onSelect,
    required this.initialFilter,
  });

  @override
  State<DisplayOptionsPicker> createState() => _DisplayOptionsPickerState();
}

class _DisplayOptionsPickerState extends State<DisplayOptionsPicker> {
  late bool isNotInAlbum;
  late bool isArchived;
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isNotInAlbum = widget.initialFilter['isNotInAlbum'] ?? false;
    isArchived = widget.initialFilter['isArchived'] ?? false;
    isFavorite = widget.initialFilter['isFavorite'] ?? false;
  }

  void _onSelectionChanged() {
    widget.onSelect({
      'isNotInAlbum': isNotInAlbum,
      'isArchived': isArchived,
      'isFavorite': isFavorite,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Show only photos that are:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),

        // Not in album option
        SwitchListTile(
          title: const Text('Not in any album'),
          subtitle: const Text('Show photos that haven\'t been added to albums'),
          value: isNotInAlbum,
          onChanged: (value) {
            setState(() {
              isNotInAlbum = value;
            });
            _onSelectionChanged();
          },
          secondary: Icon(
            Icons.photo_library_outlined,
            color: isNotInAlbum
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),

        const Divider(),

        // Archived option
        SwitchListTile(
          title: const Text('Archived'),
          subtitle: const Text('Show archived photos'),
          value: isArchived,
          onChanged: (value) {
            setState(() {
              isArchived = value;
            });
            _onSelectionChanged();
          },
          secondary: Icon(
            Icons.archive_outlined,
            color: isArchived
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),

        const Divider(),

        // Favorite option
        SwitchListTile(
          title: const Text('Favorites'),
          subtitle: const Text('Show favorite photos'),
          value: isFavorite,
          onChanged: (value) {
            setState(() {
              isFavorite = value;
            });
            _onSelectionChanged();
          },
          secondary: Icon(
            Icons.favorite_border,
            color: isFavorite
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 16),

        // Info text
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'You can combine multiple options. Photos must match all selected criteria.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}