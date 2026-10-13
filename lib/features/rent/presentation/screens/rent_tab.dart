import 'package:flutter/material.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/features/home/presentation/widgets/home_top_bar.dart';
import 'package:resido/features/rent/presentation/screens/payment_history_view.dart';
import 'package:resido/features/rent/presentation/screens/rent_due_view.dart';
import 'package:resido/features/rent/presentation/screens/rent_overview_view.dart';

enum RentSection {
  overview('Rent Overview'),
  due('Rent Due'),
  history('Payment History');

  const RentSection(this.title);

  final String title;
}

/// Rent tab: Rent Overview, Rent Due and Payment History share the tab (all
/// three designs keep the bottom navigation), switched in place.
class RentTab extends StatefulWidget {
  const RentTab({
    super.key,
    required this.onOpenNotifications,
    required this.onOpenProfile,
  });

  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenProfile;

  @override
  State<RentTab> createState() => _RentTabState();
}

class _RentTabState extends State<RentTab> {
  RentSection _section = RentSection.overview;

  void _open(RentSection section) => setState(() => _section = section);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeTopBar(
        eyebrow: 'Resido Kerala',
        section: _section.title,
        hasUnread: false,
        onNotifications: widget.onOpenNotifications,
        onAvatar: widget.onOpenProfile,
      ),
      body: switch (_section) {
        RentSection.overview => RentOverviewView(
          key: const PageStorageKey('rent-overview'),
          onOpenSection: _open,
        ),
        RentSection.due => RentDueView(
          key: const PageStorageKey('rent-due'),
          onOpenSection: _open,
        ),
        RentSection.history => PaymentHistoryView(
          key: const PageStorageKey('rent-history'),
          onOpenSection: _open,
        ),
      },
    );
  }
}

/// "← Rent Overview" pill shown at the top of Rent Due / Payment History.
class BackToOverviewButton extends StatelessWidget {
  const BackToOverviewButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    return Material(
      color: AppColors.surfaceContainer,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.arrow_back,
                size: 18,
                color: AppColors.onSurface,
              ),
              const SizedBox(width: 8),
              Text('Rent Overview', style: AppTextStyles.labelLg),
            ],
          ),
        ),
      ),
    );
  }
}
