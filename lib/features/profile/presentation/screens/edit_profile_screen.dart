import 'package:flutter/material.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/widgets/app_button.dart';
import 'package:resido/core/widgets/app_card.dart';
import 'package:resido/core/widgets/sub_page_top_bar.dart';
import 'package:resido/features/profile/data/profile_mock_data.dart';
import 'package:resido/features/properties/presentation/widgets/property_form_fields.dart';
import 'package:resido/features/tenants/presentation/widgets/tenant_widgets.dart';

/// 34. Edit Profile — prefilled landlord details. Fields are temporary;
/// "Save Changes" returns with a preview-only message and stores nothing.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _name = TextEditingController(text: ProfileMockData.name);
  final _phone = TextEditingController(text: ProfileMockData.phone);
  final _district = TextEditingController(text: ProfileMockData.district);

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _district.dispose();
    super.dispose();
  }

  void _save() {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).maybePop();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Preview only — your profile was not changed.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget helper(IconData icon, String text) => FieldHelper(text, icon: icon);

    return Scaffold(
      appBar: const SubPageTopBar(
        title: 'Edit Profile',
        showMore: true,
        showAvatar: false,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.paddingOf(context).bottom + 32,
        ),
        children: [
          const _PhotoHeader(),
          const SizedBox(height: 20),
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.domain,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Landlord Account #${ProfileMockData.accountId}',
                        style: AppTextStyles.titleLg,
                      ),
                      Text(
                        ProfileMockData.portfolioDetail,
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Personal Information', style: AppTextStyles.headlineSm),
          const SizedBox(height: 14),
          LabeledField(
            label: const FieldLabel('Full Name', required: true),
            field: FormTextInput(
              controller: _name,
              radius: 12,
              hintText: 'e.g. Harikrishnan Menon',
              prefix: const _FieldIcon(Icons.person_outline),
            ),
            helper: helper(
              Icons.info_outline,
              'As shown on your tenancy agreements.',
            ),
          ),
          const SizedBox(height: 16),
          LabeledField(
            label: const FieldLabel(
              'Email Address',
              required: true,
              trailing: FieldNote('Sign-in ID'),
            ),
            field: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      ProfileMockData.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.lock_outline,
                    size: 18,
                    color: AppColors.outline,
                  ),
                ],
              ),
            ),
            helper: helper(
              Icons.support_agent,
              'Your sign-in email. Contact Resido support to change it.',
            ),
          ),
          const SizedBox(height: 16),
          LabeledField(
            label: const FieldLabel('Contact Phone Number', required: true),
            field: IndianPhoneField(controller: _phone),
            helper: helper(
              Icons.chat_outlined,
              'Shown to tenants for enquiries.',
            ),
          ),
          const SizedBox(height: 16),
          LabeledField(
            label: const FieldLabel(
              'Property Management Base / District',
              required: true,
            ),
            field: FormTextInput(
              controller: _district,
              radius: 12,
              hintText: 'e.g. Kozhikode, Kerala',
              prefix: const _FieldIcon(Icons.location_on_outlined),
            ),
            helper: helper(
              Icons.pin_drop_outlined,
              'The main area where you manage your properties.',
            ),
          ),
          const SizedBox(height: 28),
          AppButton(
            label: 'Save Changes',
            leadingIcon: Icons.save_outlined,
            shadows: AppShadows.md,
            onPressed: _save,
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Cancel',
            height: 44,
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.onSurfaceVariant,
            textStyle: AppTextStyles.labelLg,
            shadows: const [],
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }
}

class _PhotoHeader extends StatelessWidget {
  const _PhotoHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: AppColors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: TenantAvatar(
                initials: ProfileMockData.initials,
                size: 96,
                background: AppColors.primaryContainer,
                color: AppColors.onPrimary,
                textStyle: AppTextStyles.headlineLgMobile,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.surfaceContainerLowest,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.photo_camera_outlined,
                  size: 16,
                  color: AppColors.onPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Photo upload needs device storage access: shown, but inactive.
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.edit, size: 16, color: AppColors.outline),
            const SizedBox(width: 4),
            Text(
              'Change Photo',
              style: AppTextStyles.labelLg.copyWith(color: AppColors.outline),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'Photo upload is not available in this version.',
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _FieldIcon extends StatelessWidget {
  const _FieldIcon(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 10),
      child: Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
    );
  }
}
