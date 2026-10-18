import 'package:flutter/material.dart';
import 'package:shopsphere/core/utils/constants.dart';

/// Accessible Quantity Selector with minimum 48dp tap targets.
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
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withAlpha(80),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement button
          IconButton(
            icon: const Icon(Icons.remove_rounded),
            tooltip: 'Decrease quantity',
            onPressed: canDecrement ? onDecrement : null,
            constraints: const BoxConstraints(
              minWidth: AppConstants.minTouchTarget,
              minHeight: AppConstants.minTouchTarget,
            ),
          ),

          // Quantity indicator
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.space12,
            ),
            child: Text(
              '$quantity',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Increment button
          IconButton(
            icon: const Icon(Icons.add_rounded),
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
