import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sidewallet/core/router/app_router.dart';
import 'package:sidewallet/core/theme/app_theme.dart';
import 'package:sidewallet/core/theme/theme_provider.dart';

class SideWalletApp extends ConsumerWidget {
  const SideWalletApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'SideWallet',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
