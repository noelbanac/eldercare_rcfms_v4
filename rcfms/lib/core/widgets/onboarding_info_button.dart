import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';

/// A small, branded info button used on every major screen to let users
/// manually re-trigger the onboarding walkthrough for that screen.
class OnboardingInfoButton extends StatelessWidget {
  /// Callback invoked when the button is tapped.
  final VoidCallback onPressed;

  const OnboardingInfoButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(LucideIcons.info, size: 22),
      color: AppColors.primary,
      tooltip: 'Show page guide',
      onPressed: onPressed,
      iconSize: 22,
      splashRadius: 20,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }
}
