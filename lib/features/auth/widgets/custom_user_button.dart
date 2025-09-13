import 'package:cached_network_image/cached_network_image.dart';
import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pavo_flutter/core/theme/theme_provider.dart';

class CustomUserButton extends ConsumerWidget {
  final double size;
  
  const CustomUserButton({
    super.key,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClerkAuthBuilder(
      builder: (context, authState) {
        final user = authState.user;
        
        if (user == null) {
          return const SizedBox.shrink();
        }
        
        final imageUrl = user.imageUrl;
        final initials = _getInitials(user);
        
        return PopupMenuButton<String>(
          offset: const Offset(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1,
            ),
          ),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            child: ClipOval(
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _buildFallback(context, initials),
                      errorWidget: (context, url, error) => _buildFallback(context, initials),
                    )
                  : _buildFallback(context, initials),
            ),
          ),
          itemBuilder: (context) {
            return [
              PopupMenuItem<String>(
                value: 'profile',
                child: Consumer(
                  builder: (context, ref, child) {
                    // Watch theme to rebuild when it changes
                    ref.watch(themeModeProvider);
                    final colorScheme = Theme.of(context).colorScheme;
                    final iconColor = colorScheme.onSurface;
                    final textColor = colorScheme.onSurface;
                    final subtextColor = colorScheme.onSurfaceVariant;
                    
                    return Row(
                      children: [
                        Icon(Icons.person_outline, size: 20, color: iconColor),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim().isEmpty 
                                  ? user.username ?? 'User'
                                  : '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim(),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                            if (user.emailAddresses?.isNotEmpty == true)
                              Text(
                                user.emailAddresses!.first.emailAddress,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: subtextColor,
                                ),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'theme',
                enabled: false,
                child: Consumer(
                  builder: (context, ref, child) {
                    final themeMode = ref.watch(themeModeProvider);
                    return Center(
                      child: _ThemeSelector(
                        themeMode: themeMode,
                        onChanged: (mode) {
                          ref.read(themeModeProvider.notifier).setThemeMode(mode);
                        },
                      ),
                    );
                  },
                ),
              ),
              PopupMenuItem<String>(
                value: 'account',
                child: Consumer(
                  builder: (context, ref, child) {
                    // Watch theme to rebuild when it changes
                    ref.watch(themeModeProvider);
                    final colorScheme = Theme.of(context).colorScheme;
                    final iconColor = colorScheme.onSurface;
                    final textColor = colorScheme.onSurface;
                    
                    return Row(
                      children: [
                        Icon(Icons.manage_accounts_outlined, size: 20, color: iconColor),
                        const SizedBox(width: 12),
                        Text('Manage Account', style: TextStyle(color: textColor)),
                      ],
                    );
                  },
                ),
              ),
              PopupMenuItem<String>(
                value: 'settings',
                child: Consumer(
                  builder: (context, ref, child) {
                    // Watch theme to rebuild when it changes
                    ref.watch(themeModeProvider);
                    final colorScheme = Theme.of(context).colorScheme;
                    final iconColor = colorScheme.onSurface;
                    final textColor = colorScheme.onSurface;
                    
                    return Row(
                      children: [
                        Icon(Icons.settings_outlined, size: 20, color: iconColor),
                        const SizedBox(width: 12),
                        Text('Settings', style: TextStyle(color: textColor)),
                      ],
                    );
                  },
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'signout',
                child: Row(
                  children: [
                    Icon(
                      Icons.logout_outlined,
                      size: 20,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Sign Out',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ];
          },
          onSelected: (value) async {
            switch (value) {
              case 'profile':
                // Navigate to profile or open Clerk profile
                _openClerkProfile(context);
                break;
              case 'account':
                // Open account management
                _openClerkProfile(context);
                break;
              case 'settings':
                // Navigate to app settings
                break;
              case 'theme':
                // Theme toggle is handled by the Switch widget
                break;
              case 'signout':
                // Sign out
                await _signOut(context);
                break;
            }
          },
        );
      },
    );
  }
  
  Widget _buildFallback(BuildContext context, String initials) {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w600,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }
  
  String _getInitials(clerk.User user) {
    if (user.firstName != null && user.lastName != null) {
      return '${user.firstName![0]}${user.lastName![0]}'.toUpperCase();
    } else if (user.firstName != null) {
      return user.firstName!.substring(0, 2).toUpperCase();
    } else if (user.username != null) {
      return user.username!.substring(0, 2).toUpperCase();
    }
    return 'U';
  }
  
  void _openClerkProfile(BuildContext context) {
    // Try to open Clerk's user profile if available
    // This would depend on Clerk Flutter SDK capabilities
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile management coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  Future<void> _signOut(BuildContext context) async {
    try {
      final shouldSignOut = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        ),
      );
      
      if (shouldSignOut == true && context.mounted) {
        await ClerkAuth.of(context).signOut();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign out: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

class _ThemeSelector extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeSelector({
    required this.themeMode,
    required this.onChanged,
  });

  @override
  State<_ThemeSelector> createState() => _ThemeSelectorState();
}

class _ThemeSelectorState extends State<_ThemeSelector> {
  late ThemeMode _currentMode;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.themeMode;
  }

  @override
  void didUpdateWidget(_ThemeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.themeMode != widget.themeMode) {
      _currentMode = widget.themeMode;
    }
  }

  void _handleModeChange(ThemeMode mode) {
    setState(() {
      _currentMode = mode;
    });
    widget.onChanged(mode);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final selectedIndex = _currentMode == ThemeMode.system ? 0 
        : _currentMode == ThemeMode.light ? 1 
        : 2;

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: isDarkMode
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
            : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated circle indicator (cutout effect)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            left: selectedIndex * 40.0 + 6,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Options
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOption(
                context: context,
                icon: Icons.settings_suggest,
                isSelected: _currentMode == ThemeMode.system,
                onTap: () => _handleModeChange(ThemeMode.system),
              ),
              _buildOption(
                context: context,
                icon: Icons.light_mode,
                isSelected: _currentMode == ThemeMode.light,
                onTap: () => _handleModeChange(ThemeMode.light),
              ),
              _buildOption(
                context: context,
                icon: Icons.dark_mode,
                isSelected: _currentMode == ThemeMode.dark,
                onTap: () => _handleModeChange(ThemeMode.dark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 36,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}