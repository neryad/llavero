import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/data/backup/emergency_sheet_pdf.dart';
import 'package:llavero/data/models/entry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'creates a PDF document for the entries selected by the caller',
    () async {
      final selected = <VaultEntry>[
        VaultEntry(
          id: 'selected',
          title: 'Cuenta de emergencia',
          category: 'email',
          fields: const <EntryField>[
            EntryField(
              label: 'Contraseña',
              value: 'example-secret',
              type: EntryFieldType.secret,
              isSecret: true,
            ),
          ],
          createdAt: DateTime.utc(2026, 11, 25),
          updatedAt: DateTime.utc(2026, 11, 25),
        ),
      ];
      const labels = EmergencySheetLabels(
        title: 'Hoja de emergencia',
        category: 'Categoría',
        person: 'Persona',
        notes: 'Notas',
      );

      final pdf = await EmergencySheetPdf.create(
        entries: selected,
        labels: labels,
      );

      expect(utf8.decode(pdf.take(5).toList()), '%PDF-');
    },
  );
}
