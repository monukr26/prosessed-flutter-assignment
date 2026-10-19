import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/router/app_router.dart';
import 'package:shopsphere/core/theme/app_colors.dart';
import 'package:shopsphere/core/utils/constants.dart';
import 'package:shopsphere/features/cart/presentation/providers/cart_notifier.dart';

/// App bar action widget showing a shopping cart icon with a reactive live badge.
class CartBadgeIcon extends ConsumerWidget {
  const CartBadgeIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalQuantity = ref.watch(
      cartNotifierProvider.select((s) => s.totalQuantity),
    );

    return IconButton(
      tooltip: 'Shopping Cart ($totalQuantity items)',
      constraints: const BoxConstraints(
        minWidth: AppConstants.minTouchTarget,
        minHeight: AppConstants.minTouchTarget,
      ),
      icon: Badge(
        isLabelVisible: totalQuantity > 0,
        label: Text(
          totalQuantity > 99 ? '99+' : totalQuantity.toString(),
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.primary,
        textColor: Colors.white,
        child: const Icon(Icons.shopping_bag_outlined, size: 22),
      ),
      onPressed: () => context.push(AppRoutes.cart),
    );
  }
}
