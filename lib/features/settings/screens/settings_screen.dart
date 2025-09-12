import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pavo_flutter/core/constants/app_constants.dart';
import 'package:pavo_flutter/features/auth/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          if (authState is AuthAuthenticated) ...[
            Container(
              padding: const EdgeInsets.all(AppConstants.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  const Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('U'),
                      ),
                      title: Text('User Account'),
                      subtitle: Text('Signed in'),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Container(
            padding: const EdgeInsets.all(AppConstants.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Services',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.photo_library_outlined),
                        title: const Text('Immich Server'),
                        subtitle: const Text('Configure photo and video backup'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.description_outlined),
                        title: const Text('Paperless-ngx Server'),
                        subtitle: const Text('Configure document management'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.play_circle_outline),
                        title: const Text('Jellyfin Server'),
                        subtitle: const Text('Configure media streaming'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppConstants.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text('About PAVO'),
                        subtitle: const Text('Version 1.0.0'),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.code),
                        title: const Text('Open Source Licenses'),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (authState is AuthAuthenticated) ...[
            Container(
              padding: const EdgeInsets.all(AppConstants.padding),
              child: FilledButton.tonal(
                onPressed: () async {
                  await ref.read(authProvider.notifier).signOut();
                  if (context.mounted) {
                    context.go('/signin');
                  }
                },
                child: const Text('Sign Out'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}