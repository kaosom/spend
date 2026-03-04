import 'dart:math' as math;
import 'package:intl/intl.dart';
import '../../core/constants/constants.dart';

/// Currency utility functions for MXN (Mexican Peso)
class CurrencyUtils {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'es_MX',
    symbol: AppConstants.currencySymbol,
    decimalDigits: AppConstants.decimalPlaces,
  );

  static final NumberFormat _decimalFormat = NumberFormat.decimalPattern(
    'es_MX',
  );

  /// Format amount as currency string
  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  /// Format amount as decimal string (without currency symbol)
  static String formatDecimal(double amount) {
    return _decimalFormat.format(amount);
  }

  /// Parse currency string to double
  static double? parseCurrency(String value) {
    try {
      // Remove currency symbol and common separators
      final cleaned = value
          .replaceAll(AppConstants.currencySymbol, '')
          .replaceAll(',', '')
          .replaceAll(' ', '')
          .trim();

      if (cleaned.isEmpty) return null;

      return double.parse(cleaned);
    } catch (e) {
      return null;
    }
  }

  /// Validate amount (positive, within limits)
  static bool isValidAmount(double amount) {
    return amount > 0 && amount <= AppConstants.maxAmount;
  }

  /// Clamp amount to valid range
  static double clampAmount(double amount) {
    if (amount < 0) return 0;
    if (amount > AppConstants.maxAmount) return AppConstants.maxAmount;
    return amount;
  }

  /// Check if amount is zero
  static bool isZero(double amount) {
    return amount.abs() < 0.01; // Handle floating point precision
  }

  /// Add two amounts safely
  static double add(double a, double b) {
    return clampAmount(a + b);
  }

  /// Subtract two amounts safely
  static double subtract(double a, double b) {
    return clampAmount(a - b);
  }

  /// Multiply amount by factor safely
  static double multiply(double amount, double factor) {
    return clampAmount(amount * factor);
  }

  /// Divide amount by divisor safely
  static double divide(double amount, double divisor) {
    if (divisor == 0) return 0;
    return clampAmount(amount / divisor);
  }

  /// Round to specified decimal places
  static double round(double amount, {int decimals = 2}) {
    final factor = math.pow(10, decimals);
    return (amount * factor).round() / factor;
  }

  /// Get absolute value
  static double abs(double amount) {
    return amount.abs();
  }

  /// Calculate percentage of amount
  static double percentage(double amount, double percent) {
    return multiply(amount, percent / 100);
  }

  /// Power function for currency calculations
  static double pow(double base, num exponent) {
    return math.pow(base, exponent).toDouble();
  }

  /// Extension methods for double to work with currency
  static double toFixed(double value, int decimals) {
    final factor = math.pow(10, decimals);
    return (value * factor).round() / factor;
  }
}

/// Extension on double for currency operations
extension CurrencyDoubleExtensions on double {
  String toCurrency() => CurrencyUtils.formatCurrency(this);
  String toDecimal() => CurrencyUtils.formatDecimal(this);
  bool isValidAmount() => CurrencyUtils.isValidAmount(this);
  double clamped() => CurrencyUtils.clampAmount(this);
  double rounded({int decimals = 2}) =>
      CurrencyUtils.round(this, decimals: decimals);
  double percentage(double percent) => CurrencyUtils.percentage(this, percent);
}
