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

class _DynamicTabBar extends StatefulWidget {
  final TabController controller;
  final List<Widget> screens;

  const _DynamicTabBar({
    required this.controller,
    required this.screens,
  });

  @override
  _DynamicTabBarState createState() => _DynamicTabBarState();
}

class _DynamicTabBarState extends State<_DynamicTabBar> {
  bool get isDarkMode {
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark;
  }

  List<Tab> _buildTabs() {
    return List.generate(widget.screens.length, (index) {
      final isSelected = widget.controller.index == index;
      final targetIconSize = isSelected ? 20.0 : 14.0;

      IconData iconData;
      switch (index) {
        case 0:
          iconData = Icons.photo_library;
          break;
        case 1:
          iconData = Icons.description;
          break;
        case 2:
          iconData = Icons.movie_creation;
          break;
        case 3:
          iconData = Icons.music_note;
          break;
        case 4:
          iconData = Icons.headphones;
          break;
        default:
          iconData = Icons.help;
      }

      return Tab(
        icon: TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: isSelected ? 14.0 : 20.0,
            end: targetIconSize,
          ),
          duration: const Duration(milliseconds: 200),
          builder: (context, size, child) {
            return Icon(
              iconData,
              size: size,
              color: Theme.of(context).colorScheme.onSurface,
            );
          },
        ),
        iconMargin: EdgeInsets.zero,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return SizedBox(
          height: 44,
          child: Stack(
            children: [
              // Pill background spanning full width
              Container(
                height: 36,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.2)
                      : Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              // Animated circle indicator (cutout effect) - behind the icons
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: (180.0 / 5) * widget.controller.index +
                    (180.0 / 5 - 30) / 2, // Center in each tab
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              // TabBar with transparent indicator - renders on top
              TabBar(
                controller: widget.controller,
                tabs: _buildTabs(),
                isScrollable: false,
                tabAlignment: TabAlignment.fill,
                indicator: const BoxDecoration(
                  color: Colors.transparent, // Transparent indicator
                ),
                dividerColor: Colors.transparent,
                labelPadding: EdgeInsets.zero,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        );
      },
    );
  }
}

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
        backgroundColor:
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.90),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 56, // Reduce height from default 56
        title: SizedBox(
          width: 180, // More compact width for navigation
          child: _DynamicTabBar(
            controller: _tabController,
            screens: _screens,
          ),
        ),
        centerTitle: true,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: PavoLogoSmall(size: 24), // Smaller logo for compact app bar
        ),
        leadingWidth: 56,
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

