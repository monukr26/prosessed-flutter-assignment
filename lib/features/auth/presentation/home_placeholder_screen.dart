import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/core/theme/app_colors.dart';
import 'package:shopsphere/core/utils/constants.dart';
import 'package:shopsphere/features/auth/presentation/providers/auth_notifier.dart';
import 'package:shopsphere/features/auth/presentation/providers/auth_state.dart';

/// Temporary authenticated placeholder screen validating session & logout.
class HomePlaceholderScreen extends ConsumerWidget {
  const HomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authNotifierProvider);
    final user = authState is Authenticated ? authState.user : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ShopSphere'),
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.space24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.space24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.primary.withAlpha(25),
                      backgroundImage:
                          user?.image != null && user!.image!.isNotEmpty
                          ? NetworkImage(user.image!)
                          : null,
                      child: user?.image == null
                          ? const Icon(
                              Icons.person_outline_rounded,
                              size: 40,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                    const SizedBox(height: AppConstants.space16),
                    Text(
                      user?.fullName.isNotEmpty == true
                          ? user!.fullName
                          : (user?.username ?? 'Authenticated User'),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (user?.email != null) ...[
                      const SizedBox(height: AppConstants.space4),
                      Text(
                        user!.email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppConstants.space16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.space12,
                        vertical: AppConstants.space4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.success.withAlpha(80),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 16,
                            color: AppColors.success,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Session Active & Verified',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.space24),
                    OutlinedButton.icon(
                      onPressed: () {
                        ref.read(authNotifierProvider.notifier).logout();
                      },
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Log Out'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
