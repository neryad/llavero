import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/core/utils/entry_search.dart';
import 'package:llavero/data/models/entry.dart';

void main() {
  final entries = <VaultEntry>[
    _entry(
      id: 'wifi',
      title: 'Wi-Fi casa',
      category: 'wifi',
      person: 'Mamá',
      label: 'Red inalámbrica',
      value: 'clave-secreta-no-buscable',
    ),
    _entry(
      id: 'email',
      title: 'Correo familiar',
      category: 'email',
      person: 'Abuela',
      label: 'Dirección',
      value: 'abuela@example.test',
    ),
  ];

  test('searches title, person and field labels but never field values', () {
    expect(searchEntries(entries, 'wi-fi').map((entry) => entry.id), ['wifi']);
    expect(searchEntries(entries, 'mamá').map((entry) => entry.id), ['wifi']);
    expect(searchEntries(entries, 'inalámbrica').map((entry) => entry.id), [
      'wifi',
    ]);
    expect(searchEntries(entries, 'clave-secreta-no-buscable'), isEmpty);
    expect(searchEntries(entries, 'abuela@example.test'), isEmpty);
  });

  test('combines category and person filters', () {
    expect(
      searchEntries(
        entries,
        '',
        category: 'wifi',
        person: 'mamá',
      ).map((entry) => entry.id),
      ['wifi'],
    );
    expect(
      searchEntries(entries, '', category: 'wifi', person: 'abuela'),
      isEmpty,
    );
  });

  test('omits entries already in the trash', () {
    final deleted = _entry(
      id: 'trash',
      title: 'Acceso eliminado',
      category: 'pin',
      person: null,
      label: 'Código',
      value: '1234',
      deletedAt: DateTime.utc(2026),
    );

    expect(searchEntries([deleted], 'acceso'), isEmpty);
  });
}

VaultEntry _entry({
  required String id,
  required String title,
  required String category,
  required String? person,
  required String label,
  required String value,
  DateTime? deletedAt,
}) {
  final now = DateTime.utc(2026);
  return VaultEntry(
    id: id,
    title: title,
    category: category,
    person: person,
    fields: <EntryField>[
      EntryField(
        label: label,
        value: value,
        type: EntryFieldType.secret,
        isSecret: true,
      ),
    ],
    createdAt: now,
    updatedAt: now,
    deletedAt: deletedAt,
  );
}
