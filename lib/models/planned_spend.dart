import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/constants.dart';
import '../core/utils/dates.dart';

/// Planned spend for prediction feature
class PlannedSpend extends Equatable {
  const PlannedSpend({
    required this.id,
    required this.amount,
    required this.date,
    required this.accountId,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final double amount;
  final DateTime date;
  final String accountId;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Create a new planned spend
  factory PlannedSpend.create({
    required double amount,
    required DateTime date,
    required String accountId,
    String? note,
  }) {
    final now = DateTime.now();
    return PlannedSpend(
      id: const Uuid().v4(),
      amount: amount,
      date: date,
      accountId: accountId,
      note: note?.trim(),
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create planned spend from JSON
  factory PlannedSpend.fromJson(Map<String, dynamic> json) {
    return PlannedSpend(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(json['date'] as int),
      accountId: json['accountId'] as String,
      note: json['note'] as String?,
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
      'note': note,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  /// Create a copy with updated fields
  PlannedSpend copyWith({
    String? id,
    double? amount,
    DateTime? date,
    String? accountId,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlannedSpend(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      accountId: accountId ?? this.accountId,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Mark as updated
  PlannedSpend markUpdated() {
    return copyWith(updatedAt: DateTime.now());
  }

  /// Validate planned spend data
  bool get isValid {
    return amount > 0 &&
        amount <= AppConstants.maxAmount &&
        accountId.trim().isNotEmpty &&
        (note == null || note!.length <= AppConstants.maxNoteLength);
  }

  /// Check if planned spend is in the future
  bool get isFuture => DateUtils.isFuture(date);

  /// Check if planned spend is in the past
  bool get isPast => DateUtils.isPast(date);

  /// Check if planned spend is today
  bool get isToday => DateUtils.isToday(date);

  /// Get date key
  String get dateKey => DateUtils.toDateKey(date);

  /// Get display date
  String get displayDate => DateUtils.formatDisplayDate(date);

  /// Get short date
  String get shortDate => DateUtils.formatShortDate(date);

  @override
  List<Object?> get props => [
    id,
    amount,
    date,
    accountId,
    note,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'PlannedSpend(id: $id, amount: $amount, date: $displayDate, account: $accountId)';
  }
}

/// Spend prediction result
class SpendPrediction extends Equatable {
  const SpendPrediction({
    required this.plannedSpend,
    required this.isSafe,
    required this.projectedBalance,
    required this.conflicts,
    required this.details,
  });

  final PlannedSpend plannedSpend;
  final bool isSafe;
  final double projectedBalance;
  final List<PredictionConflict> conflicts;
  final List<PredictionDetail> details;

  @override
  List<Object?> get props => [
    plannedSpend,
    isSafe,
    projectedBalance,
    conflicts,
    details,
  ];

  @override
  String toString() {
    return 'SpendPrediction(isSafe: $isSafe, projectedBalance: $projectedBalance, conflicts: ${conflicts.length})';
  }
}

/// Prediction conflict (upcoming obligatory payments or expenses)
class PredictionConflict extends Equatable {
  const PredictionConflict({
    required this.description,
    required this.amount,
    required this.date,
    required this.isObligatory,
  });

  final String description;
  final double amount;
  final DateTime date;
  final bool isObligatory;

  @override
  List<Object?> get props => [description, amount, date, isObligatory];

  @override
  String toString() {
    return 'PredictionConflict(description: $description, amount: $amount, date: ${DateUtils.formatDisplayDate(date)})';
  }
}

/// Prediction calculation detail
class PredictionDetail extends Equatable {
  const PredictionDetail({
    required this.description,
    required this.amount,
    required this.type, // income, expense, planned, balance
  });

  final String description;
  final double amount;
  final String type;

  @override
  List<Object?> get props => [description, amount, type];

  @override
  String toString() {
    return 'PredictionDetail(description: $description, amount: $amount, type: $type)';
  }
}
