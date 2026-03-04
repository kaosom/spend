import 'package:get/get.dart';
import '../../core/errors/app_error.dart';
import '../../core/utils/debounce.dart';
import '../../core/utils/dates.dart';
import '../../models/models.dart';

/// Controller for managing transactions
class TransactionsController extends GetxController {
  final RxList<Transaction> _transactions = <Transaction>[].obs;
  final RxList<RecurrenceRule> _recurrenceRules = <RecurrenceRule>[].obs;
  final RxList<PlannedSpend> _plannedSpends = <PlannedSpend>[].obs;
  final RxString _monthCursor = DateUtils.getCurrentMonthCursor().obs;
  final Rxn<AppError> lastError = Rxn<AppError>();
  final Debounce _saveDebounce = Debounce();

  List<Transaction> get transactions => _transactions;
  List<RecurrenceRule> get recurrenceRules => _recurrenceRules;
  List<PlannedSpend> get plannedSpends => _plannedSpends;
  String get monthCursor => _monthCursor.value;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  @override
  void onClose() {
    _saveDebounce.dispose();
    super.onClose();
  }

  /// Load transactions from storage
  Future<void> loadTransactions() async {
    try {
      // TODO: Implement storage loading
      _transactions.clear();
      _recurrenceRules.clear();
      _plannedSpends.clear();
      clearError();
    } catch (e) {
      setError(UnknownError(message: 'Failed to load transactions', details: e.toString()));
    }
  }

  /// Debounced save to storage
  void _debouncedSave() {
    _saveDebounce.call(() async {
      try {
        await _saveToStorage();
      } catch (e) {
        setError(StorageWriteError(message: 'Failed to save transactions', details: e.toString()));
      }
    });
  }

  /// Save to storage (internal method)
  Future<void> _saveToStorage() async {
    // TODO: Implement storage saving
  }

  /// Create a new transaction
  Future<Result<Transaction>> createTransaction({
    required double amount,
    required DateTime date,
    required String accountId,
    required String categoryId,
    required String type,
    String? note,
    String? merchant,
    bool? isObligatory,
    RecurrenceRule? recurrenceRule,
    PlannedSpend? plannedSpend,
  }) async {
    try {
      RecurrenceRule? savedRule;
      if (recurrenceRule != null) {
        final ruleResult = await createRecurrenceRule(recurrenceRule);
        if (ruleResult.isFailure) {
          return Result.failure(ruleResult.error!);
        }
        savedRule = ruleResult.data;
      }

      PlannedSpend? savedSpend;
      if (plannedSpend != null) {
        final spendResult = await createPlannedSpend(plannedSpend);
        if (spendResult.isFailure) {
          return Result.failure(spendResult.error!);
        }
        savedSpend = spendResult.data;
      }

      final transaction = Transaction.create(
        amount: amount,
        date: date,
        accountId: accountId,
        categoryId: categoryId,
        type: type,
        note: note,
        merchant: merchant,
        isObligatory: isObligatory ?? false,
        recurrenceRuleId: savedRule?.id,
        plannedSpendId: savedSpend?.id,
      );

      if (!transaction.isValid) {
        return Result.failure(ValidationError(message: 'Invalid transaction data'));
      }

      _transactions.add(transaction);
      _debouncedSave();

      return Result.success(transaction);
    } catch (e) {
      final error = UnknownError(message: 'Failed to create transaction', details: e.toString());
      setError(error);
      return Result.failure(error);
    }
  }

