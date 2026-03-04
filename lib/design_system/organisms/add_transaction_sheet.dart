import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/dates.dart' as AppDateUtils;
import '../../features/accounts/accounts_controller.dart';
import '../../features/categories/categories_controller.dart';
import '../../features/transactions/transactions_controller.dart';
import '../../features/tracking/tracking_controller.dart';
import '../../models/models.dart';

/// Bottom sheet for adding/editing transactions
class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key, this.date});

  final DateTime? date;

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _merchantController = TextEditingController();

  final _accountsController = Get.find<AccountsController>();
  final _categoriesController = Get.find<CategoriesController>();
  final _transactionsController = Get.find<TransactionsController>();
  final _trackingController = Get.find<TrackingController>();

  String _selectedType = AppConstants.transactionTypeExpense;
  Account? _selectedAccount;
  Category? _selectedCategory;
  late DateTime _selectedDate;
  bool _isObligatory = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.date ?? DateTime.now();
    _selectedAccount =
        _accountsController.selectedAccount ??
        (_accountsController.activeAccounts.isNotEmpty
            ? _accountsController.activeAccounts.first
            : null);
    _selectedCategory = _categoriesController.activeCategories.isNotEmpty
        ? _categoriesController.activeCategories.first
        : null;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _merchantController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AvidTokens.accentPrimary,
              onPrimary: AvidTokens.textPrimary,
              surface: AvidTokens.backgroundSecondary,
              onSurface: AvidTokens.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccount == null) {
      if (_accountsController.activeAccounts.isNotEmpty) {
        _selectedAccount = _accountsController.activeAccounts.firstWhere(
          (acc) => acc.name.toLowerCase() == 'cash',
          orElse: () => _accountsController.activeAccounts.first,
        );
      } else {
        Get.snackbar(
          'Error',
          'No accounts available',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }
    }
    if (_selectedCategory == null) {
      Get.snackbar(
        'Error',
        'Please select a category',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      Get.snackbar(
        'Error',
        'Please enter a valid amount',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final result = await _transactionsController.createTransaction(
      amount: amount,
      date: _selectedDate,
      accountId: _selectedAccount!.id,
      categoryId: _selectedCategory!.id,
      type: _selectedType,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      merchant: _merchantController.text.trim().isEmpty
          ? null
          : _merchantController.text.trim(),
      isObligatory: _isObligatory,
    );

    if (result.isSuccess) {
      _trackingController.refreshCurrentView();
      Get.back();
      Get.snackbar(
        'Éxito',
        'Transacción agregada exitosamente',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AvidTokens.backgroundTertiary,
        colorText: AvidTokens.textPrimary,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Error',
        result.error?.message ?? 'Fallo al crear la transacción',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AvidTokens.accentError,
        colorText: AvidTokens.textPrimary,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: BoxDecoration(
          gradient: AvidTokens.gradientCard,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AvidTokens.radiusExtraLarge),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 30,
              spreadRadius: 0,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AvidTokens.space6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar - Modern and clean
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: AvidTokens.space6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AvidTokens.borderPrimary,
                          AvidTokens.borderPrimary.withOpacity(0.5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(
                        AvidTokens.radiusRound,
                      ),
                    ),
                  ),
                ),

                // Title
                Text('Agregar Transacción', style: AvidTypography.heading3()),
                const SizedBox(height: AvidTokens.space6),

                // Form
                Form(
                  key: _formKey,
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Transaction type toggle
                          Container(
                            decoration: BoxDecoration(
                              color: AvidTokens.backgroundSecondary,
                              borderRadius: BorderRadius.circular(
                                AvidTokens.radiusMedium,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _TypeToggleButton(
                                    label: 'Gasto',
                                    icon: Icons.remove_circle_outline,
                                    isSelected:
                                        _selectedType ==
                                        AppConstants.transactionTypeExpense,
                                    color: AvidTokens.accentError,
                                    onTap: () => setState(
                                      () => _selectedType =
                                          AppConstants.transactionTypeExpense,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: _TypeToggleButton(
                                    label: 'Ingreso',
                                    icon: Icons.add_circle_outline,
                                    isSelected:
                                        _selectedType ==
                                        AppConstants.transactionTypeIncome,
                                    color: AvidTokens.accentSuccess,
                                    onTap: () => setState(
                                      () => _selectedType =
                                          AppConstants.transactionTypeIncome,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AvidTokens.space4),

                          // Amount
                          TextFormField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: AvidTypography.heading3(),
                            decoration: InputDecoration(
                              labelText: 'Monto (MXN)',
                              labelStyle: AvidTypography.bodyMedium(),
                              hintText: '0.00',
                              prefixIcon: const Icon(Icons.attach_money),
                              prefixText: '\$ ',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El monto es obligatorio';
                              }
                              final amount = double.tryParse(value.trim());
                              if (amount == null || amount <= 0) {
                                return 'Ingresa un monto válido';
                              }
                              if (amount > AppConstants.maxAmount) {
                                return 'Monto demasiado alto';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AvidTokens.space4),

                          // Category selector
                          Obx(() {
                            final categories =
                                _categoriesController.activeCategories;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Category',
                                  style: AvidTypography.labelLarge(),
                                ),
                                const SizedBox(height: AvidTokens.space2),
                                SizedBox(
                                  height: 50,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: categories.length,
                                    itemBuilder: (context, index) {
                                      final category = categories[index];
                                      final isSelected =
                                          _selectedCategory?.id == category.id;
                                      final colorValue = Color(
                                        int.parse(
                                          category.displayColor.replaceFirst(
                                            '#',
                                            '0xFF',
                                          ),
                                        ),
                                      );
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: AvidTokens.space2,
                                        ),
                                        child: GestureDetector(
                                          onTap: () => setState(
                                            () => _selectedCategory = category,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: AvidTokens.space3,
                                              vertical: AvidTokens.space2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? colorValue
                                                  : AvidTokens
                                                        .backgroundSecondary,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AvidTokens.radiusMedium,
                                                  ),
                                              border: Border.all(
                                                color: isSelected
                                                    ? colorValue
                                                    : AvidTokens.borderPrimary,
                                                width: isSelected ? 2 : 1,
                                              ),
                                              boxShadow: isSelected
                                                  ? [
                                                      BoxShadow(
                                                        color: colorValue
                                                            .withOpacity(0.3),
                                                        blurRadius: 8,
                                                        spreadRadius: 0,
                                                      ),
                                                    ]
                                                  : null,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  _getIconData(category.icon),
                                                  color: isSelected
                                                      ? Colors.white
                                                      : AvidTokens
                                                            .textSecondary,
                                                  size: 18,
                                                ),
                                                const SizedBox(
                                                  width: AvidTokens.space1,
                                                ),
                                                Text(
                                                  category.name,
                                                  style:
                                                      AvidTypography.labelSmall(
                                                        color: isSelected
                                                            ? Colors.white
                                                            : AvidTokens
                                                                  .textSecondary,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          }),
                          const SizedBox(height: AvidTokens.space4),

                          // Date selector
                          GestureDetector(
                            onTap: _selectDate,
                            child: Container(
                              padding: const EdgeInsets.all(AvidTokens.space4),
                              decoration: BoxDecoration(
                                color: AvidTokens.backgroundSecondary,
                                borderRadius: BorderRadius.circular(
                                  AvidTokens.radiusMedium,
                                ),
                                border: Border.all(
                                  color: AvidTokens.borderPrimary,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    color: AvidTokens.textSecondary,
                                  ),
                                  const SizedBox(width: AvidTokens.space3),
                                  Text(
                                    AppDateUtils.DateUtils.formatDisplayDate(
                                      _selectedDate,
                                    ),
                                    style: AvidTypography.bodyMedium(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AvidTokens.space4),

                          // Merchant (optional)
                          TextFormField(
                            controller: _merchantController,
                            style: AvidTypography.bodyLarge(),
                            decoration: InputDecoration(
                              labelText: 'Comercio (opcional)',
                              labelStyle: AvidTypography.bodyMedium(),
                              prefixIcon: const Icon(Icons.store),
                            ),
                          ),
                          const SizedBox(height: AvidTokens.space4),

                          // Note (optional)
                          TextFormField(
                            controller: _noteController,
                            style: AvidTypography.bodyLarge(),
                            maxLines: 2,
                            decoration: InputDecoration(
                              labelText: 'Nota (opcional)',
                              labelStyle: AvidTypography.bodyMedium(),
                              prefixIcon: const Icon(Icons.note),
                            ),
                          ),
                          const SizedBox(height: AvidTokens.space4),

                          // Obligatory toggle
                          Container(
                            decoration: BoxDecoration(
                              color: AvidTokens.backgroundSecondary,
                              borderRadius: BorderRadius.circular(
                                AvidTokens.radiusMedium,
                              ),
                            ),
                            child: SwitchListTile(
                              title: Text(
                                'Marcar como obligatorio',
                                style: AvidTypography.bodyMedium(),
                              ),
                              subtitle: Text(
                                'Pago fijo requerido',
                                style: AvidTypography.bodySmall(),
                              ),
                              value: _isObligatory,
                              onChanged: (value) =>
                                  setState(() => _isObligatory = value),
                              activeThumbColor: AvidTokens.accentError,
                            ),
                          ),
                          const SizedBox(height: AvidTokens.space8),

                          // Submit button - Futuristic and clean
                          Container(
                            decoration: BoxDecoration(
                              gradient:
                                  _selectedType ==
                                      AppConstants.transactionTypeIncome
                                  ? AvidTokens.gradientSuccess
                                  : AvidTokens.gradientPrimary,
                              borderRadius: BorderRadius.circular(
                                AvidTokens.radiusLarge,
                              ),
                              boxShadow: AvidTokens.shadowGlowSubtle,
                            ),
                            child: ElevatedButton(
                              onPressed: _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: AvidTokens.space5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AvidTokens.radiusLarge,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Agregar Transacción',
                                style: AvidTypography.labelLarge(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'movie':
        return Icons.movie;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'bolt':
        return Icons.bolt;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'attach_money':
        return Icons.attach_money;
      case 'category':
        return Icons.category;
      default:
        return Icons.category;
    }
  }
}

class _TypeToggleButton extends StatelessWidget {
  const _TypeToggleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AvidTokens.space3),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [color, color.withOpacity(0.8)])
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(AvidTokens.radiusMedium),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AvidTokens.textTertiary,
              size: 20,
            ),
            const SizedBox(width: AvidTokens.space2),
            Text(
              label,
              style: AvidTypography.labelMedium(
                color: isSelected ? Colors.white : AvidTokens.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
