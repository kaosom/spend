import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../features/tracking/tracking_controller.dart';
import '../organisms/daily_balance_sheet.dart';

/// Grid calendar view widget
class GridCalendarView extends StatelessWidget {
  const GridCalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TrackingController>();

    return Obx(() {
      final cells = controller.gridCells;
      if (cells.isEmpty) {
        return Center(
          child: Text('No data available', style: AvidTypography.bodyMedium()),
        );
      }

      // Group cells by week (7 days)
      final weeks = <List<GridCell>>[];
      for (var i = 0; i < cells.length; i += 7) {
        final end = (i + 7 < cells.length) ? i + 7 : cells.length;
        weeks.add(cells.sublist(i, end));
      }

      return Column(
        children: [
          // Weekday headers
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AvidTokens.space2),
            child: Row(
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .map(
                    (day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: AvidTypography.labelSmall(
                            color: AvidTokens.textTertiary,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          // Calendar grid
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: weeks.length,
              itemBuilder: (context, weekIndex) {
                final week = weeks[weekIndex];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AvidTokens.space1),
                  child: Row(
                    children: List.generate(7, (dayIndex) {
                      if (dayIndex < week.length) {
                        return Expanded(
                          child: _GridCellWidget(cell: week[dayIndex]),
                        );
                      } else {
                        return const Expanded(child: SizedBox());
                      }
                    }),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

class _GridCellWidget extends StatelessWidget {
  const _GridCellWidget({required this.cell});

  final GridCell cell;

  @override
  Widget build(BuildContext context) {
    final isInMonth = cell.isInMonth;
    final isToday = cell.isToday;
    final isFuture = cell.isFuture;
    final hasObligatory = cell.hasObligatory;

    return AspectRatio(
      aspectRatio: 1,
      child: InkWell(
        onTap: () {
          Get.bottomSheet(
            DailyBalanceSheet(cell: cell),
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
          );
        },
        borderRadius: BorderRadius.circular(AvidTokens.radiusSmall),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isInMonth
                ? AvidTokens.backgroundSecondary
                : AvidTokens.backgroundPrimary,
            borderRadius: BorderRadius.circular(AvidTokens.radiusSmall),
            border: Border.all(
              color: isToday
                  ? AvidTokens.accentPrimary
                  : (isInMonth ? AvidTokens.borderPrimary : Colors.transparent),
              width: isToday ? 2 : 1,
            ),
            boxShadow: isToday
                ? [
                    BoxShadow(
                      color: AvidTokens.glowPrimary,
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Opacity(
            opacity: isFuture ? 0.4 : 1.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${cell.date.day}',
                  style:
                      AvidTypography.bodySmall(
                        color: isInMonth
                            ? (isToday
                                  ? AvidTokens.accentPrimary
                                  : AvidTokens.textPrimary)
                            : AvidTokens.textTertiary,
                      ).copyWith(
                        fontWeight: isToday
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                ),
                if (cell.expenseTotal > 0 || hasObligatory) ...[
                  const SizedBox(height: 2),
                  if (hasObligatory)
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AvidTokens.accentError,
                        shape: BoxShape.circle,
                      ),
                    )
                  else if (cell.expenseTotal > 0)
                    Text(
                      _formatAmount(cell.expenseTotal),
                      style: AvidTypography.labelSmall(
                        color: AvidTokens.accentError,
                      ).copyWith(fontSize: 9),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}k';
    }
    return amount.toStringAsFixed(0);
  }
}
