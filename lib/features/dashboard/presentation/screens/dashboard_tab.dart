import 'package:flutter/material.dart';
import 'package:resido/features/dashboard/presentation/widgets/dashboard_view.dart';
import 'package:resido/features/dashboard/presentation/widgets/empty_dashboard_view.dart';
import 'package:resido/features/home/presentation/widgets/home_top_bar.dart';
import 'package:resido/features/home/presentation/widgets/resido_bottom_nav.dart';



/// Dashboard tab. Shows the populated portfolio (Stitch "06. Dashboard") or,
/// for a landlord with no properties yet, the empty state (Stitch
/// "09. Empty Dashboard"). The state is local presentation only.
class DashboardTab extends StatefulWidget {
  const DashboardTab({
    super.key,
    this.startEmpty = false,
    required this.onOpenTab,
    required this.onOpenNotifications,
  });

  final bool startEmpty;
  final ValueChanged<HomeTab> onOpenTab;
  final VoidCallback onOpenNotifications;

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  late bool _empty = widget.startEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeTopBar(
        section: HomeTab.dashboard.label,
        onNotifications: widget.onOpenNotifications,
        onAvatar: () => widget.onOpenTab(HomeTab.profile),
      ),
      body: _empty
          ? EmptyDashboardView(
              onExplorePreview: () => setState(() => _empty = false),
            )
          : DashboardView(onOpenTab: widget.onOpenTab),
    );
  }
}
