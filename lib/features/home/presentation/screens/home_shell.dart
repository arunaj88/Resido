import 'package:flutter/material.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/core/widgets/coming_soon_view.dart';
import 'package:resido/features/dashboard/presentation/screens/dashboard_tab.dart';
import 'package:resido/features/home/presentation/widgets/home_top_bar.dart';
import 'package:resido/features/home/presentation/widgets/resido_bottom_nav.dart';
import 'package:resido/features/properties/presentation/screens/property_list_tab.dart';

/// Arguments for [AppRoutes.home].
class HomeArgs {
  const HomeArgs({this.emptyPortfolio = false});

  /// Shows the Empty Dashboard state (a landlord with no properties yet).
  final bool emptyPortfolio;
}

/// Signed-in shell: the five top-level tabs with the persistent bottom bar.
/// Tabs keep their state while switching; Android back from another tab
/// returns to Dashboard first.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, this.args = const HomeArgs()});

  final HomeArgs args;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  HomeTab _tab = HomeTab.dashboard;

  void _select(HomeTab tab) => setState(() => _tab = tab);

  void _openNotifications() =>
      Navigator.of(context).pushNamed(AppRoutes.notifications);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _tab == HomeTab.dashboard,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _select(HomeTab.dashboard);
      },
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: _tab.index,
          children: [
            for (final tab in HomeTab.values)
              if (tab == HomeTab.dashboard)
                DashboardTab(
                  startEmpty: widget.args.emptyPortfolio,
                  onOpenTab: _select,
                  onOpenNotifications: _openNotifications,
                )
              else if (tab == HomeTab.properties)
                PropertyListTab(
                  onOpenNotifications: _openNotifications,
                  onOpenProfile: () => _select(HomeTab.profile),
                )
              else
                _PlaceholderTab(
                  tab: tab,
                  onOpenNotifications: _openNotifications,
                  onOpenProfile: () => _select(HomeTab.profile),
                ),
          ],
        ),
        bottomNavigationBar: ResidoBottomNav(
          selected: _tab,
          onSelected: _select,
        ),
      ),
    );
  }
}

/// Later-batch tab (Tenants, Rent, Profile).
class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({
    required this.tab,
    required this.onOpenNotifications,
    required this.onOpenProfile,
  });

  final HomeTab tab;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeTopBar(
        section: tab.label,
        onNotifications: onOpenNotifications,
        onAvatar: onOpenProfile,
      ),
      body: ComingSoonView(title: tab.label, icon: tab.selectedIcon),
    );
  }
}
