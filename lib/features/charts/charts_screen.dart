import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sidewallet/features/transactions/transaction_provider.dart';
import 'package:sidewallet/shared/models/transaction_model.dart';

// -- Period enum ---------------------------------------------------------------
enum _Period { week, month, year }

// -- Provider for selected period ---------------------------------------------
final _periodProvider = StateProvider<_Period>((_) => _Period.month);

// -- Category meta -------------------------------------------------------------
const _categoryColors = {
  'food': Color(0xFFFF9800),
  'transport': Color(0xFF2196F3),
  'shopping': Color(0xFFCC44FF),
  'health': Color(0xFFFF4466),
  'entertainment': Color(0xFF00E5FF),
  'salary': Color(0xFF00FF88),
  'other': Color(0xFF9E9E9E),
};

// -----------------------------------------------------------------------------
class ChartsScreen extends ConsumerWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(_periodProvider);
    final allTx = ref.watch(transactionsProvider);
    final filtered = _filterByPeriod(allTx, period);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131929),
        title: const Text(
          'Reports & Analytics',
          style: TextStyle(
            color: Color(0xFF00E5FF),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PeriodSelector(period: period, ref: ref),
            const SizedBox(height: 20),
            _SummaryCards(transactions: filtered),
            const SizedBox(height: 20),
            _sectionTitle('Spending by Category'),
            const SizedBox(height: 12),
            _DonutChart(transactions: filtered),
            const SizedBox(height: 20),
            _sectionTitle('Income vs Expense'),
            const SizedBox(height: 12),
            _IncomeExpenseBar(transactions: filtered, period: period),
            const SizedBox(height: 20),
            _sectionTitle('Monthly Trend'),
            const SizedBox(height: 12),
            _MonthlyLineChart(transactions: allTx),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      );

  List<Transaction> _filterByPeriod(
      List<Transaction> txs, _Period period) {
    final now = DateTime.now();
    return txs.where((t) {
      final diff = now.difference(t.date);
      switch (period) {
        case _Period.week:
          return diff.inDays <= 7;
        case _Period.month:
          return diff.inDays <= 30;
        case _Period.year:
          return diff.inDays <= 365;
      }
    }).toList();
  }
}

// -- Period Selector -----------------------------------------------------------
class _PeriodSelector extends StatelessWidget {
  final _Period period;
  final WidgetRef ref;
  const _PeriodSelector({required this.period, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131929),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: _Period.values
            .map((p) => Expanded(child: _PeriodTab(p, period, ref)))
            .toList(),
      ),
    );
  }
}

class _PeriodTab extends StatelessWidget {
  final _Period value;
  final _Period selected;
  final WidgetRef ref;
  const _PeriodTab(this.value, this.selected, this.ref);

  String get _label {
    switch (value) {
      case _Period.week:
        return 'Week';
      case _Period.month:
        return 'Month';
      case _Period.year:
        return 'Year';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => ref.read(_periodProvider.notifier).state = value,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF00E5FF), Color(0xFF0097A7)],
                )
              : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            _label,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white54,
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

