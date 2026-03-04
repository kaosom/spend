import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import '../../core/utils/dates.dart';
import '../../models/models.dart';
import '../accounts/accounts_controller.dart';
import '../transactions/transactions_controller.dart';
import '../settings/settings_controller.dart';

/// Cell data for calendar grid
class GridCell extends Equatable {
  const GridCell({
    required this.date,
    required this.isInMonth,
    required this.isToday,
    required this.isFuture,
    required this.expenseTotal,
    required this.netTotal,
    required this.transactionCount,
    required this.hasObligatory,
  });

  final DateTime date;
  final bool isInMonth;
  final bool isToday;
  final bool isFuture;
  final double expenseTotal;
  final double netTotal;
  final int transactionCount;
  final bool hasObligatory;

  @override
  List<Object?> get props => [
    date,
    isInMonth,
    isToday,
    isFuture,
    expenseTotal,
    netTotal,
    transactionCount,
    hasObligatory,
  ];
}

/// Heatmap cell data
class HeatmapCell extends Equatable {
  const HeatmapCell({
    required this.date,
    required this.intensity,
    required this.expenseTotal,
    required this.transactionCount,
    required this.hasObligatory,
  });

  final DateTime date;
  final double intensity; // 0.0 to 1.0
  final double expenseTotal;
  final int transactionCount;
  final bool hasObligatory;

  @override
  List<Object?> get props => [
    date,
    intensity,
    expenseTotal,
    transactionCount,
    hasObligatory,
  ];
}

/// Controller for tracking views (Grid and Heatmap)
class TrackingController extends GetxController {
  final RxList<GridCell> _gridCells = <GridCell>[].obs;
  final RxList<List<HeatmapCell>> _heatmapCells = <List<HeatmapCell>>[].obs;
  final RxString _currentView = 'grid'.obs; // 'grid' or 'heatmap'

  List<GridCell> get gridCells => _gridCells;
  List<List<HeatmapCell>> get heatmapCells => _heatmapCells;
  String get currentView => _currentView.value;

  /// Switch to grid view
  void switchToGrid() {
    _currentView.value = 'grid';
    updateGrid();
  }

  /// Switch to heatmap view
  void switchToHeatmap() {
    _currentView.value = 'heatmap';
    updateHeatmap();
  }

  /// Update grid view for current month
  void updateGrid() {
    final transactionsController = Get.find<TransactionsController>();
    final accountsController = Get.find<AccountsController>();
    final settingsController = Get.find<SettingsController>();

    final selectedAccount = accountsController.selectedAccount;
    if (selectedAccount == null) {
      _gridCells.clear();
      return;
    }

    final monthDate = DateUtils.parseMonthCursor(
      transactionsController.monthCursor,
    );
    final monthStart = DateUtils.getMonthStart(monthDate);
    final monthEnd = DateUtils.getMonthEnd(monthDate);

    // Get transactions for the selected account in a broader range to include leading/trailing days
    final gridStart = DateUtils.getWeekStart(monthStart);
    final gridEnd = DateUtils.getWeekEnd(monthEnd);

    final transactions = transactionsController
        .getTransactionsInRange(gridStart, gridEnd)
        .where((t) => t.accountId == selectedAccount.id)
        .toList();

    final dailyTotals = transactionsController
        .getDailyTotals(gridStart, gridEnd)
        .where(
          (dt) =>
              dt.date.isAfter(gridStart.subtract(const Duration(days: 1))) &&
              dt.date.isBefore(gridEnd.add(const Duration(days: 1))),
        )
        .toList();

    // Group transactions by date for additional data
    final transactionsByDate = <String, List<Transaction>>{};
    for (final transaction in transactions) {
      final dateKey = transaction.dateKey;
      transactionsByDate.putIfAbsent(dateKey, () => []).add(transaction);
    }

    // Create grid cells
    final cells = <GridCell>[];
    var currentDate = gridStart;

    while (!currentDate.isAfter(gridEnd)) {
      final dateKey = DateUtils.toDateKey(currentDate);
      final dayTransactions = transactionsByDate[dateKey] ?? [];
      final dayTotals = dailyTotals.firstWhere(
        (dt) => dt.dateKey == dateKey,
        orElse: () =>
            DailyTotals(date: currentDate, income: 0, expense: 0, net: 0),
      );

      final hasObligatory = dayTransactions.any((t) => t.isObligatory);

      cells.add(
        GridCell(
          date: currentDate,
          isInMonth:
              currentDate.month == monthDate.month &&
              currentDate.year == monthDate.year,
          isToday: DateUtils.isToday(currentDate),
          isFuture:
              DateUtils.isFuture(currentDate) &&
              !settingsController.allowFutureTransactions,
          expenseTotal: dayTotals.expense,
          netTotal: dayTotals.net,
          transactionCount: dayTransactions.length,
          hasObligatory: hasObligatory,
        ),
      );

      currentDate = currentDate.add(const Duration(days: 1));
    }

    _gridCells.value = cells;
  }

