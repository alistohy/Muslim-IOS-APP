import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:sidewallet/app.dart';
import 'package:sidewallet/shared/models/transaction_model.dart';
import 'package:sidewallet/shared/models/wallet_model.dart';
import 'package:sidewallet/features/transactions/transaction_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Hive.initFlutter();
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(WalletAdapter());
  await Hive.openBox<Transaction>(transactionBoxName);
  await Hive.openBox<Wallet>('wallets');

  runApp(
    const ProviderScope(
      child: SideWalletApp(),
    ),
  );
}
