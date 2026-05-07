import 'package:budget_app/features/budget/presentation/analytics/cubit/analytics_cubit.dart';
import 'package:budget_app/features/budget/presentation/analytics/cubit/analytics_state.dart';
import 'package:budget_app/features/budget/presentation/shared/widgets/async_state_views.dart';
import 'package:budget_app/features/budget/presentation/shared/widgets/budget_card.dart';
import 'package:budget_app/features/budget/presentation/shared/widgets/category_icons.dart';
import 'package:budget_app/features/budget/presentation/transaction/cubit/transaction_cubit.dart';
import 'package:budget_app/features/budget/presentation/transaction/cubit/transaction_state.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int _touchedPieIndex = -1;

  @override
  void initState() {
    super.initState();
    final transactions = context.read<TransactionCubit>().state.transactions;
    context.read<AnalyticsCubit>().syncTransactions(transactions);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<TransactionCubit, TransactionState>(
      listener: (context, transactionState) {
        context.read<AnalyticsCubit>().syncTransactions(
          transactionState.transactions,
        );
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: BlocBuilder<AnalyticsCubit, AnalyticsState>(
              builder: (context, state) {
                final loading =
                    context.watch<TransactionCubit>().state.status ==
                    TransactionStatus.loading;
                if (loading) {
                  return const BudgetLoadingView(height: 220);
                }
                if (state.status == AnalyticsStatus.empty) {
                  return BudgetMessageCard(
                    message: 'Add transactions to see your analytics.',
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Analytics',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CupertinoSlidingSegmentedControl<AnalyticsRange>(
                      groupValue: state.selectedRange,
                      children: const {
                        AnalyticsRange.today: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('Today'),
                        ),
                        AnalyticsRange.week: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('Week'),
                        ),
                        AnalyticsRange.month: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('Month'),
                        ),
                        AnalyticsRange.year: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('Year'),
                        ),
                      },
                      onValueChanged: (value) {
                        if (value == null) return;
                        context.read<AnalyticsCubit>().setRange(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    BudgetCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Balance trend',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 220,
                            child: LineChart(_buildLineChartData(state, theme)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    BudgetCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Expenses by category',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Total spent: \$${state.totalExpenses.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 220,
                            child: PieChart(_buildPieChartData(state)),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 10,
                            children: state.categorySlices.map((slice) {
                              final share = state.totalExpenses == 0
                                  ? 0
                                  : (slice.amount / state.totalExpenses) * 100;
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: categoryColorFor(slice.colorKey),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${share.toStringAsFixed(0)}% ${slice.label}',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  LineChartData _buildLineChartData(AnalyticsState state, ThemeData theme) {
    final points = state.balancePoints;
    if (points.isEmpty) {
      return LineChartData(lineBarsData: const []);
    }

    final spots = points
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.balance))
        .toList();

    final minY = points
        .map((point) => point.balance)
        .reduce((a, b) => a < b ? a : b);
    final maxY = points
        .map((point) => point.balance)
        .reduce((a, b) => a > b ? a : b);
    final interval = (((maxY - minY).abs() / 4).clamp(
      1,
      double.infinity,
    )).toDouble();

    return LineChartData(
      minX: 0,
      maxX: (spots.length - 1).toDouble(),
      minY: minY - (interval * 0.2),
      maxY: maxY + (interval * 0.2),
      gridData: FlGridData(
        show: true,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: theme.colorScheme.outlineVariant),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: interval,
            reservedSize: 56,
            getTitlesWidget: (value, meta) => SideTitleWidget(
              meta: meta,
              child: Text('\$${value.toStringAsFixed(0)}'),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx < 0 || idx >= points.length) {
                return const SizedBox.shrink();
              }
              final shouldShow =
                  idx == 0 ||
                  idx == points.length ~/ 2 ||
                  idx == points.length - 1;
              if (!shouldShow) return const SizedBox.shrink();
              final date = points[idx].date;
              final label =
                  '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
              return SideTitleWidget(meta: meta, child: Text(label));
            },
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          barWidth: 3,
          color: theme.colorScheme.primary,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
          ),
        ),
      ],
    );
  }

  PieChartData _buildPieChartData(AnalyticsState state) {
    return PieChartData(
      sectionsSpace: 2,
      centerSpaceRadius: 38,
      pieTouchData: PieTouchData(
        touchCallback: (event, response) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                response?.touchedSection == null) {
              _touchedPieIndex = -1;
              return;
            }
            _touchedPieIndex = response!.touchedSection!.touchedSectionIndex;
          });
        },
      ),
      sections: state.categorySlices.asMap().entries.map((entry) {
        final index = entry.key;
        final slice = entry.value;
        final highlighted = index == _touchedPieIndex;
        return PieChartSectionData(
          value: slice.amount,
          color: categoryColorFor(slice.colorKey),
          radius: highlighted ? 80 : 72,
          title: '',
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        );
      }).toList(),
    );
  }
}
