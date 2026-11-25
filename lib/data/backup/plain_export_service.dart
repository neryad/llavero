import 'dart:convert';

import '../models/entry.dart';
import '../vault_storage.dart';

/// Creates user-requested, unencrypted exports of all vault contents.
class PlainExportService {
  const PlainExportService();

  String encodeJson(VaultContents contents) {
    return const JsonEncoder.withIndent('  ').convert(<String, Object?>{
      'version': 1,
      'entries': contents.entries.map((entry) => entry.toJson()).toList(),
      'customCategories': contents.customCategories
          .map((category) => category.toJson())
          .toList(),
    });
  }

  String encodeCsv(VaultContents contents) {
    final customCategoryNames = <String, String>{
      for (final category in contents.customCategories)
        category.id: category.name,
    };
    final output = StringBuffer()
      ..write(
        <String>[
          'entryId',
          'title',
          'category',
          'person',
          'notes',
          'isFavorite',
          'createdAt',
          'updatedAt',
          'deletedAt',
          'fieldLabel',
          'fieldValue',
          'fieldType',
          'isSecret',
        ].map(_escapeCsvValue).join(','),
      )
      ..write('\r\n');

    for (final entry in contents.entries) {
      final List<EntryField?> fields = entry.fields.isEmpty
          ? const <EntryField?>[null]
          : entry.fields;
      for (final field in fields) {
        output
          ..write(
            <String>[
              entry.id,
              entry.title,
              customCategoryNames[entry.category] ?? entry.category,
              entry.person ?? '',
              entry.notes,
              entry.isFavorite.toString(),
              entry.createdAt.toIso8601String(),
              entry.updatedAt.toIso8601String(),
              entry.deletedAt?.toIso8601String() ?? '',
              field?.label ?? '',
              field?.value ?? '',
              field?.type.name ?? '',
              field?.isSecret.toString() ?? '',
            ].map(_escapeCsvValue).join(','),
          )
          ..write('\r\n');
      }
    }
    return output.toString();
  }

  String _escapeCsvValue(String value) {
    final firstNonWhitespace = value.trimLeft();
    final startsWithFormula =
        firstNonWhitespace.isNotEmpty &&
        const <String>{'=', '+', '-', '@'}.contains(firstNonWhitespace[0]);
    final safeValue = startsWithFormula ? "'$value" : value;
    if (safeValue.contains(RegExp(r'[",\r\n]'))) {
      return '"${safeValue.replaceAll('"', '""')}"';
    }
    return safeValue;
  }
}
