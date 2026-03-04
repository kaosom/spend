import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/constants.dart';

/// Account model for storing account information
class Account extends Equatable {
  const Account({
    required this.id,
    required this.name,
    required this.type,
    this.colorPreset = 'blue',
    this.sortIndex = 0,
    this.isArchived = false,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String type; // cash, debit, credit
  final String colorPreset;
  final int sortIndex;
  final bool isArchived;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Create a new account with default values
  factory Account.create({
    required String name,
    required String type,
    String? colorPreset,
  }) {
    final now = DateTime.now();
    return Account(
      id: const Uuid().v4(),
      name: name.trim(),
      type: type,
      colorPreset: colorPreset ?? 'blue',
      sortIndex: 0,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create account from JSON
  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
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
      'type': type,
      'colorPreset': colorPreset,
      'sortIndex': sortIndex,
      'isArchived': isArchived,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  /// Create a copy with updated fields
  Account copyWith({
    String? id,
    String? name,
    String? type,
    String? colorPreset,
    int? sortIndex,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      colorPreset: colorPreset ?? this.colorPreset,
      sortIndex: sortIndex ?? this.sortIndex,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Mark as updated
  Account markUpdated() {
    return copyWith(updatedAt: DateTime.now());
  }

  /// Archive the account
  Account archive() {
    return copyWith(isArchived: true, updatedAt: DateTime.now());
  }

  /// Restore the account
  Account restore() {
    return copyWith(isArchived: false, updatedAt: DateTime.now());
  }

  /// Validate account data
  bool get isValid {
    return name.trim().isNotEmpty &&
        name.trim().length <= AppConstants.maxNameLength &&
        _isValidType(type);
  }

  static bool _isValidType(String type) {
    return [
      AppConstants.accountTypeCash,
      AppConstants.accountTypeDebit,
      AppConstants.accountTypeCredit,
    ].contains(type);
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
      default:
        return '#3B82F6'; // default blue
    }
  }

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    colorPreset,
    sortIndex,
    isArchived,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'Account(id: $id, name: $name, type: $type, archived: $isArchived)';
  }
}
