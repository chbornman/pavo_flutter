import 'package:cached_network_image/cached_network_image.dart';
import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';

class CustomUserButton extends StatelessWidget {
  final double size;
  
  const CustomUserButton({
    super.key,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
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
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'profile',
              child: Row(
                children: [
                  const Icon(Icons.person_outline, size: 20),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim().isEmpty 
                            ? user.username ?? 'User'
                            : '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim(),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      if (user.emailAddresses?.isNotEmpty == true)
                        Text(
                          user.emailAddresses!.first.emailAddress,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'account',
              child: Row(
                children: const [
                  Icon(Icons.manage_accounts_outlined, size: 20),
                  SizedBox(width: 12),
                  Text('Manage Account'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'settings',
              child: Row(
                children: const [
                  Icon(Icons.settings_outlined, size: 20),
                  SizedBox(width: 12),
                  Text('Settings'),
                ],
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
          ],
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
        await ClerkAuth.of(context)?.signOut();
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