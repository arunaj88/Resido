import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';



/// The five persistent destinations from Stitch "07. Main Navigation".
enum HomeTab {
  dashboard('Dashboard', Icons.grid_view, Icons.grid_view_outlined),
  properties('Properties', Icons.domain, Icons.domain_outlined),
  tenants('Tenants', Icons.group, Icons.group_outlined),
  rent('Rent', Icons.currency_rupee, Icons.currency_rupee),
  profile('Profile', Icons.account_circle, Icons.account_circle_outlined);

  const HomeTab(this.label, this.selectedIcon, this.icon);

  final String label;
  final IconData selectedIcon;
  final IconData icon;
}

/// Frosted 64px bottom bar. Active tab: filled icon, Deep Emerald colour and
/// a 6px anchor dot; inactive: outlined icon in slate grey.
class ResidoBottomNav extends StatelessWidget {
  const ResidoBottomNav({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final HomeTab selected;
  final ValueChanged<HomeTab> onSelected;

  static const barHeight = 64.0;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(color: Color(0x0F064E3B), offset: Offset(0, -2), blurRadius: 12),
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: ColoredBox(
            color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: barHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      for (final tab in HomeTab.values)
                        Expanded(
                          child: _NavItem(
                            tab: tab,
                            selected: tab == selected,
                            onTap: () => onSelected(tab),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({required this.tab, required this.selected, required this.onTap});

  final HomeTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.selected ? AppColors.primaryContainer : AppColors.outline;
    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.tab.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        // Pressed state from the spec: scale 0.95.
        child: AnimatedScale(
          scale: _pressed ? 0.95 : 1,
          duration: const Duration(milliseconds: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 32,
                height: 28,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      widget.selected ? widget.tab.selectedIcon : widget.tab.icon,
                      size: 22,
                      color: color,
                    ),
                    if (widget.selected)
                      Positioned(
                        bottom: -2,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.tab.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSm.copyWith(
                  color: color,
                  fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
