import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../domain/entities/audiobook_entity.dart';
import '../providers/audiobooks_provider.dart';
import 'audiobook_card.dart';

class ContinueListeningSection extends ConsumerWidget {
  final Function(AudiobookEntity) onAudiobookTap;
  final Function(AudiobookEntity) onPlayTap;

  const ContinueListeningSection({
    super.key,
    required this.onAudiobookTap,
    required this.onPlayTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inProgressAsync = ref.watch(inProgressAudiobooksProvider);
    final theme = Theme.of(context);

    return inProgressAsync.when(
      data: (audiobooks) {
        if (audiobooks.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.padding,
                AppConstants.padding,
                AppConstants.padding,
                AppConstants.paddingSmall,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.play_circle_outline,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: AppConstants.paddingSmall),
                  Text(
                    'Continue Listening',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(
              height: 260, // Increased height for text beneath covers
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.padding,
                ),
                itemCount: audiobooks.length,
                itemBuilder: (context, index) {
                  final audiobook = audiobooks[index];
                  
                  return Container(
                    width: 160, // Slightly wider for better proportions
                    margin: EdgeInsets.only(
                      right: index < audiobooks.length - 1 
                          ? AppConstants.padding 
                          : 0,
                    ),
                    child: AudiobookCard(
                      audiobook: audiobook,
                      onTap: () => onAudiobookTap(audiobook),
                      onPlayTap: () => onPlayTap(audiobook),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: AppConstants.padding),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(AppConstants.padding),
        child: Text(
          'Failed to load in-progress audiobooks',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      ),
    );
  }
}