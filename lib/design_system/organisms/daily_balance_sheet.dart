import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme/tokens.dart';
import '../../core/utils/dates.dart' as AppDateUtils;
import '../../features/tracking/tracking_controller.dart';

class DailyBalanceSheet extends StatelessWidget {
  final GridCell cell;

  const DailyBalanceSheet({super.key, required this.cell});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AvidTokens.backgroundSecondary,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AvidTokens.radiusLarge),
        ),
        boxShadow: AvidTokens.shadowLarge,
      ),
      padding: const EdgeInsets.all(AvidTokens.space6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppDateUtils.DateUtils.formatDisplayDate(cell.date),
                style: AvidTokens.heading3,
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AvidTokens.textSecondary),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const SizedBox(height: AvidTokens.space6),
          _buildSummaryRow(
            title: 'Income',
            amount:
                cell.expenseTotal +
                cell.netTotal, // Re-calculating income because it's (Income - Expense = Net) -> Income = Net + Expense
            color: AvidTokens.accentSuccess,
            icon: Icons.arrow_downward,
          ),
          const SizedBox(height: AvidTokens.space4),
          _buildSummaryRow(
            title: 'Expenses',
            amount: cell.expenseTotal,
            color: AvidTokens.accentError,
            icon: Icons.arrow_upward,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AvidTokens.space4),
            child: Divider(color: AvidTokens.borderPrimary),
          ),
          _buildSummaryRow(
            title: 'Daily Balance',
            amount: cell.netTotal,
            color: AvidTokens.textPrimary,
            icon: Icons.account_balance_wallet,
            isTotal: true,
          ),
          const SizedBox(height: AvidTokens.space8),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
    bool isTotal = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AvidTokens.space2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AvidTokens.radiusMedium),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: AvidTokens.space3),
        Text(
          title,
          style: isTotal
              ? AvidTokens.heading4.copyWith(color: AvidTokens.textSecondary)
              : AvidTokens.bodyLarge,
        ),
        const Spacer(),
        Text(
          _formatCurrency(amount),
          style: isTotal
              ? AvidTokens.heading3.copyWith(color: color)
              : AvidTokens.heading4.copyWith(color: color),
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    final absAmount = amount.abs();
    final prefix = amount < 0 ? '-' : '';
    return '$prefix\$${absAmount.toStringAsFixed(2)}';
  }
}
