import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/constants.dart';

/// Category model for transaction categorization
class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    this.colorPreset = 'blue',
    this.sortIndex = 0,
    this.isArchived = false,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String icon; // Material icon name
  final String colorPreset;
  final int sortIndex;
  final bool isArchived;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Create a new category with default values
  factory Category.create({
    required String name,
    required String icon,
    String? colorPreset,
  }) {
    final now = DateTime.now();
    return Category(
      id: const Uuid().v4(),
      name: name.trim(),
      icon: icon,
      colorPreset: colorPreset ?? 'blue',
      sortIndex: 0,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create category from JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      colorPreset: json['colorPreset'] as String? ?? 'blue',
      sortIndex: json['sortIndex'] as int? ?? 0,
      isArchived: json['isArchived'] as bool? ?? false,
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
      'name': name,
      'icon': icon,
      'colorPreset': colorPreset,
      'sortIndex': sortIndex,
      'isArchived': isArchived,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  /// Create a copy with updated fields
  Category copyWith({
    String? id,
    String? name,
    String? icon,
    String? colorPreset,
    int? sortIndex,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      colorPreset: colorPreset ?? this.colorPreset,
      sortIndex: sortIndex ?? this.sortIndex,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Mark as updated
  Category markUpdated() {
    return copyWith(updatedAt: DateTime.now());
  }

  /// Archive the category
  Category archive() {
    return copyWith(isArchived: true, updatedAt: DateTime.now());
  }

  /// Restore the category
  Category restore() {
    return copyWith(isArchived: false, updatedAt: DateTime.now());
  }

  /// Validate category data
  bool get isValid {
    return name.trim().isNotEmpty &&
           name.trim().length <= AppConstants.maxNameLength &&
           icon.trim().isNotEmpty;
  }

  /// Get display color based on preset
  String get displayColor {
    switch (colorPreset) {
      case 'red':
        return '#EF4444';
      case 'green':
        return '#10B981';
      case 'blue':
        return '#3B82F6';
      case 'purple':
        return '#8B5CF6';
      case 'orange':
        return '#F59E0B';
      case 'pink':
        return '#EC4899';
      case 'gray':
        return '#6B7280';
      case 'teal':
        return '#14B8A6';
      default:
        return '#3B82F6'; // default blue
    }
  }

  @override
  List<Object?> get props => [id, name, icon, colorPreset, sortIndex, isArchived, createdAt, updatedAt];

  @override
  String toString() {
    return 'Category(id: $id, name: $name, icon: $icon, archived: $isArchived)';
  }
}

/// Predefined categories for quick setup
class PresetCategories {
  static const food = Category(
    id: 'preset_food',
    name: 'Food & Dining',
    icon: 'restaurant',
    colorPreset: 'orange',
    sortIndex: 0,
    isArchived: false,
  );

  static const transportation = Category(
    id: 'preset_transportation',
    name: 'Transportation',
    icon: 'directions_car',
    colorPreset: 'blue',
    sortIndex: 1,
    isArchived: false,
  );

  static const entertainment = Category(
    id: 'preset_entertainment',
    name: 'Entertainment',
    icon: 'movie',
    colorPreset: 'purple',
    sortIndex: 2,
    isArchived: false,
  );

  static const shopping = Category(
    id: 'preset_shopping',
    name: 'Shopping',
    icon: 'shopping_bag',
    colorPreset: 'pink',
    sortIndex: 3,
    isArchived: false,
  );

  static const utilities = Category(
    id: 'preset_utilities',
    name: 'Utilities',
    icon: 'bolt',
    colorPreset: 'teal',
    sortIndex: 4,
    isArchived: false,
  );

  static const healthcare = Category(
    id: 'preset_healthcare',
    name: 'Healthcare',
    icon: 'local_hospital',
    colorPreset: 'red',
    sortIndex: 5,
    isArchived: false,
  );

  static const income = Category(
    id: 'preset_income',
    name: 'Income',
    icon: 'attach_money',
    colorPreset: 'green',
    sortIndex: 6,
    isArchived: false,
  );

  static const other = Category(
    id: 'preset_other',
    name: 'Other',
    icon: 'category',
    colorPreset: 'gray',
    sortIndex: 7,
    isArchived: false,
  );

  static List<Category> get all => [
    food,
    transportation,
    entertainment,
    shopping,
    utilities,
    healthcare,
    income,
    other,
  ];
}
