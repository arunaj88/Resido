import 'package:flutter/material.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/features/dashboard/data/dashboard_mock_data.dart';
import 'package:resido/features/dashboard/presentation/widgets/dashboard_metrics.dart';
import 'package:resido/features/dashboard/presentation/widgets/dashboard_sections.dart';
import 'package:resido/features/home/presentation/widgets/resido_bottom_nav.dart';
import 'package:resido/features/properties/data/property_mock_data.dart';

/// Populated dashboard (Stitch "06. Dashboard") built from mock data.
class DashboardView extends StatelessWidget {
  const DashboardView({super.key, required this.onOpenTab});

  final ValueChanged<HomeTab> onOpenTab;

  @override
  Widget build(BuildContext context) {
    void soon(String title, IconData icon) =>
        AppRoutes.openComingSoon(context, title, icon);

    // Bottom inset covers the translucent navigation bar.
    final bottom = MediaQuery.paddingOf(context).bottom + 24;

    return ListView(
      padding: EdgeInsets.fromLTRB(24, 8, 24, bottom),
      children: [
        const _Greeting(),
        const SizedBox(height: 24),
        const MetricGrid(),
        const SizedBox(height: 24),
        RentCollectionCard(onTap: () => onOpenTab(HomeTab.rent)),
        const SizedBox(height: 24),
        QuickActionsSection(
          onAddProperty: () =>
              Navigator.of(context).pushNamed(AppRoutes.addProperty),
          onAddTenant: () => soon('Add Tenant', Icons.person_add_outlined),
          onRecordRent: () => soon('Record Rent', Icons.payments_outlined),
        ),
        const SizedBox(height: 24),
        PendingActionsSection(
          onAssignPlumber: () =>
              soon('Maintenance Request', Icons.engineering_outlined),
        ),
        const SizedBox(height: 24),
        SpotlightSection(
          // The spotlight card shows Palm Grove Enclave.
          onViewLedger: () => AppRoutes.openPropertyDetails(
            context,
            PropertyMockData.palmGrove,
          ),
        ),
        const SizedBox(height: 24),
        RecentActivitySection(
          onViewAll: () => soon('Recent Activity', Icons.history),
        ),
        const SizedBox(height: 24),
        const MonsoonTipCard(),
      ],
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final heading = AppTextStyles.headlineLgMobile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                DashboardMockData.dateLabel.toUpperCase(),
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 0.55,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DashboardMockData.locationLabel,
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            text: 'Namaskaram, ',
            children: [
              TextSpan(
                text: DashboardMockData.landlordFirstName,
                style: heading.copyWith(color: AppColors.primaryContainer),
              ),
            ],
          ),
          style: heading,
        ),
        const SizedBox(height: 2),
        Text(
          DashboardMockData.portfolioLabel,
          style: AppTextStyles.bodySm.copyWith(color: AppColors.outline),
        ),
      ],
    );
  }
}
