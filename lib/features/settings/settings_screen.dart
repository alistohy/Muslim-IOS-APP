import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sidewallet/core/theme/theme_provider.dart';
import 'package:sidewallet/features/settings/settings_providers.dart';
import 'package:sidewallet/features/settings/settings_providers.dart';
import 'package:sidewallet/features/settings/settings_providers.dart';
import 'package:sidewallet/features/transactions/transaction_provider.dart';

// -----------------------------------------------------------------------------
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final currency = ref.watch(currencyProvider);
    final biometric = ref.watch(biometricProvider);
    final budgetAlerts = ref.watch(budgetAlertsProvider);
    final txAlerts = ref.watch(transactionAlertsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131929),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Color(0xFF00E5FF),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // -- Appearance --------------------------------------------------
          _SettingsGroup(
            title: 'APPEARANCE',
            icon: Icons.palette_outlined,
            children: [
              _SettingsTile(
                icon: isDark ? Icons.dark_mode : Icons.light_mode,
                iconColor: const Color(0xFFCC44FF),
                title: 'Dark Mode',
                subtitle: isDark ? 'Dark theme enabled' : 'Light theme enabled',
                trailing: Switch(
                  value: isDark,
                  activeColor: const Color(0xFF00E5FF),
                  onChanged: (val) {
                    ref.read(themeModeProvider.notifier).setMode(
                        val ? ThemeMode.dark : ThemeMode.light);
                  },
                ),
              ),
              _SettingsTile(
                icon: Icons.currency_exchange,
                iconColor: const Color(0xFF00E5FF),
                title: 'Currency',
                subtitle: _currencyLabel(currency),
                trailing: DropdownButton<String>(
                  value: currency,
                  dropdownColor: const Color(0xFF131929),
                  underline: const SizedBox.shrink(),
                  style: const TextStyle(color: Color(0xFF00E5FF)),
                  items: const [
                    DropdownMenuItem(value: 'EGP', child: Text('EGP')),
                    DropdownMenuItem(value: 'USD', child: Text('USD')),
                    DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                    DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(currencyProvider.notifier).setCurrency(val);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // -- Security ----------------------------------------------------
          _SettingsGroup(
            title: 'SECURITY',
            icon: Icons.shield_outlined,
            children: [
              _SettingsTile(
                icon: Icons.fingerprint,
                iconColor: const Color(0xFF00FF88),
                title: 'Biometric Lock',
                subtitle:
                    biometric ? 'Fingerprint / Face ID enabled' : 'Disabled',
                trailing: Switch(
                  value: biometric,
                  activeColor: const Color(0xFF00E5FF),
                  onChanged: (val) {
                    ref.read(biometricProvider.notifier).toggle();
                  },
                ),
              ),
              _SettingsTile(
                icon: Icons.lock_outline,
                iconColor: const Color(0xFFFF4466),
                title: 'Change PIN',
                subtitle: 'Update your 4-digit PIN',
                trailing: const Icon(Icons.chevron_right,
                    color: Colors.white38),
                onTap: () => context.push('/change-pin'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // -- Notifications -----------------------------------------------
          _SettingsGroup(
            title: 'NOTIFICATIONS',
            icon: Icons.notifications_outlined,
            children: [
              _SettingsTile(
                icon: Icons.account_balance_wallet_outlined,
                iconColor: const Color(0xFFFF9800),
                title: 'Budget Alerts',
                subtitle: 'Notify when near budget limit',
                trailing: Switch(
                  value: budgetAlerts,
                  activeColor: const Color(0xFF00E5FF),
                  onChanged: (val) {
                    ref
                        .read(budgetAlertsProvider.notifier)
                        .toggle();
                  },
                ),
              ),
              _SettingsTile(
                icon: Icons.receipt_long_outlined,
                iconColor: const Color(0xFF00E5FF),
                title: 'Transaction Alerts',
                subtitle: 'Notify on each transaction',
                trailing: Switch(
                  value: txAlerts,
                  activeColor: const Color(0xFF00E5FF),
                  onChanged: (val) {
                    ref
                        .read(transactionAlertsProvider.notifier)
                        .toggle();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // -- Data --------------------------------------------------------
          _SettingsGroup(
            title: 'DATA',
            icon: Icons.storage_outlined,
            children: [
              _SettingsTile(
                icon: Icons.download_outlined,
                iconColor: const Color(0xFF00E5FF),
                title: 'Export CSV',
                subtitle: 'Download all transactions as CSV',
                trailing: const Icon(Icons.chevron_right,
                    color: Colors.white38),
                onTap: () => _exportCsv(context, ref),
              ),
              _SettingsTile(
                icon: Icons.delete_forever_outlined,
                iconColor: const Color(0xFFFF4466),
                title: 'Clear All Data',
                subtitle: 'Permanently delete all transactions',
                trailing: const Icon(Icons.chevron_right,
                    color: Colors.white38),
                onTap: () => _confirmClear(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // -- About --------------------------------------------------------
          _SettingsGroup(
            title: 'ABOUT',
            icon: Icons.info_outlined,
            children: [
              _AboutTile(),
              _SettingsTile(
                icon: Icons.code,
                iconColor: const Color(0xFFCC44FF),
                title: 'Version',
                subtitle: '1.0.0 � Build 1',
                trailing: const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _currencyLabel(String code) {
    const labels = {
      'EGP': 'Egyptian Pound (EGP)',
      'USD': 'US Dollar (USD)',
      'EUR': 'Euro (EUR)',
      'GBP': 'British Pound (GBP)',
    };
    return labels[code] ?? code;
  }

  void _exportCsv(BuildContext context, WidgetRef ref) {
    // In production, generate and share CSV via share_plus / path_provider
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export feature coming soon!'),
        backgroundColor: Color(0xFF131929),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131929),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFFF4466), width: 1)),
        title: const Text('Clear All Data',
            style: TextStyle(color: Color(0xFFFF4466))),
        content: const Text(
          'This will permanently delete ALL transactions and budgets. This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4466)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete All',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(transactionProvider.notifier).clearAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data cleared.'),
            backgroundColor: Color(0xFFFF4466),
          ),
        );
      }
    }
  }
}

// -- Settings Group Container --------------------------------------------------
class _SettingsGroup extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsGroup({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF00E5FF), size: 14),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF00E5FF),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF131929),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: const Color(0xFF00E5FF).withOpacity(0.1)),
          ),
          child: Column(
            children: children
                .asMap()
                .entries
                .map((e) => Column(
                      children: [
                        e.value,
                        if (e.key < children.length - 1)
                          Divider(
                            height: 1,
                            indent: 56,
                            color: Colors.white.withOpacity(0.05),
                          ),
                      ],
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

// -- Settings Tile -------------------------------------------------------------
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

// -- About Tile ----------------------------------------------------------------
class _AboutTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          // Metallic "S" logo
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00E5FF), Color(0xFFCC44FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'S',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SideWallet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Smart Finance Tracker',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
