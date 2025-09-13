#!/bin/bash

# List of files to update
files=(
  "./lib/features/media/tv_shows/screens/tv_show_detail_screen.dart"
  "./lib/features/media/tv_shows/widgets/tv_show_grid.dart"
  "./lib/features/media/tv_shows/widgets/tv_show_card.dart"
  "./lib/features/media/movies/screens/movie_detail_screen.dart"
  "./lib/features/media/movies/screens/movie_player_screen.dart"
  "./lib/features/media/movies/widgets/movie_card.dart"
  "./lib/features/media/movies/widgets/movie_grid.dart"
)

for file in "${files[@]}"; do
  echo "Processing $file"
  
  # Add import if not present
  if ! grep -q "jellyfin_provider.dart" "$file"; then
    # Find the last import line and add our import after it
    sed -i '' "/^import.*dart';$/a\\
import 'package:pavo_flutter/shared/providers/jellyfin_provider.dart';" "$file"
  fi
  
  # Replace JellyfinService() with ref.watch(jellyfinServiceProvider)
  sed -i '' 's/final jellyfinService = JellyfinService();/final jellyfinService = ref.watch(jellyfinServiceProvider);/g' "$file"
  sed -i '' 's/final service = JellyfinService();/final service = ref.watch(jellyfinServiceProvider);/g' "$file"
done

echo "Done!"
