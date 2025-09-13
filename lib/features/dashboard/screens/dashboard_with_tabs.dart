import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                      : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              // Animated circle indicator (cutout effect) - behind the icons
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: (180.0 / 5) * widget.controller.index + (180.0 / 5 - 30) / 2, // Center in each tab
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

class _DashboardWithTabsState extends ConsumerState<DashboardWithTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Widget> _screens = const [
    PhotosScreen(),
    DocumentsScreen(),
    MediaScreen(),
    MusicScreen(),
    AudiobooksScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _screens.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Allow body content to flow behind app bar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64), // Slightly taller for pill effect
        child: Container(
          margin: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(32), // Pill shape
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent, // Transparent to show pill background
            elevation: 0, // Remove default shadow since we have custom pill shadow
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            title: SizedBox(
              width: 180, // More compact width for navigation
              child: _DynamicTabBar(
                controller: _tabController,
                screens: _screens,
              ),
            ),
            centerTitle: true,
            leading: const Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: PavoLogoSmall(size: 32),
            ),
            leadingWidth: 56,
            actions: [
              const CustomUserButton(),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16), // Add top padding to account for pill app bar
        child: TabBarView(
          controller: _tabController,
          children: _screens,
        ),
      ),
    );
  }
}