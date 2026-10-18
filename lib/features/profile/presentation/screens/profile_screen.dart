import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/theme/app_colors.dart';
import 'package:shopsphere/core/utils/constants.dart';
import 'package:shopsphere/core/widgets/error_view.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/profile/presentation/providers/profile_notifier.dart';
import 'package:shopsphere/features/profile/presentation/providers/profile_state.dart';

/// Polished Material 3 user profile screen displaying avatar, user details,
/// pull-to-refresh, error retry, and secure logout.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(profileNotifierProvider);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWideScreen = screenWidth >= 768;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back to Catalogue',
          onPressed: () => context.pop(),
        ),
        title: const Text('My Profile'),
      ),
      body: switch (state.status) {
        ProfileStatus.loading when state.user == null => const Center(
          child: CircularProgressIndicator(),
        ),
        ProfileStatus.error when state.user == null => ErrorView(
          message: state.errorMessage ?? 'Failed to load user profile.',
          onRetry: () =>
              ref.read(profileNotifierProvider.notifier).loadProfile(),
        ),
        ProfileStatus.sessionExpired when state.user == null => ErrorView(
          message:
              state.errorMessage ??
              'Your session has expired. Please sign in again.',
          onRetry: () =>
              ref.read(profileNotifierProvider.notifier).loadProfile(),
        ),
        _ => RefreshIndicator(
          onRefresh: () =>
              ref.read(profileNotifierProvider.notifier).loadProfile(),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWideScreen ? 600 : double.infinity,
              ),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppConstants.space16),
                child: Column(
                  children: [
                    // Transient retry banner if background refresh failed
                    if (state.isError && state.user != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppConstants.space12),
                        margin: const EdgeInsets.only(
                          bottom: AppConstants.space16,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(
                            AppConstants.radius12,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(width: AppConstants.space12),
                            Expanded(
                              child: Text(
                                state.errorMessage ??
                                    'Could not refresh profile details.',
                                style: TextStyle(
                                  color: theme.colorScheme.onErrorContainer,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => ref
                                  .read(profileNotifierProvider.notifier)
                                  .loadProfile(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (state.user != null) ...[
                      _buildProfileHeader(context, state.user!),
                      const SizedBox(height: AppConstants.space24),
                      _buildInfoCard(context, state.user!),
                      const SizedBox(height: AppConstants.space32),
                      _buildLogoutButton(context, ref, state.isLoggingOut),
                      const SizedBox(height: AppConstants.space24),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, User user) {
    final theme = Theme.of(context);
    final initials = user.firstName.isNotEmpty && user.lastName.isNotEmpty
        ? '${user.firstName[0]}${user.lastName[0]}'.toUpperCase()
        : user.username.isNotEmpty
        ? user.username[0].toUpperCase()
        : 'U';

    return Column(
      children: [
        // User Avatar
        Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 3),
          ),
          child: ClipOval(
            child: user.image != null && user.image!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: user.image!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: Text(
                        initials,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Center(
                      child: Text(
                        initials,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  )
                : Container(
                    color: AppColors.primary.withAlpha(30),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: AppConstants.space16),

        // Full Name
        Text(
          user.fullName.isNotEmpty ? user.fullName : user.username,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.space4),

        // Username handle tag
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.space12,
            vertical: AppConstants.space4,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(AppConstants.radius16),
          ),
          child: Text(
            '@${user.username}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, User user) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radius16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.space16,
          vertical: AppConstants.space12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: AppConstants.space4,
                top: AppConstants.space4,
                bottom: AppConstants.space8,
              ),
              child: Text(
                'Account Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),

            // User ID
            _buildInfoTile(
              context,
              icon: Icons.badge_outlined,
              label: 'User ID',
              value: '#${user.id}',
            ),
            const Divider(),

            // Email
            _buildInfoTile(
              context,
              icon: Icons.email_outlined,
              label: 'Email',
              value: user.email.isNotEmpty ? user.email : 'Not provided',
            ),
            const Divider(),

            // Phone number
            _buildInfoTile(
              context,
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: user.phone != null && user.phone!.isNotEmpty
                  ? user.phone!
                  : 'Not provided',
            ),

            // Gender (if available)
            if (user.gender != null && user.gender!.isNotEmpty) ...[
              const Divider(),
              _buildInfoTile(
                context,
                icon: Icons.person_outline_rounded,
                label: 'Gender',
                value:
                    user.gender![0].toUpperCase() + user.gender!.substring(1),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.space8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.space8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppConstants.radius8),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: AppConstants.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
    WidgetRef ref,
    bool isLoggingOut,
  ) {
    return FilledButton.icon(
      onPressed: isLoggingOut ? null : () => _confirmLogout(context, ref),
      icon: isLoggingOut
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.logout_rounded),
      label: Text(isLoggingOut ? 'Signing out...' : 'Sign Out'),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radius12),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out of ShopSphere?'),
        content: const Text(
          'Are you sure you want to end your active session and return to the login screen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ref.read(profileNotifierProvider.notifier).logout();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
