import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('My Profile')),
      body: switch (state.status) {
        ProfileStatus.loading when state.user == null => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.space20,
                  vertical: AppConstants.space16,
                ),
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
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(
                            AppConstants.radius12,
                          ),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: AppConstants.space12),
                            Expanded(
                              child: Text(
                                state.errorMessage ??
                                    'Could not refresh profile details.',
                                style: const TextStyle(
                                  color: Color(0xFF991B1B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
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
                      const SizedBox(height: AppConstants.space28),
                      _buildInfoCard(context, state.user!),
                      const SizedBox(height: AppConstants.space32),
                      _buildLogoutButton(context, ref, state.isLoggingOut),
                      const SizedBox(height: AppConstants.space32),
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
        // User Avatar with circular gradient border
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(30),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: user.image != null && user.image!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: user.image!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.primary.withAlpha(20),
                      alignment: Alignment.center,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 28,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.primary.withAlpha(20),
                      alignment: Alignment.center,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 28,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  )
                : Container(
                    color: AppColors.primary.withAlpha(20),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
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
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),

        // Username handle tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Text(
            '@${user.username}',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, User user) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radius16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.space16,
        vertical: AppConstants.space16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: AppConstants.space4,
              bottom: AppConstants.space12,
            ),
            child: Text(
              'Personal Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
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
            label: 'Email Address',
            value: user.email.isNotEmpty ? user.email : 'Not provided',
          ),
          const Divider(),

          // Phone number
          _buildInfoTile(
            context,
            icon: Icons.phone_outlined,
            label: 'Phone Number',
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
              value: user.gender![0].toUpperCase() + user.gender!.substring(1),
            ),
          ],
        ],
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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(AppConstants.radius10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
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
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
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
    return OutlinedButton.icon(
      onPressed: isLoggingOut ? null : () => _confirmLogout(context, ref),
      icon: isLoggingOut
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.error,
              ),
            )
          : const Icon(Icons.logout_rounded, size: 18),
      label: Text(
        isLoggingOut ? 'Signing out...' : 'Sign Out of Account',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.error,
        side: const BorderSide(color: Color(0xFFFCA5A5), width: 1.2),
        minimumSize: const Size.fromHeight(50),
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
