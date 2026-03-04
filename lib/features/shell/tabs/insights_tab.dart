import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/utils/dates.dart' as AppDateUtils;
import '../../../core/constants/constants.dart';
import '../../../models/models.dart';
import '../../accounts/accounts_controller.dart';
import '../../transactions/transactions_controller.dart';
import '../../../design_system/molecules/insight_summary_cards.dart';
import '../../../design_system/organisms/insights_bar_chart.dart';
import '../../../design_system/organisms/daily_transaction_list.dart';

enum TimeFilter { daily, weekly, monthly }

class InsightsTab extends StatefulWidget {
  const InsightsTab({super.key});

  @override
  State<InsightsTab> createState() => _InsightsTabState();
}

class _InsightsTabState extends State<InsightsTab> {
  TimeFilter _timeFilter = TimeFilter.daily;
  int _timeOffset = 0; // 0 = present. 1 = 1 period ago, etc.

  String _getFilterName() {
    switch (_timeFilter) {
      case TimeFilter.daily:
        return 'Diario';
      case TimeFilter.weekly:
        return 'Semanal';
      case TimeFilter.monthly:
        return 'Mensual';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return months[month - 1];
  }

  String _getDateRangeLabel(DateTime start, DateTime now) {
    if (_timeFilter == TimeFilter.daily) {
      if (start.month == now.month && start.year == now.year) {
        return '${start.day} - ${now.day} de ${_getMonthName(now.month)} ${now.year}';
      } else if (start.year == now.year) {
        return '${start.day} de ${_getMonthName(start.month)} - ${now.day} de ${_getMonthName(now.month)} ${now.year}';
      } else {
        return '${start.day} ${_getMonthName(start.month)} ${start.year} - ${now.day} ${_getMonthName(now.month)} ${now.year}';
      }
    } else if (_timeFilter == TimeFilter.weekly) {
      if (start.year == now.year) {
        return '${start.day} ${_getMonthName(start.month)} - ${now.day} ${_getMonthName(now.month)} ${now.year}';
      } else {
        return '${start.day} ${_getMonthName(start.month)} ${start.year} - ${now.day} ${_getMonthName(now.month)} ${now.year}';
      }
    } else {
      if (start.year == now.year) {
        return '${_getMonthName(start.month)} - ${_getMonthName(now.month)} ${now.year}';
      } else {
        return '${_getMonthName(start.month)} ${start.year} - ${_getMonthName(now.month)} ${now.year}';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final txController = Get.find<TransactionsController>();
    final accountsController = Get.find<AccountsController>();

    return SafeArea(
      child: Scaffold(
        backgroundColor: AvidTokens.backgroundPrimary,
        appBar: AppBar(
          backgroundColor: AvidTokens.backgroundPrimary,
          elevation: 0,
          title: Text('Resumen', style: AvidTokens.heading2),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  _timeOffset++;
                });
              },
              icon: const Icon(
                Icons.chevron_left,
                color: AvidTokens.textPrimary,
              ),
            ),
            PopupMenuButton<TimeFilter>(
              onSelected: (filter) => setState(() {
                _timeFilter = filter;
                _timeOffset = 0; // Reset offset when changing filters
              }),
              offset: const Offset(0, 40),
              color: AvidTokens.backgroundSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AvidTokens.radiusMedium),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: TimeFilter.daily,
                  child: Text(
                    'Diario',
                    style: AvidTokens.bodyMedium.copyWith(
                      color: _timeFilter == TimeFilter.daily
                          ? AvidTokens.accentPrimary
                          : AvidTokens.textPrimary,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: TimeFilter.weekly,
                  child: Text(
                    'Semanal',
                    style: AvidTokens.bodyMedium.copyWith(
                      color: _timeFilter == TimeFilter.weekly
                          ? AvidTokens.accentPrimary
                          : AvidTokens.textPrimary,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: TimeFilter.monthly,
                  child: Text(
                    'Mensual',
                    style: AvidTokens.bodyMedium.copyWith(
                      color: _timeFilter == TimeFilter.monthly
                          ? AvidTokens.accentPrimary
                          : AvidTokens.textPrimary,
                    ),
                  ),
                ),
              ],
              child: Container(
                margin: const EdgeInsets.only(right: AvidTokens.space4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AvidTokens.backgroundSecondary,
                  borderRadius: BorderRadius.circular(AvidTokens.radiusRound),
                  border: Border.all(color: AvidTokens.borderPrimary),
                ),
                child: Row(
                  children: [
                    Text(_getFilterName(), style: AvidTokens.labelMedium),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: AvidTokens.textPrimary,
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _timeOffset--; // Negative offset means future
                });
              },
              icon: const Icon(
                Icons.chevron_right,
                color: AvidTokens.textPrimary,
              ),
            ),
          ],
        ),
        body: Obx(() {
          final account = accountsController.selectedAccount;
          if (account == null) {
            return Center(
              child: Text('No Account Selected', style: AvidTokens.bodyMedium),
            );
          }

          // Date range configuration based on _timeOffset
          DateTime now = DateTime.now();
          DateTime start;
          int chartPoints = 0;

          if (_timeFilter == TimeFilter.daily) {
            now = now.subtract(Duration(days: 7 * _timeOffset));
            start = now.subtract(const Duration(days: 6)); // Last 7 days
            chartPoints = 7;
          } else if (_timeFilter == TimeFilter.weekly) {
            now = now.subtract(Duration(days: 84 * _timeOffset));
            start = now.subtract(const Duration(days: 84)); // Last 12 weeks
            chartPoints = 12;
            // Align start to the beginning of the week (Monday)
            start = start.subtract(Duration(days: start.weekday - 1));
          } else {
            now = DateTime(now.year, now.month - (12 * _timeOffset), now.day);
            start = DateTime(now.year, now.month - 11, 1); // Last 12 months
            chartPoints = 12;
          }

          final allTransactions = txController.transactions
              .where((t) => t.accountId == account.id)
              .toList();

          double totalIncome = 0;
          double totalExpense = 0;
          final List<double> chartValues = [];
          final List<String> chartLabels = [];

          if (_timeFilter == TimeFilter.daily) {
            // Daily Logic (Last 7 days)
            final dailyTotals = txController.getDailyTotals(start, now);
            var current = start;
            while (!current.isAfter(now) && chartLabels.length < chartPoints) {
              final dateKey = AppDateUtils.DateUtils.toDateKey(current);
              final dayTotal = dailyTotals.firstWhere(
                (dt) => dt.dateKey == dateKey,
                orElse: () =>
                    DailyTotals(date: current, income: 0, expense: 0, net: 0),
              );

              totalIncome += dayTotal.income;
              totalExpense += dayTotal.expense;
              // Chart represents net flow (Income - Expense)
              chartValues.add(dayTotal.net);

              // Label: 'S', 'M', 'T', 'W', 'T', 'F', 'S'
              const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
              chartLabels.add(days[current.weekday - 1]);

              current = current.add(const Duration(days: 1));
            }
          } else if (_timeFilter == TimeFilter.weekly) {
            // Weekly Logic (Last 12 weeks)
            var currentStart = start;
            for (int i = 0; i < chartPoints; i++) {
              var currentEnd = currentStart.add(const Duration(days: 6));
              if (currentEnd.isAfter(now)) currentEnd = now;

              double weekIncome = 0;
              double weekExpense = 0;

              for (final t in allTransactions) {
                if (t.date.isAfter(
                      currentStart.subtract(const Duration(seconds: 1)),
                    ) &&
                    t.date.isBefore(currentEnd.add(const Duration(days: 1)))) {
                  if (t.type == AppConstants.transactionTypeIncome) {
                    weekIncome += t.amount;
                  } else {
                    weekExpense += t.amount;
                  }
                }
              }

              totalIncome += weekIncome;
              totalExpense += weekExpense;
              chartValues.add(weekIncome - weekExpense);
              chartLabels.add('S${(i + 1)}'); // W1, W2...

              currentStart = currentStart.add(const Duration(days: 7));
            }
          } else {
            // Monthly Logic (Last 12 months)
            var currentMonth = DateTime(start.year, start.month, 1);
            for (int i = 0; i < chartPoints; i++) {
              double monthIncome = 0;
              double monthExpense = 0;

              for (final t in allTransactions) {
                if (t.date.year == currentMonth.year &&
                    t.date.month == currentMonth.month) {
                  if (t.type == AppConstants.transactionTypeIncome) {
                    monthIncome += t.amount;
                  } else {
                    monthExpense += t.amount;
                  }
                }
              }

              totalIncome += monthIncome;
              totalExpense += monthExpense;
              chartValues.add(monthIncome - monthExpense);

              const months = [
                'E',
                'F',
                'M',
                'A',
                'M',
                'J',
                'J',
                'A',
                'S',
                'O',
                'N',
                'D',
              ];
              chartLabels.add(months[currentMonth.month - 1]);

              currentMonth = DateTime(
                currentMonth.year,
                currentMonth.month + 1,
                1,
              );
            }
          }

          // Compute max absolute value for chart scaling
          final maxChartValue = chartValues.isEmpty
              ? 1.0
              : chartValues.map((v) => v.abs()).reduce((a, b) => a > b ? a : b);

          // Determine the most expensive day this week to naturally highlight it
          int activeIndex = chartValues.length - 1; // Default highlight today
          double activeValue = chartValues.last;
          if (maxChartValue > 0) {
            for (int i = 0; i < chartValues.length; i++) {
              if (chartValues[i] == maxChartValue) {
                activeIndex = i;
                activeValue = chartValues[i];
                break;
              }
            }
          }

          // Gather Transactions for lists
          allTransactions.sort(
            (a, b) => b.date.compareTo(a.date),
          ); // Newest first

          final todayTxs = allTransactions
              .where((t) => AppDateUtils.DateUtils.isToday(t.date))
              .toList();
          final yesterday = DateTime.now().subtract(const Duration(days: 1));
          final yesterdayTxs = allTransactions
              .where((t) => AppDateUtils.DateUtils.isSameDay(t.date, yesterday))
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AvidTokens.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Temporal Range Label
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AvidTokens.space3),
                    child: Text(
                      _getDateRangeLabel(start, now),
                      style: AvidTokens.labelMedium.copyWith(
                        color: AvidTokens.textTertiary,
                      ),
                    ),
                  ),
                ),

                // Summary Cards
                InsightSummaryCards(income: totalIncome, expense: totalExpense),

                const SizedBox(height: AvidTokens.space6),

                // Bar Chart
                InsightsBarChart(
                  values: chartValues,
                  labels: chartLabels,
                  maxValue: maxChartValue,
                  activeIndex: activeIndex,
                  activeValue: activeValue,
                ),

                const SizedBox(height: AvidTokens.space6),

                // Lists
                if (todayTxs.isNotEmpty)
                  DailyTransactionList(
                    dateHeader: 'Hoy',
                    transactions: todayTxs,
                    onSeeAll: () {
                      Get.snackbar(
                        'Logs',
                        'See all Today pressed',
                        snackPosition: SnackPosition.TOP,
                      );
                    },
                  ),

                if (yesterdayTxs.isNotEmpty) ...[
                  if (todayTxs.isNotEmpty)
                    const SizedBox(height: AvidTokens.space6),
                  DailyTransactionList(
                    dateHeader: 'Ayer',
                    transactions: yesterdayTxs,
                    onSeeAll: () {
                      Get.snackbar(
                        'Logs',
                        'See all Yesterday pressed',
                        snackPosition: SnackPosition.TOP,
                      );
                    },
                  ),
                ],

                if (todayTxs.isEmpty && yesterdayTxs.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        'Sin transacciones recientes.',
                        style: AvidTokens.bodyMedium,
                      ),
                    ),
                  ),

                const SizedBox(
                  height: AvidTokens.space12,
                ), // Bottom padding for FAB space
              ],
            ),
          );
        }),
      ),
    );
  }
}
