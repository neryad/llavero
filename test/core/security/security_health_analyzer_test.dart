import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/core/security/security_health_analyzer.dart';
import 'package:llavero/data/models/entry.dart';

void main() {
  group('SecurityHealthAnalyzer', () {
    test('counts weak and reused secrets without returning their values', () {
      final entries = <VaultEntry>[
        _entry(
          id: 'one',
          fields: const <EntryField>[
            EntryField(
              label: 'Password',
              value: 'short',
              type: EntryFieldType.secret,
              isSecret: true,
            ),
            EntryField(
              label: 'Second password',
              value: 'same-password',
              type: EntryFieldType.secret,
              isSecret: true,
            ),
          ],
        ),
        _entry(
          id: 'two',
          fields: const <EntryField>[
            EntryField(
              label: 'Password',
              value: 'same-password',
              type: EntryFieldType.secret,
              isSecret: true,
            ),
            EntryField(
              label: 'Email',
              value: 'same-password',
              type: EntryFieldType.email,
              isSecret: false,
            ),
          ],
        ),
      ];

      final report = SecurityHealthAnalyzer().analyze(entries);

      expect(report.checkedSecretCount, 3);
      expect(report.weakSecretCount, 1);
      expect(report.reusedSecretCount, 1);
      expect(report.toString(), isNot(contains('same-password')));
      expect(report.toString(), isNot(contains('short')));
    });

    test('does not count deleted entries or non-secret fields', () {
      final report = SecurityHealthAnalyzer().analyze(<VaultEntry>[
        _entry(
          id: 'trash',
          deletedAt: DateTime.utc(2026, 11, 25),
          fields: const <EntryField>[
            EntryField(
              label: 'Password',
              value: 'tiny',
              type: EntryFieldType.secret,
              isSecret: true,
            ),
          ],
        ),
        _entry(
          id: 'active',
          fields: const <EntryField>[
            EntryField(
              label: 'Note',
              value: 'tiny',
              type: EntryFieldType.text,
              isSecret: false,
            ),
          ],
        ),
      ]);

      expect(report.checkedSecretCount, 0);
      expect(report.weakSecretCount, 0);
      expect(report.reusedSecretCount, 0);
    });
  });
}

VaultEntry _entry({
  required String id,
  required List<EntryField> fields,
  DateTime? deletedAt,
}) {
  return VaultEntry(
    id: id,
    title: 'Entry $id',
    category: 'other',
    fields: fields,
    createdAt: DateTime.utc(2026, 11, 25),
    updatedAt: DateTime.utc(2026, 11, 25),
    deletedAt: deletedAt,
  );
}
