import '../../data/models/resident_model.dart';

/// Describes a single missing field in a resident profile.
class MissingFieldInfo {
  final String fieldName;
  final String label;
  final String category;

  const MissingFieldInfo({
    required this.fieldName,
    required this.label,
    required this.category,
  });
}

/// Result of a completeness check on a resident profile.
class ResidentCompleteness {
  final int totalFields;
  final int completedFields;
  final List<MissingFieldInfo> missingFields;

  const ResidentCompleteness({
    required this.totalFields,
    required this.completedFields,
    required this.missingFields,
  });

  double get percentage =>
      totalFields > 0 ? completedFields / totalFields : 1.0;

  int get missingCount => missingFields.length;

  bool get isComplete => missingFields.isEmpty;

  String get summaryLabel {
    final pct = (percentage * 100).round();
    if (isComplete) return 'Profile 100% Complete';
    return '$completedFields of $totalFields fields complete ($pct%)';
  }

  /// Group missing fields by category for display.
  Map<String, List<MissingFieldInfo>> get missingByCategory {
    final map = <String, List<MissingFieldInfo>>{};
    for (final field in missingFields) {
      map.putIfAbsent(field.category, () => []).add(field);
    }
    return map;
  }
}

/// Analyzes a [ResidentModel] and returns a completeness report.
///
/// Context-aware: if the resident is NOT in a psych ward, psych-specific
/// fields (like mentalHealthCondition) are excluded from the check.
class ResidentCompletenessChecker {
  /// Whether the resident belongs to a psych unit.
  /// Pass `true` if the resident's ward is a psych ward.
  final bool isPsychResident;

  const ResidentCompletenessChecker({this.isPsychResident = false});

  ResidentCompleteness check(ResidentModel resident) {
    final missing = <MissingFieldInfo>[];

    // ── Basic Info ──
    _checkField(resident.middleName, 'middleName', 'Middle Name', 'Basic Info',
        missing);
    _checkField(
        resident.placeOfBirth, 'placeOfBirth', 'Place of Birth', 'Basic Info',
        missing);
    _checkField(resident.civilStatus, 'civilStatus', 'Civil Status',
        'Basic Info', missing);
    _checkField(
        resident.religion, 'religion', 'Religion', 'Basic Info', missing);
    _checkField(
        resident.photoUrl, 'photoUrl', 'Profile Photo', 'Basic Info', missing);

    // ── Address ──
    _checkField(
        resident.province, 'province', 'Province', 'Address', missing);
    _checkField(resident.city, 'city', 'City/Municipality', 'Address', missing);
    _checkField(
        resident.barangay, 'barangay', 'Barangay', 'Address', missing);
    _checkField(resident.streetAddress, 'streetAddress', 'Street Address',
        'Address', missing);

    // ── Referral ──
    _checkField(
        resident.referredBy, 'referredBy', 'Referred By', 'Referral', missing);
    _checkField(resident.referringContactPerson, 'referringContactPerson',
        'Contact Person', 'Referral', missing);
    _checkField(resident.caseCategory, 'caseCategory', 'Case Category',
        'Referral', missing);
    _checkField(
        resident.caseNumber, 'caseNumber', 'Case Number', 'Referral', missing);

    // ── Education ──
    _checkField(resident.educationalAttainment, 'educationalAttainment',
        'Educational Attainment', 'Education', missing);

    // ── Family ──
    if (resident.familyComposition == null ||
        resident.familyComposition!.isEmpty) {
      missing.add(const MissingFieldInfo(
        fieldName: 'familyComposition',
        label: 'Family Composition',
        category: 'Family',
      ));
    }
    _checkField(resident.nearestRelativeName, 'nearestRelativeName',
        'Nearest Relative', 'Family', missing);
    _checkField(resident.nearestRelativeAddress, 'nearestRelativeAddress',
        'Relative Address', 'Family', missing);
    _checkField(
        resident.nearestRelativeContactNumber,
        'nearestRelativeContactNumber',
        'Relative Contact No.',
        'Family',
        missing);

    // ── Emergency Contact ──
    _checkField(resident.emergencyContactName, 'emergencyContactName',
        'Emergency Contact Name', 'Emergency Contact', missing);
    _checkField(resident.emergencyContactPhone, 'emergencyContactPhone',
        'Emergency Contact Phone', 'Emergency Contact', missing);
    _checkField(resident.emergencyContactRelation, 'emergencyContactRelation',
        'Emergency Contact Relation', 'Emergency Contact', missing);

    // ── Medical ──
    _checkField(resident.primaryDiagnosis, 'primaryDiagnosis',
        'Primary Diagnosis', 'Medical', missing);
    _checkField(
        resident.allergies, 'allergies', 'Allergies', 'Medical', missing);

    // ── Assignment ──
    _checkField(resident.houseparentId, 'houseparentId',
        'Assigned Houseparent', 'Assignment', missing);
    _checkField(resident.socialWorkerId, 'socialWorkerId',
        'Assigned Social Worker', 'Assignment', missing);

    // ── Psych-specific (only if psych resident) ──
    if (isPsychResident) {
      _checkField(resident.mentalHealthCondition, 'mentalHealthCondition',
          'Mental Health Condition', 'Medical', missing);
    }

    final totalFields = missing.length +
        (_countCompleted(resident, isPsychResident));
    final completedFields = totalFields - missing.length;

    return ResidentCompleteness(
      totalFields: totalFields,
      completedFields: completedFields,
      missingFields: missing,
    );
  }

