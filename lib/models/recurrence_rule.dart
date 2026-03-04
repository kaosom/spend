import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/constants.dart';

/// Recurrence rule for recurring transactions
class RecurrenceRule extends Equatable {
  const RecurrenceRule({
    required this.id,
    required this.pattern,
    required this.interval,
    this.endDate,
    this.occurrencesLeft,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String pattern; // weekly, biweekly, custom
  final int interval; // days for custom, 1 for weekly/biweekly
  final DateTime? endDate;
  final int? occurrencesLeft;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Create a new recurrence rule
  factory RecurrenceRule.create({
    required String pattern,
    required int interval,
    DateTime? endDate,
    int? occurrencesLeft,
  }) {
    final now = DateTime.now();
    return RecurrenceRule(
      id: const Uuid().v4(),
      pattern: pattern,
      interval: interval,
      endDate: endDate,
      occurrencesLeft: occurrencesLeft,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create daily recurrence
  factory RecurrenceRule.daily() {
    return RecurrenceRule.create(
      pattern: AppConstants.recurrenceDaily,
      interval: 1,
    );
  }

  /// Create weekly recurrence
  factory RecurrenceRule.weekly() {
    return RecurrenceRule.create(
      pattern: AppConstants.recurrenceWeekly,
      interval: 1,
    );
  }

  /// Create biweekly recurrence
  factory RecurrenceRule.biweekly() {
    return RecurrenceRule.create(
      pattern: AppConstants.recurrenceBiweekly,
      interval: 1,
    );
  }

  /// Create monthly recurrence
  factory RecurrenceRule.monthly() {
    return RecurrenceRule.create(
      pattern: AppConstants.recurrenceMonthly,
      interval: 1,
    );
  }

  /// Create custom recurrence (every X days)
  factory RecurrenceRule.custom(int days) {
    return RecurrenceRule.create(
      pattern: AppConstants.recurrenceCustom,
      interval: days,
    );
  }

  /// Create recurrence rule from JSON
  factory RecurrenceRule.fromJson(Map<String, dynamic> json) {
    return RecurrenceRule(
      id: json['id'] as String,
      pattern: json['pattern'] as String,
      interval: json['interval'] as int,
      endDate: json['endDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['endDate'] as int)
          : null,
      occurrencesLeft: json['occurrencesLeft'] as int?,
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
      'pattern': pattern,
      'interval': interval,
      'endDate': endDate?.millisecondsSinceEpoch,
      'occurrencesLeft': occurrencesLeft,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  /// Create a copy with updated fields
  RecurrenceRule copyWith({
    String? id,
    String? pattern,
    int? interval,
    DateTime? endDate,
    int? occurrencesLeft,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurrenceRule(
      id: id ?? this.id,
      pattern: pattern ?? this.pattern,
      interval: interval ?? this.interval,
      endDate: endDate ?? this.endDate,
      occurrencesLeft: occurrencesLeft ?? this.occurrencesLeft,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Mark as updated
  RecurrenceRule markUpdated() {
    return copyWith(updatedAt: DateTime.now());
  }

  /// Validate recurrence rule
  bool get isValid {
    return _isValidPattern(pattern) && interval > 0;
  }

  bool _isValidPattern(String pattern) {
    return [
      AppConstants.recurrenceDaily,
      AppConstants.recurrenceWeekly,
      AppConstants.recurrenceBiweekly,
      AppConstants.recurrenceMonthly,
      AppConstants.recurrenceCustom,
    ].contains(pattern);
  }

  /// Check if rule has ended
  bool hasEnded(DateTime currentDate) {
    if (endDate != null && currentDate.isAfter(endDate!)) {
      return true;
    }
    if (occurrencesLeft != null && occurrencesLeft! <= 0) {
      return true;
    }
    return false;
  }

  /// Decrement occurrences left (for limited recurrences)
  RecurrenceRule decrementOccurrences() {
    if (occurrencesLeft == null) return this;
    return copyWith(occurrencesLeft: occurrencesLeft! - 1);
  }

  /// Get next occurrence date after the given date
  DateTime? getNextOccurrence(DateTime afterDate) {
    if (hasEnded(afterDate)) return null;

    switch (pattern) {
      case AppConstants.recurrenceDaily:
        return _getNextDailyOccurrence(afterDate);
      case AppConstants.recurrenceWeekly:
        return _getNextWeeklyOccurrence(afterDate);
      case AppConstants.recurrenceBiweekly:
        return _getNextBiweeklyOccurrence(afterDate);
      case AppConstants.recurrenceMonthly:
        return _getNextMonthlyOccurrence(afterDate);
      case AppConstants.recurrenceCustom:
        return _getNextCustomOccurrence(afterDate);
      default:
        return null;
    }
  }

  DateTime _getNextDailyOccurrence(DateTime afterDate) {
    return afterDate.add(const Duration(days: 1));
  }

  DateTime _getNextWeeklyOccurrence(DateTime afterDate) {
    return afterDate.add(const Duration(days: 7));
  }

  DateTime _getNextBiweeklyOccurrence(DateTime afterDate) {
    return afterDate.add(const Duration(days: 14));
  }

  DateTime _getNextMonthlyOccurrence(DateTime afterDate) {
    int nextMonth = afterDate.month + 1;
    int nextYear = afterDate.year;

    if (nextMonth > 12) {
      nextMonth = 1;
      nextYear++;
    }

    int daysInNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
    int nextDay = afterDate.day;

    // Si el día de origen es mayor a los días que tiene el mes destino (ej. 31 de Ene a Feb)
    if (nextDay > daysInNextMonth) {
      nextDay = daysInNextMonth;
    }

    return DateTime(
      nextYear,
      nextMonth,
      nextDay,
      afterDate.hour,
      afterDate.minute,
      afterDate.second,
    );
  }

  DateTime _getNextCustomOccurrence(DateTime afterDate) {
    return afterDate.add(Duration(days: interval));
  }

  /// Generate occurrences between two dates
  List<DateTime> generateOccurrences(DateTime startDate, DateTime endDate) {
    final occurrences = <DateTime>[];
    var currentDate = startDate;

    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      occurrences.add(currentDate);

      final nextDate = getNextOccurrence(currentDate);
      if (nextDate == null || nextDate.isAfter(endDate)) break;

      currentDate = nextDate;
    }

    return occurrences;
  }

  /// Get display text for the recurrence pattern
  String get displayText {
    switch (pattern) {
      case AppConstants.recurrenceDaily:
        return 'Diario';
      case AppConstants.recurrenceWeekly:
        return 'Semanal';
      case AppConstants.recurrenceBiweekly:
        return 'Quincenal';
      case AppConstants.recurrenceMonthly:
        return 'Mensual';
      case AppConstants.recurrenceCustom:
        return 'Cada $interval días';
      default:
        return 'Desconocido';
    }
  }

  @override
  List<Object?> get props => [
    id,
    pattern,
    interval,
    endDate,
    occurrencesLeft,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'RecurrenceRule(id: $id, pattern: $pattern, interval: $interval)';
  }
}
