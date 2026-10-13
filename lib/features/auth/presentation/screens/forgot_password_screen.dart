import 'package:flutter/material.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/widgets/app_button.dart';
import 'package:resido/core/widgets/pulse.dart';
import 'package:resido/core/widgets/resido_logo.dart';
import 'package:resido/features/auth/presentation/screens/recovery_feedback_screen.dart';
import 'package:resido/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:resido/features/auth/presentation/widgets/auth_top_bar.dart';
import 'package:resido/features/auth/presentation/widgets/info_pill.dart';


/// 04. Forgot Password. "Send Reset Link" only opens the recovery feedback
/// screen; no email is sent.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  final _email = TextEditingController();
  bool _formatLooksValid = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _onEmailChanged(String value) {
    final valid = _emailPattern.hasMatch(value.trim());
    if (valid != _formatLooksValid) setState(() => _formatLooksValid = valid);
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pushNamed(
      AppRoutes.recoveryFeedback,
      arguments: RecoveryFeedbackState.linkSent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthTopBar(
        title: 'Forgot Password',
        logoSize: 32,
        trailing: const SizedBox(width: 44, height: 44),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _TopRow(),
              const SizedBox(height: 12),
              const _Intro(),
              const SizedBox(height: 16),
              _EmailCard(
                controller: _email,
                showValidPill: _formatLooksValid,
                onChanged: _onEmailChanged,
                onSubmit: _submit,
              ),
              const SizedBox(height: 16),
              const _HelpCard(),
              const SizedBox(height: 20),
              Center(
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).maybePop(),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: Text(
                    'Back to Sign In',
                    style: AppTextStyles.titleLg.copyWith(color: AppColors.secondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () => Navigator.of(context).maybePop(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_back, size: 20, color: AppColors.secondary),
                  const SizedBox(width: 4),
                  Text(
                    'Sign In',
                    style: AppTextStyles.labelLg.copyWith(color: AppColors.secondary),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(999),
              boxShadow: AppShadows.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ResidoLogo(size: 16, borderRadius: 6),
                const SizedBox(width: 4),
                Text(
                  'IDENTITY SAFE',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 0.55,
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

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.secondaryContainer,
              shape: BoxShape.circle,
              boxShadow: AppShadows.sm,
            ),
            child: const Icon(Icons.lock_reset, size: 30, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Reset Your Password',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineLgMobile,
        ),
        const SizedBox(height: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Text(
            'Enter the email address registered with your Resido landlord '
            'account. We will send you a secure link to reset your password.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              height: AppTextStyles.relaxed,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmailCard extends StatelessWidget {
  const _EmailCard({
    required this.controller,
    required this.showValidPill,
    required this.onChanged,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool showValidPill;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 18,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Registered Email Address',
                    style: AppTextStyles.labelLg,
                  ),
                ),
                if (showValidPill)
                  const InfoPill(
                    label: 'Verified format',
                    uppercase: false,
                    icon: Icons.check,
                    iconSize: 12,
                    gap: 4,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    background: AppColors.secondaryContainer,
                    foreground: AppColors.onSecondaryContainer,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          AuthTextField(
            controller: controller,
            hintText: 'e.g., owner@keralaestates.in',
            prefixIcon: Icons.mail_outline,
            fillColor: AppColors.surfaceContainerLow,
            focusedFillColor: AppColors.surfaceContainerLowest,
            shadows: const [],
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            onChanged: onChanged,
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Icon(Icons.info_outline, size: 14, color: AppColors.secondary),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Instructions will arrive in your inbox within 2 minutes.',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Send Reset Link',
            trailingIcon: Icons.arrow_forward,
            shadows: AppShadows.md,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  const _HelpCard();

  @override
  Widget build(BuildContext context) {
    final body = AppTextStyles.bodySm.copyWith(
      color: AppColors.onSurfaceVariant,
      height: AppTextStyles.relaxed,
    );
    final contact = body.copyWith(
      color: AppColors.secondary,
      fontWeight: FontWeight.w600,
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.headset_mic_outlined,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need help recovering your account?',
                  style: AppTextStyles.titleLg,
                ),
                const SizedBox(height: 4),
                // Contact details are display-only in this UI phase.
                Text.rich(
                  TextSpan(
                    text: 'Contact Resido Landlord Desk at ',
                    children: [
                      TextSpan(text: 'support@resido.in', style: contact),
                      const TextSpan(text: ' or call '),
                      TextSpan(text: '1800-425-RENT', style: contact),
                      const TextSpan(text: ' (8:00 AM – 8:00 PM IST).'),
                    ],
                  ),
                  style: body,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const StatusDot(color: AppColors.secondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Kerala Support Desk active 8:00 AM – 8:00 PM IST',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
