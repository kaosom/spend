import 'package:flutter/material.dart';
import '../../../app/theme/tokens.dart';

class InsightSummaryCards extends StatelessWidget {
  final double income;
  final double expense;

  const InsightSummaryCards({
    super.key,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildCard(
            'Ingresos',
            income,
            AvidTokens.accentSuccess,
            Icons.arrow_downward,
          ),
        ),
        const SizedBox(width: AvidTokens.space4),
        Expanded(
          child: _buildCard(
            'Gastos',
            expense,
            AvidTokens.accentError,
            Icons.arrow_upward,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(
    String title,
    double amount,
    Color accentColor,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AvidTokens.space3,
        vertical: AvidTokens.space3,
      ),
      decoration: BoxDecoration(
        color: AvidTokens.backgroundSecondary,
        borderRadius: BorderRadius.circular(AvidTokens.radiusMedium),
        boxShadow: AvidTokens.shadowSmall,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AvidTokens.space2),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: AvidTokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AvidTokens.bodyMedium.copyWith(fontSize: 13),
                ),
                Text(
                  '\$${amount.toStringAsFixed(2)}',
                  style: AvidTokens.heading4.copyWith(fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
