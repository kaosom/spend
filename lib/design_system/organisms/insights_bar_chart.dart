import 'package:flutter/material.dart';
import '../../../app/theme/tokens.dart';

class InsightsBarChart extends StatefulWidget {
  final List<double> values;
  final List<String> labels;
  final double maxValue;
  final int activeIndex;
  final double activeValue; // Number to display in the black tooltip

  const InsightsBarChart({
    super.key,
    required this.values,
    required this.labels,
    required this.maxValue,
    required this.activeIndex,
    required this.activeValue,
  });

  @override
  State<InsightsBarChart> createState() => _InsightsBarChartState();
}

class _InsightsBarChartState extends State<InsightsBarChart> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    if (widget.values.isEmpty || widget.labels.isEmpty)
      return const SizedBox.shrink();

    // Ensures we don't divide by zero
    final safeMax = widget.maxValue > 0 ? widget.maxValue : 1.0;

    return Container(
      height: 220,
      padding: const EdgeInsets.symmetric(vertical: AvidTokens.space2),
      child: Stack(
        children: [
          // Background grid lines
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildGridLine('15K'),
              _buildGridLine('10K', isDashed: true),
              _buildGridLine('  5K'),
              _buildGridLine('  1K'),
              _buildGridLine('     0'),
            ],
          ),

          // The actual bars
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(left: 36.0, bottom: 20, top: 20),
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(widget.values.length, (index) {
                        final val = widget.values[index];
                        final absVal = val.abs();
                        final fillPercentage = (absVal / safeMax).clamp(
                          0.0,
                          1.0,
                        );
                        final isActive = index == widget.activeIndex;

                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: widget.values.length > 7 ? 8.0 : 16.0,
                          ),
                          child: _buildBar(
                            fillPercentage,
                            widget.labels[index],
                            isActive,
                            val >= 0,
                          ),
                        );
                      }),
                    ),

                    // The active tooltip (e.g. $10,509.09) attached to the active bar
                    if (widget.activeIndex >= 0 &&
                        widget.activeIndex < widget.values.length)
                      Positioned(
                        top: 0,
                        // We calculate the left offset manually by knowing the padding width
                        left: _calculateTooltipLeftPosition(),
                        child: FractionalTranslation(
                          translation: const Offset(-0.5, 0),
                          child: _buildTooltip(widget.activeValue),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridLine(String label, {bool isDashed = false}) {
    return Row(
      children: [
        Text(
          label,
          style: AvidTokens.labelSmall.copyWith(
            color: AvidTokens.textTertiary,
            fontSize: 10,
          ),
        ),
        const SizedBox(width: AvidTokens.space2),
        Expanded(
          child: isDashed
              ? _buildDashedLine()
              : Container(
                  height: 1,
                  color: AvidTokens.borderPrimary.withValues(alpha: 0.5),
                ),
        ),
      ],
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashSpace = 4.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: AvidTokens.textTertiary),
              ),
            );
          }),
        );
      },
    );
  }

  double _calculateTooltipLeftPosition() {
    final paddingPerBar = widget.values.length > 7 ? 8.0 : 16.0;
    // Each bar takes 14px width + (paddingPerBar * 2) margins
    final barTotalWidth = 14.0 + (paddingPerBar * 2);
    // Point at the horizontal center of the active bar
    return (widget.activeIndex * barTotalWidth) + (barTotalWidth / 2);
  }

  Widget _buildBar(
    double fillPercentage,
    String label,
    bool isActive,
    bool isPositive,
  ) {
    Color barColor;
    if (fillPercentage == 0) {
      barColor = AvidTokens.borderPrimary; // Gray if exactly 0
    } else if (isPositive) {
      barColor = AvidTokens.accentSuccess; // Green for positive cash flow
    } else {
      barColor = AvidTokens.accentError; // Red for negative cash flow
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            width: 14, // Pill shape exactly as requested
            decoration: BoxDecoration(
              color: AvidTokens.borderSecondary, // Light grey background track
              borderRadius: BorderRadius.circular(AvidTokens.radiusRound),
            ),
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: fillPercentage > 0
                  ? fillPercentage
                  : 0.05, // Minimum size
              child: Container(
                decoration: BoxDecoration(
                  color: isActive ? barColor : barColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AvidTokens.radiusRound),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AvidTokens.space2),
        Text(
          label,
          style: AvidTokens.labelSmall.copyWith(
            color: isActive ? AvidTokens.textPrimary : AvidTokens.textTertiary,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTooltip(double value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AvidTokens.accentPrimary, // Black like the design
        borderRadius: BorderRadius.circular(AvidTokens.radiusMedium),
      ),
      child: Text(
        value >= 0
            ? '+\$${value.toStringAsFixed(2)}'
            : '-\$${value.abs().toStringAsFixed(2)}',
        style: AvidTokens.labelMedium.copyWith(color: Colors.white),
      ),
    );
  }
}
