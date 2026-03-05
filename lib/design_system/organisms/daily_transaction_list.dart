import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/tokens.dart';
import '../../../models/models.dart';
import 'add_transaction_sheet.dart';

class DailyTransactionList extends StatelessWidget {
  final String dateHeader;
  final List<Transaction> transactions;
  final VoidCallback onSeeAll;

  const DailyTransactionList({
    super.key,
    required this.dateHeader,
    required this.transactions,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(dateHeader, style: AvidTokens.heading4),
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                alignment: Alignment.centerRight,
              ),
              child: Text(
                'See All',
                style: AvidTokens.labelSmall.copyWith(
                  color: AvidTokens.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AvidTokens.space3),
        ...transactions.map((tx) => _buildTransactionItem(tx)),
      ],
    );
  }

  Widget _buildTransactionItem(Transaction tx) {
    final isExpense = tx.isExpense;
    final amountColor = isExpense
        ? AvidTokens.textPrimary
        : AvidTokens.accentSuccess;
    final amountPrefix = isExpense ? '-\$' : '+\$';

    // Dummy icon logic: normally would fetch from Category provider
    IconData icon = Icons.receipt_long;
    Color iconColor = AvidTokens.accentPrimary;

    if (tx.categoryId.toLowerCase().contains('food')) {
      icon = Icons.restaurant;
      iconColor = AvidTokens.accentWarning;
    } else if (tx.categoryId.toLowerCase().contains('transport')) {
      icon = Icons.directions_bus;
      iconColor = AvidTokens.accentSuccess; // Teal/green
    }

    return GestureDetector(
      onTap: () {
        Get.bottomSheet(
          AddTransactionSheet(transactionToEdit: tx),
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: AvidTokens.space4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AvidTokens.space3),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: AvidTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (tx.note != null && tx.note!.isNotEmpty)
                        ? tx.note!
                        : 'Transaction',
                    style: AvidTokens.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(_formatTime(tx.date), style: AvidTokens.bodySmall),
                ],
              ),
            ),
            Text(
              '$amountPrefix${tx.amount.toStringAsFixed(2)}',
              style: AvidTokens.heading4.copyWith(color: amountColor),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
