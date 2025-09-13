import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pavo_flutter/features/media/movies/widgets/movie_grid.dart';
import 'package:pavo_flutter/features/photos/presentation/widgets/floating_filter_bar.dart';

class MoviesScreen extends ConsumerWidget {
  const MoviesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          const MovieGrid(),
          const FloatingFilterBar(screenType: ScreenType.movies),
        ],
      ),
    );
  }
}