import '../../data/models/entry.dart';

/// Summary-only password health results; secret values are never retained.
class SecurityHealthReport {
  const SecurityHealthReport({
    required this.checkedSecretCount,
    required this.weakSecretCount,
    required this.reusedSecretCount,
  });

  final int checkedSecretCount;
  final int weakSecretCount;
  final int reusedSecretCount;

  @override
  String toString() =>
      'SecurityHealthReport(checked: $checkedSecretCount, weak: $weakSecretCount, reused: $reusedSecretCount)';
}

/// Checks active secret fields in memory without persisting secret values.
class SecurityHealthAnalyzer {
  const SecurityHealthAnalyzer();
  static const Set<String> _commonPasswords = <String>{
    'password',
    'password123',
    'qwerty123',
    'letmein123',
    'welcome123',
  };

  SecurityHealthReport analyze(Iterable<VaultEntry> entries) {
    final seenValues = <String>{};
    var checkedSecretCount = 0;
    var weakSecretCount = 0;
    var reusedSecretCount = 0;

    for (final entry in entries) {
      if (entry.deletedAt != null) {
        continue;
      }
      for (final field in entry.fields) {
        if (!field.isSecret || field.value.isEmpty) {
          continue;
        }
        checkedSecretCount++;
        if (_isWeak(field.value)) {
          weakSecretCount++;
        }
        if (!seenValues.add(field.value)) {
          reusedSecretCount++;
        }
      }
    }

    return SecurityHealthReport(
      checkedSecretCount: checkedSecretCount,
      weakSecretCount: weakSecretCount,
      reusedSecretCount: reusedSecretCount,
    );
  }

  bool _isWeak(String value) {
    final normalized = value.toLowerCase();
    if (value.length < 12 || _commonPasswords.contains(normalized)) {
      return true;
    }
    if (RegExp(r'^(.)\1+$').hasMatch(value)) {
      return true;
    }
    return _isSequentialDigits(value);
  }

  bool _isSequentialDigits(String value) {
    if (value.length < 4 || !RegExp(r'^\d+$').hasMatch(value)) {
      return false;
    }
    final ascending = '0123456789'.contains(value);
    final descending = '9876543210'.contains(value);
    return ascending || descending;
  }
}
