import 'package:flutter_test/flutter_test.dart';
import 'package:avid_spend/core/utils/dates.dart';

void main() {
  group('DateUtils', () {
    test('toDateKey formats date correctly', () {
      final date = DateTime(2024, 1, 15);
      expect(DateUtils.toDateKey(date), '2024-01-15');
    });

    test('parseDateKey parses date correctly', () {
      const dateKey = '2024-01-15';
      final date = DateUtils.parseDateKey(dateKey);
      expect(date.year, 2024);
      expect(date.month, 1);
      expect(date.day, 15);
    });

    test('getMonthStart returns first day of month', () {
      final date = DateTime(2024, 3, 15);
      final monthStart = DateUtils.getMonthStart(date);
      expect(monthStart.year, 2024);
      expect(monthStart.month, 3);
      expect(monthStart.day, 1);
    });

    test('getMonthEnd returns last day of month', () {
      final date = DateTime(2024, 3, 15);
      final monthEnd = DateUtils.getMonthEnd(date);
      expect(monthEnd.year, 2024);
      expect(monthEnd.month, 3);
      expect(monthEnd.day, 31);
    });

    test('addMonthsSafe handles month transitions', () {
      final date = DateUtils.addMonthsSafe(DateTime(2024, 1, 31), 1);
      expect(date.month, 2);
      expect(date.day, 29); // 2024 is leap year
    });

    test('isSameDay compares dates correctly', () {
      final date1 = DateTime(2024, 1, 15, 10, 30);
      final date2 = DateTime(2024, 1, 15, 15, 45);
      final date3 = DateTime(2024, 1, 16, 10, 30);

      expect(DateUtils.isSameDay(date1, date2), true);
      expect(DateUtils.isSameDay(date1, date3), false);
    });

    test('isToday identifies current date', () {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      expect(DateUtils.isToday(today), true);
      expect(DateUtils.isToday(yesterday), false);
    });

    test('getWeekStart returns Sunday', () {
      // Wednesday, Jan 17, 2024
      final wednesday = DateTime(2024, 1, 17);
      final weekStart = DateUtils.getWeekStart(wednesday);

      expect(weekStart.weekday, DateTime.sunday);
      expect(weekStart.day, 14); // Sunday before Wednesday
    });

    test('parseMonthCursor handles valid input', () {
      final date = DateUtils.parseMonthCursor('2024-03');
      expect(date.year, 2024);
      expect(date.month, 3);
      expect(date.day, 1);
    });

    test('parseMonthCursor throws on invalid input', () {
      expect(() => DateUtils.parseMonthCursor('invalid'), throwsA(isA<FormatException>()));
      expect(() => DateUtils.parseMonthCursor('2024-13'), throwsA(isA<FormatException>()));
    });

    test('formatMonthCursor formats correctly', () {
      final date = DateTime(2024, 3, 15);
      expect(DateUtils.formatMonthCursor(date), '2024-03');
    });

    test('getDateRange generates correct range', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 3);
      final range = DateUtils.getDateRange(start, end);

      expect(range.length, 3);
      expect(range[0].day, 1);
      expect(range[1].day, 2);
      expect(range[2].day, 3);
    });
  });
}
