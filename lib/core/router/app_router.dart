import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/splash_screen.dart';
import '../../core/auth/biometric_auth_screen.dart';
import '../../features/home/dashboard_screen.dart';
import '../../features/wallet/wallet_screen.dart';
import '../../features/transactions/transaction_history_screen.dart';
import '../../features/charts/charts_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/transactions/add_transaction_screen.dart';
import '../../shared/widgets/main_scaffold.dart';

abstract class AppRoutes {
  static const splash        = '/splash';
  static const auth          = '/auth';
  static const home          = '/home';
  static const dashboard     = '/home/dashboard';
  static const wallet        = '/home/wallet';
  static const history       = '/home/history';
  static const charts        = '/home/charts';
  static const settings      = '/home/settings';
  static const addTransaction = '/add-transaction';
}

final rootNavigatorKey  = GlobalKey<NavigatorState>(debugLabel: 'root');
final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey:    rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path:    AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path:    AppRoutes.auth,
        builder: (_, __) => const BiometricAuthScreen(),
      ),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (_, __, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: AppRoutes.wallet,
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: WalletScreen()),
          ),
          GoRoute(
            path: AppRoutes.history,
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: TransactionHistoryScreen()),
          ),
          GoRoute(
            path: AppRoutes.charts,
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: ChartsScreen()),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: SettingsScreen()),
          ),
        ],
      ),
      GoRoute(
        path:            AppRoutes.addTransaction,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, __) => const AddTransactionScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFF00E5FF), size: 64),
            const SizedBox(height: 16),
            Text('Page not found',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.white)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.splash),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
