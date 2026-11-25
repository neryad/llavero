import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/data/backup/plain_export_service.dart';
import 'package:llavero/data/models/entry.dart';
import 'package:llavero/data/models/vault_category.dart';
import 'package:llavero/data/vault_storage.dart';

void main() {
  const service = PlainExportService();
  final contents = VaultContents(
    entries: <VaultEntry>[
      VaultEntry(
        id: 'entry-1',
        title: 'Casa, "familia"\nWi-Fi',
        category: 'home-network',
        person: 'Mamá',
        fields: const <EntryField>[
          EntryField(
            label: 'Contraseña',
            value: 'red, "principal"\nsegunda línea',
            type: EntryFieldType.secret,
            isSecret: true,
          ),
        ],
        notes: 'Nota, privada',
        isFavorite: true,
        createdAt: DateTime.utc(2026, 11, 25),
        updatedAt: DateTime.utc(2026, 11, 25),
      ),
      VaultEntry(
        id: 'entry-empty',
        title: 'Sin campos',
        category: 'other',
        fields: const <EntryField>[],
        createdAt: DateTime.utc(2026, 11, 20),
        updatedAt: DateTime.utc(2026, 11, 21),
        deletedAt: DateTime.utc(2026, 11, 22),
      ),
    ],
    customCategories: const <VaultCategory>[
      VaultCategory(id: 'home-network', name: 'Red familiar'),
    ],
  );

  test('encodes all entries and custom categories as versioned JSON', () {
    final json =
        jsonDecode(service.encodeJson(contents)) as Map<String, Object?>;

    expect(json['version'], 1);
    expect(json['entries'], hasLength(2));
    expect(json['entries'], contains(containsPair('deletedAt', isNotNull)));
    expect(json['customCategories'], <Map<String, Object?>>[
      <String, Object?>{'id': 'home-network', 'name': 'Red familiar'},
    ]);
  });

  test(
    'quotes CSV delimiters and preserves one row for an entry without fields',
    () {
      final csv = service.encodeCsv(contents);

      expect(csv, contains('"Casa, ""familia""\nWi-Fi"'));
      expect(csv, contains('"red, ""principal""\nsegunda línea"'));
      expect(csv, contains('entry-empty,Sin campos,other'));
    },
  );

  test('escapes spreadsheet formula prefixes in exported values', () {
    final formulaContents = VaultContents(
      entries: <VaultEntry>[
        VaultEntry(
          id: 'formula',
          title: '=1+1',
          category: 'other',
          fields: const <EntryField>[
            EntryField(
              label: 'Dato',
              value: ' @SUM(A1:A2)',
              type: EntryFieldType.text,
              isSecret: false,
            ),
          ],
          createdAt: DateTime.utc(2026, 11, 25),
          updatedAt: DateTime.utc(2026, 11, 25),
        ),
      ],
      customCategories: const <VaultCategory>[],
    );

    final csv = service.encodeCsv(formulaContents);

    expect(csv, contains("'=1+1"));
    expect(csv, contains("' @SUM(A1:A2)"));
  });
}
