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

  String? _selectedRecurrence;
  final _customDaysController = TextEditingController(text: '1');

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
    _customDaysController.dispose();
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

    RecurrenceRule? recurrenceRule;
    if (_selectedRecurrence != null) {
      if (_selectedRecurrence == AppConstants.recurrenceDaily) {
        recurrenceRule = RecurrenceRule.daily();
      } else if (_selectedRecurrence == AppConstants.recurrenceWeekly) {
        recurrenceRule = RecurrenceRule.weekly();
      } else if (_selectedRecurrence == AppConstants.recurrenceBiweekly) {
        recurrenceRule = RecurrenceRule.biweekly();
      } else if (_selectedRecurrence == AppConstants.recurrenceMonthly) {
        recurrenceRule = RecurrenceRule.monthly();
      } else if (_selectedRecurrence == AppConstants.recurrenceCustom) {
        final customDays = int.tryParse(_customDaysController.text.trim()) ?? 1;
        recurrenceRule = RecurrenceRule.custom(customDays);
      }
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
      recurrenceRule: recurrenceRule,
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: BoxDecoration(
          color: AvidTokens.backgroundPrimary,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AvidTokens.radiusExtraLarge),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        // Envuelve todo el contenido en una vista scrolleable que reaccione al teclado
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: AvidTokens.space6,
            left: AvidTokens.space6,
            right: AvidTokens.space6,
            bottom: bottomInset > 0
                ? bottomInset + AvidTokens.space4
                : AvidTokens.space8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AvidTokens.space6),
                  decoration: BoxDecoration(
                    color: AvidTokens.borderPrimary,
                    borderRadius: BorderRadius.circular(AvidTokens.radiusRound),
                  ),
                ),
              ),

              // Title
              Text('Agregar Transacción', style: AvidTypography.heading3()),
              const SizedBox(height: AvidTokens.space6),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Transaction type toggle
                    Container(
                      padding: const EdgeInsets.all(4),
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
                              icon: Icons.remove_circle,
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
                              icon: Icons.add_circle,
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
                    const SizedBox(height: AvidTokens.space6),

                    // Amount (minimalist, huge text)
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: AvidTypography.heading1().copyWith(fontSize: 48),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        filled: false,
                        hintText: '0.00',
                        hintStyle: AvidTypography.heading1().copyWith(
                          fontSize: 48,
                          color: AvidTokens.textTertiary,
                        ),
                        prefixText: '\$ ',
                        prefixStyle: AvidTypography.heading2().copyWith(
                          color: AvidTokens.textSecondary,
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty)
                          return 'El monto es obligatorio';
                        final amount = double.tryParse(value.trim());
                        if (amount == null || amount <= 0)
                          return 'Ingresa un monto válido';
                        if (amount > AppConstants.maxAmount)
                          return 'Monto demasiado alto';
                        return null;
                      },
                    ),
                    const SizedBox(height: AvidTokens.space6),

                    // Category selector (cleaner)
                    Obx(() {
                      final categories = _categoriesController.activeCategories;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Categoría',
                            style: AvidTypography.labelMedium(),
                          ),
                          const SizedBox(height: AvidTokens.space3),
                          SizedBox(
                            height: 48,
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
                                    right: AvidTokens.space3,
                                  ),
                                  child: GestureDetector(
                                    onTap: () => setState(
                                      () => _selectedCategory = category,
                                    ),
                                    child: AnimatedContainer(
                                      duration: AppConstants.animationFast,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AvidTokens.space4,
                                        vertical: AvidTokens.space2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? colorValue
                                            : AvidTokens.backgroundSecondary,
                                        borderRadius: BorderRadius.circular(
                                          AvidTokens.radiusRound,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _getIconData(category.icon),
                                            color: isSelected
                                                ? Colors.white
                                                : AvidTokens.textSecondary,
                                            size: 18,
                                          ),
                                          const SizedBox(
                                            width: AvidTokens.space2,
                                          ),
                                          Text(
                                            category.name,
                                            style: AvidTypography.labelSmall(
                                              color: isSelected
                                                  ? Colors.white
                                                  : AvidTokens.textPrimary,
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
                    const SizedBox(height: AvidTokens.space6),

                    // Grouped Clean Options (Date & Recurrence)
                    Container(
                      decoration: BoxDecoration(
                        color: AvidTokens.backgroundSecondary,
                        borderRadius: BorderRadius.circular(
                          AvidTokens.radiusLarge,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Date picker row
                          ListTile(
                            leading: const Icon(
                              Icons.calendar_today,
                              color: AvidTokens.textSecondary,
                              size: 20,
                            ),
                            title: Text(
                              'Fecha',
                              style: AvidTypography.bodyMedium(),
                            ),
                            trailing: Text(
                              AppDateUtils.DateUtils.formatDisplayDate(
                                _selectedDate,
                              ),
                              style: AvidTypography.labelMedium(
                                color: AvidTokens.accentPrimary,
                              ),
                            ),
                            onTap: _selectDate,
                          ),
                          const Divider(
                            height: 1,
                            indent: 48,
                            color: AvidTokens.borderPrimary,
                          ),

                          // Recurrence selector row
                          ListTile(
                            leading: const Icon(
                              Icons.repeat,
                              color: AvidTokens.textSecondary,
                              size: 22,
                            ),
                            title: Text(
                              'Repetir',
                              style: AvidTypography.bodyMedium(),
                            ),
                            trailing: DropdownButtonHideUnderline(
                              child: DropdownButton<String?>(
                                value: _selectedRecurrence,
                                dropdownColor: AvidTokens.backgroundSecondary,
                                icon: const Icon(Icons.unfold_more, size: 16),
                                style: AvidTypography.labelMedium(
                                  color: AvidTokens.textPrimary,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text("Nunca"),
                                  ),
                                  DropdownMenuItem(
                                    value: AppConstants.recurrenceDaily,
                                    child: Text("Diario"),
                                  ),
                                  DropdownMenuItem(
                                    value: AppConstants.recurrenceWeekly,
                                    child: Text("Semanal"),
                                  ),
                                  DropdownMenuItem(
                                    value: AppConstants.recurrenceBiweekly,
                                    child: Text("Quincenal"),
                                  ),
                                  DropdownMenuItem(
                                    value: AppConstants.recurrenceMonthly,
                                    child: Text("Mensual"),
                                  ),
                                  DropdownMenuItem(
                                    value: AppConstants.recurrenceCustom,
                                    child: Text("Custom..."),
                                  ),
                                ],
                                onChanged: (val) =>
                                    setState(() => _selectedRecurrence = val),
                              ),
                            ),
                          ),

                          if (_selectedRecurrence ==
                              AppConstants.recurrenceCustom) ...[
                            const Divider(
                              height: 1,
                              indent: 48,
                              color: AvidTokens.borderPrimary,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Cada',
                                      style: AvidTypography.bodyMedium(),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 60,
                                    child: TextFormField(
                                      controller: _customDaysController,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                        filled: true,
                                        fillColor: AvidTokens.backgroundPrimary,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'días',
                                    style: AvidTypography.bodyMedium(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AvidTokens.space6),

                    // Advanced Options Toggle (Merchant, Note, Obligatory)
                    Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: Text(
                          'Opciones Avanzadas',
                          style: AvidTypography.labelMedium(),
                        ),
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AvidTokens.backgroundSecondary,
                              borderRadius: BorderRadius.circular(
                                AvidTokens.radiusLarge,
                              ),
                            ),
                            child: Column(
                              children: [
                                // Obligatory switch
                                SwitchListTile(
                                  title: Text(
                                    'Gasto Obligatorio',
                                    style: AvidTypography.bodyMedium(),
                                  ),
                                  value: _isObligatory,
                                  onChanged: (val) =>
                                      setState(() => _isObligatory = val),
                                  activeColor: AvidTokens.accentPrimary,
                                  inactiveTrackColor: AvidTokens.borderPrimary,
                                ),
                                const Divider(
                                  height: 1,
                                  indent: 16,
                                  color: AvidTokens.borderPrimary,
                                ),
                                // Merchant
                                TextFormField(
                                  controller: _merchantController,
                                  decoration: const InputDecoration(
                                    labelText: 'Comercio / Vendedor',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.storefront,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const Divider(
                                  height: 1,
                                  indent: 48,
                                  color: AvidTokens.borderPrimary,
                                ),
                                // Note
                                TextFormField(
                                  controller: _noteController,
                                  maxLines: 2,
                                  decoration: const InputDecoration(
                                    labelText: 'Nota especial',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    prefixIcon: Icon(Icons.notes, size: 20),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AvidTokens.space8),

                    // Submit button
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AvidTokens.textPrimary,
                        foregroundColor: AvidTokens.backgroundPrimary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AvidTokens.radiusRound,
                          ),
                        ),
                      ),
                      child: Text(
                        'Guardar Transacción',
                        style: AvidTypography.labelLarge(
                          color: AvidTokens.backgroundPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
      child: AnimatedContainer(
        duration: AppConstants.animationFast,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AvidTokens.radiusMedium),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? color : AvidTokens.textTertiary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AvidTypography.labelMedium(
                color: isSelected ? color : AvidTokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
