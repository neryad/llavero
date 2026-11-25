import '../../data/models/entry.dart';

/// Filters active entries using only titles, people, and field labels.
List<VaultEntry> searchEntries(
  Iterable<VaultEntry> entries,
  String query, {
  String? category,
  String? person,
}) {
  final normalizedQuery = query.trim().toLowerCase();
  final normalizedPerson = person?.trim().toLowerCase();

  return entries
      .where((entry) {
        if (entry.deletedAt != null) {
          return false;
        }
        if (category != null && entry.category != category) {
          return false;
        }
        if (normalizedPerson != null &&
            normalizedPerson.isNotEmpty &&
            entry.person?.toLowerCase() != normalizedPerson) {
          return false;
        }
        if (normalizedQuery.isEmpty) {
          return true;
        }

        return entry.title.toLowerCase().contains(normalizedQuery) ||
            (entry.person?.toLowerCase().contains(normalizedQuery) ?? false) ||
            entry.fields.any(
              (field) => field.label.toLowerCase().contains(normalizedQuery),
            );
      })
      .toList(growable: false);
}
