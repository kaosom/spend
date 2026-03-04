import 'package:intl/intl.dart';
import '../../core/constants/constants.dart';

/// Date utility functions for Avid Spend
class DateUtils {
  static final DateFormat _dateKeyFormat = DateFormat(AppConstants.dateKeyFormat);
  static final DateFormat _displayDateFormat = DateFormat(AppConstants.displayDateFormat);
  static final DateFormat _shortDateFormat = DateFormat(AppConstants.shortDateFormat);
  static final DateFormat _monthYearFormat = DateFormat(AppConstants.monthYearFormat);

  /// Convert DateTime to date key string (YYYY-MM-DD)
  static String toDateKey(DateTime date) {
    return _dateKeyFormat.format(date);
  }

  /// Parse date key string back to DateTime (assumes local timezone)
  static DateTime parseDateKey(String dateKey) {
    return _dateKeyFormat.parse(dateKey, true).toLocal();
  }

  /// Format date for display
  static String formatDisplayDate(DateTime date) {
    return _displayDateFormat.format(date);
  }

  /// Format date as short format (MM/dd)
  static String formatShortDate(DateTime date) {
    return _shortDateFormat.format(date);
  }

  /// Format month and year
  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  /// Get start of month for given date
  static DateTime getMonthStart(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month for given date
  static DateTime getMonthEnd(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// Add months to a date safely
  static DateTime addMonthsSafe(DateTime date, int months) {
    final newYear = date.year + (date.month + months - 1) ~/ 12;
    final newMonth = (date.month + months - 1) % 12 + 1;
    final newDay = date.day;

    // Handle cases where the target month has fewer days
    final maxDaysInNewMonth = DateTime(newYear, newMonth + 1, 0).day;
    final adjustedDay = newDay > maxDaysInNewMonth ? maxDaysInNewMonth : newDay;

    return DateTime(newYear, newMonth, adjustedDay, date.hour, date.minute, date.second, date.millisecond, date.microsecond);
  }

  /// Subtract months from a date safely
  static DateTime subtractMonthsSafe(DateTime date, int months) {
    return addMonthsSafe(date, -months);
  }

  /// Get the first day of the week (Sunday) for a given date
  static DateTime getWeekStart(DateTime date) {
    final weekday = date.weekday; // 1 = Monday, 7 = Sunday in Dart
    final daysToSubtract = weekday == DateTime.sunday ? 0 : weekday;
    return date.subtract(Duration(days: daysToSubtract));
  }

  /// Get the last day of the week (Saturday) for a given date
  static DateTime getWeekEnd(DateTime date) {
    final weekStart = getWeekStart(date);
    return weekStart.add(const Duration(days: 6));
  }

  /// Check if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return isSameDay(date, now);
  }

  /// Check if date is in the future
  static bool isFuture(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final compareDate = DateTime(date.year, date.month, date.day);
    return compareDate.isAfter(today);
  }

  /// Check if date is in the past
  static bool isPast(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final compareDate = DateTime(date.year, date.month, date.day);
    return compareDate.isBefore(today);
  }

  /// Get all days in a month, organized by weeks (Sunday start)
  static List<List<DateTime>> getMonthCalendar(DateTime month) {
    final monthStart = getMonthStart(month);
    final monthEnd = getMonthEnd(month);

    final calendar = <List<DateTime>>[];
    var currentWeek = <DateTime>[];

    // Start from the week containing the first day of the month
    var currentDate = getWeekStart(monthStart);

    // Continue until we've covered the entire month and any trailing days
    while (currentDate.isBefore(monthEnd) || currentDate.isAtSameMomentAs(monthEnd) || currentWeek.isNotEmpty) {
      currentWeek.add(currentDate);

      if (currentWeek.length == 7) {
        calendar.add(List.from(currentWeek));
        currentWeek.clear();
      }

      currentDate = currentDate.add(const Duration(days: 1));

      // Stop if we've gone past the month end and completed the current week
      if (currentDate.isAfter(monthEnd) && currentWeek.isEmpty) {
        break;
      }
    }

    // Add any remaining days in the last week
    if (currentWeek.isNotEmpty) {
      calendar.add(currentWeek);
    }

    return calendar;
  }

  /// Get the number of days between two dates
  static int daysBetween(DateTime start, DateTime end) {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    return endDate.difference(startDate).inDays;
  }

  /// Get a list of dates from start to end (inclusive)
  static List<DateTime> getDateRange(DateTime start, DateTime end) {
    final dates = <DateTime>[];
    var current = start;

    while (!current.isAfter(end)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }

    return dates;
  }

  /// Parse month cursor string (YYYY-MM) and return DateTime
  static DateTime parseMonthCursor(String cursor) {
    final parts = cursor.split('-');
    if (parts.length != 2) {
      throw FormatException('Invalid month cursor format: $cursor');
    }

    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    if (month < 1 || month > 12) {
      throw FormatException('Invalid month: $month');
    }

    return DateTime(year, month, 1);
  }

  /// Format DateTime as month cursor string (YYYY-MM)
  static String formatMonthCursor(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  /// Get current month cursor
  static String getCurrentMonthCursor() {
    final now = DateTime.now();
    return formatMonthCursor(now);
  }

  /// Get relative month cursor (e.g., -1 for previous month, +1 for next month)
  static String getRelativeMonthCursor(String currentCursor, int offset) {
    final currentDate = parseMonthCursor(currentCursor);
    final targetDate = addMonthsSafe(currentDate, offset);
    return formatMonthCursor(targetDate);
  }
}
