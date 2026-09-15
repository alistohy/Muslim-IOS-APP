import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sidewallet_flutter/shared/models/transaction_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Box name constant
// ─────────────────────────────────────────────────────────────────────────────

/// Hive box name for transactions. Must be unique across all boxes.
const String transactionBoxName = 'transactions';

// ─────────────────────────────────────────────────────────────────────────────
// Low-level box provider
// ─────────────────────────────────────────────────────────────────────────────

/// Provides the open [Box<Transaction>].
/// The box **must** be opened (e.g. via [Hive.openBox]) before this provider
/// is first read — typically done in [main] during app initialisation.
final transactionBoxProvider = Provider<Box<Transaction>>((ref) {
  return Hive.box<Transaction>(transactionBoxName);
});

// ─────────────────────────────────────────────────────────────────────────────
// State notifier
// ─────────────────────────────────────────────────────────────────────────────

/// Manages CRUD operations on the transactions Hive box and exposes a reactive
/// [List<Transaction>] sorted by date descending.
class TransactionNotifier extends StateNotifier<List<Transaction>> {
  TransactionNotifier(this._box) : super(_sortedTransactions(_box));

  final Box<Transaction> _box;

  // ── helpers ────────────────────────────────────────────────────────────────

  static List<Transaction> _sortedTransactions(Box<Transaction> box) {
    final list = box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(list);
  }

  void _refresh() => state = _sortedTransactions(_box);

  // ── public API ─────────────────────────────────────────────────────────────

  /// Adds a new [transaction] to the Hive box.
  Future<void> addTransaction(Transaction transaction) async {
    await _box.put(transaction.id, transaction);
    _refresh();
  }

  /// Deletes the transaction identified by [id].
  Future<void> deleteTransaction(String id) async {
    await _box.delete(id);
    _refresh();
  }

  /// Updates an existing transaction.  The [updated] object must share the
  /// same [Transaction.id] as the persisted record.
  Future<void> updateTransaction(Transaction updated) async {
    await _box.put(updated.id, updated);
    _refresh();
  }

  /// Convenience: delete all transactions (useful for testing / reset flows).
  Future<void> clearAll() async {
    await _box.clear();
    _refresh();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Primary state provider
// ─────────────────────────────────────────────────────────────────────────────

/// Exposes the [TransactionNotifier] and the reactive list of transactions.
final transactionProvider =
    StateNotifierProvider<TransactionNotifier, List<Transaction>>((ref) {
  final box = ref.watch(transactionBoxProvider);
  return TransactionNotifier(box);
});

// ─────────────────────────────────────────────────────────────────────────────
// Convenience derived providers
// ─────────────────────────────────────────────────────────────────────────────

/// All transactions sorted by date descending.
final transactionsProvider = Provider<List<Transaction>>((ref) {
  return ref.watch(transactionProvider);
});

/// Sum of all income transactions.
final totalIncomeProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider);
  return transactions
      .where((t) => t.isIncome)
      .fold<double>(0.0, (sum, t) => sum + t.amount);
});

/// Sum of all expense transactions.
final totalExpenseProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider);
  return transactions
      .where((t) => !t.isIncome)
      .fold<double>(0.0, (sum, t) => sum + t.amount);
});

/// Net balance = total income − total expense.
final balanceProvider = Provider<double>((ref) {
  final income = ref.watch(totalIncomeProvider);
  final expense = ref.watch(totalExpenseProvider);
  return income - expense;
});

// ─────────────────────────────────────────────────────────────────────────────
// Per-wallet derived providers
// ─────────────────────────────────────────────────────────────────────────────

/// Returns all transactions belonging to a specific wallet.
final walletTransactionsProvider =
    Provider.family<List<Transaction>, String>((ref, walletId) {
  return ref
      .watch(transactionsProvider)
      .where((t) => t.walletId == walletId)
      .toList();
});

/// Returns transactions belonging to a specific wallet filtered by category.
final walletCategoryTransactionsProvider =
    Provider.family<List<Transaction>, ({String walletId, String category})>(
        (ref, params) {
  return ref
      .watch(walletTransactionsProvider(params.walletId))
      .where((t) => t.category == params.category)
      .toList();
});

// ─────────────────────────────────────────────────────────────────────────────
// Single-transaction lookup
// ─────────────────────────────────────────────────────────────────────────────

/// Finds a single [Transaction] by its [id], or returns `null` if not found.
final transactionByIdProvider =
    Provider.family<Transaction?, String>((ref, id) {
  try {
    return ref.watch(transactionsProvider).firstWhere((t) => t.id == id);
  } catch (_) {
    return null;
  }
});
