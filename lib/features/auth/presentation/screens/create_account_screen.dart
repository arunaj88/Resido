import 'package:flutter/material.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/widgets/app_button.dart';
import 'package:resido/features/auth/presentation/screens/recovery_feedback_screen.dart';
import 'package:resido/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:resido/features/auth/presentation/widgets/auth_top_bar.dart';
import 'package:resido/features/auth/presentation/widgets/info_pill.dart';


/// 02. Create Account. The primary action only opens the "Verify Account"
/// feedback state; no account is created.
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  // Mock values shown in the Stitch design.
  final _name = TextEditingController(text: 'Harikrishnan Menon');
  final _email = TextEditingController(text: 'landlord@keralaestates.in');
  final _password = TextEditingController(text: 'Tharavadu#2024');
  final _confirm = TextEditingController(text: 'Tharavadu#2024');
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreed = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _continue() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pushNamed(
      AppRoutes.recoveryFeedback,
      arguments: RecoveryFeedbackState.verifyAccount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fieldText = AppTextStyles.bodyMd.copyWith(fontSize: 15, height: 1.5);

    return Scaffold(
      appBar: AuthTopBar(
        title: 'Create Account',
        titleStyle: AppTextStyles.headlineSm.copyWith(fontSize: 17),
        backIconSize: 24,
        trailing: const AuthHeaderBadge(
          icon: Icons.verified_user_outlined,
          color: AppColors.primary,
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Intro(),
              const SizedBox(height: 24),
              const _FieldLabel('Full Name', note: '(as per Govt ID)'),
              const SizedBox(height: 6),
              AuthTextField(
                controller: _name,
                hintText: 'e.g., Harikrishnan Menon',
                prefixIcon: Icons.badge_outlined,
                textStyle: fieldText,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
              ),
              const SizedBox(height: 8),
              const _HelperText(
                icon: Icons.verified_user_outlined,
                iconSize: 15,
                text: 'Used for official rent receipts and agreements',
              ),
              const SizedBox(height: 20),
              const _FieldLabel('Email Address'),
              const SizedBox(height: 6),
              AuthTextField(
                controller: _email,
                hintText: 'e.g., landlord@keralaestates.in',
                prefixIcon: Icons.alternate_email,
                textStyle: fieldText,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                suffix: FieldIconButton(
                  icon: Icons.cancel_outlined,
                  iconSize: 18,
                  tooltip: 'Clear email',
                  onPressed: _email.clear,
                ),
              ),
              const SizedBox(height: 20),
              const _FieldLabel('Password'),
              const SizedBox(height: 6),
              AuthTextField(
                controller: _password,
                hintText: 'Create a strong password',
                prefixIcon: Icons.lock_outline,
                textStyle: fieldText,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                suffix: _VisibilityToggle(
                  obscured: _obscurePassword,
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 10),
              const _StrengthCard(),
              const SizedBox(height: 20),
              const _FieldLabel('Confirm Password'),
              const SizedBox(height: 6),
              AuthTextField(
                controller: _confirm,
                hintText: 'Re-enter your password',
                prefixIcon: Icons.lock_reset,
                textStyle: fieldText,
                obscureText: _obscureConfirm,
                textInputAction: TextInputAction.done,
                suffix: _VisibilityToggle(
                  obscured: _obscureConfirm,
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: _MatchBadge(),
              ),
              const SizedBox(height: 24),
              _AgreementTile(
                value: _agreed,
                onChanged: (v) => setState(() => _agreed = v),
              ),
              const SizedBox(height: 28),
              AppButton(
                label: 'Create Account',
                trailingIcon: Icons.arrow_forward,
                textStyle: AppTextStyles.titleLg.copyWith(height: 1.5),
                onPressed: _continue,
              ),
              const SizedBox(height: 12),
              const _SignInPrompt(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoPill(
          label: 'Landlord Onboarding',
          icon: Icons.real_estate_agent_outlined,
          iconSize: 16,
          background: AppColors.secondaryContainer.withValues(alpha: 0.3),
          foreground: AppColors.secondary,
          textStyle: AppTextStyles.labelMd.copyWith(letterSpacing: 0.275),
        ),
        const SizedBox(height: 12),
        Text('Create Landlord Account', style: AppTextStyles.headlineLgMobile),
        const SizedBox(height: 4),
        Text(
          'Set up your owner profile to manage rental properties across Kerala.',
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
            height: AppTextStyles.relaxed,
          ),
        ),
      ],
    );
  }
}

/// Field label: 15px Jakarta title with a red required marker.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {this.note});

  final String text;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.titleLg.copyWith(fontSize: 15, height: 1.5);
    return Text.rich(
      TextSpan(
        text: text,
        children: [
          TextSpan(
            text: ' *',
            style: style.copyWith(color: AppColors.error),
          ),
          if (note != null)
            TextSpan(
              text: ' $note',
              style: style.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                fontFamily: AppTextStyles.bodyFamily,
                color: AppColors.onSurfaceVariant,
              ),
            ),
        ],
      ),
      style: style,
    );
  }
}

class _HelperText extends StatelessWidget {
  const _HelperText({required this.icon, required this.text, this.iconSize = 14});

  final IconData icon;
  final String text;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: iconSize, color: AppColors.secondary),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _VisibilityToggle extends StatelessWidget {
  const _VisibilityToggle({required this.obscured, required this.onPressed});

  final bool obscured;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FieldIconButton(
      icon: obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      tooltip: obscured ? 'Show password' : 'Hide password',
      onPressed: onPressed,
    );
  }
}

/// Static "Strong" strength indicator, as shown in the approved design.
class _StrengthCard extends StatelessWidget {
  const _StrengthCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'SECURITY STRENGTH',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Icon(Icons.shield_outlined, size: 15, color: AppColors.secondary),
              const SizedBox(width: 4),
              Text(
                'Strong',
                style: AppTextStyles.labelMd.copyWith(color: AppColors.secondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < 4; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          const _HelperText(
            icon: Icons.check,
            text: 'Strong: 8+ chars, includes numbers & symbols',
          ),
        ],
      ),
    );
  }
}

class _MatchBadge extends StatelessWidget {
  const _MatchBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            size: 16,
            color: AppColors.onSecondaryContainer,
          ),
          const SizedBox(width: 6),
          Text(
            'Passwords match',
            style: AppTextStyles.labelMd.copyWith(
              color: AppColors.onSecondaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AgreementTile extends StatelessWidget {
  const _AgreementTile({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final base = AppTextStyles.bodyMd.copyWith(fontSize: 13, height: 1.375);
    final link = base.copyWith(
      color: AppColors.secondary,
      fontWeight: FontWeight.w600,
    );
    return Material(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: AuthCheckbox(value: value, onChanged: onChanged),
              ),
              const SizedBox(width: 12),
              // Terms / Privacy pages are outside Batch 01: styled, no link yet.
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: "I agree to Resido's ",
                    children: [
                      TextSpan(text: 'Terms of Service', style: link),
                      const TextSpan(text: ' and '),
                      TextSpan(text: 'Privacy Policy', style: link),
                      const TextSpan(
                        text: ' as an individual property owner in India.',
                      ),
                    ],
                  ),
                  style: base,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignInPrompt extends StatelessWidget {
  const _SignInPrompt();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        children: [
          Text(
            'Already have a Resido account?',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () => AppRoutes.openSignIn(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sign In',
                  style: AppTextStyles.labelLg.copyWith(color: AppColors.secondary),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.chevron_right, size: 16, color: AppColors.secondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
