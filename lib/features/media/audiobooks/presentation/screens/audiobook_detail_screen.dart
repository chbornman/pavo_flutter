import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../domain/entities/audiobook_entity.dart';
import '../providers/audiobooks_provider.dart';
import '../providers/audiobook_player_provider.dart';

class AudiobookDetailScreen extends ConsumerStatefulWidget {
  final String audiobookId;

  const AudiobookDetailScreen({
    super.key,
    required this.audiobookId,
  });

  @override
  ConsumerState<AudiobookDetailScreen> createState() => _AudiobookDetailScreenState();
}

class _AudiobookDetailScreenState extends ConsumerState<AudiobookDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final playbackState = ref.watch(audiobookPlayerProvider);
    final audiobooksAsync = ref.watch(audiobooksListProvider());
    
    return audiobooksAsync.when(
      data: (audiobooks) {
        final matching = audiobooks.where((book) => book.id == widget.audiobookId);
        final audiobook = matching.isNotEmpty ? matching.first : null;
        
        if (audiobook == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Audiobook Not Found')),
            body: const Center(
              child: Text('Audiobook not found'),
            ),
          );
        }
        
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildCoverSection(audiobook),
                ),
              ),
              
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildAudiobookInfo(audiobook),
                    _buildPlaybackControls(audiobook),
                    _buildTabBar(),
                  ],
                ),
              ),
              
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDetailsTab(audiobook),
                    _buildChaptersTab(audiobook),
                    _buildProgressTab(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text('Error loading audiobook: $error'),
        ),
      ),
    );
  }

  Widget _buildCoverSection(AudiobookEntity audiobook) {
    final coverUrl = ref.watch(coverUrlProvider(widget.audiobookId, width: 400));
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.3),
            Colors.black.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Center(
        child: CachedNetworkImage(
          imageUrl: coverUrl,
          width: 200,
          height: 200,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 200,
            height: 200,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.headphones_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: 200,
            height: 200,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.headphones_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAudiobookInfo(AudiobookEntity audiobook) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(AppConstants.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            audiobook.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            'by ${audiobook.author}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (audiobook.narrator.isNotEmpty && audiobook.narrator != audiobook.author) ...[
            const SizedBox(height: 4),
            Text(
              'narrated by ${audiobook.narrator}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                audiobook.formattedDuration,
                style: theme.textTheme.bodyMedium,
              ),
              if (audiobook.hasProgress) ...[
                const SizedBox(width: 16),
                Text(
                  '${(audiobook.progress * 100).round()}% complete',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackControls(AudiobookEntity audiobook) {
    final playbackState = ref.watch(audiobookPlayerProvider);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Skip backward
          IconButton(
            onPressed: playbackState.canPlay && playbackState.currentAudiobook?.id == audiobook.id
                ? () => ref.read(audiobookPlayerProvider.notifier).skipBackward()
                : null,
            icon: const Icon(Icons.replay_30),
            iconSize: 32,
          ),
          
          // Play/Pause
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: playbackState.isLoading
                  ? null
                  : () {
                      final player = ref.read(audiobookPlayerProvider.notifier);
                      if (playbackState.currentAudiobook?.id == audiobook.id) {
                        // Already loaded, just play/pause
                        if (playbackState.isPlaying) {
                          player.pause();
                        } else {
                          player.play();
                        }
                      } else {
                        // Load this audiobook first
                        player.playAudiobook(audiobook);
                      }
                    },
              icon: playbackState.isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : Icon(
                      playbackState.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: theme.colorScheme.onPrimary,
                    ),
              iconSize: 48,
            ),
          ),
          
          // Skip forward
          IconButton(
            onPressed: playbackState.canPlay && playbackState.currentAudiobook?.id == audiobook.id
                ? () => ref.read(audiobookPlayerProvider.notifier).skipForward()
                : null,
            icon: const Icon(Icons.forward_30),
            iconSize: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: 'Details'),
        Tab(text: 'Chapters'),
        Tab(text: 'Progress'),
      ],
    );
  }

  Widget _buildDetailsTab(AudiobookEntity audiobook) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (audiobook.description != null && audiobook.description!.isNotEmpty) ...[
            Text(
              'Description',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              audiobook.description!,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppConstants.padding),
          ],
          
          if (audiobook.genres.isNotEmpty) ...[
            Text(
              'Genres',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: audiobook.genres
                  .map((genre) => Chip(
                        label: Text(genre),
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      ))
                  .toList(),
            ),
            const SizedBox(height: AppConstants.padding),
          ],
          
          Text(
            'Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          
          if (audiobook.publisher != null) ...[
            _buildDetailRow('Publisher', audiobook.publisher!),
          ],
          if (audiobook.publishedDate != null) ...[
            _buildDetailRow('Published', audiobook.publishedDate!),
          ],
          if (audiobook.isbn != null) ...[
            _buildDetailRow('ISBN', audiobook.isbn!),
          ],
          _buildDetailRow('Duration', audiobook.formattedDuration),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChaptersTab(AudiobookEntity audiobook) {
    final theme = Theme.of(context);
    
    if (audiobook.chapters.isEmpty) {
      return const Center(
        child: Text('No chapters available'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingSmall),
      itemCount: audiobook.chapters.length,
      itemBuilder: (context, index) {
        final chapter = audiobook.chapters[index];
        final playbackState = ref.watch(audiobookPlayerProvider);
        final isCurrentChapter = playbackState.currentChapter?.id == chapter.id;
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isCurrentChapter 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.surfaceContainerHighest,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: isCurrentChapter 
                      ? theme.colorScheme.onPrimary 
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            title: Text(
              chapter.title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: isCurrentChapter ? FontWeight.w600 : null,
                color: isCurrentChapter ? theme.colorScheme.primary : null,
              ),
            ),
            subtitle: Text(chapter.formattedDuration),
            trailing: playbackState.currentAudiobook?.id == audiobook.id
                ? IconButton(
                    icon: Icon(
                      isCurrentChapter && playbackState.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                    onPressed: () {
                      final player = ref.read(audiobookPlayerProvider.notifier);
                      if (isCurrentChapter && playbackState.isPlaying) {
                        player.pause();
                      } else {
                        player.playChapter(chapter);
                      }
                    },
                  )
                : null,
            onTap: () {
              final player = ref.read(audiobookPlayerProvider.notifier);
              if (playbackState.currentAudiobook?.id != audiobook.id) {
                player.playAudiobook(audiobook);
              }
              player.playChapter(chapter);
            },
          ),
        );
      },
    );
  }

  Widget _buildProgressTab() {
    final playbackState = ref.watch(audiobookPlayerProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppConstants.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Playback Progress',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: AppConstants.padding),
          
          if (playbackState.currentAudiobook != null) ...[
            LinearProgressIndicator(
              value: playbackState.progress,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(playbackState.currentPosition),
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  _formatDuration(playbackState.totalDuration),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            
            if (playbackState.currentChapter != null) ...[
              const SizedBox(height: AppConstants.padding),
              Text(
                'Current Chapter',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                playbackState.currentChapter!.title,
                style: theme.textTheme.bodyLarge,
              ),
            ],
            
            const SizedBox(height: AppConstants.padding),
            Row(
              children: [
                Text(
                  'Playback Speed: ',
                  style: theme.textTheme.titleMedium,
                ),
                DropdownButton<double>(
                  value: playbackState.playbackSpeed,
                  items: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
                      .map((speed) => DropdownMenuItem(
                            value: speed,
                            child: Text('${speed}x'),
                          ))
                      .toList(),
                  onChanged: (speed) {
                    if (speed != null) {
                      ref.read(audiobookPlayerProvider.notifier).setPlaybackSpeed(speed);
                    }
                  },
                ),
              ],
            ),
          ] else ...[
            const Text('No audiobook currently loaded'),
          ],
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}