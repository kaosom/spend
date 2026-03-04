import 'package:get/get.dart';
import '../../core/errors/app_error.dart';
import '../../core/utils/debounce.dart';
import '../../models/models.dart';
import '../tracking/tracking_controller.dart';

/// Controller for app settings
class SettingsController extends GetxController {
  final Rx<AppSettings> _settings = AppSettings.defaults().obs;
  final Rxn<AppError> lastError = Rxn<AppError>();
  final Debounce _saveDebounce = Debounce();

  AppSettings get settings => _settings.value;
  String? get selectedAccountId => settings.selectedAccountId;
  String? get monthCursor => settings.monthCursor;
  String get heatmapRange => settings.heatmapRange;
  int get heatmapRangeDays => settings.heatmapRangeDays;
  bool get allowFutureTransactions => settings.allowFutureTransactions;
  double get safetyBuffer => settings.safetyBuffer;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  @override
  void onClose() {
    _saveDebounce.dispose();
    super.onClose();
  }

  /// Load settings from storage
  Future<void> loadSettings() async {
    try {
      // TODO: Implement storage loading
      _settings.value = AppSettings.defaults();
      clearError();
    } catch (e) {
      setError(
        UnknownError(message: 'Failed to load settings', details: e.toString()),
      );
    }
  }

  /// Debounced save to storage
  void _debouncedSave() {
    _saveDebounce.call(() async {
      try {
        await _saveToStorage();
      } catch (e) {
        setError(
          StorageWriteError(
            message: 'Failed to save settings',
            details: e.toString(),
          ),
        );
      }
    });
  }

  /// Save to storage (internal method)
  Future<void> _saveToStorage() async {
    // TODO: Implement storage saving
  }

  /// Update settings
  Future<Result<void>> updateSettings(AppSettings newSettings) async {
    try {
      if (!newSettings.isValid) {
        return Result.failure(ValidationError(message: 'Invalid settings'));
      }

      _settings.value = newSettings;
      _debouncedSave();

      // Notify other controllers of changes
      if (newSettings.selectedAccountId != settings.selectedAccountId) {
        Get.find<TrackingController>().refreshCurrentView();
      }

      return const Result.success(null);
    } catch (e) {
      final error = UnknownError(
        message: 'Failed to update settings',
        details: e.toString(),
      );
      setError(error);
      return Result.failure(error);
    }
  }

  /// Set selected account
  Future<Result<void>> setSelectedAccount(String? accountId) async {
    final newSettings = settings.copyWith(selectedAccountId: accountId);
    return updateSettings(newSettings);
  }

  /// Set month cursor
  Future<Result<void>> setMonthCursor(String? cursor) async {
    final newSettings = settings.copyWith(monthCursor: cursor);
    return updateSettings(newSettings);
  }

  /// Set heatmap range
  Future<Result<void>> setHeatmapRange(String range) async {
    final newSettings = settings.copyWith(heatmapRange: range);
    final result = await updateSettings(newSettings);
    if (result.isSuccess) {
      Get.find<TrackingController>().updateHeatmap();
    }
    return result;
  }

  /// Set allow future transactions
  Future<Result<void>> setAllowFutureTransactions(bool allow) async {
    final newSettings = settings.copyWith(allowFutureTransactions: allow);
    final result = await updateSettings(newSettings);
    if (result.isSuccess) {
      Get.find<TrackingController>().refreshCurrentView();
    }
    return result;
  }

  /// Set safety buffer
  Future<Result<void>> setSafetyBuffer(double buffer) async {
    final newSettings = settings.copyWith(safetyBuffer: buffer);
    return updateSettings(newSettings);
  }

  /// Reset settings to defaults
  Future<Result<void>> resetToDefaults() async {
    final defaultSettings = AppSettings.defaults();
    return updateSettings(defaultSettings);
  }

  /// Clear last error
  void clearError() {
    lastError.value = null;
  }

  /// Set error
  void setError(AppError error) {
    lastError.value = error;
  }
}
