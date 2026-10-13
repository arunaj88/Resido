import 'package:flutter/material.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/widgets/app_button.dart';
import 'package:resido/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:resido/features/auth/presentation/widgets/info_pill.dart';

/// Mock address shown in the approved recovery designs.
const _mockEmail = 'menon.properties.kochi@gmail.com';

/// State A — reset link requested ("Check your email").
class LinkSentView extends StatelessWidget {
  const LinkSentView({super.key, required this.onReturnToSignIn});

  final VoidCallback onReturnToSignIn;

  @override
  Widget build(BuildContext context) {
    return _CenteredStateLayout(
      hero: const _StateHero(
        background: AppColors.primaryContainer,
        foreground: AppColors.onPrimary,
        icon: Icons.check,
        shadows: AppShadows.lg,
        ping: true,
      ),
      pill: const InfoPill(
        label: 'Check Your Email',
        icon: Icons.mark_email_read_outlined,
        background: AppColors.secondaryContainer,
        foreground: AppColors.onSecondaryContainer,
      ),
      title: 'Check your email',
      // Worded as what happens next, not as a completed send.
      body: const _BodyWithEmail(
        before: 'A password reset link will be sent to',
        after: 'Follow the instructions to establish your new credentials.',
      ),
      card: const _InfoCard(
        icon: Icons.schedule,
        iconBackground: AppColors.primaryContainer,
        iconColor: AppColors.onPrimaryContainer,
        title: 'Valid for 15 minutes',
        titleColor: AppColors.primary,
        body:
            "If you don't see the email within a couple minutes, please check "
            'your spam folder or request a new link below.',
      ),
      cardSpacing: 12,
      actions: [
        AppButton(
          label: 'Return to Sign In',
          trailingIcon: Icons.arrow_forward,
          iconSize: 18,
          shadows: AppShadows.md,
          onPressed: onReturnToSignIn,
        ),
        // Shown in its countdown (unavailable) state, as in the design.
        const _TextAction(
          icon: Icons.history,
          iconColor: AppColors.outline,
          label: 'Resend email in 45s',
          color: AppColors.onSurfaceVariant,
        ),
      ],
    );
  }
}

/// State B — request failed.
class FailedView extends StatelessWidget {
  const FailedView({
    super.key,
    required this.onRetry,
    required this.onBackToSignIn,
  });

  final VoidCallback onRetry;
  final VoidCallback onBackToSignIn;

  @override
  Widget build(BuildContext context) {
    return _CenteredStateLayout(
      hero: const _StateHero(
        background: AppColors.errorContainer,
        foreground: AppColors.error,
        icon: Icons.wifi_off,
      ),
      pill: const InfoPill(
        label: 'Connection Failure',
        icon: Icons.warning_amber,
        background: AppColors.errorContainer,
        foreground: AppColors.onErrorContainer,
      ),
      title: 'Unable to Send Reset Link',
      body: const _Paragraph(
        "We couldn't connect to the verification server. Please check your "
        'internet connection and try again.',
      ),
      card: const _InfoCard(
        icon: Icons.info_outline,
        iconBackground: AppColors.error,
        iconColor: AppColors.onError,
        title: 'Diagnostic Status',
        titleColor: AppColors.onSurface,
        body:
            'Verification gateway timed out (ERR_GATEWAY_TIMEOUT). Secure '
            'records remain unsynchronized.',
      ),
      cardSpacing: 16,
      actions: [
        AppButton(
          label: 'Retry Again',
          leadingIcon: Icons.replay,
          iconSize: 18,
          shadows: AppShadows.md,
          onPressed: onRetry,
        ),
        AppButton(
          label: 'Back to Sign In',
          backgroundColor: AppColors.surfaceContainerHigh,
          foregroundColor: AppColors.primary,
          shadows: const [],
          onPressed: onBackToSignIn,
        ),
      ],
    );
  }
}

/// State C — new account awaiting email verification.
class VerifyAccountView extends StatelessWidget {
  const VerifyAccountView({super.key, required this.onGoToSignIn});

  final VoidCallback onGoToSignIn;

  @override
  Widget build(BuildContext context) {
    return _CenteredStateLayout(
      hero: const _StateHero(
        background: AppColors.secondaryContainer,
        foreground: AppColors.secondary,
        icon: Icons.mark_email_unread_outlined,
        iconWeightBold: false,
      ),
      pill: const InfoPill(
        label: 'Verification Pending',
        icon: Icons.mail_outline,
        background: AppColors.secondaryContainer,
        foreground: AppColors.onSecondaryContainer,
      ),
      title: 'Confirm Your Email',
      // Worded as what happens next, not as a completed sign-up.
      body: const _BodyWithEmail(
        before:
            'A verification link will be sent to your inbox once your '
            'landlord account is set up. Please verify before signing in.',
      ),
      card: const _InfoCard(
        icon: Icons.verified_user_outlined,
        iconBackground: AppColors.primaryContainer,
        iconColor: AppColors.onPrimaryContainer,
        title: 'Pending Verification',
        titleColor: AppColors.primary,
        body:
            'Your profile is currently unverified. Account management '
            'features will unlock immediately once the link is confirmed.',
      ),
      cardSpacing: 12,
      actions: [
        AppButton(
          label: 'Go to Sign In',
          trailingIcon: Icons.login,
          iconSize: 18,
          shadows: AppShadows.md,
          onPressed: onGoToSignIn,
        ),
        // No email service in the UI-only phase; the link has no effect yet.
        _TextAction(
          icon: Icons.send_outlined,
          iconColor: AppColors.secondary,
          label: 'Resend Verification Email',
          color: AppColors.secondary,
          bold: true,
          onPressed: () {},
        ),
      ],
    );
  }
}