  void _checkField(
    String? value,
    String fieldName,
    String label,
    String category,
    List<MissingFieldInfo> missing,
  ) {
    if (value == null || value.trim().isEmpty) {
      missing.add(MissingFieldInfo(
        fieldName: fieldName,
        label: label,
        category: category,
      ));
    }
  }

  /// Count the total number of fields we are checking.
  /// This is the same set of fields checked above — we just need the total
  /// count so we can compute: total = completed + missing.
  static int _countCompleted(ResidentModel r, bool isPsych) {
    int count = 0;
    // Basic Info (5)
    if (_filled(r.middleName)) count++;
    if (_filled(r.placeOfBirth)) count++;
    if (_filled(r.civilStatus)) count++;
    if (_filled(r.religion)) count++;
    if (_filled(r.photoUrl)) count++;
    // Address (4)
    if (_filled(r.province)) count++;
    if (_filled(r.city)) count++;
    if (_filled(r.barangay)) count++;
    if (_filled(r.streetAddress)) count++;
    // Referral (4)
    if (_filled(r.referredBy)) count++;
    if (_filled(r.referringContactPerson)) count++;
    if (_filled(r.caseCategory)) count++;
    if (_filled(r.caseNumber)) count++;
    // Education (1)
    if (_filled(r.educationalAttainment)) count++;
    // Family (4)
    if (r.familyComposition != null && r.familyComposition!.isNotEmpty) count++;
    if (_filled(r.nearestRelativeName)) count++;
    if (_filled(r.nearestRelativeAddress)) count++;
    if (_filled(r.nearestRelativeContactNumber)) count++;
    // Emergency (3)
    if (_filled(r.emergencyContactName)) count++;
    if (_filled(r.emergencyContactPhone)) count++;
    if (_filled(r.emergencyContactRelation)) count++;
    // Medical (2)
    if (_filled(r.primaryDiagnosis)) count++;
    if (_filled(r.allergies)) count++;
    // Assignment (2)
    if (_filled(r.houseparentId)) count++;
    if (_filled(r.socialWorkerId)) count++;
    // Psych (1, conditional)
    if (isPsych && _filled(r.mentalHealthCondition)) count++;
    return count;
  }

  static bool _filled(String? v) => v != null && v.trim().isNotEmpty;
}
