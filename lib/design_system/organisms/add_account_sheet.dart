import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../core/constants/constants.dart';
import '../../features/accounts/accounts_controller.dart';
import '../../features/tracking/tracking_controller.dart';

/// Bottom sheet for adding/editing accounts
class AddAccountSheet extends StatefulWidget {
  const AddAccountSheet({super.key});

  @override
  State<AddAccountSheet> createState() => _AddAccountSheetState();
}

class _AddAccountSheetState extends State<AddAccountSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _accountsController = Get.find<AccountsController>();
  final _trackingController = Get.find<TrackingController>();

  String _selectedType = AppConstants.accountTypeCash;
  String _selectedColor = 'blue';

  final List<Map<String, dynamic>> _accountTypes = [
    {
      'value': AppConstants.accountTypeCash,
      'label': 'Cash',
      'icon': Icons.money,
    },
    {
      'value': AppConstants.accountTypeDebit,
      'label': 'Debit',
      'icon': Icons.credit_card,
    },
    {
      'value': AppConstants.accountTypeCredit,
      'label': 'Credit',
      'icon': Icons.payment,
    },
  ];

  final List<Map<String, Color>> _colorOptions = [
    {'blue': AvidTokens.accentPrimary},
    {'purple': AvidTokens.accentSecondary},
    {'green': AvidTokens.accentSuccess},
    {'red': AvidTokens.accentError},
    {'orange': AvidTokens.accentWarning},
    {'pink': const Color(0xFFEC4899)},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final result = await _accountsController.createAccount(
      name: _nameController.text.trim(),
      type: _selectedType,
      colorPreset: _selectedColor,
    );

    if (result.isSuccess) {
      _trackingController.refreshCurrentView();
      Get.back();
      Get.snackbar(
        'Success',
        'Account created successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AvidTokens.backgroundTertiary,
        colorText: AvidTokens.textPrimary,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Error',
        result.error?.message ?? 'Failed to create account',
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
                Text('Add Account', style: AvidTypography.heading3()),
                const SizedBox(height: AvidTokens.space6),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Account name
                      TextFormField(
                        controller: _nameController,
                        style: AvidTypography.bodyLarge(),
                        decoration: InputDecoration(
                          labelText: 'Account Name',
                          labelStyle: AvidTypography.bodyMedium(),
                          hintText: 'e.g., Main Wallet',
                          prefixIcon: const Icon(Icons.account_balance_wallet),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Account name is required';
                          }
                          if (value.trim().length >
                              AppConstants.maxNameLength) {
                            return 'Name too long';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AvidTokens.space4),

                      // Account type
                      Text('Account Type', style: AvidTypography.labelLarge()),
                      const SizedBox(height: AvidTokens.space2),
                      Row(
                        children: _accountTypes.map((type) {
                          final isSelected = _selectedType == type['value'];
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: AvidTokens.space2,
                              ),
                              child: GestureDetector(
                                onTap: () => setState(
                                  () => _selectedType = type['value'] as String,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(
                                    AvidTokens.space3,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? AvidTokens.gradientPrimary
                                        : null,
                                    color: isSelected
                                        ? null
                                        : AvidTokens.backgroundSecondary,
                                    borderRadius: BorderRadius.circular(
                                      AvidTokens.radiusMedium,
                                    ),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.transparent
                                          : AvidTokens.borderPrimary,
                                    ),
                                    boxShadow: isSelected
                                        ? AvidTokens.shadowGlow
                                        : null,
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        type['icon'] as IconData,
                                        color: isSelected
                                            ? AvidTokens.textPrimary
                                            : AvidTokens.textSecondary,
                                      ),
                                      const SizedBox(height: AvidTokens.space1),
                                      Text(
                                        type['label'] as String,
                                        style: AvidTypography.labelSmall(
                                          color: isSelected
                                              ? AvidTokens.textPrimary
                                              : AvidTokens.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AvidTokens.space6),

                      // Color selection
                      Text('Color', style: AvidTypography.labelLarge()),
                      const SizedBox(height: AvidTokens.space2),
                      Row(
                        children: _colorOptions.map((colorMap) {
                          final colorName = colorMap.keys.first;
                          final colorValue = colorMap.values.first;
                          final isSelected = _selectedColor == colorName;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedColor = colorName),
                            child: Container(
                              width: 44,
                              height: 44,
                              margin: const EdgeInsets.only(
                                right: AvidTokens.space2,
                              ),
                              decoration: BoxDecoration(
                                color: colorValue,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AvidTokens.textPrimary
                                      : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: isSelected
                                    ? AvidTokens.shadowGlow
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 20,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AvidTokens.space8),

                      // Submit button - Futuristic and clean
                      Container(
                        decoration: BoxDecoration(
                          gradient: AvidTokens.gradientPrimary,
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
                            'Create Account',
                            style: AvidTypography.labelLarge(),
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
      ),
    );
  }
}
