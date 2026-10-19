import 'package:flutter/material.dart';
import 'package:shopsphere/core/theme/app_colors.dart';
import 'package:shopsphere/core/utils/constants.dart';
import 'package:shopsphere/features/products/domain/entities/sort_option.dart';

/// Bottom sheet allowing user to select sorting criteria with polished Material 3 design.
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                vertical: AppConstants.space4,
              ),
              child: Text(
                'Sort Products',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.space8),
            const Divider(),
            ...SortOption.values.map((option) {
              final isSelected = currentSort == option;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withAlpha(15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppConstants.radius12),
                ),
                child: ListTile(
                  dense: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radius12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.space12,
                    vertical: 2,
                  ),
                  title: Text(
                    option.label,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : theme.colorScheme.onSurface,
                      fontSize: 14,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary,
                          size: 20,
                        )
                      : null,
                  onTap: () => onSortSelected(option),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
