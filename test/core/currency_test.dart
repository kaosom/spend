import 'package:flutter_test/flutter_test.dart';
import 'package:avid_spend/core/utils/currency.dart';

void main() {
  group('CurrencyUtils', () {
    test('formatCurrency formats MXN correctly', () {
      expect(CurrencyUtils.formatCurrency(1234.56), '\$1,234.56');
      expect(CurrencyUtils.formatCurrency(0), '\$0.00');
      expect(CurrencyUtils.formatCurrency(-500), '-\$500.00');
    });

    test('formatDecimal formats without symbol', () {
      expect(CurrencyUtils.formatDecimal(1234.56), '1,234.56');
      expect(CurrencyUtils.formatDecimal(0), '0.00');
    });

    test('parseCurrency handles valid input', () {
      expect(CurrencyUtils.parseCurrency('\$1,234.56'), 1234.56);
      expect(CurrencyUtils.parseCurrency('500'), 500.0);
      expect(CurrencyUtils.parseCurrency('0'), 0.0);
    });

    test('parseCurrency handles invalid input', () {
      expect(CurrencyUtils.parseCurrency('invalid'), null);
      expect(CurrencyUtils.parseCurrency(''), null);
      expect(CurrencyUtils.parseCurrency('\$'), null);
    });

    test('isValidAmount validates correctly', () {
      expect(CurrencyUtils.isValidAmount(100.50), true);
      expect(CurrencyUtils.isValidAmount(0.01), true);
      expect(CurrencyUtils.isValidAmount(0), false);
      expect(CurrencyUtils.isValidAmount(-100), false);
      expect(CurrencyUtils.isValidAmount(100000), false); // Over max
    });

    test('clampAmount enforces limits', () {
      expect(CurrencyUtils.clampAmount(100.50), 100.50);
      expect(CurrencyUtils.clampAmount(-50), 0);
      expect(CurrencyUtils.clampAmount(100000), 999999.99); // Max amount
    });

    test('add performs safe addition', () {
      expect(CurrencyUtils.add(100, 50), 150);
      expect(CurrencyUtils.add(999999, 1), 999999.99); // Clamped
    });

    test('subtract performs safe subtraction', () {
      expect(CurrencyUtils.subtract(100, 50), 50);
      expect(CurrencyUtils.subtract(50, 100), 0); // Clamped
    });

    test('multiply performs safe multiplication', () {
      expect(CurrencyUtils.multiply(100, 2), 200);
      expect(CurrencyUtils.multiply(500000, 3), 999999.99); // Clamped
    });

    test('round rounds to specified decimals', () {
      expect(CurrencyUtils.round(123.456, decimals: 2), 123.46);
      expect(CurrencyUtils.round(123.454, decimals: 2), 123.45);
    });

    test('percentage calculates correctly', () {
      expect(CurrencyUtils.percentage(1000, 10), 100);
      expect(CurrencyUtils.percentage(200, 25), 50);
    });
  });

  group('CurrencyDoubleExtensions', () {
    test('toCurrency extension works', () {
      expect(1234.56.toCurrency(), '\$1,234.56');
    });

    test('toDecimal extension works', () {
      expect(1234.56.toDecimal(), '1,234.56');
    });

    test('isValidAmount extension works', () {
      expect(100.50.isValidAmount(), true);
      expect((-50.0).isValidAmount(), false);
    });

    test('clamped extension works', () {
      expect(100000.0.clamped(), 999999.99);
    });

    test('rounded extension works', () {
      expect(123.456.rounded(), 123.46);
    });

    test('percentage extension works', () {
      expect(1000.0.percentage(10), 100);
    });
  });
}
