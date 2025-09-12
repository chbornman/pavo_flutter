import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';

class MusicSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String? hintText;

  const MusicSearchBar({
    super.key,
    required this.onChanged,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText ?? 'Search artists, albums, songs...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.padding,
          vertical: AppConstants.paddingSmall,
        ),
      ),
    );
  }
}