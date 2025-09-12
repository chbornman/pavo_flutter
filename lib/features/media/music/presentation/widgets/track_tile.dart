import 'package:flutter/material.dart';
import '../../domain/entities/track.dart';

class TrackTile extends StatelessWidget {
  final Track track;
  final int trackNumber;
  final bool isCurrentTrack;
  final bool isPlaying;
  final VoidCallback onTap;

  const TrackTile({
    super.key,
    required this.track,
    required this.trackNumber,
    required this.isCurrentTrack,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListTile(
      onTap: onTap,
      leading: SizedBox(
        width: 32,
        child: Center(
          child: isCurrentTrack && isPlaying
              ? Icon(
                  Icons.graphic_eq,
                  size: 16,
                  color: theme.colorScheme.primary,
                )
              : Text(
                  trackNumber.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isCurrentTrack
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
        ),
      ),
      title: Text(
        track.name,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isCurrentTrack ? theme.colorScheme.primary : null,
          fontWeight: isCurrentTrack ? FontWeight.w500 : null,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: track.artists.isNotEmpty
          ? Text(
              track.displayArtist,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isCurrentTrack
                    ? theme.colorScheme.primary.withValues(alpha: 0.8)
                    : theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: track.duration != null
          ? Text(
              _formatDuration(track.duration!),
              style: theme.textTheme.bodySmall?.copyWith(
                color: isCurrentTrack
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}