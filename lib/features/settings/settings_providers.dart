import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Currency Provider ─────────────────────────────────────────────────────────
class CurrencyNotifier extends StateNotifier<String> {
  CurrencyNotifier() : super('EGP') {
    _load();
  }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('currency') ?? 'EGP';
  }
  Future<void> setCurrency(String currency) async {
    state = currency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency);
  }
}

final currencyProvider = StateNotifierProvider<CurrencyNotifier, String>(
  (ref) => CurrencyNotifier(),
);

// ── Biometric Provider ────────────────────────────────────────────────────────
class BiometricNotifier extends StateNotifier<bool> {
  BiometricNotifier() : super(true) {
    _load();
  }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('biometric_enabled') ?? true;
  }
  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', state);
  }
}

final biometricProvider = StateNotifierProvider<BiometricNotifier, bool>(
  (ref) => BiometricNotifier(),
);

// ── Budget Alerts Provider ────────────────────────────────────────────────────
class BudgetAlertsNotifier extends StateNotifier<bool> {
  BudgetAlertsNotifier() : super(true) {
    _load();
  }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('budget_alerts') ?? true;
  }
  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('budget_alerts', state);
  }
}

final budgetAlertsProvider = StateNotifierProvider<BudgetAlertsNotifier, bool>(
  (ref) => BudgetAlertsNotifier(),
);

// ── Transaction Alerts Provider ───────────────────────────────────────────────
class TransactionAlertsNotifier extends StateNotifier<bool> {
  TransactionAlertsNotifier() : super(true) {
    _load();
  }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('transaction_alerts') ?? true;
  }
  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('transaction_alerts', state);
  }
}

final transactionAlertsProvider =
    StateNotifierProvider<TransactionAlertsNotifier, bool>(
  (ref) => TransactionAlertsNotifier(),
);
