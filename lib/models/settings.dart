import 'package:equatable/equatable.dart';
import 'account.dart';
import 'category.dart';
import 'transaction.dart';
import 'recurrence_rule.dart';
import 'planned_spend.dart';
import '../core/constants/constants.dart';

/// App settings model
class AppSettings extends Equatable {
  const AppSettings({
    this.selectedAccountId,
    this.monthCursor,
    this.heatmapRange = AppConstants.defaultHeatmapRange,
    this.allowFutureTransactions = AppConstants.defaultAllowFutureTransactions,
    this.safetyBuffer = AppConstants.defaultSafetyBuffer,
  });

  final String? selectedAccountId;
  final String? monthCursor;
  final String heatmapRange;
  final bool allowFutureTransactions;
  final double safetyBuffer;

  /// Create default settings
  factory AppSettings.defaults() {
    return const AppSettings(
      selectedAccountId: null,
      monthCursor: null,
      heatmapRange: AppConstants.defaultHeatmapRange,
      allowFutureTransactions: AppConstants.defaultAllowFutureTransactions,
      safetyBuffer: AppConstants.defaultSafetyBuffer,
    );
  }

  /// Create settings from JSON
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      selectedAccountId: json['selectedAccountId'] as String?,
      monthCursor: json['monthCursor'] as String?,
      heatmapRange: json['heatmapRange'] as String? ?? AppConstants.defaultHeatmapRange,
      allowFutureTransactions: json['allowFutureTransactions'] as bool? ?? AppConstants.defaultAllowFutureTransactions,
      safetyBuffer: (json['safetyBuffer'] as num?)?.toDouble() ?? AppConstants.defaultSafetyBuffer,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'selectedAccountId': selectedAccountId,
      'monthCursor': monthCursor,
      'heatmapRange': heatmapRange,
      'allowFutureTransactions': allowFutureTransactions,
      'safetyBuffer': safetyBuffer,
    };
  }

  /// Create a copy with updated fields
  AppSettings copyWith({
    String? selectedAccountId,
    String? monthCursor,
    String? heatmapRange,
    bool? allowFutureTransactions,
    double? safetyBuffer,
  }) {
    return AppSettings(
      selectedAccountId: selectedAccountId ?? this.selectedAccountId,
      monthCursor: monthCursor ?? this.monthCursor,
      heatmapRange: heatmapRange ?? this.heatmapRange,
      allowFutureTransactions: allowFutureTransactions ?? this.allowFutureTransactions,
      safetyBuffer: safetyBuffer ?? this.safetyBuffer,
    );
  }

  /// Get heatmap range in days
  int get heatmapRangeDays {
    switch (heatmapRange) {
      case '30':
        return 30;
      case '90':
        return 90;
      case '365':
        return 365;
      default:
        return int.tryParse(heatmapRange) ?? 90;
    }
  }

  /// Validate settings
  bool get isValid {
    return safetyBuffer >= 0 &&
           heatmapRangeDays > 0 &&
           heatmapRangeDays <= 365;
  }

  /// Get available heatmap ranges
  static List<String> get availableHeatmapRanges => ['30', '90', '365'];

  @override
  List<Object?> get props => [
    selectedAccountId,
    monthCursor,
    heatmapRange,
    allowFutureTransactions,
    safetyBuffer,
  ];

  @override
  String toString() {
    return 'AppSettings(selectedAccountId: $selectedAccountId, monthCursor: $monthCursor, heatmapRange: $heatmapRange)';
  }
}

/// App state containing all data
class AppState extends Equatable {
  const AppState({
    required this.accounts,
    required this.categories,
    required this.transactions,
    required this.recurrenceRules,
    required this.plannedSpends,
    required this.settings,
  });

  final List<Account> accounts;
  final List<Category> categories;
  final List<Transaction> transactions;
  final List<RecurrenceRule> recurrenceRules;
  final List<PlannedSpend> plannedSpends;
  final AppSettings settings;