// -- Summary Cards -------------------------------------------------------------
class _SummaryCards extends StatelessWidget {
  final List<Transaction> transactions;
  const _SummaryCards({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final expenses =
        transactions.where((t) => !t.isIncome);
    final totalSpent =
        expenses.fold<double>(0, (s, t) => s + t.amount);
    final days = _uniqueDays(expenses.toList());
    final avgPerDay = days > 0 ? totalSpent / days : 0.0;

    final categoryCounts = <String, double>{};
    for (final t in expenses) {
      categoryCounts[t.category] =
          (categoryCounts[t.category] ?? 0) + t.amount;
    }
    final topCat = categoryCounts.entries.isEmpty
        ? 'N/A'
        : (categoryCounts.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .first
            .key;

    return Row(
      children: [
        _SummaryCard(
            label: 'Total Spent',
            value: 'EGP ${totalSpent.toStringAsFixed(0)}',
            icon: Icons.payments_outlined,
            color: const Color(0xFFFF4466)),
        const SizedBox(width: 8),
        _SummaryCard(
            label: 'Avg / Day',
            value: 'EGP ${avgPerDay.toStringAsFixed(0)}',
            icon: Icons.today_outlined,
            color: const Color(0xFF00E5FF)),
        const SizedBox(width: 8),
        _SummaryCard(
            label: 'Top Category',
            value: _capitalize(topCat),
            icon: Icons.category_outlined,
            color: const Color(0xFFCC44FF)),
      ],
    );
  }

  int _uniqueDays(List<Transaction> txs) {
    final set = <String>{};
    for (final t in txs) {
      set.add('${t.date.year}-${t.date.month}-${t.date.day}');
    }
    return set.isEmpty ? 1 : set.length;
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _SummaryCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF131929),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

// -- Donut Chart ---------------------------------------------------------------
class _DonutChart extends StatefulWidget {
  final List<Transaction> transactions;
  const _DonutChart({required this.transactions});

  @override
  State<_DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<_DonutChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final byCategory = <String, double>{};
    for (final t in widget.transactions
        .where((t) => !t.isIncome)) {
      byCategory[t.category] = (byCategory[t.category] ?? 0) + t.amount;
    }

    if (byCategory.isEmpty) {
      return _emptyState('No expense data for this period');
    }

    final total = byCategory.values.fold<double>(0, (a, b) => a + b);
    final sections = byCategory.entries.toList().asMap().entries.map((entry) {
      final idx = entry.key;
      final cat = entry.value.key;
      final val = entry.value.value;
      final color = _categoryColors[cat] ?? const Color(0xFF9E9E9E);
      final isTouched = idx == _touchedIndex;
      return PieChartSectionData(
        color: color,
        value: val,
        title: isTouched ? '${(val / total * 100).toStringAsFixed(1)}%' : '',
        radius: isTouched ? 80 : 65,
        titleStyle: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
        badgeWidget: isTouched
            ? null
            : null,
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131929),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFF00E5FF).withOpacity(0.15)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          response == null ||
                          response.touchedSection == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex =
                          response.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 3,
                centerSpaceRadius: 55,
                sections: sections,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: byCategory.entries.map((e) {
              final color = _categoryColors[e.key] ?? Colors.grey;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text(
                    '${_cap(e.key)} (${(e.value / total * 100).toStringAsFixed(0)}%)',
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 11),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// -- Income vs Expense Bar Chart -----------------------------------------------
class _IncomeExpenseBar extends StatelessWidget {
  final List<Transaction> transactions;
  final _Period period;
  const _IncomeExpenseBar(
      {required this.transactions, required this.period});

  @override
  Widget build(BuildContext context) {
    final groups = _buildGroups();
    if (groups.isEmpty) return _emptyState('No data for this period');

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF131929),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFFCC44FF).withOpacity(0.15)),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _maxY(groups),
          barGroups: groups,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.white.withOpacity(0.05),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (val, meta) => Text(
                  val >= 1000
                      ? '${(val / 1000).toStringAsFixed(0)}k'
                      : val.toStringAsFixed(0),
                  style:
                      const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  final labels = _groupLabels();
                  final idx = val.toInt();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      idx < labels.length ? labels[idx] : '',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF0A0E1A),
              getTooltipItem: (group, groupIdx, rod, rodIdx) {
                final label = rodIdx == 0 ? 'Income' : 'Expense';
                return BarTooltipItem(
                  '$label\nEGP ${rod.toY.toStringAsFixed(0)}',
                  const TextStyle(color: Colors.white, fontSize: 11),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  double _maxY(List<BarChartGroupData> groups) {
    double max = 0;
    for (final g in groups) {
      for (final r in g.barRods) {
        if (r.toY > max) max = r.toY;
      }
    }
    return max * 1.2 + 100;
  }

  List<BarChartGroupData> _buildGroups() {
    final buckets = <int, Map<String, double>>{};
    for (final t in transactions) {
      final key = _bucketKey(t.date);
      buckets[key] ??= {'income': 0, 'expense': 0};
      if (t.isIncome) {
        buckets[key]!['income'] = buckets[key]!['income']! + t.amount;
      } else {
        buckets[key]!['expense'] = buckets[key]!['expense']! + t.amount;
      }
    }
    final sorted = buckets.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return sorted.asMap().entries.map((e) {
      final data = e.value.value;
      return BarChartGroupData(
        x: e.key,
        groupVertically: false,
        barRods: [
          BarChartRodData(
            toY: data['income'] ?? 0,
            color: const Color(0xFF00FF88),
            width: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: data['expense'] ?? 0,
            color: const Color(0xFFFF4466),
            width: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        barsSpace: 4,
      );
    }).toList();
  }

  int _bucketKey(DateTime date) {
    switch (period) {
      case _Period.week:
        return date.weekday;
      case _Period.month:
        return (date.day / 7).ceil();
      case _Period.year:
        return date.month;
    }
  }

  List<String> _groupLabels() {
    switch (period) {
      case _Period.week:
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      case _Period.month:
        return ['W1', 'W2', 'W3', 'W4', 'W5'];
      case _Period.year:
        return [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
    }
  }
}

// -- Monthly Line Chart --------------------------------------------------------
class _MonthlyLineChart extends StatelessWidget {
  final List<Transaction> transactions;
  const _MonthlyLineChart({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final byMonth = <int, double>{};
    for (final t in transactions
        .where((t) => !t.isIncome)) {
      final m = t.date.month;
      byMonth[m] = (byMonth[m] ?? 0) + t.amount;
    }

    if (byMonth.isEmpty) return _emptyState('No expense history');

    final months = byMonth.keys.toList()..sort();
    final spots = months
        .map((m) => FlSpot(m.toDouble(), byMonth[m]!))
        .toList();

    final maxY =
        byMonth.values.fold<double>(0, (a, b) => a > b ? a : b) * 1.2 +
            100;

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF131929),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFF00E5FF).withOpacity(0.15)),
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFF00E5FF),
              barWidth: 2.5,
              dotData: FlDotData(
                getDotPainter: (_, __, ___, ____) =>
                    FlDotCirclePainter(
                        radius: 4,
                        color: const Color(0xFF00E5FF),
                        strokeColor: Colors.white,
                        strokeWidth: 1.5),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF00E5FF).withOpacity(0.25),
                    const Color(0xFF00E5FF).withOpacity(0),
                  ],
                ),
              ),
            ),
          ],
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.white.withOpacity(0.05),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (val, _) => Text(
                  val >= 1000
                      ? '${(val / 1000).toStringAsFixed(0)}k'
                      : val.toStringAsFixed(0),
                  style:
                      const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, _) {
                  const names = [
                    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                  ];
                  final idx = val.toInt();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      idx >= 1 && idx <= 12 ? names[idx] : '',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF0A0E1A),
              getTooltipItems: (spots) => spots
                  .map((s) => LineTooltipItem(
                        'EGP ${s.y.toStringAsFixed(0)}',
                        const TextStyle(
                            color: Color(0xFF00E5FF),
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// -- Empty State ---------------------------------------------------------------
Widget _emptyState(String msg) => Container(
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF131929),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bar_chart_outlined,
                color: Colors.white24, size: 36),
            const SizedBox(height: 8),
            Text(msg,
                style: const TextStyle(color: Colors.white38, fontSize: 13)),
          ],
        ),
      ),
    );
