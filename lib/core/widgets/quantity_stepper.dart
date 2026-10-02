import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../utils/context_x.dart';

/// A "+" button that grows into − count + once the dish is in the cart.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.itemName,
    this.onIncrement,
    this.onDecrement,
  });

  final int quantity;
  final String itemName;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: AlignmentDirectional.centerEnd,
      child: quantity == 0
          ? _StepButton(
              icon: Icons.add_rounded,
              tooltip: l10n.addItem(itemName),
              filled: true,
              onPressed: onIncrement,
            )
          : Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(color: context.sufra.softAccent, borderRadius: BorderRadius.circular(14)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StepButton(icon: Icons.remove_rounded, tooltip: l10n.decrease, onPressed: onDecrement),
                  SizedBox(
                    width: 30,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
                      child: Text(
                        '$quantity',
                        key: ValueKey(quantity),
                        textAlign: TextAlign.center,
                        style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  _StepButton(icon: Icons.add_rounded, tooltip: l10n.increase, filled: true, onPressed: onIncrement),
                ],
              ),
            ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.tooltip, this.filled = false, this.onPressed});

  final IconData icon;
  final String tooltip;
  final bool filled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              onPressed!();
            },
      iconSize: 20,
      style: IconButton.styleFrom(
        fixedSize: const Size(40, 40),
        minimumSize: const Size(40, 40),
        padding: EdgeInsets.zero,
        backgroundColor: filled ? AppColors.ember : context.colors.surface,
        foregroundColor: filled ? Colors.white : AppColors.ember,
        disabledBackgroundColor: context.sufra.border,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon),
    );
  }
}
