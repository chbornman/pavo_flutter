import 'package:flutter/material.dart';
import '../../domain/entities/photo_entity.dart';

/// Media type filter picker widget
/// Allows selection between photos, videos, or all media
class MediaTypePicker extends StatefulWidget {
  final Function(PhotoType?) onSelect;
  final PhotoType? initialFilter;

  const MediaTypePicker({
    super.key,
    required this.onSelect,
    required this.initialFilter,
  });

  @override
  State<MediaTypePicker> createState() => _MediaTypePickerState();
}

class _MediaTypePickerState extends State<MediaTypePicker> {
  late PhotoType? selectedType;

  @override
  void initState() {
    super.initState();
    selectedType = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Media Type',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),

        // All media option
        InkWell(
          onTap: () {
            setState(() {
              selectedType = null;
            });
            widget.onSelect(null);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Radio<PhotoType?>(
                  value: null,
                  groupValue: selectedType,
                  onChanged: (value) {
                    setState(() {
                      selectedType = value;
                    });
                    widget.onSelect(value);
                  },
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.photo_library,
                  color: selectedType == null
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'All Media',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Show both photos and videos',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Photos only option
        InkWell(
          onTap: () {
            setState(() {
              selectedType = PhotoType.image;
            });
            widget.onSelect(PhotoType.image);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Radio<PhotoType?>(
                  value: PhotoType.image,
                  groupValue: selectedType,
                  onChanged: (value) {
                    setState(() {
                      selectedType = value;
                    });
                    widget.onSelect(value);
                  },
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.photo,
                  color: selectedType == PhotoType.image
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Photos Only',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Show only photos',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Videos only option
        InkWell(
          onTap: () {
            setState(() {
              selectedType = PhotoType.video;
            });
            widget.onSelect(PhotoType.video);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Radio<PhotoType?>(
                  value: PhotoType.video,
                  groupValue: selectedType,
                  onChanged: (value) {
                    setState(() {
                      selectedType = value;
                    });
                    widget.onSelect(value);
                  },
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.videocam,
                  color: selectedType == PhotoType.video
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Videos Only',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Show only videos',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}