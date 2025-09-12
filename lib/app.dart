import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pavo_flutter/core/config/env_config.dart';
import 'package:pavo_flutter/core/theme/app_theme.dart';
import 'package:pavo_flutter/core/theme/theme_provider.dart';
import 'package:pavo_flutter/features/dashboard/screens/dashboard_with_tabs.dart';

class PavoApp extends ConsumerWidget {
  const PavoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return ClerkAuth(
      config: ClerkAuthConfig(
        publishableKey: EnvConfig.clerkPublishableKey,
      ),
      child: MaterialApp(
        title: 'PAVO',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: ClerkAuthBuilder(
            signedInBuilder: (context, authState) => const DashboardWithTabs(),
            signedOutBuilder: (context, authState) => const ClerkAuthentication(),
          ),
        ),
      ),
    );
  }
}