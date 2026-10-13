import 'package:flutter/material.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';

/// Body for temporary placeholder destinations that belong to later
/// batches. Clearly labelled so it is never mistaken for a finished screen.
class ComingSoonView extends StatelessWidget {
  const ComingSoonView({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: AppColors.primaryContainer),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineSm,
            ),
            const SizedBox(height: 6),
            Text(
              'Placeholder — this screen is built in a later batch.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Arguments for the pushed placeholder route.
class ComingSoonArgs {
  const ComingSoonArgs(this.title, this.icon);

  final String title;
  final IconData icon;
}

/// Pushed placeholder destination with a plain back bar.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.args});

  final ComingSoonArgs args;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        title: Text(args.title, style: AppTextStyles.titleLg),
      ),
      body: ComingSoonView(title: args.title, icon: args.icon),
    );
  }
}
