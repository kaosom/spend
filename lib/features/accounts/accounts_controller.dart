import 'package:get/get.dart';
import '../../core/errors/app_error.dart';
import '../../models/models.dart';
import '../settings/settings_controller.dart';
import '../../core/constants/constants.dart';
import '../../core/storage/storage_service.dart';

/// Controller for managing accounts
class AccountsController extends GetxController {
  final RxList<Account> _accounts = <Account>[].obs;
  final Rxn<AppError> lastError = Rxn<AppError>();

  List<Account> get accounts => _accounts;
  List<Account> get activeAccounts =>
      _accounts.where((a) => !a.isArchived).toList();
  List<Account> get archivedAccounts =>
      _accounts.where((a) => a.isArchived).toList();

  /// Get selected account (from settings)
  Account? get selectedAccount {
    final settingsController = Get.find<SettingsController>();
    final selectedId = settingsController.selectedAccountId;
    if (selectedId == null)
      return activeAccounts.isNotEmpty ? activeAccounts.first : null;
    try {
      return _accounts.firstWhere((a) => a.id == selectedId);
    } catch (e) {
      return activeAccounts.isNotEmpty
          ? activeAccounts.first
          : (_accounts.isNotEmpty ? _accounts.first : null);
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Load accounts from storage when controller initializes
    loadAccounts();
  }

  /// Load accounts from storage
  Future<void> loadAccounts() async {
    try {
      final result = await StorageService.retrieve('accounts_data');
      if (result.isSuccess && result.data != null) {
        final data = result.data!['accounts'] as List;
        _accounts.value = data.map((e) => Account.fromJson(e)).toList();
      }

      if (_accounts.isEmpty) {
        _accounts.add(
          Account.create(
            name: 'Cash',
            type: AppConstants.accountTypeCash,
            colorPreset: 'green',
          ),
        );
        await saveAccounts();
      }
      clearError();
    } catch (e) {
      setError(
        UnknownError(message: 'Failed to load accounts', details: e.toString()),
      );
    }
  }

  /// Save accounts to storage
  Future<void> saveAccounts() async {
    try {
      final data = {'accounts': _accounts.map((e) => e.toJson()).toList()};
      await StorageService.store('accounts_data', data);
      clearError();
    } catch (e) {
      setError(
        StorageWriteError(
          message: 'Failed to save accounts',
          details: e.toString(),
        ),
      );
    }
  }

  /// Create a new account
  Future<Result<Account>> createAccount({
    required String name,
    required String type,
    String? colorPreset,
  }) async {
    try {
      final account = Account.create(
        name: name,
        type: type,
        colorPreset: colorPreset,
      );

      if (!account.isValid) {
        return Result.failure(ValidationError(message: 'Invalid account data'));
      }

      _accounts.add(account);
      await saveAccounts();

      return Result.success(account);
    } catch (e) {
      final error = UnknownError(
        message: 'Failed to create account',
        details: e.toString(),
      );
      setError(error);
      return Result.failure(error);
    }
  }

  /// Update an existing account
  Future<Result<Account>> updateAccount(Account account) async {
    try {
      if (!account.isValid) {
        return Result.failure(ValidationError(message: 'Invalid account data'));
      }

      final index = _accounts.indexWhere((a) => a.id == account.id);
      if (index == -1) {
        return Result.failure(NotFoundError(message: 'Account not found'));
      }

      final updatedAccount = account.markUpdated();
      _accounts[index] = updatedAccount;
      await saveAccounts();

      return Result.success(updatedAccount);
    } catch (e) {
      final error = UnknownError(
        message: 'Failed to update account',
        details: e.toString(),
      );
      setError(error);
      return Result.failure(error);
    }
  }

  /// Archive an account
  Future<Result<Account>> archiveAccount(String accountId) async {
    try {
      final account = _accounts.firstWhere((a) => a.id == accountId);
      final archivedAccount = account.archive();

      final index = _accounts.indexWhere((a) => a.id == accountId);
      _accounts[index] = archivedAccount;
      await saveAccounts();

      return Result.success(archivedAccount);
    } catch (e) {
      final error = NotFoundError(message: 'Account not found');
      setError(error);
      return Result.failure(error);
    }
  }

  /// Restore an archived account
  Future<Result<Account>> restoreAccount(String accountId) async {
    try {
      final account = _accounts.firstWhere((a) => a.id == accountId);
      final restoredAccount = account.restore();

      final index = _accounts.indexWhere((a) => a.id == accountId);
      _accounts[index] = restoredAccount;
      await saveAccounts();

      return Result.success(restoredAccount);
    } catch (e) {
      final error = NotFoundError(message: 'Account not found');
      setError(error);
      return Result.failure(error);
    }
  }

  /// Permanently delete an account (hard delete)
  Future<Result<void>> deleteAccount(String accountId) async {
    try {
      final index = _accounts.indexWhere((a) => a.id == accountId);
      if (index == -1) {
        return Result.failure(NotFoundError(message: 'Account not found'));
      }

      _accounts.removeAt(index);
      await saveAccounts();

      return const Result.success(null);
    } catch (e) {
      final error = UnknownError(
        message: 'Failed to delete account',
        details: e.toString(),
      );
      setError(error);
      return Result.failure(error);
    }
  }

  /// Reorder accounts
  Future<Result<void>> reorderAccounts(List<Account> reorderedAccounts) async {
    try {
      // Update sort indices
      final updatedAccounts = <Account>[];
      for (var i = 0; i < reorderedAccounts.length; i++) {
        updatedAccounts.add(reorderedAccounts[i].copyWith(sortIndex: i));
      }

      _accounts.value = updatedAccounts;
      await saveAccounts();

      return const Result.success(null);
    } catch (e) {
      final error = UnknownError(
        message: 'Failed to reorder accounts',
        details: e.toString(),
      );
      setError(error);
      return Result.failure(error);
    }
  }

  /// Get account by ID
  Account? getAccountById(String id) {
    try {
      return _accounts.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Set the selected account (updates settings)
  Future<void> selectAccount(String? accountId) async {
    try {
      // TODO: Update settings controller
      clearError();
    } catch (e) {
      setError(
        UnknownError(
          message: 'Failed to select account',
          details: e.toString(),
        ),
      );
    }
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
