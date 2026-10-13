import 'package:flutter/material.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/widgets/sub_page_top_bar.dart';
import 'package:resido/features/profile/data/profile_mock_data.dart';
import 'package:resido/features/profile/presentation/widgets/profile_widgets.dart';
import 'package:resido/features/tenants/presentation/widgets/tenant_widgets.dart';

/// 35. Settings — account, notification preferences, support and Sign Out.
/// The switches are temporary UI state; nothing is saved.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final List<bool> _enabled = [
    for (final p in ProfileMockData.notificationPreferences) p.enabledByDefault,
  ];

  void _toggle(int index, bool value) {
    setState(() => _enabled[index] = value);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Preview only — this preference was not saved.'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    void soon(String title, IconData icon) =>
        AppRoutes.openComingSoon(context, title, icon);
    const prefs = ProfileMockData.notificationPreferences;

    return Scaffold(
      appBar: const SubPageTopBar(
        title: 'Settings',
        showMore: true,
        showAvatar: false,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.paddingOf(context).bottom + 32,
        ),
        children: [
          const _LandlordBanner(),
          const SizedBox(height: 22),
          const ProfileSectionTitle(
            'Account Information',
            trailing: Icon(
              Icons.badge_outlined,
              size: 18,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          ProfileGroup(
            children: [
              ProfileMenuRow(
                icon: Icons.person_pin_outlined,
                title: ProfileMockData.name,
                subtitle: 'Account ID: ${ProfileMockData.accountId}',
                trailing: TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.editProfile),
                  child: Text(
                    'Edit',
                    style: AppTextStyles.labelLg.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ),
              ProfileMenuRow(
                icon: Icons.lock_reset,
                title: 'Change Password',
                subtitle: ProfileMockData.passwordNote,
                onTap: () => soon('Change Password', Icons.lock_reset),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const ProfileSectionTitle(
            'Notification Preferences',
            trailing: Icon(
              Icons.notifications_active_outlined,
              size: 18,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          ProfileGroup(
            children: [
              for (final (i, p) in prefs.indexed)
                ProfileMenuRow(
                  icon: p.icon,
                  iconBackground: i == 0
                      ? AppColors.secondaryContainer
                      : AppColors.surfaceContainer,
                  iconColor: i == 0
                      ? AppColors.onSecondaryContainer
                      : AppColors.primary,
                  title: p.title,
                  subtitle: p.description,
                  onTap: () => _toggle(i, !_enabled[i]),
                  trailing: Switch(
                    value: _enabled[i],
                    onChanged: (v) => _toggle(i, v),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Notifications are not sent in this version.',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 22),
          const ProfileSectionTitle(
            'Support & Legal',
            trailing: Icon(
              Icons.help_center_outlined,
              size: 18,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          ProfileGroup(
            children: [
              ProfileMenuRow(
                icon: Icons.support_agent,
                title: 'Help & Support',
                subtitle: 'Landlord help desk & tenancy guidance',
                onTap: () => soon('Help & Support', Icons.support_agent),
              ),
              ProfileMenuRow(
                icon: Icons.policy_outlined,
                title: 'Privacy Policy',
                subtitle: 'How Resido handles your information',
                onTap: () => soon('Privacy Policy', Icons.policy_outlined),
              ),
              ProfileMenuRow(
                icon: Icons.info_outline,
                title: 'About Resido',
                subtitle:
                    'Property manager for Kerala landlords · '
                    '${ProfileMockData.appVersion}',
                onTap: () => soon('About Resido', Icons.info_outline),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const SignOutButton(),
          const SizedBox(height: 8),
          Text.rich(
            const TextSpan(
              children: [
                TextSpan(text: 'Sign out of '),
                TextSpan(
                  text: ProfileMockData.name,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: ' on this device'),
              ],
            ),
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _LandlordBanner extends StatelessWidget {
  const _LandlordBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          TenantAvatar(
            initials: ProfileMockData.initials,
            size: 44,
            background: AppColors.primary,
            color: AppColors.onPrimary,
            textStyle: AppTextStyles.titleLg,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACTIVE LANDLORD',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  ProfileMockData.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleLg,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              ProfileMockData.accountId,
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