  /// Update heatmap view
  void updateHeatmap() {
    final transactionsController = Get.find<TransactionsController>();
    final accountsController = Get.find<AccountsController>();
    final settingsController = Get.find<SettingsController>();

    final selectedAccount = accountsController.selectedAccount;
    if (selectedAccount == null) {
      _heatmapCells.clear();
      return;
    }

    final rangeDays = settingsController.heatmapRangeDays;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: rangeDays - 1));

    final transactions = transactionsController
        .getTransactionsInRange(startDate, endDate)
        .where((t) => t.accountId == selectedAccount.id)
        .toList();

    // Calculate max expense for intensity scaling
    final dailyTotals = transactionsController.getDailyTotals(
      startDate,
      endDate,
    );
    final maxExpense = dailyTotals.isEmpty
        ? 0.0
        : dailyTotals.map((dt) => dt.expense).reduce((a, b) => a > b ? a : b);

    // Group transactions by date
    final transactionsByDate = <String, List<Transaction>>{};
    for (final transaction in transactions) {
      final dateKey = transaction.dateKey;
      transactionsByDate.putIfAbsent(dateKey, () => []).add(transaction);
    }

    // Create heatmap data (7 rows for days of week, columns for weeks)
    final heatmapData = <List<HeatmapCell>>[];
    var currentDate = startDate;

    // Find the first Sunday to start the grid
    while (currentDate.weekday != DateTime.sunday) {
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    // Calculate the number of weeks needed
    final weeksNeeded =
        ((endDate.difference(currentDate).inDays / 7).ceil() + 1);

    // Create 7 rows (Sun-Sat)
    for (var dayOfWeek = 0; dayOfWeek < 7; dayOfWeek++) {
      final row = <HeatmapCell>[];
      var weekDate = currentDate.add(Duration(days: dayOfWeek));

      // Create columns for each week - ensure all rows have the same length
      for (var week = 0; week < weeksNeeded; week++) {
        // Only add cells for dates within the range
        if (weekDate.isBefore(endDate.add(const Duration(days: 7)))) {
          final dateKey = DateUtils.toDateKey(weekDate);
          final dayTransactions = transactionsByDate[dateKey] ?? [];
          final dayTotals = dailyTotals.firstWhere(
            (dt) => dt.dateKey == dateKey,
            orElse: () =>
                DailyTotals(date: weekDate, income: 0, expense: 0, net: 0),
          );

          final intensity = maxExpense == 0
              ? 0.0
              : (dayTotals.expense / maxExpense).clamp(0.0, 1.0);
          final hasObligatory = dayTransactions.any((t) => t.isObligatory);

          row.add(
            HeatmapCell(
              date: weekDate,
              intensity: intensity,
              expenseTotal: dayTotals.expense,
              transactionCount: dayTransactions.length,
              hasObligatory: hasObligatory,
            ),
          );
        } else {
          // Add empty cell to maintain consistent row length
          row.add(
            HeatmapCell(
              date: weekDate,
              intensity: 0.0,
              expenseTotal: 0.0,
              transactionCount: 0,
              hasObligatory: false,
            ),
          );
        }

        weekDate = weekDate.add(const Duration(days: 7));
      }

      heatmapData.add(row);
    }

    _heatmapCells.value = heatmapData;
  }

  /// Get grid cell for a specific date
  GridCell? getGridCellForDate(DateTime date) {
    try {
      return _gridCells.firstWhere(
        (cell) => DateUtils.isSameDay(cell.date, date),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get heatmap cell for a specific date
  HeatmapCell? getHeatmapCellForDate(DateTime date) {
    for (final row in _heatmapCells) {
      for (final cell in row) {
        if (DateUtils.isSameDay(cell.date, date)) {
          return cell;
        }
      }
    }
    return null;
  }

  /// Force refresh current view
  void refreshCurrentView() {
    if (currentView == 'grid') {
      updateGrid();
    } else {
      updateHeatmap();
    }
  }
}
