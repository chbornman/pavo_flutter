import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../domain/entities/audiobook_entity.dart';
import 'audiobook_card.dart';

class AudiobookGrid extends ConsumerWidget {
  final List<AudiobookEntity> audiobooks;
  final Function(AudiobookEntity) onAudiobookTap;
  final Function(AudiobookEntity) onPlayTap;

  const AudiobookGrid({
    super.key,
    required this.audiobooks,
    required this.onAudiobookTap,
    required this.onPlayTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.padding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: AppConstants.padding,
        mainAxisSpacing: AppConstants.padding,
      ),
      itemCount: audiobooks.length,
      itemBuilder: (context, index) {
        final audiobook = audiobooks[index];
        
        return AudiobookCard(
          audiobook: audiobook,
          onTap: () => onAudiobookTap(audiobook),
          onPlayTap: () => onPlayTap(audiobook),
        );
      },
    );
  }
}