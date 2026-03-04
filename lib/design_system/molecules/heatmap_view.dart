import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../core/utils/dates.dart' as AppDateUtils;
import '../../features/tracking/tracking_controller.dart';

/// Heatmap view widget (GitHub-like)
class HeatmapView extends StatelessWidget {
  const HeatmapView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TrackingController>();

    return Obx(() {
      final heatmapData = controller.heatmapCells;
      if (heatmapData.isEmpty) {
        return Center(
          child: Text('No data available', style: AvidTypography.bodyMedium()),
        );
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day labels
            Padding(
              padding: const EdgeInsets.only(
                left: AvidTokens.space6,
                bottom: AvidTokens.space2,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Column(
                      children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                          .map(
                            (day) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                day,
                                style: AvidTypography.labelSmall(
                                  color: AvidTokens.textTertiary,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(width: AvidTokens.space2),
                  // Heatmap cells
                  Row(
                    children:
                        heatmapData.isNotEmpty && heatmapData[0].isNotEmpty
                        ? List.generate(
                            heatmapData[0].length,
                            (weekIndex) => Column(
                              children: List.generate(7, (dayIndex) {
                                // Safe access with bounds checking
                                if (dayIndex < heatmapData.length &&
                                    weekIndex < heatmapData[dayIndex].length) {
                                  return Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: _HeatmapCellWidget(
                                      cell: heatmapData[dayIndex][weekIndex],
                                    ),
                                  );
                                }
                                // Return empty cell if out of bounds
                                return Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: AvidTokens.backgroundSecondary,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          )
                        : [],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _HeatmapCellWidget extends StatelessWidget {
  const _HeatmapCellWidget({required this.cell});

  final HeatmapCell cell;

  @override
  Widget build(BuildContext context) {
    final intensity = cell.intensity;
    final isToday = AppDateUtils.DateUtils.isToday(cell.date);
    final hasObligatory = cell.hasObligatory;

    // Calculate color based on intensity
    Color cellColor;
    if (hasObligatory) {
      cellColor = AvidTokens.accentError;
    } else if (intensity == 0) {
      cellColor = AvidTokens.backgroundSecondary;
    } else if (intensity < 0.25) {
      cellColor = const Color(0xFF1E3A5F); // Very low intensity
    } else if (intensity < 0.5) {
      cellColor = const Color(0xFF2D4A7A); // Low intensity
    } else if (intensity < 0.75) {
      cellColor = const Color(0xFF3B5F95); // Medium intensity
    } else {
      cellColor = AvidTokens.accentPrimary; // High intensity
    }

    return Tooltip(
      message:
          '${AppDateUtils.DateUtils.formatDisplayDate(cell.date)}\n'
          'Expense: \$${cell.expenseTotal.toStringAsFixed(2)}\n'
          'Transactions: ${cell.transactionCount}',
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(2),
          border: isToday
              ? Border.all(color: AvidTokens.accentPrimary, width: 2)
              : null,
          boxShadow: isToday
              ? [
                  BoxShadow(
                    color: AvidTokens.glowPrimary,
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}