/// State D — request in progress (locked form with spinner).
class SubmittingView extends StatefulWidget {
  const SubmittingView({super.key});

  @override
  State<SubmittingView> createState() => _SubmittingViewState();
}

class _SubmittingViewState extends State<SubmittingView> {
  final _email = TextEditingController(text: _mockEmail);

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.onSurfaceVariant.withValues(alpha: 0.7);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        const Align(
          alignment: Alignment.centerLeft,
          child: InfoPill(
            label: 'In Progress',
            icon: Icons.pending_outlined,
            background: AppColors.surfaceContainer,
            foreground: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Submitting Request',
          style: AppTextStyles.headlineMd.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Please wait while we authenticate your ownership profile with '
          'Resido Cloud.',
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppShadows.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Email or Landlord ID',
                style: AppTextStyles.labelLg.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              AuthTextField(
                controller: _email,
                enabled: false,
                height: 48,
                hintText: '',
                prefixIcon: Icons.email_outlined,
                prefixInset: 12,
                fillColor: AppColors.surfaceContainerLow,
                shadows: const [],
                textStyle: AppTextStyles.bodyMd.copyWith(color: muted),
                suffix: const Icon(
                  Icons.lock_outline,
                  size: 20,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Input locked while verification handshake is processing.',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              const Opacity(
                opacity: 0.9,
                child: AppButton(
                  label: 'Submitting...',
                  shadows: AppShadows.md,
                  onPressed: null,
                  leading: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.onPrimary,
                      backgroundColor: Color(0x40FFFFFF),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _TextAction(
                icon: Icons.cancel_outlined,
                iconColor: muted,
                label: 'Cancel Request',
                color: muted,
                verticalPadding: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Shared column for the three centred states.
class _CenteredStateLayout extends StatelessWidget {
  const _CenteredStateLayout({
    required this.hero,
    required this.pill,
    required this.title,
    required this.body,
    required this.card,
    required this.cardSpacing,
    required this.actions,
  });

  final Widget hero;
  final Widget pill;
  final String title;
  final Widget body;
  final Widget card;
  final double cardSpacing;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Center(child: hero),
        const SizedBox(height: 16),
        Center(child: pill),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineLgMobile.copyWith(letterSpacing: 0),
        ),
        const SizedBox(height: 8),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: body,
          ),
        ),
        SizedBox(height: cardSpacing),
        card,
        const SizedBox(height: 24),
        for (final (i, action) in actions.indexed) ...[
          if (i > 0) const SizedBox(height: 8),
          action,
        ],
      ],
    );
  }
}

/// 80px state icon; [ping] adds the expanding halo from the success state.
class _StateHero extends StatelessWidget {
  const _StateHero({
    required this.background,
    required this.foreground,
    required this.icon,
    this.shadows = AppShadows.md,
    this.ping = false,
    this.iconWeightBold = true,
  });

  final Color background;
  final Color foreground;
  final IconData icon;
  final List<BoxShadow> shadows;
  final bool ping;
  final bool iconWeightBold;

  @override
  Widget build(BuildContext context) {
    final circle = Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        boxShadow: shadows,
      ),
      child: Icon(
        icon,
        size: 40,
        color: foreground,
        weight: iconWeightBold ? 700 : null,
      ),
    );
    if (!ping) return circle;
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [const _PingHalo(), circle],
      ),
    );
  }
}

/// Tailwind `animate-ping` on a 96px mint circle.
class _PingHalo extends StatefulWidget {
  const _PingHalo();

  @override
  State<_PingHalo> createState() => _PingHaloState();
}

class _PingHaloState extends State<_PingHalo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      maxWidth: 96,
      maxHeight: 96,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = Curves.easeOut.transform(_controller.value);
          return Opacity(
            opacity: 0.75 * (1 - t),
            child: Transform.scale(scale: 1 + t, child: child),
          );
        },
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: AppColors.secondaryFixed.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: AppTextStyles.bodyMd.copyWith(
        color: AppColors.onSurfaceVariant,
        height: AppTextStyles.relaxed,
      ),
    );
  }
}

/// Paragraph with the highlighted email chip between [before] and [after].
class _BodyWithEmail extends StatelessWidget {
  const _BodyWithEmail({required this.before, this.after});

  final String before;
  final String? after;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Paragraph(before),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _mockEmail,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleLg.copyWith(color: AppColors.primary),
          ),
        ),
        if (after != null) _Paragraph(after!),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.titleColor,
    required this.body,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final Color titleColor;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleLg.copyWith(color: titleColor),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
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

/// Small centred icon + label action under the main button.
class _TextAction extends StatelessWidget {
  const _TextAction({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.color,
    this.bold = false,
    this.onPressed,
    this.verticalPadding = 10,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final Color color;
  final bool bold;
  final VoidCallback? onPressed;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.bodySm.copyWith(
                color: color,
                fontWeight: bold ? FontWeight.w600 : null,
              ),
            ),
          ),
        ],
      ),
    );
    if (onPressed == null) return content;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onPressed,
      child: content,
    );
  }
}
