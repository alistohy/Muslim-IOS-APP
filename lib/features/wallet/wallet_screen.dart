import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/models/wallet_model.dart';
import '../../shared/models/transaction_model.dart';
import '../../shared/widgets/circuit_background.dart';
import '../transactions/transaction_provider.dart';
import 'wallet_provider.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallets = ref.watch(walletProvider);
    final selectedIndex = ref.watch(selectedWalletIndexProvider);
    final transactions = ref.watch(transactionsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currencyFormat = NumberFormat('#,##0.00');

    return CircuitBackground(
      isDark: isDark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('My Wallets'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddWalletSheet(context, ref),
            ),
          ],
        ),
        body: wallets.isEmpty
            ? _buildEmpty(context)
            : Column(
                children: [
                  // Wallet cards PageView
                  SizedBox(
                    height: 200,
                    child: PageView.builder(
                      itemCount: wallets.length,
                      onPageChanged: (i) =>
                          ref.read(selectedWalletIndexProvider.notifier).state = i,
                      itemBuilder: (ctx, i) =>
                          _WalletCard(wallet: wallets[i], currencyFormat: currencyFormat),
                    ),
                  ),
                  // Dots indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      wallets.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        width: i == selectedIndex ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == selectedIndex
                              ? AppColors.primary
                              : AppColors.primary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Stats row
                  _buildStatsRow(context, ref, currencyFormat),
                  const SizedBox(height: 16),
                  // Recent transactions for selected wallet
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Activity',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () => context.go('/home/history'),
                          child: Text('See All',
                              style: TextStyle(color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _buildTransactionList(
                      context,
                      transactions
                          .where((t) =>
                              wallets.isNotEmpty &&
                              t.walletId == wallets[selectedIndex.clamp(0, wallets.length - 1)].id)
                          .take(10)
                          .toList(),
                      currencyFormat,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 80, color: AppColors.primary.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text('No wallets yet'),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Add Wallet'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(
      BuildContext context, WidgetRef ref, NumberFormat fmt) {
    final income = ref.watch(totalIncomeProvider);
    final expense = ref.watch(totalExpenseProvider);
    final total = ref.watch(totalAssetsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _StatCard(label: 'Total Assets', value: 'EGP ${fmt.format(total)}',
              color: AppColors.primary),
          const SizedBox(width: 8),
          _StatCard(label: 'Income', value: 'EGP ${fmt.format(income)}',
              color: AppColors.success),
          const SizedBox(width: 8),
          _StatCard(label: 'Expenses', value: 'EGP ${fmt.format(expense)}',
              color: AppColors.error),
        ],
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context,
      List<Transaction> txns, NumberFormat fmt) {
    if (txns.isEmpty) {
      return Center(
        child: Text('No transactions yet',
            style: TextStyle(color: AppColors.textSecondary)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: txns.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final t = txns[i];
        return _TxTile(transaction: t, fmt: fmt);
      },
    );
  }

  void _showAddWalletSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddWalletSheet(ref: ref),
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({required this.wallet, required this.currencyFormat});
  final Wallet wallet;
  final NumberFormat currencyFormat;

  @override
  Widget build(BuildContext context) {
    final color = _hexColor(wallet.color);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.9), AppColors.secondary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(wallet.name,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const Icon(Icons.account_balance_wallet, color: Colors.white70),
              ],
            ),
            const Spacer(),
            Text('${wallet.currency} ${currencyFormat.format(wallet.balance)}',
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Available Balance',
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Color _hexColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primary;
    }
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  const _TxTile({required this.transaction, required this.fmt});
  final Transaction transaction;
  final NumberFormat fmt;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkCardBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: _categoryColor(transaction.category).withOpacity(0.2),
            child: Icon(_categoryIcon(transaction.category),
                color: _categoryColor(transaction.category), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(transaction.category,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'} EGP ${fmt.format(transaction.amount)}',
            style: TextStyle(
                color: isIncome ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.bold,
                fontSize: 13),
          ),
        ],
      ),
    );
  }

  Color _categoryColor(String cat) {
    const map = {
      'food': Color(0xFFFF9800), 'transport': Color(0xFF2196F3),
      'shopping': Color(0xFF9C27B0), 'health': Color(0xFFF44336),
      'entertainment': Color(0xFF00E5FF), 'salary': Color(0xFF00FF88),
    };
    return map[cat.toLowerCase()] ?? AppColors.textSecondary;
  }

  IconData _categoryIcon(String cat) {
    const map = {
      'food': Icons.restaurant, 'transport': Icons.directions_car,
      'shopping': Icons.shopping_bag, 'health': Icons.favorite,
      'entertainment': Icons.games, 'salary': Icons.attach_money,
    };
    return map[cat.toLowerCase()] ?? Icons.category;
  }
}

class _AddWalletSheet extends StatefulWidget {
  const _AddWalletSheet({required this.ref});
  final WidgetRef ref;

  @override
  State<_AddWalletSheet> createState() => _AddWalletSheetState();
}

class _AddWalletSheetState extends State<_AddWalletSheet> {
  final _nameCtrl = TextEditingController();
  String _currency = 'EGP';
  String _color = '#00E5FF';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add New Wallet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Wallet Name'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _currency,
            decoration: const InputDecoration(labelText: 'Currency'),
            items: ['EGP', 'USD', 'EUR', 'GBP']
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _currency = v!),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_nameCtrl.text.isNotEmpty) {
                widget.ref.read(walletProvider.notifier).addWallet(
                      Wallet(
                          id: '', name: _nameCtrl.text,
                          balance: 0, currency: _currency,
                          color: _color, icon: 'wallet'),
                    );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: const Text('Create Wallet'),
          ),
        ],
      ),
    );
  }
}
