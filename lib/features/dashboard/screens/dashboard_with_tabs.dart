import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pavo_flutter/core/theme/theme_provider.dart';
import 'package:pavo_flutter/features/auth/widgets/custom_user_button.dart';
import 'package:pavo_flutter/features/photos/screens/photos_screen.dart';
import 'package:pavo_flutter/features/documents/screens/documents_screen.dart';
import 'package:pavo_flutter/features/media/screens/media_screen.dart';
import 'package:pavo_flutter/features/media/music/screens/music_screen.dart';
import 'package:pavo_flutter/features/media/audiobooks/screens/audiobooks_screen.dart';
import 'package:pavo_flutter/shared/widgets/pavo_logo.dart';

class DashboardWithTabs extends ConsumerStatefulWidget {
  const DashboardWithTabs({super.key});

  @override
  ConsumerState<DashboardWithTabs> createState() => _DashboardWithTabsState();
}

class _DashboardWithTabsState extends ConsumerState<DashboardWithTabs> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    PhotosScreen(),
    DocumentsScreen(),
    MediaScreen(),
    MusicScreen(),
    AudiobooksScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final themeModeNotifier = ref.read(themeModeProvider.notifier);
    
    // Determine the actual theme being used
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const PavoLogoSmall(size: 32),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              size: 24,
            ),
            onPressed: () {
              themeModeNotifier.toggleTheme();
            },
            tooltip: themeMode == ThemeMode.system 
              ? 'Theme: System' 
              : (themeMode == ThemeMode.dark ? 'Theme: Dark' : 'Theme: Light'),
          ),
          const CustomUserButton(),
          const SizedBox(width: 12),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.photo_library_outlined),
            selectedIcon: Icon(Icons.photo_library),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.movie_creation_outlined),
            selectedIcon: Icon(Icons.movie_creation),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.music_note_outlined),
            selectedIcon: Icon(Icons.music_note),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.headphones_outlined),
            selectedIcon: Icon(Icons.headphones),
            label: '',
          ),
        ],
      ),
    );
  }
}