  /// Update an existing transaction
  Future<Result<Transaction>> updateTransaction(Transaction transaction) async {
    try {
      if (!transaction.isValid) {
        return Result.failure(ValidationError(message: 'Invalid transaction data'));
      }

      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index == -1) {
        return Result.failure(NotFoundError(message: 'Transaction not found'));
      }

      final updatedTransaction = transaction.markUpdated();
      _transactions[index] = updatedTransaction;
      _debouncedSave();

      return Result.success(updatedTransaction);
    } catch (e) {
      final error = UnknownError(message: 'Failed to update transaction', details: e.toString());
      setError(error);
      return Result.failure(error);
    }
  }

  /// Delete a transaction
  Future<Result<void>> deleteTransaction(String transactionId) async {
    try {
      final index = _transactions.indexWhere((t) => t.id == transactionId);
      if (index == -1) {
        return Result.failure(NotFoundError(message: 'Transaction not found'));
      }

      _transactions.removeAt(index);
      _debouncedSave();

      return const Result.success(null);
    } catch (e) {
      final error = UnknownError(message: 'Failed to delete transaction', details: e.toString());
      setError(error);
      return Result.failure(error);
    }
  }

  /// Get transactions for a specific account
  List<Transaction> getTransactionsForAccount(String accountId) {
    return _transactions.where((t) => t.accountId == accountId).toList();
  }

  /// Get transactions for a specific date range
  List<Transaction> getTransactionsInRange(DateTime startDate, DateTime endDate) {
    return _transactions.where((t) {
      return !t.date.isBefore(startDate) && !t.date.isAfter(endDate);
    }).toList();
  }

  /// Get daily totals for a date range
  List<DailyTotals> getDailyTotals(DateTime startDate, DateTime endDate) {
    final transactionsInRange = getTransactionsInRange(startDate, endDate);
    final dailyMap = <String, List<Transaction>>{};

    // Group transactions by date
    for (final transaction in transactionsInRange) {
      final dateKey = transaction.dateKey;
      dailyMap.putIfAbsent(dateKey, () => []).add(transaction);
    }

    // Create daily totals
    final totals = <DailyTotals>[];
    var currentDate = startDate;

    while (!currentDate.isAfter(endDate)) {
      final dateKey = DateUtils.toDateKey(currentDate);
      final dayTransactions = dailyMap[dateKey] ?? [];
      totals.add(DailyTotals.fromTransactions(currentDate, dayTransactions));
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return totals;
  }

  /// Set month cursor
  void setMonthCursor(String cursor) {
    _monthCursor.value = cursor;
  }

  /// Navigate to previous month
  void previousMonth() {
    final newCursor = DateUtils.getRelativeMonthCursor(_monthCursor.value, -1);
    setMonthCursor(newCursor);
  }

  /// Navigate to next month
  void nextMonth() {
    final newCursor = DateUtils.getRelativeMonthCursor(_monthCursor.value, 1);
    setMonthCursor(newCursor);
  }

  /// Navigate to today
  void goToToday() {
    final todayCursor = DateUtils.getCurrentMonthCursor();
    setMonthCursor(todayCursor);
  }

  /// Create recurrence rule
  Future<Result<RecurrenceRule>> createRecurrenceRule(RecurrenceRule rule) async {
    try {
      if (!rule.isValid) {
        return Result.failure(ValidationError(message: 'Invalid recurrence rule'));
      }

      _recurrenceRules.add(rule);
      _debouncedSave();

      return Result.success(rule);
    } catch (e) {
      final error = UnknownError(message: 'Failed to create recurrence rule', details: e.toString());
      setError(error);
      return Result.failure(error);
    }
  }

  /// Create planned spend
  Future<Result<PlannedSpend>> createPlannedSpend(PlannedSpend spend) async {
    try {
      if (!spend.isValid) {
        return Result.failure(ValidationError(message: 'Invalid planned spend'));
      }

      _plannedSpends.add(spend);
      _debouncedSave();

      return Result.success(spend);
    } catch (e) {
      final error = UnknownError(message: 'Failed to create planned spend', details: e.toString());
      setError(error);
      return Result.failure(error);
    }
  }

  /// Update planned spend
  Future<Result<PlannedSpend>> updatePlannedSpend(PlannedSpend spend) async {
    try {
      if (!spend.isValid) {
        return Result.failure(ValidationError(message: 'Invalid planned spend'));
      }

      final index = _plannedSpends.indexWhere((s) => s.id == spend.id);
      if (index == -1) {
        return Result.failure(NotFoundError(message: 'Planned spend not found'));
      }

      final updatedSpend = spend.markUpdated();
      _plannedSpends[index] = updatedSpend;
      _debouncedSave();

      return Result.success(updatedSpend);
    } catch (e) {
      final error = UnknownError(message: 'Failed to update planned spend', details: e.toString());
      setError(error);
      return Result.failure(error);
    }
  }

  /// Delete planned spend
  Future<Result<void>> deletePlannedSpend(String spendId) async {
    try {
      final index = _plannedSpends.indexWhere((s) => s.id == spendId);
      if (index == -1) {
        return Result.failure(NotFoundError(message: 'Planned spend not found'));
      }

      _plannedSpends.removeAt(index);
      _debouncedSave();

      return const Result.success(null);
    } catch (e) {
      final error = UnknownError(message: 'Failed to delete planned spend', details: e.toString());
      setError(error);
      return Result.failure(error);
    }
  }

  /// Get transaction by ID
  Transaction? getTransactionById(String id) {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get recurrence rule by ID
  RecurrenceRule? getRecurrenceRuleById(String id) {
    try {
      return _recurrenceRules.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get planned spend by ID
  PlannedSpend? getPlannedSpendById(String id) {
    try {
      return _plannedSpends.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
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
