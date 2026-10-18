import 'package:flutter/material.dart';
import 'package:shopsphere/core/utils/constants.dart';
import 'package:shopsphere/features/products/domain/entities/sort_option.dart';

/// Bottom sheet allowing user to select sorting criteria.
class SortFilterSheet extends StatelessWidget {
  final SortOption currentSort;
  final ValueChanged<SortOption> onSortSelected;

  const SortFilterSheet({
    super.key,
    required this.currentSort,
    required this.onSortSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required SortOption currentSort,
    required ValueChanged<SortOption> onSortSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SortFilterSheet(
        currentSort: currentSort,
        onSortSelected: (option) {
          Navigator.of(context).pop();
          onSortSelected(option);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppConstants.space16,
          right: AppConstants.space16,
          bottom: AppConstants.space24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.space8,
                vertical: AppConstants.space8,
              ),
              child: Text(
                'Sort Products',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            ...SortOption.values.map((option) {
              final isSelected = currentSort == option;
              return ListTile(
                title: Text(
                  option.label,
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
                trailing: isSelected
                    ? Icon(
                        Icons.check_circle_rounded,
                        color: theme.colorScheme.primary,
                      )
                    : null,
                onTap: () => onSortSelected(option),
              );
            }),
          ],
        ),
      ),
    );
  }
}
