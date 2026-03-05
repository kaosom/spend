import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/utils/dates.dart' as AppDateUtils;
import '../../../models/models.dart';
import '../../accounts/accounts_controller.dart';
import '../../transactions/transactions_controller.dart';
import '../../../design_system/organisms/daily_transaction_list.dart';

class TransactionsTab extends StatefulWidget {
  const TransactionsTab({super.key});

  @override
  State<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<TransactionsTab> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

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
          title: Text('Transacciones', style: AvidTokens.heading2),
          actions: [
            IconButton(
              icon: const Icon(Icons.today, color: AvidTokens.textPrimary),
              onPressed: () {
                // Return to Today when pressing the calendar icon
                // We'll calculate the index dynamically or rely on the logic inside
                _itemScrollController.scrollTo(
                  index: _getTodayIndex(),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              tooltip: 'Ir a Hoy',
            ),
          ],
        ),
        body: Obx(() {
          final account = accountsController.selectedAccount;
          if (account == null) {
            return Center(
              child: Text(
                'No Account Selected',
                style: AvidTokens.bodyMedium.copyWith(
                  color: AvidTokens.textTertiary,
                ),
              ),
            );
          }

          // We define our temporal window: 30 days ago to 365 days in the future
          final DateTime now = DateTime.now();
          final DateTime today = DateTime(now.year, now.month, now.day);
          final DateTime startDate = today.subtract(const Duration(days: 30));
          final DateTime endDate = today.add(const Duration(days: 365));

          // 1. Get ALL transactions (including projected ones via getTransactionsInRange)
          // Since getTransactionsInRange is a method that expects a range, we grab from way past to our endDate to get initial balance correct.
          final allExpectedTransactions = txController
              .getTransactionsInRange(
                DateTime(2000), // Far past to calculate initial balance
                endDate,
              )
              .where((t) => t.accountId == account.id)
              .toList();

          // 2. Calculate initial balance (Transactions strictly before our visual startDate)
          double initialBalance = 0;
          for (final tx in allExpectedTransactions) {
            if (tx.date.isBefore(startDate)) {
              if (tx.isIncome) {
                initialBalance += tx.amount;
              } else {
                initialBalance -= tx.amount;
              }
            }
          }

          // 3. Filter transactions that belong to our visual window
          final windowTransactions = allExpectedTransactions
              .where(
                (t) => !t.date.isBefore(startDate) && !t.date.isAfter(endDate),
              )
              .toList();

          // Sort explicitly by date ascending to process chronologically
          windowTransactions.sort((a, b) => a.date.compareTo(b.date));

          // 4. Generate the map of Days and compile the data structure
          final int totalDays = endDate.difference(startDate).inDays + 1;
          final List<_DailyBalanceInfo> daysInfo = [];

          double runningBalance = initialBalance;
          int transactionIndex = 0;

          // Iterate chronologically to calculate the balance at the end of each day
          for (int i = 0; i < totalDays; i++) {
            final currentDay = startDate.add(Duration(days: i));
            final currentDayEnd = currentDay
                .add(const Duration(days: 1))
                .subtract(const Duration(milliseconds: 1));

            final List<Transaction> dayTxs = [];
            double dailyIncome = 0;
            double dailyExpense = 0;

            // Pick up all transactions for this day
            while (transactionIndex < windowTransactions.length) {
              final tx = windowTransactions[transactionIndex];
              // If transaction is on or after currentDay AND before currentDayEnd
              if (!tx.date.isBefore(currentDay) &&
                  tx.date.isBefore(currentDayEnd)) {
                dayTxs.add(tx);
                if (tx.isIncome) {
                  dailyIncome += tx.amount;
                  runningBalance += tx.amount;
                } else {
                  dailyExpense += tx.amount;
                  runningBalance -= tx.amount;
                }
                transactionIndex++;
              } else {
                break; // Because they are sorted, if it's not today, it's future
              }
            }

            // Sort day transactions newest first for display purposes
            dayTxs.sort((a, b) => b.date.compareTo(a.date));

            daysInfo.add(
              _DailyBalanceInfo(
                date: currentDay,
                cumulativeBalance: runningBalance,
                dailyIncome: dailyIncome,
                dailyExpense: dailyExpense,
                transactions: dayTxs,
              ),
            );
          }

          if (_todayIndexCache == -1 || _cachedTotalDays != totalDays) {
            // Find today's index
            for (int i = 0; i < daysInfo.length; i++) {
              if (AppDateUtils.DateUtils.isToday(daysInfo[i].date)) {
                _todayIndexCache = i;
                break;
              }
            }
            _cachedTotalDays = totalDays;

            // Initial jump to today (only execute once after layout)
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_itemScrollController.isAttached && _todayIndexCache != -1) {
                _itemScrollController.jumpTo(index: _todayIndexCache);
              }
            });
          }

