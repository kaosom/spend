import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../core/utils/dates.dart' as AppDateUtils;
import '../../design_system/atoms/account_chip.dart';
import '../../design_system/molecules/grid_calendar_view.dart';
import '../../design_system/molecules/heatmap_view.dart';
import '../../design_system/organisms/add_account_sheet.dart';
import '../../design_system/organisms/add_transaction_sheet.dart';
import '../../design_system/organisms/manage_accounts_sheet.dart';
import '../accounts/accounts_controller.dart';
import '../transactions/transactions_controller.dart';
import '../tracking/tracking_controller.dart';
import '../settings/settings_controller.dart';

/// Main home screen of Avid Spend
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TrackingController _trackingController = Get.find<TrackingController>();
  final AccountsController _accountsController = Get.find<AccountsController>();
  final TransactionsController _transactionsController =
      Get.find<TransactionsController>();
  final SettingsController _settingsController = Get.find<SettingsController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Initialize tracking controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackingController.switchToGrid();
      _trackingController.updateGrid();
    });
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      if (_tabController.index == 0) {
        _trackingController.switchToGrid();
      } else {
        _trackingController.switchToHeatmap();
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AvidTokens.backgroundPrimary,
        appBar: AppBar(
          title: const Text('Avid Spend'),
          backgroundColor: AvidTokens.backgroundPrimary,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Grid'),
              Tab(text: 'Heatmap'),
            ],
            labelColor: AvidTokens.textPrimary,
            unselectedLabelColor: AvidTokens.textTertiary,
            indicatorColor: AvidTokens.accentPrimary,
            onTap: (index) {
              if (index == 0) {
                _trackingController.switchToGrid();
              } else {
                _trackingController.switchToHeatmap();
              }
            },
          ),
          actions: [
            Obx(() {
              final currentView = _trackingController.currentView;
              if (currentView == 'grid') {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        _transactionsController.previousMonth();
                        _trackingController.updateGrid();
                      },
                      tooltip: 'Previous month',
                    ),
                    Obx(() {
                      final monthDate = AppDateUtils.DateUtils.parseMonthCursor(
                        _transactionsController.monthCursor,
                      );
                      return TextButton(
                        onPressed: () {
                          _transactionsController.goToToday();
                          _trackingController.updateGrid();
                        },
                        child: Text(
                          AppDateUtils.DateUtils.formatMonthYear(monthDate),
                          style: AvidTypography.bodyMedium(
                            color: AvidTokens.textPrimary,
                          ),
                        ),
                      );
                    }),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        _transactionsController.nextMonth();
                        _trackingController.updateGrid();
                      },
                      tooltip: 'Next month',
                    ),
                  ],
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    // TODO: Navigate to settings
                    Get.snackbar(
                      'Settings',
                      'Settings screen coming soon',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: AvidTokens.backgroundSecondary,
                      colorText: AvidTokens.textPrimary,
                    );
                  },
                  tooltip: 'Settings',
                );
              }
            }),
          ],
        ),
        body: Column(
          children: [
            // Account selector section
            Obx(() {
              final accounts = _accountsController.activeAccounts;
              final selectedAccount = _accountsController.selectedAccount;

              if (accounts.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(AvidTokens.space4),
                  color: AvidTokens.backgroundSecondary,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'No accounts yet. Create one to get started.',
                          style: AvidTypography.bodyMedium(
                            color: AvidTokens.textTertiary,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const AddAccountSheet(),
                          );
                        },
                        child: const Text('Manage'),
                      ),
                    ],
                  ),
                );
              }

              return Container(
                padding: const EdgeInsets.all(AvidTokens.space4),
                color: AvidTokens.backgroundSecondary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: accounts.map((account) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    right: AvidTokens.space2,
                                  ),
                                  child: AccountChip(
                                    account: account,
                                    isSelected:
                                        selectedAccount?.id == account.id,
                                    onTap: () async {
                                      await _settingsController
                                          .setSelectedAccount(account.id);
                                      _trackingController.refreshCurrentView();
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(width: AvidTokens.space2),
                        TextButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => const ManageAccountsSheet(),
                            );
                          },
                          child: Text(
                            'Manage',
                            style: AvidTypography.labelLarge(),
                          ),
                        ),
                      ],
                    ),
                    // Heatmap range label (only for heatmap view)
                    Obx(() {
                      if (_trackingController.currentView == 'heatmap') {
                        return Padding(
                          padding: const EdgeInsets.only(
                            top: AvidTokens.space2,
                          ),
                          child: Text(
                            'Range: ${_settingsController.heatmapRange}',
                            style: AvidTypography.bodySmall(
                              color: AvidTokens.textTertiary,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              );
            }),
            // Main content area
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Grid view
                  Obx(() {
                    final selectedAccount = _accountsController.selectedAccount;
                    if (selectedAccount == null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 64,
                              color: AvidTokens.textTertiary,
                            ),
                            const SizedBox(height: AvidTokens.space4),
                            Text(
                              'Select an account to view transactions',
                              style: AvidTypography.bodyMedium(
                                color: AvidTokens.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const GridCalendarView();
                  }),
                  // Heatmap view
                  Obx(() {
                    final selectedAccount = _accountsController.selectedAccount;
                    if (selectedAccount == null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 64,
                              color: AvidTokens.textTertiary,
                            ),
                            const SizedBox(height: AvidTokens.space4),
                            Text(
                              'Select an account to view heatmap',
                              style: AvidTypography.bodyMedium(
                                color: AvidTokens.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const HeatmapView();
                  }),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            gradient: AvidTokens.gradientPrimary,
            shape: BoxShape.circle,
            boxShadow: AvidTokens.shadowGlow,
          ),
          child: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const AddTransactionSheet(),
              );
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: const Icon(Icons.add, color: AvidTokens.textPrimary),
          ),
        ),
      ),
    );
  }
}
