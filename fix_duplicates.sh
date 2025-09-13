#!/bin/bash

# Function to remove duplicate imports and fix widgets
fix_file() {
    local file=$1
    echo "Fixing $file"
    
    # Create a temporary file
    temp_file=$(mktemp)
    
    # Process the file: keep only unique import lines
    awk '
    /^import.*jellyfin_provider\.dart/ {
        if (!seen) {
            print
            seen = 1
        }
        next
    }
    { print }
    ' "$file" > "$temp_file"
    
    # Replace the original file
    mv "$temp_file" "$file"
}

# List of files to fix
files=(
  "./lib/features/media/tv_shows/screens/tv_show_detail_screen.dart"
  "./lib/features/media/tv_shows/widgets/tv_show_grid.dart"
  "./lib/features/media/tv_shows/widgets/tv_show_card.dart"
  "./lib/features/media/movies/screens/movie_detail_screen.dart"
  "./lib/features/media/movies/screens/movie_player_screen.dart"
  "./lib/features/media/movies/widgets/movie_grid.dart"
)

for file in "${files[@]}"; do
    fix_file "$file"
done

echo "Done removing duplicate imports!"
