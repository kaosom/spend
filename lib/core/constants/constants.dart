/// App-wide constants for Avid Spend
class AppConstants {
  // App info
  static const String appName = 'Avid Spend';
  static const String appVersion = '1.0.0';

  // Storage
  static const String storageVersion = 'v1';
  static const String encryptedStorageKey = 'avid_spend_${storageVersion}_encrypted';
  static const String encryptionKeyKeychainKey = 'avid_spend_encryption_key';

  // Database
  static const String databaseName = 'avid_spend.db';
  static const int databaseVersion = 1;

  // Date formats
  static const String dateKeyFormat = 'yyyy-MM-dd'; // For date keys
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String shortDateFormat = 'MM/dd';
  static const String monthYearFormat = 'MMMM yyyy';

  // Currency
  static const String currencyCode = 'MXN';
  static const String currencySymbol = '\$';
  static const int decimalPlaces = 2;

  // UI Constants
  static const double minTouchTarget = 44.0;
  static const double borderRadiusSmall = 6.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusExtraLarge = 16.0;

  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 200);
  static const Duration animationSlow = Duration(milliseconds: 300);

  // Debounce delays
  static const Duration debounceShort = Duration(milliseconds: 100);
  static const Duration debounceNormal = Duration(milliseconds: 250);
  static const Duration debounceLong = Duration(milliseconds: 500);

  // Limits
  static const int maxNameLength = 50;
  static const int maxNoteLength = 200;
  static const int maxMerchantLength = 100;
  static const double maxAmount = 999999.99;
  static const int maxRecurringOccurrences = 365; // 1 year max

  // Heatmap ranges
  static const int heatmapRange30Days = 30;
  static const int heatmapRange90Days = 90;
  static const int heatmapRange365Days = 365;

  // Default settings
  static const bool defaultAllowFutureTransactions = false;
  static const String defaultHeatmapRange = '90'; // 90 days
  static const double defaultSafetyBuffer = 1000.0; // MXN

  // Recurrence patterns
  static const String recurrenceWeekly = 'weekly';
  static const String recurrenceBiweekly = 'biweekly';
  static const String recurrenceCustom = 'custom';

  // Account types
  static const String accountTypeCash = 'cash';
  static const String accountTypeDebit = 'debit';
  static const String accountTypeCredit = 'credit';

  // Transaction types
  static const String transactionTypeIncome = 'income';
  static const String transactionTypeExpense = 'expense';

  // Validation messages
  static const String validationRequired = 'This field is required';
  static const String validationInvalidAmount = 'Please enter a valid amount';
  static const String validationAmountTooLarge = 'Amount cannot exceed \$$maxAmount';
  static const String validationNameTooLong = 'Name cannot exceed $maxNameLength characters';
  static const String validationNoteTooLong = 'Note cannot exceed $maxNoteLength characters';

  // Error messages
  static const String errorGeneric = 'An unexpected error occurred';
  static const String errorStorageRead = 'Failed to load data';
  static const String errorStorageWrite = 'Failed to save data';
  static const String errorEncryption = 'Security error occurred';
  static const String errorNetwork = 'Network connection error';

  // Success messages
  static const String successSaved = 'Saved successfully';
  static const String successDeleted = 'Deleted successfully';
  static const String successRestored = 'Restored successfully';

  // Confirmation messages
  static const String confirmDelete = 'Are you sure you want to delete this item?';
  static const String confirmArchive = 'Are you sure you want to archive this item?';

  // Empty states
  static const String emptyAccounts = 'No accounts yet';
  static const String emptyTransactions = 'No transactions yet';
  static const String emptyCategories = 'No categories yet';

  // Feature flags (for future use)
  static const bool featureTransfers = false;
  static const bool featureBudgets = false;
  static const bool featureReports = false;
}
