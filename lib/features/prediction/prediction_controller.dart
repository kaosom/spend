import 'package:get/get.dart';
import '../../core/errors/app_error.dart';
import '../../core/utils/dates.dart';
import '../../models/models.dart';
import '../accounts/accounts_controller.dart';
import '../transactions/transactions_controller.dart';
import '../settings/settings_controller.dart';

/// Controller for spend prediction feature
class PredictionController extends GetxController {
  final Rxn<SpendPrediction> _lastPrediction = Rxn<SpendPrediction>();
  final RxBool _isCalculating = false.obs;
  final Rxn<AppError> lastError = Rxn<AppError>();

  SpendPrediction? get lastPrediction => _lastPrediction.value;
  bool get isCalculating => _isCalculating.value;

  /// Calculate spend prediction for a planned spend
  Future<Result<SpendPrediction>> calculatePrediction(
    PlannedSpend plannedSpend,
  ) async {
    _isCalculating.value = true;
    try {
      final accountsController = Get.find<AccountsController>();
      final transactionsController = Get.find<TransactionsController>();
      final settingsController = Get.find<SettingsController>();

      final account = accountsController.getAccountById(plannedSpend.accountId);
      if (account == null) {
        return Result.failure(NotFoundError(message: 'Account not found'));
      }

      // Get current balance (sum of all transactions for this account)
      final allTransactions = transactionsController.getTransactionsForAccount(
        account.id,
      );
      final currentBalance = allTransactions.fold<double>(
        0,
        (balance, transaction) => balance + transaction.signedAmount,
      );

      // Get upcoming transactions that affect this account
      final upcomingTransactions = _getUpcomingTransactions(
        account.id,
        plannedSpend.date,
        transactionsController,
      );

      // Get planned spends for this account
      final plannedSpends = transactionsController.plannedSpends
          .where(
            (s) =>
                s.accountId == account.id && s.date.isBefore(plannedSpend.date),
          )
          .toList();

      // Calculate projected balance
      double projectedBalance = currentBalance;
      final conflicts = <PredictionConflict>[];
      final details = <PredictionDetail>[];

      // Add current balance to details
      details.add(
        PredictionDetail(
          description: 'Current balance',
          amount: currentBalance,
          type: 'balance',
        ),
      );

      // Process upcoming income
      final upcomingIncome = upcomingTransactions
          .where((t) => t.isIncome)
          .toList();
      for (final transaction in upcomingIncome) {
        projectedBalance += transaction.amount;
        details.add(
          PredictionDetail(
            description:
                '${transaction.merchant ?? 'Income'} (${transaction.displayDate})',
            amount: transaction.amount,
            type: 'income',
          ),
        );
      }

      // Process upcoming expenses (including obligatory ones)
      final upcomingExpenses = upcomingTransactions
          .where((t) => t.isExpense)
          .toList();
      for (final transaction in upcomingExpenses) {
        projectedBalance -= transaction.amount;
        details.add(
          PredictionDetail(
            description:
                '${transaction.merchant ?? 'Expense'} (${transaction.displayDate})',
            amount: -transaction.amount,
            type: 'expense',
          ),
        );

        if (transaction.isObligatory) {
          conflicts.add(
            PredictionConflict(
              description: transaction.merchant ?? 'Obligatory payment',
              amount: transaction.amount,
              date: transaction.date,
              isObligatory: true,
            ),
          );
        }
      }

      // Process planned spends
      for (final spend in plannedSpends) {
        projectedBalance -= spend.amount;
        details.add(
          PredictionDetail(
            description:
                'Planned: ${spend.note ?? 'Spend'} (${spend.displayDate})',
            amount: -spend.amount,
            type: 'planned',
          ),
        );
      }

      // Add the current planned spend
      projectedBalance -= plannedSpend.amount;
      details.add(
        PredictionDetail(
          description: 'This planned spend (${plannedSpend.displayDate})',
          amount: -plannedSpend.amount,
          type: 'planned',
        ),
      );

      // Determine if it's safe
      final safetyBuffer = settingsController.safetyBuffer;
      final isSafe = projectedBalance >= safetyBuffer;

      // Create final balance detail
      details.add(
        PredictionDetail(
          description: 'Projected balance after spend',
          amount: projectedBalance,
          type: 'balance',
        ),
      );

      final prediction = SpendPrediction(
        plannedSpend: plannedSpend,
        isSafe: isSafe,
        projectedBalance: projectedBalance,
        conflicts: conflicts,
        details: details,
      );

      _lastPrediction.value = prediction;
      return Result.success(prediction);
    } catch (e) {
      final error = UnknownError(
        message: 'Failed to calculate prediction',
        details: e.toString(),
      );
      setError(error);
      return Result.failure(error);
    } finally {
      _isCalculating.value = false;
    }
  }

  /// Get upcoming transactions for an account up to a certain date
  List<Transaction> _getUpcomingTransactions(
    String accountId,
    DateTime upToDate,
    TransactionsController transactionsController,
  ) {
    final now = DateTime.now();
    final transactions = transactionsController.getTransactionsForAccount(
      accountId,
    );

    // Get one-time transactions in the future
    final oneTimeTransactions = transactions.where((t) {
      return t.date.isAfter(now) &&
          !t.date.isAfter(upToDate) &&
          t.recurrenceRuleId == null;
    }).toList();

    // Generate recurring transactions
    final recurringTransactions = <Transaction>[];
    for (final transaction in transactions) {
      if (transaction.recurrenceRuleId != null) {
        final rule = transactionsController.getRecurrenceRuleById(
          transaction.recurrenceRuleId!,
        );
        if (rule != null) {
          final occurrences = rule.generateOccurrences(
            transaction.date,
            upToDate,
          );
          for (final occurrence in occurrences) {
            if (occurrence.isAfter(now) && !occurrence.isAfter(upToDate)) {
              // Create a transaction instance for this occurrence
              recurringTransactions.add(
                transaction.copyWith(
                  id: '${transaction.id}_${DateUtils.toDateKey(occurrence)}',
                  date: occurrence,
                ),
              );
            }
          }
        }
      }
    }

    // Combine and sort by date
    final allUpcoming = [...oneTimeTransactions, ...recurringTransactions];
    allUpcoming.sort((a, b) => a.date.compareTo(b.date));

    return allUpcoming;
  }

  /// Clear last prediction
  void clearLastPrediction() {
    _lastPrediction.value = null;
  }

  /// Clear last error
  void clearError() {
    lastError.value = null;
  }

  /// Set error
  void setError(AppError error) {
    lastError.value = error;
  }
}
