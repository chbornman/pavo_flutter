import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../features/photos/presentation/widgets/floating_filter_bar.dart';
import '../presentation/providers/audiobooks_provider.dart';
import '../presentation/providers/audiobook_player_provider.dart';
import '../presentation/widgets/continue_listening_section.dart';
import '../presentation/widgets/audiobook_card.dart';
import '../data/services/audiobookshelf_service.dart';
import '../domain/entities/audiobook_entity.dart';

class AudiobooksScreen extends ConsumerStatefulWidget {
  const AudiobooksScreen({super.key});

  @override
  ConsumerState<AudiobooksScreen> createState() => _AudiobooksScreenState();
}

class _AudiobooksScreenState extends ConsumerState<AudiobooksScreen> {
  // TODO: Remove local filter/sort state - will be managed by FloatingFilterBar
  AudiobookFilter _currentFilter = AudiobookFilter.all;
  AudiobookSort _currentSort = AudiobookSort.nameAsc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final audiobooksAsync = ref.watch(audiobooksListProvider(
      filter: _currentFilter,
      sort: _currentSort,
    ));

    return Scaffold(
      body: Stack(
        children: [
          audiobooksAsync.when(
            data: (audiobooks) {
              if (audiobooks.isEmpty) {
                return _buildEmptyState();
              }

               return SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Continue Listening Section
                    ContinueListeningSection(
                      onAudiobookTap: _navigateToDetail,
                      onPlayTap: _playAudiobook,
                    ),

                    // Main audiobooks grid
                    Padding(
                      padding: const EdgeInsets.all(AppConstants.padding),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.6, // Taller to accommodate text beneath
                          crossAxisSpacing: AppConstants.paddingSmall,
                          mainAxisSpacing: AppConstants.padding,
                        ),
                        itemCount: audiobooks.length,
                        itemBuilder: (context, index) {
                          final audiobook = audiobooks[index];

                          return AudiobookCard(
                            audiobook: audiobook,
                            onTap: () => _navigateToDetail(audiobook),
                            onPlayTap: () => _playAudiobook(audiobook),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => _buildErrorState(error),
          ),

          // Floating filter bar
          const FloatingFilterBar(screenType: ScreenType.audiobooks),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.headphones_outlined,
            size: 100,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppConstants.padding),
          Text(
            _getEmptyStateMessage(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            'Connect your Audiobookshelf server to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: AppConstants.padding),
          Text(
            'Failed to load audiobooks',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.padding),
          ElevatedButton.icon(
            onPressed: () {
              ref.invalidate(audiobooksListProvider);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _getEmptyStateMessage() {
    switch (_currentFilter) {
      case AudiobookFilter.inProgress:
        return 'No audiobooks in progress';
      case AudiobookFilter.finished:
        return 'No finished audiobooks';
      case AudiobookFilter.notStarted:
        return 'No unstarted audiobooks';
      case AudiobookFilter.all:
        return 'Your audiobooks will appear here';
    }
  }

  void _navigateToDetail(AudiobookEntity audiobook) {
    context.push('/audiobooks/detail/${audiobook.id}');
  }

  void _playAudiobook(AudiobookEntity audiobook) {
    final player = ref.read(audiobookPlayerProvider.notifier);
    player.playAudiobook(audiobook);
  }
}