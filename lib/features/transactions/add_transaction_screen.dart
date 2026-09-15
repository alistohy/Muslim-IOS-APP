import 'package:flutter/material.dart';
import 'package:sidewallet/shared/models/wallet_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sidewallet/features/transactions/transaction_provider.dart';
import 'package:sidewallet/features/wallet/wallet_provider.dart';
import 'package:sidewallet/shared/models/transaction_model.dart';

// --- Category Model -----------------------------------------------------------
class _CategoryItem {
  final String label;
  final IconData icon;
  final Color color;
  const _CategoryItem(this.label, this.icon, this.color);
}

const List<_CategoryItem> _categories = [
  _CategoryItem('Food',          Icons.restaurant_rounded,      Color(0xFFFF8C42)),
  _CategoryItem('Transport',     Icons.directions_car_rounded,  Color(0xFF4FC3F7)),
  _CategoryItem('Shopping',      Icons.shopping_bag_rounded,    Color(0xFFCC44FF)),
  _CategoryItem('Health',        Icons.favorite_rounded,        Color(0xFFFF4466)),
  _CategoryItem('Entertainment', Icons.movie_rounded,           Color(0xFF00E5FF)),
  _CategoryItem('Salary',        Icons.work_rounded,            Color(0xFF00FF88)),
  _CategoryItem('Other',         Icons.category_rounded,        Color(0xFF9E9E9E)),
];

