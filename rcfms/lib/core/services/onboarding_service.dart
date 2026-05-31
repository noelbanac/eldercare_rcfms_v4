import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing onboarding walkthrough state via SharedPreferences.
///
/// Each screen has its own onboarding flag so walkthroughs can be
/// triggered independently (e.g. only replay the Dashboard tour).
class OnboardingService {
  OnboardingService._();

  static const _keyPrefix = 'onboarding_completed_';

  /// Known screen identifiers.
  static const screenDashboard = 'dashboard';
  static const screenResidents = 'residents';
  static const screenForms = 'forms';
  static const screenSettings = 'settings';

  static final _allScreens = [
    screenDashboard,
    screenResidents,
    screenForms,
    screenSettings,
  ];

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Returns `true` if the user has already completed (or skipped) the
  /// walkthrough for [screenId].
  static Future<bool> hasSeenOnboarding(String screenId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_keyPrefix$screenId') ?? false;
  }

  /// Marks the walkthrough for [screenId] as completed.
  static Future<void> markOnboardingComplete(String screenId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_keyPrefix$screenId', true);
  }

  /// Resets the walkthrough for a single [screenId] so it will auto-trigger
  /// again on the next visit.
  static Future<void> resetOnboarding(String screenId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPrefix$screenId');
  }

  /// Resets ALL onboarding flags. Used by the "Replay All" option in Settings.
  static Future<void> resetAllOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    for (final id in _allScreens) {
      await prefs.remove('$_keyPrefix$id');
    }
  }
}
