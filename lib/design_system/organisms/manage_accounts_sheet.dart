import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../features/accounts/accounts_controller.dart';
import '../../features/tracking/tracking_controller.dart';
import '../../features/settings/settings_controller.dart';
import '../../models/models.dart';
import 'add_account_sheet.dart';

/// Bottom sheet for managing accounts
class ManageAccountsSheet extends StatelessWidget {
  const ManageAccountsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final accountsController = Get.find<AccountsController>();
    final trackingController = Get.find<TrackingController>();
    final settingsController = Get.find<SettingsController>();

    return Container(
      decoration: BoxDecoration(
        gradient: AvidTokens.gradientCard,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AvidTokens.radiusLarge),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AvidTokens.space6),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Manage Accounts', style: AvidTypography.heading3()),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    onPressed: () {
                      Get.back();
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const AddAccountSheet(),
                      );
                    },
                    color: AvidTokens.accentPrimary,
                  ),
                ],
              ),
              const SizedBox(height: AvidTokens.space6),

              // Accounts list
              Obx(() {
                final accounts = accountsController.activeAccounts;
                final selectedAccount = accountsController.selectedAccount;

                if (accounts.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(AvidTokens.space8),
                    child: Column(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 64,
                          color: AvidTokens.textTertiary,
                        ),
                        const SizedBox(height: AvidTokens.space4),
                        Text(
                          'No accounts yet',
                          style: AvidTypography.bodyMedium(),
                        ),
                        const SizedBox(height: AvidTokens.space2),
                        Text(
                          'Create your first account to get started',
                          style: AvidTypography.bodySmall(),
                        ),
                      ],
                    ),
                  );
                }

                return Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                      final account = accounts[index];
                      final isSelected = selectedAccount?.id == account.id;
                      final colorValue = Color(
                        int.parse(
                          account.displayColor.replaceFirst('#', '0xFF'),
                        ),
                      );

                      return Container(
                        margin: const EdgeInsets.only(
                          bottom: AvidTokens.space2,
                        ),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    colorValue.withOpacity(0.2),
                                    colorValue.withOpacity(0.1),
                                  ],
                                )
                              : null,
                          color: isSelected
                              ? null
                              : AvidTokens.backgroundSecondary,
                          borderRadius: BorderRadius.circular(
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
                                    color: colorValue.withOpacity(0.3),
                                    blurRadius: 12,
                                    spreadRadius: 0,
                                  ),
                                ]
                              : null,
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colorValue,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: colorValue.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Icon(
                              _getAccountIcon(account.type),
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            account.name,
                            style: AvidTypography.bodyLarge(
                              color: isSelected
                                  ? AvidTokens.textPrimary
                                  : AvidTokens.textSecondary,
                            ),
                          ),
                          subtitle: Text(
                            account.type.toUpperCase(),
                            style: AvidTypography.bodySmall(),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: colorValue)
                              : IconButton(
                                  icon: const Icon(Icons.more_vert),
                                  onPressed: () =>
                                      _showAccountOptions(context, account),
                                ),
                          onTap: () async {
                            await settingsController.setSelectedAccount(
                              account.id,
                            );
                            trackingController.refreshCurrentView();
                            Get.back();
                          },
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showAccountOptions(BuildContext context, Account account) {
    final accountsController = Get.find<AccountsController>();
    final trackingController = Get.find<TrackingController>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: AvidTokens.gradientCard,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AvidTokens.radiusLarge),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AvidTokens.space4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.archive),
                  title: Text('Archive', style: AvidTypography.bodyMedium()),
                  onTap: () async {
                    Get.back();
                    final result = await accountsController.archiveAccount(
                      account.id,
                    );
                    if (result.isSuccess) {
                      trackingController.refreshCurrentView();
                      Get.snackbar(
                        'Success',
                        'Account archived',
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: AvidTokens.backgroundTertiary,
                        colorText: AvidTokens.textPrimary,
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete,
                    color: AvidTokens.accentError,
                  ),
                  title: Text(
                    'Delete',
                    style: AvidTypography.bodyMedium(
                      color: AvidTokens.accentError,
                    ),
                  ),
                  onTap: () async {
                    Get.back();
                    final confirmed = await Get.dialog<bool>(
                      AlertDialog(
                        backgroundColor: AvidTokens.backgroundSecondary,
                        title: Text(
                          'Delete Account?',
                          style: AvidTypography.heading4(),
                        ),
                        content: Text(
                          'This will permanently delete "${account.name}". This action cannot be undone.',
                          style: AvidTypography.bodyMedium(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(result: false),
                            child: Text(
                              'Cancel',
                              style: AvidTypography.labelLarge(),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Get.back(result: true),
                            style: TextButton.styleFrom(
                              foregroundColor: AvidTokens.accentError,
                            ),
                            child: Text(
                              'Delete',
                              style: AvidTypography.labelLarge(),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      final result = await accountsController.deleteAccount(
                        account.id,
                      );
                      if (result.isSuccess) {
                        trackingController.refreshCurrentView();
                        Get.snackbar(
                          'Success',
                          'Account deleted',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: AvidTokens.backgroundTertiary,
                          colorText: AvidTokens.textPrimary,
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getAccountIcon(String type) {
    switch (type) {
      case 'cash':
        return Icons.money;
      case 'debit':
        return Icons.credit_card;
      case 'credit':
        return Icons.payment;
      default:
        return Icons.account_balance_wallet;
    }
  }
}
