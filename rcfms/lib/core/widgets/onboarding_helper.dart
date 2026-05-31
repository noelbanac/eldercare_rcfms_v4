import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../services/onboarding_service.dart';
import '../theme/app_colors.dart';

/// Helper that builds RCFMS-branded coach-mark targets and shows them using
/// [TutorialCoachMark].
///
/// Usage:
/// ```dart
/// final targets = [
///   OnboardingHelper.buildTarget(
///     key: _bellKey,
///     title: 'Notifications',
///     description: 'Tap here to view alerts.',
///     icon: LucideIcons.bell,
///   ),
/// ];
/// OnboardingHelper.showTutorial(context: context, targets: targets, screenId: 'dashboard');
/// ```
class OnboardingHelper {
  OnboardingHelper._();

  // ---------------------------------------------------------------------------
  // Target builder
  // ---------------------------------------------------------------------------

  /// Creates a single coach-mark target with consistent RCFMS theming.
  ///
  /// [key] must be attached to the widget you want to spotlight.
  static TargetFocus buildTarget({
    required GlobalKey key,
    required String title,
    required String description,
    required IconData icon,
    ContentAlign align = ContentAlign.bottom,
    ShapeLightFocus shape = ShapeLightFocus.RRect,
    double? paddingFocus,
    int? stepIndex,
    int? totalSteps,
  }) {
    return TargetFocus(
      identify: key.toString(),
      keyTarget: key,
      alignSkip: Alignment.topRight,
      enableOverlayTab: true,
      enableTargetTab: true,
      shape: shape,
      paddingFocus: paddingFocus ?? 8,
      contents: [
        TargetContent(
          align: align,
          builder: (context, controller) {
            return _CoachCardContent(
              title: title,
              description: description,
              icon: icon,
              stepIndex: stepIndex,
              totalSteps: totalSteps,
              onNext: controller.next,
              onSkip: controller.skip,
              isLast: stepIndex != null &&
                  totalSteps != null &&
                  stepIndex == totalSteps - 1,
            );
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Show tutorial
  // ---------------------------------------------------------------------------

  /// Shows the coach-mark tutorial for [screenId].
  ///
  /// Automatically marks the walkthrough as complete when the user finishes
  /// or skips it.
  static void showTutorial({
    required BuildContext context,
    required List<TargetFocus> targets,
    required String screenId,
    VoidCallback? onFinish,
  }) {
    if (targets.isEmpty) return;

    final tutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      opacityShadow: 0.78,
      hideSkip: true, // We handle skip inside the card
      onFinish: () {
        OnboardingService.markOnboardingComplete(screenId);
        onFinish?.call();
      },
      onSkip: () {
        OnboardingService.markOnboardingComplete(screenId);
        onFinish?.call();
        return true;
      },
    );

    tutorial.show(context: context);
  }

  // ---------------------------------------------------------------------------
  // Auto-trigger helper
  // ---------------------------------------------------------------------------

  /// Checks persistence and, if the user hasn't seen this screen's walkthrough,
  /// triggers it after a short delay to allow the UI to settle.
  static Future<void> autoTriggerIfNeeded({
    required BuildContext context,
    required String screenId,
    required List<TargetFocus> targets,
    Duration delay = const Duration(milliseconds: 600),
  }) async {
    final seen = await OnboardingService.hasSeenOnboarding(screenId);
    if (seen) return;

    await Future.delayed(delay);
    if (!context.mounted) return;

    showTutorial(
      context: context,
      targets: targets,
      screenId: screenId,
    );
  }
}

// =============================================================================
// Private coach-card widget
// =============================================================================

class _CoachCardContent extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final int? stepIndex;
  final int? totalSteps;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final bool isLast;

  const _CoachCardContent({
    required this.title,
    required this.description,
    required this.icon,
    this.stepIndex,
    this.totalSteps,
    required this.onNext,
    required this.onSkip,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasSteps = stepIndex != null && totalSteps != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: icon + title + step counter
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              if (hasSteps)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${stepIndex! + 1}/$totalSteps',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Skip button
              if (!isLast)
                GestureDetector(
                  onTap: onSkip,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),

              // Next / Got it button
              GestureDetector(
                onTap: onNext,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isLast ? 'Got it!' : 'Next',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
