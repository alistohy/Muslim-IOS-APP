import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

// -- Category meta -------------------------------------------------------------
class _CatMeta {
  final String emoji;
  final Color color;
  const _CatMeta(this.emoji, this.color);
}

const _catMeta = <String, _CatMeta>{
  'food':          _CatMeta('??', Color(0xFFFF9800)),
  'transport':     _CatMeta('??', Color(0xFF2196F3)),
  'shopping':      _CatMeta('???', Color(0xFFCC44FF)),
  'health':        _CatMeta('??', Color(0xFFFF4466)),
  'entertainment': _CatMeta('??', Color(0xFF00E5FF)),
  'salary':        _CatMeta('??', Color(0xFF00FF88)),
  'other':         _CatMeta('??', Color(0xFF9E9E9E)),
};

// -----------------------------------------------------------------------------
/// Reusable transaction list tile.
///
/// Usage:
/// ```dart
/// TransactionTile(transaction: tx)
/// TransactionTile(transaction: tx, onTap: () { ... })
/// ```
class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final meta = _catMeta[transaction.category] ??
        const _CatMeta('??', Color(0xFF9E9E9E));
    final isIncome = transaction.type == TransactionType.income;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF131929),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (isIncome
                  ? const Color(0xFF00FF88)
                  : const Color(0xFFFF4466))
              .withOpacity(0.12),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(14),
          splashColor: const Color(0xFF00E5FF).withOpacity(0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // -- Category avatar -------------------------------------
                _CategoryAvatar(meta: meta),
                const SizedBox(width: 14),

                // -- Title + date ----------------------------------------
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            _formatDate(transaction.date),
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _CategoryChip(meta: meta, category: transaction.category),
                        ],
                      ),
                    ],
                  ),
                ),

                // -- Amount ----------------------------------------------
                _AmountBadge(
                  amount: transaction.amount,
                  isIncome: isIncome,
                  currency: transaction.currency,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today, ${DateFormat('HH:mm').format(date)}';
    if (diff.inDays == 1) return 'Yesterday, ${DateFormat('HH:mm').format(date)}';
    if (diff.inDays < 7) return DateFormat('EEEE').format(date);
    return DateFormat('dd MMM yyyy').format(date);
  }
}

// -- Category Avatar -----------------------------------------------------------
class _CategoryAvatar extends StatelessWidget {
  final _CatMeta meta;
  const _CategoryAvatar({required this.meta});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: meta.color.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: meta.color.withOpacity(0.4), width: 1.5),
      ),
      child: Center(
        child: Text(
          meta.emoji,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

// -- Category chip -------------------------------------------------------------
class _CategoryChip extends StatelessWidget {
  final _CatMeta meta;
  final String category;
  const _CategoryChip({required this.meta, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: meta.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _cap(category),
        style: TextStyle(
          color: meta.color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// -- Amount Badge --------------------------------------------------------------
class _AmountBadge extends StatelessWidget {
  final double amount;
  final bool isIncome;
  final String currency;

  const _AmountBadge({
    required this.amount,
    required this.isIncome,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isIncome ? const Color(0xFF00FF88) : const Color(0xFFFF4466);
    final prefix = isIncome ? '+' : '-';
    final formatted = _formatAmount(amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$prefix$currency $formatted',
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: 32,
          height: 2,
          decoration: BoxDecoration(
            color: color.withOpacity(0.4),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }

  String _formatAmount(double val) {
    if (val >= 1000000) return '${(val / 1000000).toStringAsFixed(2)}M';
    if (val >= 1000) return '${(val / 1000).toStringAsFixed(1)}k';
    return val.toStringAsFixed(2);
  }
}