  /// Create empty state
  factory AppState.empty() {
    return AppState(
      accounts: [],
      categories: [],
      transactions: [],
      recurrenceRules: [],
      plannedSpends: [],
      settings: AppSettings.defaults(),
    );
  }

  /// Create state from JSON
  factory AppState.fromJson(Map<String, dynamic> json) {
    return AppState(
      accounts: (json['accounts'] as List<dynamic>?)
          ?.map((e) => Account.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      transactions: (json['transactions'] as List<dynamic>?)
          ?.map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      recurrenceRules: (json['recurrenceRules'] as List<dynamic>?)
          ?.map((e) => RecurrenceRule.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      plannedSpends: (json['plannedSpends'] as List<dynamic>?)
          ?.map((e) => PlannedSpend.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      settings: json['settings'] != null
          ? AppSettings.fromJson(json['settings'] as Map<String, dynamic>)
          : AppSettings.defaults(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'accounts': accounts.map((e) => e.toJson()).toList(),
      'categories': categories.map((e) => e.toJson()).toList(),
      'transactions': transactions.map((e) => e.toJson()).toList(),
      'recurrenceRules': recurrenceRules.map((e) => e.toJson()).toList(),
      'plannedSpends': plannedSpends.map((e) => e.toJson()).toList(),
      'settings': settings.toJson(),
    };
  }

  /// Create a copy with updated fields
  AppState copyWith({
    List<Account>? accounts,
    List<Category>? categories,
    List<Transaction>? transactions,
    List<RecurrenceRule>? recurrenceRules,
    List<PlannedSpend>? plannedSpends,
    AppSettings? settings,
  }) {
    return AppState(
      accounts: accounts ?? this.accounts,
      categories: categories ?? this.categories,
      transactions: transactions ?? this.transactions,
      recurrenceRules: recurrenceRules ?? this.recurrenceRules,
      plannedSpends: plannedSpends ?? this.plannedSpends,
      settings: settings ?? this.settings,
    );
  }

  /// Get active (non-archived) accounts
  List<Account> get activeAccounts => accounts.where((a) => !a.isArchived).toList();

  /// Get archived accounts
  List<Account> get archivedAccounts => accounts.where((a) => a.isArchived).toList();

  /// Get active categories
  List<Category> get activeCategories => categories.where((c) => !c.isArchived).toList();

  /// Get archived categories
  List<Category> get archivedCategories => categories.where((c) => c.isArchived).toList();

  /// Get selected account
  Account? get selectedAccount {
    if (settings.selectedAccountId == null) return null;
    return accounts.firstWhere(
      (a) => a.id == settings.selectedAccountId,
      orElse: () => activeAccounts.first,
    );
  }

  /// Get transactions for selected account
  List<Transaction> get selectedAccountTransactions {
    if (selectedAccount == null) return [];
    return transactions.where((t) => t.accountId == selectedAccount!.id).toList();
  }

  /// Get transactions for account
  List<Transaction> getTransactionsForAccount(String accountId) {
    return transactions.where((t) => t.accountId == accountId).toList();
  }

  /// Get category by ID
  Category? getCategoryById(String categoryId) {
    return categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => categories.firstWhere(
        (c) => c.id == PresetCategories.other.id,
        orElse: () => PresetCategories.other,
      ),
    );
  }

  /// Get account by ID
  Account? getAccountById(String accountId) {
    return accounts.firstWhere((a) => a.id == accountId);
  }

  /// Get recurrence rule by ID
  RecurrenceRule? getRecurrenceRuleById(String ruleId) {
    return recurrenceRules.firstWhere((r) => r.id == ruleId);
  }

  /// Get planned spend by ID
  PlannedSpend? getPlannedSpendById(String spendId) {
    return plannedSpends.firstWhere((s) => s.id == spendId);
  }

  @override
  List<Object?> get props => [accounts, categories, transactions, recurrenceRules, plannedSpends, settings];

  @override
  String toString() {
    return 'AppState(accounts: ${accounts.length}, categories: ${categories.length}, transactions: ${transactions.length})';
  }
}
