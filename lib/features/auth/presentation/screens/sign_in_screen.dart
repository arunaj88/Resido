import 'package:flutter/material.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/widgets/app_button.dart';
import 'package:resido/core/widgets/resido_logo.dart';
import 'package:resido/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:resido/features/auth/presentation/widgets/auth_top_bar.dart';
import 'package:resido/features/auth/presentation/widgets/info_pill.dart';
import 'package:resido/features/home/presentation/screens/home_shell.dart';


/// 03. Sign In. "Sign In" only navigates to the Dashboard; no credentials
/// are checked.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, this.newAccount = false});

  /// Reached from the Create Account flow: lands on the Empty Dashboard.
  final bool newAccount;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // Mock values shown in the Stitch design.
  final _email = TextEditingController(text: 'menon.properties.kochi@gmail.com');
  final _password = TextEditingController(text: 'Kochi@2024Estate!');
  bool _obscurePassword = true;
  bool _rememberMe = true;

  static const _ink = AppColors.softCharcoal;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _openDashboard() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (_) => false,
      arguments: HomeArgs(emptyPortfolio: widget.newAccount),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fieldText = AppTextStyles.bodyMd.copyWith(color: _ink);
    final label = AppTextStyles.labelLg.copyWith(
      color: _ink,
      fontWeight: FontWeight.w500,
    );

    return Scaffold(
      appBar: const AuthTopBar(
        title: 'Sign In',
        trailing: AuthHeaderBadge(
          icon: Icons.person_outline,
          color: AppColors.primaryContainer,
        ),
      ),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              sliver: SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _Intro(),
                    Row(
                      children: [
                        Text('Email Address', style: label),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Registered Owner / NRI ID',
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    AuthTextField(
                      controller: _email,
                      hintText: 'e.g., menon.properties.kochi@gmail.com',
                      prefixIcon: Icons.alternate_email,
                      prefixIconColor: AppColors.onSurfaceVariant,
                      prefixInset: 16,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      textStyle: fieldText,
                      suffix: FieldIconButton(
                        icon: Icons.cancel_outlined,
                        iconSize: 18,
                        tooltip: 'Clear email',
                        onPressed: _email.clear,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Password', style: label),
                    const SizedBox(height: 6),
                    AuthTextField(
                      controller: _password,
                      hintText: 'Enter your password',
                      prefixIcon: Icons.lock_outline,
                      prefixIconColor: AppColors.onSurfaceVariant,
                      prefixInset: 16,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      textStyle: fieldText.copyWith(letterSpacing: 0.7),
                      suffix: FieldIconButton(
                        icon: _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off_outlined,
                        tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                        color: AppColors.primaryContainer,
                        size: 36,
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _OptionsRow(
                      rememberMe: _rememberMe,
                      onRememberMeChanged: (v) => setState(() => _rememberMe = v),
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      label: 'Sign In',
                      trailingIcon: Icons.arrow_forward,
                      textStyle: AppTextStyles.headlineSm,
                      onPressed: _openDashboard,
                    ),
                    const SizedBox(height: 24),
                    const _TrustCallout(),
                    const Spacer(),
                    const SizedBox(height: 32),
                    const _CreateAccountPrompt(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ResidoLogoTile(),
              const SizedBox(width: 8),
              Flexible(
                child: InfoPill(
                  label: 'Kerala Landlord Portal',
                  background: AppColors.surfaceContainer,
                  foreground: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  textStyle: AppTextStyles.labelMd.copyWith(letterSpacing: 0.55),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Welcome Back',
            style: AppTextStyles.headlineLgMobile.copyWith(
              color: AppColors.softCharcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Sign in with your email and password to access your rental '
            'properties and tenant records.',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              height: AppTextStyles.relaxed,
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionsRow extends StatelessWidget {
  const _OptionsRow({required this.rememberMe, required this.onRememberMeChanged});

  final bool rememberMe;
  final ValueChanged<bool> onRememberMeChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onRememberMeChanged(!rememberMe),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Row(
                children: [
                  AuthCheckbox(
                    value: rememberMe,
                    radius: 4,
                    onChanged: onRememberMeChanged,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Remember Me',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.softCharcoal,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoutes.forgotPassword),
          style: TextButton.styleFrom(
            minimumSize: const Size(0, 44),
            padding: EdgeInsets.zero,
            foregroundColor: AppColors.deepEmerald,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Forgot Password?',
            style: AppTextStyles.labelLg.copyWith(color: AppColors.deepEmerald),
          ),
        ),
      ],
    );
  }
}

class _TrustCallout extends StatelessWidget {
  const _TrustCallout();

  @override
  Widget build(BuildContext context) {
    final body = AppTextStyles.bodySm.copyWith(
      color: AppColors.onSurfaceVariant,
      height: 1.375,
    );
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              size: 18,
              color: AppColors.deepEmerald,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Verified Protection',
                    style: body.copyWith(
                      color: AppColors.softCharcoal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(
                    text: ' • Secure 256-bit encryption for landlord & '
                        'tenancy records',
                  ),
                ],
              ),
              style: body,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateAccountPrompt extends StatelessWidget {
  const _CreateAccountPrompt();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          "Don't have an account yet?",
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(width: 4),
        InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () => AppRoutes.openCreateAccount(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'Create Account',
              style: AppTextStyles.labelLg.copyWith(
                color: AppColors.deepEmerald,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
