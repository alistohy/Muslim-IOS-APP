import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:sidewallet/shared/models/wallet_model.dart';

const walletBoxName = 'wallets';
const _uuid = Uuid();

// ── Box provider ─────────────────────────────────────────────────────────────
final walletBoxProvider = Provider<Box<Wallet>>(
  (ref) => Hive.box<Wallet>(walletBoxName),
);

// ── Notifier ──────────────────────────────────────────────────────────────────
class WalletNotifier extends StateNotifier<List<Wallet>> {
  WalletNotifier(this._box) : super(_box.values.toList()) {
    if (state.isEmpty) _createDefaultWallet();
  }

  final Box<Wallet> _box;

  void _createDefaultWallet() {
    final w = Wallet(
      id: _uuid.v4(),
      name: 'My Wallet',
      balance: 0,
      currency: 'EGP',
      color: '#00E5FF',
      icon: 'wallet',
    );
    _box.put(w.id, w);
    state = [w];
  }

  Future<void> addWallet(Wallet wallet) async {
    final w = wallet.copyWith(id: _uuid.v4());
    await _box.put(w.id, w);
    state = _box.values.toList();
  }

  Future<void> updateBalance(String walletId, double delta) async {
    final w = _box.get(walletId);
    if (w == null) return;
    final updated = w.copyWith(balance: w.balance + delta);
    await _box.put(walletId, updated);
    state = _box.values.toList();
  }

  Future<void> deleteWallet(String walletId) async {
    await _box.delete(walletId);
    state = _box.values.toList();
  }

  Future<void> clearAll() async {
    await _box.clear();
    state = [];
    _createDefaultWallet();
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────
final walletProvider = StateNotifierProvider<WalletNotifier, List<Wallet>>(
  (ref) => WalletNotifier(ref.watch(walletBoxProvider)),
);

final selectedWalletIndexProvider = StateProvider<int>((ref) => 0);

final selectedWalletProvider = Provider<Wallet?>((ref) {
  final wallets = ref.watch(walletProvider);
  final index = ref.watch(selectedWalletIndexProvider);
  if (wallets.isEmpty) return null;
  return wallets[index.clamp(0, wallets.length - 1)];
});

final totalAssetsProvider = Provider<double>((ref) {
  return ref.watch(walletProvider).fold(0, (sum, w) => sum + w.balance);
});
