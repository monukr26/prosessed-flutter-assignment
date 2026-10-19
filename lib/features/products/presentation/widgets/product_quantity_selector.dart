import 'package:flutter/material.dart';
import 'package:shopsphere/core/utils/constants.dart';

/// Accessible Quantity Selector with minimum 48dp tap targets and crisp Material 3 design.
class ProductQuantitySelector extends StatelessWidget {
  final int quantity;
  final int maxStock;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const ProductQuantitySelector({
    super.key,
    required this.quantity,
    required this.maxStock,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canDecrement = quantity > 1;
    final canIncrement = quantity < maxStock;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radius12),
        border: Border.all(color: theme.colorScheme.outline, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement button
          IconButton(
            icon: const Icon(Icons.remove_rounded, size: 18),
            tooltip: 'Decrease quantity',
            onPressed: canDecrement ? onDecrement : null,
            constraints: const BoxConstraints(
              minWidth: AppConstants.minTouchTarget,
              minHeight: AppConstants.minTouchTarget,
            ),
          ),

          // Quantity indicator
          Container(
            constraints: const BoxConstraints(minWidth: 36),
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),

          // Increment button
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 18),
            tooltip: 'Increase quantity',
            onPressed: canIncrement ? onIncrement : null,
            constraints: const BoxConstraints(
              minWidth: AppConstants.minTouchTarget,
              minHeight: AppConstants.minTouchTarget,
            ),
          ),
        ],
      ),
    );
  }
}
