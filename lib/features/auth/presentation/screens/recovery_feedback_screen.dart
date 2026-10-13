import 'package:flutter/material.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/features/auth/presentation/widgets/auth_top_bar.dart';
import 'package:resido/features/auth/presentation/widgets/recovery_state_tabs.dart';
import 'package:resido/features/auth/presentation/widgets/recovery_state_views.dart';

/// The four presentation states from "05. Recovery Feedback States".
enum RecoveryFeedbackState { linkSent, failed, verifyAccount, submitting }

/// 05. Recovery Feedback States. Purely presentational: the state is local
/// and switched with the design's tab strip; nothing is sent or verified.
class RecoveryFeedbackScreen extends StatefulWidget {
  const RecoveryFeedbackScreen({
    super.key,
    this.initialState = RecoveryFeedbackState.linkSent,
  });

  final RecoveryFeedbackState initialState;

  @override
  State<RecoveryFeedbackScreen> createState() => _RecoveryFeedbackScreenState();
}

class _RecoveryFeedbackScreenState extends State<RecoveryFeedbackScreen> {
  late RecoveryFeedbackState _state = widget.initialState;

  void _toSignIn() => AppRoutes.openSignIn(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthTopBar(
        logoSize: 32,
        trailing: TextButton(
          onPressed: _toSignIn,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.secondary,
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          child: Text(
            'Sign In',
            style: AppTextStyles.labelLg.copyWith(color: AppColors.secondary),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RecoveryStateTabs(
                selected: _state,
                onSelected: (s) => setState(() => _state = s),
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: KeyedSubtree(
                  key: ValueKey(_state),
                  child: switch (_state) {
                    RecoveryFeedbackState.linkSent => LinkSentView(
                      onReturnToSignIn: _toSignIn,
                    ),
                    RecoveryFeedbackState.failed => FailedView(
                      onRetry: () => Navigator.of(context).maybePop(),
                      onBackToSignIn: _toSignIn,
                    ),
                    RecoveryFeedbackState.verifyAccount => VerifyAccountView(
                      onGoToSignIn: () =>
                          AppRoutes.openSignIn(context, newAccount: true),
                    ),
                    RecoveryFeedbackState.submitting => const SubmittingView(),
                  },
                ),
              ),
              const SizedBox(height: 24),
              const _EncryptionFootnote(),
            ],
          ),
        ),
      ),
    );
  }
}

class _EncryptionFootnote extends StatelessWidget {
  const _EncryptionFootnote();

  @override
  Widget build(BuildContext context) {
    final color = AppColors.onSurfaceVariant.withValues(alpha: 0.7);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.security, size: 14, color: color),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            'End-to-End 256-bit Encrypted • Kerala Land Administration Standard',
            style: AppTextStyles.labelSm.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
