import 'package:flutter/material.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/features/home/presentation/widgets/home_top_bar.dart';
import 'package:resido/features/profile/data/profile_mock_data.dart';
import 'package:resido/features/profile/presentation/widgets/profile_widgets.dart';
import 'package:resido/features/tenants/presentation/widgets/tenant_widgets.dart';

/// 33. Profile tab — landlord summary, account and support rows, Sign Out.
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key, required this.onOpenNotifications});

  final VoidCallback onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    void soon(String title, IconData icon) =>
        AppRoutes.openComingSoon(context, title, icon);
    void openSettings() => Navigator.of(context).pushNamed(AppRoutes.settings);

    return Scaffold(
      appBar: HomeTopBar(
        eyebrow: 'Resido Kerala',
        section: 'Profile',
        hasUnread: false,
        onNotifications: onOpenNotifications,
        // Already on Profile.
        onAvatar: () {},
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 12, 16, bottom + 24),
        children: [
          const _IdentityCard(),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.event_available,
                  iconBackground: AppColors.secondaryContainer,
                  iconColor: AppColors.onSecondaryContainer,
                  label: 'Next Cycle',
                  value: ProfileMockData.rentCycle,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  icon: Icons.notifications_active_outlined,
                  iconBackground: AppColors.tertiaryFixed,
                  iconColor: AppColors.onTertiaryFixedVariant,
                  label: 'Rent Reminders',
                  value: 'On',
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const ProfileSectionTitle('Account & Preferences'),
          ProfileGroup(
            children: [
              ProfileMenuRow(
                icon: Icons.manage_accounts_outlined,
                title: 'Account Settings',
                subtitle: 'Account details and preferences',
                onTap: openSettings,
              ),
              ProfileMenuRow(
                icon: Icons.lock_reset,
                title: 'Change Password',
                subtitle: 'Update your sign-in password',
                onTap: () => soon('Change Password', Icons.lock_reset),
              ),
              ProfileMenuRow(
                icon: Icons.notifications_active_outlined,
                title: 'Notification Preferences',
                subtitle: 'Rent reminders, WhatsApp receipts & repairs',
                onTap: openSettings,
              ),
            ],
          ),
          const SizedBox(height: 22),
          const ProfileSectionTitle('Support & Information'),
          ProfileGroup(
            children: [
              ProfileMenuRow(
                icon: Icons.support_agent,
                title: 'Help & Support',
                subtitle: 'Landlord help desk & tenancy guidance',
                onTap: () => soon('Help & Support', Icons.support_agent),
              ),
              ProfileMenuRow(
                icon: Icons.verified_user_outlined,
                title: 'Privacy Policy',
                subtitle: 'How Resido handles your information',
                onTap: () =>
                    soon('Privacy Policy', Icons.verified_user_outlined),
              ),
              ProfileMenuRow(
                icon: Icons.info_outline,
                title: 'About Resido',
                subtitle:
                    '${ProfileMockData.appVersion} · For Indian Landlords',
                onTap: () => soon('About Resido', Icons.info_outline),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const SignOutButton(),
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.eco_outlined,
                    size: 14,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      "Crafted for Estates & Tharavadus across God's Own "
                      'Country',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard();

  @override
  Widget build(BuildContext context) {
    final muted = AppTextStyles.bodySm.copyWith(
      color: AppColors.onSurfaceVariant,
    );
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.sm,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryFixed.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: TenantAvatar(
                    initials: ProfileMockData.initials,
                    size: 72,
                    background: AppColors.primaryContainer,
                    color: AppColors.onPrimary,
                    textStyle: AppTextStyles.headlineMd,
                  ),
                ),
                const SizedBox(height: 12),
                Text(ProfileMockData.name, style: AppTextStyles.headlineMd),
                const SizedBox(height: 2),
                Text(ProfileMockData.email, style: muted),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${ProfileMockData.displayPhone} • '
                        '${ProfileMockData.city}',
                        style: muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final summary = Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.domain,
                              size: 20,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'MANAGED PORTFOLIO',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  ProfileMockData.portfolio,
                                  style: AppTextStyles.labelLg,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                      const edit = _EditProfileButton();
                      // Side by side when there is room; stacked on very
                      // narrow screens.
                      if (constraints.maxWidth >= 300) {
                        return Row(
                          children: [
                            Expanded(child: summary),
                            const SizedBox(width: 8),
                            edit,
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [summary, const SizedBox(height: 10), edit],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProfileButton extends StatelessWidget {
  const _EditProfileButton();

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10);
    return Material(
      color: AppColors.primaryContainer,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.editProfile),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.edit, size: 16, color: AppColors.onPrimary),
              const SizedBox(width: 6),
              Text(
                'Edit Profile',
                style: AppTextStyles.labelLg.copyWith(
                  color: AppColors.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(value, style: AppTextStyles.titleLg),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
