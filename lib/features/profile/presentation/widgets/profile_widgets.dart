import 'package:flutter/material.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/widgets/app_button.dart';
import 'package:resido/features/profile/data/profile_mock_data.dart';

/// Uppercase section heading ("ACCOUNT & PREFERENCES").
class ProfileSectionTitle extends StatelessWidget {
  const ProfileSectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text.toUpperCase(),
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// White grouped card of rows separated by hairlines.
class ProfileGroup extends StatelessWidget {
  const ProfileGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: [
          for (final (i, child) in children.indexed) ...[
            if (i > 0)
              const Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: AppColors.surfaceContainerHigh,
              ),
            child,
          ],
        ],
      ),
    );
  }
}

/// Icon tile + title + subtitle row with a trailing chevron (or [trailing]).
class ProfileMenuRow extends StatelessWidget {
  const ProfileMenuRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
    this.iconBackground = AppColors.surfaceContainer,
    this.iconColor = AppColors.primary,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color iconBackground;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 22, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleLg),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing ??
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.onSurfaceVariant,
                ),
          ],
        ),
      ),
    );
  }
}

/// Shows the Sign Out confirmation (Stitch 36, pattern 01). Confirming
/// returns to Welcome; it does not touch any session or credentials.
Future<void> showSignOutDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierColor: const Color(0x99293040),
    builder: (_) => const SignOutDialog(),
  );
  if (confirmed == true && context.mounted) {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamedAndRemoveUntil(AppRoutes.welcome, (_) => false);
  }
}

class SignOutDialog extends StatelessWidget {
  const SignOutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final body = AppTextStyles.bodyMd.copyWith(
      color: AppColors.onSurfaceVariant,
      height: 1.45,
    );
    return Dialog(
      backgroundColor: AppColors.surfaceContainerLowest,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout, color: AppColors.error),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Sign Out of Resido?',
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineSm,
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'You are signed in as '),
                  TextSpan(
                    text: ProfileMockData.name,
                    style: body.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(
                    text:
                        '. You will need to sign in again with your email '
                        'and password to access your properties and rent '
                        'records.',
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              style: body,
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primaryContainer,
                    child: Text(
                      ProfileMockData.initials,
                      style: TextStyle(
                        color: AppColors.onPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ProfileMockData.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelLg,
                        ),
                        Text(
                          'Landlord · ${ProfileMockData.portfolio}',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AppButton(
              label: 'Yes, Sign Out',
              leadingIcon: Icons.power_settings_new,
              height: 48,
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onError,
              textStyle: AppTextStyles.labelLg,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: 8),
            AppButton(
              label: 'Stay Signed In',
              height: 48,
              backgroundColor: AppColors.surfaceContainer,
              foregroundColor: AppColors.onSurface,
              textStyle: AppTextStyles.labelLg,
              shadows: const [],
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}

/// Red "Sign Out" row shared by Profile and Settings.
class SignOutButton extends StatelessWidget {
  const SignOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: AppShadows.sm),
      child: Material(
        color: AppColors.surfaceContainerLowest,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => showSignOutDialog(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.logout,
                    size: 22,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Sign Out',
                    style: AppTextStyles.titleLg.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward, color: AppColors.error),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
