import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/constants.dart';
import '../core/utils/dates.dart';

/// Transaction model for income and expense tracking
class Transaction extends Equatable {
  const Transaction({
    required this.id,
    required this.amount,
    required this.date,
    required this.accountId,
    required this.categoryId,
    required this.type,
    this.note,
    this.merchant,
    this.isObligatory = false,
    this.recurrenceRuleId,
    this.plannedSpendId,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final double amount;
  final DateTime date;
  final String accountId;
  final String categoryId;
  final String type; // income or expense
  final String? note;
  final String? merchant;
  final bool isObligatory;
  final String? recurrenceRuleId;
  final String? plannedSpendId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Create a new transaction with default values
  factory Transaction.create({
    required double amount,
    required DateTime date,
    required String accountId,
    required String categoryId,
    required String type,
    String? note,
    String? merchant,
    bool? isObligatory,
    String? recurrenceRuleId,
    String? plannedSpendId,
  }) {
    final now = DateTime.now();
    return Transaction(
      id: const Uuid().v4(),
      amount: amount,
      date: date,
      accountId: accountId,
      categoryId: categoryId,
      type: type,
      note: note?.trim(),
      merchant: merchant?.trim(),
      isObligatory: isObligatory ?? false,
      recurrenceRuleId: recurrenceRuleId,
      plannedSpendId: plannedSpendId,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create transaction from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(json['date'] as int),
      accountId: json['accountId'] as String,
      categoryId: json['categoryId'] as String,
      type: json['type'] as String,
      note: json['note'] as String?,
      merchant: json['merchant'] as String?,
      isObligatory: json['isObligatory'] as bool? ?? false,
      recurrenceRuleId: json['recurrenceRuleId'] as String?,
      plannedSpendId: json['plannedSpendId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'accountId': accountId,
      'categoryId': categoryId,
      'type': type,
      'note': note,
      'merchant': merchant,
      'isObligatory': isObligatory,
      'recurrenceRuleId': recurrenceRuleId,
      'plannedSpendId': plannedSpendId,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  /// Create a copy with updated fields
  Transaction copyWith({
    String? id,
    double? amount,
    DateTime? date,
    String? accountId,
    String? categoryId,
    String? type,
    String? note,
    String? merchant,
    bool? isObligatory,
    String? recurrenceRuleId,
    String? plannedSpendId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      note: note ?? this.note,
      merchant: merchant ?? this.merchant,
      isObligatory: isObligatory ?? this.isObligatory,
      recurrenceRuleId: recurrenceRuleId ?? this.recurrenceRuleId,
      plannedSpendId: plannedSpendId ?? this.plannedSpendId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Mark as updated
  Transaction markUpdated() {
    return copyWith(updatedAt: DateTime.now());
  }

  /// Validate transaction data
  bool get isValid {
    return amount > 0 &&
           amount <= AppConstants.maxAmount &&
           _isValidType(type) &&
           accountId.trim().isNotEmpty &&
           categoryId.trim().isNotEmpty &&
           _isValidNote() &&
           _isValidMerchant();
  }

  bool _isValidType(String type) {
    return [AppConstants.transactionTypeIncome, AppConstants.transactionTypeExpense]
        .contains(type);
  }

  bool _isValidNote() {
    return note == null || note!.length <= AppConstants.maxNoteLength;
  }

  bool _isValidMerchant() {
    return merchant == null || merchant!.length <= AppConstants.maxMerchantLength;
  }

  /// Check if transaction is income
  bool get isIncome => type == AppConstants.transactionTypeIncome;

  /// Check if transaction is expense
  bool get isExpense => type == AppConstants.transactionTypeExpense;

  /// Check if transaction is recurring
  bool get isRecurring => recurrenceRuleId != null;

  /// Check if transaction is from a planned spend
  bool get isFromPlannedSpend => plannedSpendId != null;

  /// Get signed amount (positive for income, negative for expense)
  double get signedAmount {
    return isIncome ? amount : -amount;
  }

  /// Get date key for grouping
  String get dateKey => DateUtils.toDateKey(date);

  /// Get display date
  String get displayDate => DateUtils.formatDisplayDate(date);

  /// Get short date
  String get shortDate => DateUtils.formatShortDate(date);

  @override
  List<Object?> get props => [
    id, amount, date, accountId, categoryId, type, note, merchant,
    isObligatory, recurrenceRuleId, plannedSpendId, createdAt, updatedAt
  ];

  @override
  String toString() {
    return 'Transaction(id: $id, amount: $amount, type: $type, date: $displayDate, account: $accountId)';
  }
}

/// Daily transaction totals
class DailyTotals extends Equatable {
  const DailyTotals({
    required this.date,
    required this.income,
    required this.expense,
    required this.net,
  });

  final DateTime date;
  final double income;
  final double expense;
  final double net;

  /// Create from list of transactions
  factory DailyTotals.fromTransactions(DateTime date, List<Transaction> transactions) {
    double income = 0;
    double expense = 0;

    for (final transaction in transactions) {
      if (transaction.isIncome) {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }

    return DailyTotals(
      date: date,
      income: income,
      expense: expense,
      net: income - expense,
    );
  }

  /// Check if day has any transactions
  bool get hasTransactions => income > 0 || expense > 0;

  /// Check if day has spending
  bool get hasSpending => expense > 0;

  /// Get date key for grouping
  String get dateKey => DateUtils.toDateKey(date);

  @override
  List<Object?> get props => [date, income, expense, net];

  @override
  String toString() {
    return 'DailyTotals(date: ${DateUtils.formatDisplayDate(date)}, income: $income, expense: $expense, net: $net)';
  }
}
