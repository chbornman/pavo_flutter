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
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
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