// --- Screen -------------------------------------------------------------------
class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen>
    with SingleTickerProviderStateMixin {

  // Controllers
  final _formKey    = GlobalKey<FormState>();
  final _titleCtrl  = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl   = TextEditingController();

  // State
  bool        _isIncome     = false;
  int         _categoryIdx  = 0;
  DateTime    _selectedDate = DateTime.now();
  String?     _selectedWalletId;

  // Animation
  late AnimationController _toggleAnim;
  late Animation<double>   _slideAnim;

  // -- Colors ----------------------------------------------------------------
  static const _darkBg    = Color(0xFF0A0E1A);
  static const _darkCard  = Color(0xFF131929);
  static const _cyan      = Color(0xFF00E5FF);
  static const _purple    = Color(0xFFCC44FF);
  static const _success   = Color(0xFF00FF88);
  static const _error     = Color(0xFFFF4466);

  @override
  void initState() {
    super.initState();
    _toggleAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _toggleAnim, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _toggleAnim.dispose();
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  // -- Helpers ---------------------------------------------------------------
  void _setType(bool income) {
    if (_isIncome == income) return;
    setState(() => _isIncome = income);
    income ? _toggleAnim.reverse() : _toggleAnim.forward();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: _cyan,
            onPrimary: _darkBg,
            surface: _darkCard,
            onSurface: Colors.white,
          ),
          dialogBackgroundColor: _darkCard,
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWalletId == null) {
      _showSnack('Please select a wallet', _error);
      return;
    }

    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;
    if (amount <= 0) {
      _showSnack('Enter a valid amount', _error);
      return;
    }

    final cat = _categories[_categoryIdx];
    final tx = Transaction(
      id:         DateTime.now().millisecondsSinceEpoch.toString(),
      title:      _titleCtrl.text.trim(),
      amount:     amount,
      isIncome:   _isIncome,
      category:   cat.label,
      date:       _selectedDate,
      note:       _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      walletId:   _selectedWalletId!,
    );

    await ref.read(transactionProvider.notifier).addTransaction(tx);
    if (mounted) {
      _showSnack('Transaction saved!', _success);
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: color.withOpacity(0.9),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  // -- Build -----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletProvider);

    return Scaffold(
      backgroundColor: _darkBg,
      appBar: AppBar(
        backgroundColor: _darkBg,
        elevation: 0,
        title: const Text(
          'Add Transaction',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildToggleRow(),
                const SizedBox(height: 28),
                _buildAmountField(),
                const SizedBox(height: 20),
                _buildTitleField(),
                const SizedBox(height: 20),
                _buildCategorySection(),
                const SizedBox(height: 20),
                _buildDateField(),
                const SizedBox(height: 20),
                _buildNoteField(),
                const SizedBox(height: 20),
                _buildWalletSelector(wallets),
                const SizedBox(height: 32),
                _buildSaveButton(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -- Toggle Income / Expense -----------------------------------------------
  Widget _buildToggleRow() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: _darkCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: AnimatedBuilder(
        animation: _slideAnim,
        builder: (_, __) {
          return Stack(
            children: [
              // Sliding indicator
              AnimatedAlign(
                alignment: _isIncome ? Alignment.centerLeft : Alignment.centerRight,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Container(
                  width: MediaQuery.of(context).size.width / 2 - 20,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isIncome
                          ? [_success.withOpacity(0.8), _success.withOpacity(0.5)]
                          : [_error.withOpacity(0.8), _error.withOpacity(0.5)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _setType(true),
                      child: Container(
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_downward_rounded,
                                color: _isIncome ? Colors.white : Colors.white38, size: 18),
                            const SizedBox(width: 6),
                            Text('INCOME',
                                style: TextStyle(
                                  color: _isIncome ? Colors.white : Colors.white38,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 1.2,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _setType(false),
                      child: Container(
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_upward_rounded,
                                color: !_isIncome ? Colors.white : Colors.white38, size: 18),
                            const SizedBox(width: 6),
                            Text('EXPENSE',
                                style: TextStyle(
                                  color: !_isIncome ? Colors.white : Colors.white38,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 1.2,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // -- Amount ----------------------------------------------------------------
  Widget _buildAmountField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (_isIncome ? _success : _error).withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AMOUNT',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('\$',
                  style: TextStyle(
                    color: _isIncome ? _success : _error,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  )),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _amountCtrl,
                  style: TextStyle(
                    color: _isIncome ? _success : _error,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.00',
                    hintStyle: TextStyle(color: Colors.white24, fontSize: 36),
                    contentPadding: EdgeInsets.zero,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Amount is required';
                    final n = double.tryParse(v);
                    if (n == null || n <= 0) return 'Enter a valid amount';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -- Title -----------------------------------------------------------------
  Widget _buildTitleField() {
    return _inputContainer(
      label: 'TITLE',
      child: TextFormField(
        controller: _titleCtrl,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Transaction title',
          hintStyle: TextStyle(color: Colors.white30),
          contentPadding: EdgeInsets.zero,
        ),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
      ),
    );
  }

  // -- Category --------------------------------------------------------------
  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('CATEGORY',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            )),
        const SizedBox(height: 12),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final cat      = _categories[i];
              final selected = _categoryIdx == i;
              return GestureDetector(
                onTap: () => setState(() => _categoryIdx = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 72,
                  decoration: BoxDecoration(
                    color: selected ? cat.color.withOpacity(0.2) : _darkCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected ? cat.color : Colors.white12,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(cat.icon, color: cat.color, size: 26),
                      const SizedBox(height: 6),
                      Text(
                        cat.label,
                        style: TextStyle(
                          color: selected ? cat.color : Colors.white54,
                          fontSize: 10,
                          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // -- Date ------------------------------------------------------------------
  Widget _buildDateField() {
    return GestureDetector(
      onTap: _pickDate,
      child: _inputContainer(
        label: 'DATE',
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const Icon(Icons.calendar_today_rounded, color: _cyan, size: 20),
          ],
        ),
      ),
    );
  }

  // -- Note ------------------------------------------------------------------
  Widget _buildNoteField() {
    return _inputContainer(
      label: 'NOTE (OPTIONAL)',
      child: TextFormField(
        controller: _noteCtrl,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        maxLines: 3,
        minLines: 1,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Add a note...',
          hintStyle: TextStyle(color: Colors.white30),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  // -- Wallet Selector -------------------------------------------------------
  Widget _buildWalletSelector(List<Wallet> wallets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('WALLET',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            )),
        const SizedBox(height: 12),
        Builder(builder: (context) {
            if (wallets.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF131929),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'No wallets found.',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: wallets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final w = wallets[i];
                final isSelected = w.id == _selectedWalletId;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedWalletId = w.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131929),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF00E5FF) : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.account_balance_wallet,
                              color: Color(0xFF00E5FF), size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                w.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\ ',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle,
                              color: Color(0xFF00E5FF)),
                      ],
                    ),
                  ),
                );
              },
            );
        }),
      ],
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _save,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_cyan, _purple],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _cyan.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          'SAVE TRANSACTION',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  // -- Input Container Helper ------------------------------------------------
  Widget _inputContainer({required String label, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: _darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 11,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
