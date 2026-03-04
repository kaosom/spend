import 'package:get/get.dart';
import '../../core/errors/app_error.dart';
import '../../models/models.dart';
import '../../core/storage/storage_service.dart';

/// Controller for managing categories
class CategoriesController extends GetxController {
  final RxList<Category> _categories = <Category>[].obs;
  final Rxn<AppError> lastError = Rxn<AppError>();

  List<Category> get categories => _categories;
  List<Category> get activeCategories =>
      _categories.where((c) => !c.isArchived).toList();
  List<Category> get archivedCategories =>
      _categories.where((c) => c.isArchived).toList();

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  /// Load categories from storage
  Future<void> loadCategories() async {
    try {
      // Initialize from storage or with preset categories if empty
      final result = await StorageService.retrieve('categories_data');
      if (result.isSuccess && result.data != null) {
        final data = result.data!['categories'] as List;
        _categories.value = data.map((e) => Category.fromJson(e)).toList();
      }

      if (_categories.isEmpty) {
        _categories.value = PresetCategories.all;
        await saveCategories();
      }
      clearError();
    } catch (e) {
      setError(
        UnknownError(
          message: 'Failed to load categories',
          details: e.toString(),
        ),
      );
    }
  }

  /// Save categories to storage
  Future<void> saveCategories() async {
    try {
      final data = {'categories': _categories.map((c) => c.toJson()).toList()};
      await StorageService.store('categories_data', data);
      clearError();
    } catch (e) {
      setError(
        StorageWriteError(
          message: 'Failed to save categories',
          details: e.toString(),
        ),
      );
    }
  }

  /// Create a new category
  Future<Result<Category>> createCategory({
    required String name,
    required String icon,
    String? colorPreset,
  }) async {
    try {
      final category = Category.create(
        name: name,
        icon: icon,
        colorPreset: colorPreset,
      );

      if (!category.isValid) {
        return Result.failure(
          ValidationError(message: 'Invalid category data'),
        );
      }

      _categories.add(category);
      await saveCategories();

      return Result.success(category);
    } catch (e) {
      final error = UnknownError(
        message: 'Failed to create category',
        details: e.toString(),
      );
      setError(error);
      return Result.failure(error);
    }
  }

  /// Get category by ID
  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      // Return preset category if not found
      return PresetCategories.all.firstWhere(
        (c) => c.id == id,
        orElse: () => PresetCategories.other,
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
