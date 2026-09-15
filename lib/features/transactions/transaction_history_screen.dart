import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sidewallet/features/transactions/transaction_provider.dart';
import 'package:sidewallet/shared/models/transaction_model.dart';

// --- Filter Enum -------------------------------------------------------------
enum _Filter { all, income, expense, thisMonth, lastMonth }

extension _FilterLabel on _Filter {
  String get label {
    switch (this) {
      case _Filter.all:       return 'All';
      case _Filter.income:    return 'Income';
      case _Filter.expense:   return 'Expense';
      case _Filter.thisMonth: return 'This Month';
      case _Filter.lastMonth: return 'Last Month';
    }
  }
}

// --- Category Helpers ---------------------------------------------------------
IconData _categoryIcon(String cat) {
  switch (cat.toLowerCase()) {
    case 'food':          return Icons.restaurant_rounded;
    case 'transport':     return Icons.directions_car_rounded;
    case 'shopping':      return Icons.shopping_bag_rounded;
    case 'health':        return Icons.favorite_rounded;
    case 'entertainment': return Icons.movie_rounded;
    case 'salary':        return Icons.work_rounded;
    default:              return Icons.category_rounded;
  }
}

Color _categoryColor(String cat) {
  switch (cat.toLowerCase()) {
    case 'food':          return const Color(0xFFFF8C42);
    case 'transport':     return const Color(0xFF4FC3F7);
    case 'shopping':      return const Color(0xFFCC44FF);
    case 'health':        return const Color(0xFFFF4466);
    case 'entertainment': return const Color(0xFF00E5FF);
    case 'salary':        return const Color(0xFF00FF88);
    default:              return const Color(0xFF9E9E9E);
  }
}

// --- Screen -------------------------------------------------------------------
class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {

  static const _darkBg   = Color(0xFF0A0E1A);
  static const _darkCard = Color(0xFF131929);
  static const _cyan     = Color(0xFF00E5FF);
  static const _success  = Color(0xFF00FF88);
  static const _error    = Color(0xFFFF4466);

  _Filter _activeFilter = _Filter.all;
  String  _searchQuery  = '';
  final   _searchCtrl   = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // -- Filter + search logic -------------------------------------------------
  List<Transaction> _applyFilters(List<Transaction> all) {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    var list = all.where((t) {
      switch (_activeFilter) {
        case _Filter.all:       return true;
        case _Filter.income:    return t.isIncome;
        case _Filter.expense:   return !t.isIncome;
        case _Filter.thisMonth:
          return t.date.year == now.year && t.date.month == now.month;
        case _Filter.lastMonth:
          final lm = DateTime(now.year, now.month - 1);
          return t.date.year == lm.year && t.date.month == lm.month;
      }
    }).toList();

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((t) =>
        t.title.toLowerCase().contains(q) ||
        t.category.toLowerCase().contains(q)).toList();
    }

    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  // -- Group by date ---------------------------------------------------------
  Map<String, List<Transaction>> _groupByDate(List<Transaction> list) {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yest  = today.subtract(const Duration(days: 1));
    final groups = <String, List<Transaction>>{};

    for (final t in list) {
      final d   = DateTime(t.date.year, t.date.month, t.date.day);
      String key;
      if (d == today)    key = 'Today';
      else if (d == yest) key = 'Yesterday';
      else               key = DateFormat('MMMM d, yyyy').format(t.date);

      groups.putIfAbsent(key, () => []).add(t);
    }
    return groups;
  }

  // -- Build -----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(transactionProvider);

    return Scaffold(
      backgroundColor: _darkBg,
      appBar: AppBar(
        backgroundColor: _darkBg,
        elevation: 0,
        title: const Text(
          'History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 12),
                _buildFilterChips(),
              ],
            ),
          ),
                    Expanded(
            child: Builder(
              builder: (context) {
                final all = txAsync;
                final filtered = _applyFilters(all);
                if (filtered.isEmpty) return _buildEmptyState();
                final grouped = _groupByDate(filtered);
                return _buildGroupedList(grouped, all);
              },
            ),
          ),
        ],
      ),
    );
  }

  // -- Search ----------------------------------------------------------------
  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: _darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: _searchCtrl,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Search transactions...',
          hintStyle: const TextStyle(color: Colors.white30, fontSize: 15),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.white38, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, color: Colors.white38, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  // -- Filter Chips ----------------------------------------------------------
  Widget _buildFilterChips() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _Filter.values.map((f) {
          final active = _activeFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _activeFilter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: active
                      ? const LinearGradient(
                          colors: [Color(0xFF00E5FF), Color(0xFFCC44FF)],
                        )
                      : null,
                  color: active ? null : _darkCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active ? Colors.transparent : Colors.white12,
                  ),
                ),
                child: Text(
                  f.label,
                  style: TextStyle(
                    color: active ? Colors.white : Colors.white54,
                    fontSize: 13,
                    fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // -- Grouped List ----------------------------------------------------------
  Widget _buildGroupedList(
      Map<String, List<Transaction>> groups,
      List<Transaction> allTx) {
    final sections = groups.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: sections.length,
      itemBuilder: (_, si) {
        final section = sections[si];
        final label   = section.key;
        final items   = section.value;
        final dayTotal = items.fold<double>(
          0,
          (sum, t) => sum + (t.isIncome ? t.amount : -t.amount),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      )),
                  Text(
                    '${dayTotal >= 0 ? '+' : ''}\$${dayTotal.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      color: dayTotal >= 0 ? _success : _error,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ...items.map((t) => _buildTransactionTile(t, allTx)),
          ],
        );
      },
    );
  }

  // -- Transaction Tile with Swipe-to-Dismiss --------------------------------
  Widget _buildTransactionTile(
      Transaction t, List<Transaction> allTx) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: Key(t.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: _error.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_rounded, color: _error, size: 26),
        ),
        confirmDismiss: (_) async {
          return await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: _darkCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Delete Transaction',
                  style: TextStyle(color: Colors.white)),
              content: Text(
                'Are you sure you want to delete "${t.title}"?',
                style: const TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Delete', style: TextStyle(color: _error)),
                ),
              ],
            ),
          ) ?? false;
        },
        onDismissed: (_) {
          ref.read(transactionProvider.notifier).deleteTransaction(t.id);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Deleted "${t.title}"',
                style: const TextStyle(color: Colors.white)),
            backgroundColor: _error.withOpacity(0.85),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _categoryColor(t.category).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_categoryIcon(t.category),
                    color: _categoryColor(t.category), size: 22),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _categoryColor(t.category).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            t.category,
                            style: TextStyle(
                              color: _categoryColor(t.category),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('h:mm a').format(t.date),
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Amount
              Text(
                '${t.isIncome ? '+' : '-'}\$${t.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: t.isIncome ? _success : _error,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -- Empty State -----------------------------------------------------------
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: _darkCard,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white10, width: 2),
            ),
            child: const Icon(Icons.receipt_long_rounded,
                color: Colors.white24, size: 44),
          ),
          const SizedBox(height: 20),
          const Text('No transactions found',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Add your first transaction\nto get started',
            style: const TextStyle(color: Colors.white38, fontSize: 14, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
