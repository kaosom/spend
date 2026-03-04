import 'package:flutter/material.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../models/models.dart';

/// Account chip widget for account selection
class AccountChip extends StatelessWidget {
  const AccountChip({
    super.key,
    required this.account,
    required this.isSelected,
    required this.onTap,
  });

  final Account account;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorString = account.displayColor;
    final colorValue = Color(int.parse(colorString.replaceFirst('#', '0xFF')));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AvidTokens.space3,
          vertical: AvidTokens.space2,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AvidTokens.backgroundTertiary
              : AvidTokens.backgroundSecondary,
          borderRadius: BorderRadius.circular(AvidTokens.radiusMedium),
          border: Border.all(
            color: isSelected ? colorValue : AvidTokens.borderPrimary,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorValue.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colorValue,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AvidTokens.space2),
            Text(
              account.name,
              style: isSelected
                  ? AvidTypography.bodyMedium(
                      color: AvidTokens.textPrimary,
                    ).copyWith(fontWeight: FontWeight.w600)
                  : AvidTypography.bodyMedium(),
            ),
          ],
        ),
      ),
    );
  }
}