          return ScrollablePositionedList.builder(
            itemCount: daysInfo.length,
            itemScrollController: _itemScrollController,
            itemPositionsListener: _itemPositionsListener,
            padding: const EdgeInsets.only(
              left: AvidTokens.space4,
              right: AvidTokens.space4,
              top: AvidTokens.space2,
              bottom: AvidTokens.space12, // Space for FAB
            ),
            itemBuilder: (context, index) {
              final info = daysInfo[index];
              final isToday = AppDateUtils.DateUtils.isToday(info.date);
              final isFuture = info.date.isAfter(today);
              final isPositiveBalance = info.cumulativeBalance >= 0;

              // Format date header string
              String dateHeader = AppDateUtils.DateUtils.formatDisplayDate(
                info.date,
              );
              if (isToday) {
                dateHeader = 'Hoy';
              } else if (AppDateUtils.DateUtils.isSameDay(
                info.date,
                today.subtract(const Duration(days: 1)),
              )) {
                dateHeader = 'Ayer';
              } else if (AppDateUtils.DateUtils.isSameDay(
                info.date,
                today.add(const Duration(days: 1)),
              )) {
                dateHeader = 'Mañana';
              }

              return Container(
                margin: const EdgeInsets.only(bottom: AvidTokens.space4),
                decoration: BoxDecoration(
                  color: isToday
                      ? AvidTokens.accentPrimary.withValues(alpha: 0.05)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AvidTokens.radiusMedium),
                  border: isToday
                      ? Border.all(
                          color: AvidTokens.accentPrimary.withValues(
                            alpha: 0.3,
                          ),
                          width: 1,
                        )
                      : null,
                ),
                padding: isToday
                    ? const EdgeInsets.all(AvidTokens.space3)
                    : EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Day Header with Balance
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              dateHeader,
                              style: AvidTokens.heading4.copyWith(
                                color: isFuture
                                    ? AvidTokens.textSecondary
                                    : AvidTokens.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Balance Total',
                              style: AvidTokens.labelSmall.copyWith(
                                color: AvidTokens.textTertiary,
                              ),
                            ),
                            Text(
                              '${isPositiveBalance ? '' : '-'}\$${info.cumulativeBalance.abs().toStringAsFixed(2)}',
                              style: AvidTokens.labelLarge.copyWith(
                                color: isPositiveBalance
                                    ? AvidTokens.accentSuccess
                                    : AvidTokens.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    if (info.transactions.isNotEmpty) ...[
                      const SizedBox(height: AvidTokens.space3),
                      // List of transactions using the existing widget
                      DailyTransactionList(
                        dateHeader: '', // Header is handled above
                        transactions: info.transactions,
                        onSeeAll: () {},
                      ),
                    ] else ...[
                      // Small indicator for steady day
                      const SizedBox(height: AvidTokens.space2),
                      Row(
                        children: [
                          Icon(
                            Icons.horizontal_rule,
                            size: 16,
                            color: AvidTokens.textTertiary.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(width: AvidTokens.space2),
                          Text(
                            'Sin movimientos',
                            style: AvidTokens.bodySmall.copyWith(
                              color: AvidTokens.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }

  int _todayIndexCache = -1;
  int _cachedTotalDays = -1;

  int _getTodayIndex() {
    return _todayIndexCache != -1 ? _todayIndexCache : 0;
  }
}

class _DailyBalanceInfo {
  final DateTime date;
  final double cumulativeBalance;
  final double dailyIncome;
  final double dailyExpense;
  final List<Transaction> transactions;

  _DailyBalanceInfo({
    required this.date,
    required this.cumulativeBalance,
    required this.dailyIncome,
    required this.dailyExpense,
    required this.transactions,
  });
}
