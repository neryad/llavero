import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/data/models/entry.dart';

void main() {
  group('VaultEntry', () {
    final createdAt = DateTime.utc(2026, 3, 10, 12);
    final updatedAt = DateTime.utc(2026, 3, 11, 9);
    final deletedAt = DateTime.utc(2026, 3, 12, 8);
    final entry = VaultEntry(
      id: 'entry-1',
      title: 'Wi-Fi casa',
      category: 'wifi',
      person: 'Mamá',
      fields: const <EntryField>[
        EntryField(
          label: 'Contraseña',
          value: 'secreto-local',
          type: EntryFieldType.secret,
          isSecret: true,
        ),
        EntryField(
          label: 'PIN',
          value: '4831',
          type: EntryFieldType.numberPin,
          isSecret: true,
        ),
      ],
      notes: 'Router del salón',
      isFavorite: true,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );

    test('round-trips every entry and field value through JSON', () {
      final restored = VaultEntry.fromJson(entry.toJson());

      expect(restored.toJson(), equals(entry.toJson()));
    });

    test('copies changes and can clear optional person and trash date', () {
      final restored = entry.copyWith(
        title: 'Wi-Fi renovado',
        person: null,
        deletedAt: null,
      );

      expect(restored.title, 'Wi-Fi renovado');
      expect(restored.person, isNull);
      expect(restored.deletedAt, isNull);
      expect(restored.createdAt, createdAt);
      expect(restored.fields, hasLength(2));
    });

    test('does not expose mutable entry or field lists', () {
      expect(() => entry.fields.clear(), throwsUnsupportedError);
    });

    test('rejects unknown field types without exposing field values', () {
      final invalidJson = entry.toJson();
      final fields = List<Map<String, Object?>>.from(
        invalidJson['fields']! as List<Map<String, Object?>>,
      );
      fields[0] = <String, Object?>{
        ...fields[0],
        'type': 'unrecognized',
        'value': 'private-value',
      };
      invalidJson['fields'] = fields;

      expect(
        () => VaultEntry.fromJson(invalidJson),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'message',
            isNot(contains('private-value')),
          ),
        ),
      );
    });
  });
}
