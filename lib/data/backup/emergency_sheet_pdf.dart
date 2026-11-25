import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/entry.dart';

/// Generates a printable sheet containing only the entries explicitly chosen.
class EmergencySheetPdf {
  static Future<Uint8List> create({
    required List<VaultEntry> entries,
    required EmergencySheetLabels labels,
    Map<String, String> categoryNamesById = const <String, String>{},
  }) async {
    final regularFontData = await rootBundle.load(
      'assets/fonts/Plus_Jakarta_Sans/static/PlusJakartaSans-Regular.ttf',
    );
    final boldFontData = await rootBundle.load(
      'assets/fonts/Plus_Jakarta_Sans/static/PlusJakartaSans-SemiBold.ttf',
    );
    final document = pw.Document(
      theme: pw.ThemeData.withFont(
        base: pw.Font.ttf(regularFontData),
        bold: pw.Font.ttf(boldFontData),
      ),
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) => <pw.Widget>[
          pw.Header(level: 0, child: pw.Text(labels.title)),
          for (final entry in entries) ...<pw.Widget>[
            pw.Header(level: 1, child: pw.Text(entry.title)),
            pw.Text(
              '${labels.category}: '
              '${categoryNamesById[entry.category] ?? entry.category}',
            ),
            if (entry.person?.isNotEmpty ?? false)
              pw.Text('${labels.person}: ${entry.person}'),
            for (final field in entry.fields)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 4),
                child: pw.Text('${field.label}: ${field.value}'),
              ),
            if (entry.notes.isNotEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 4),
                child: pw.Text('${labels.notes}: ${entry.notes}'),
              ),
            pw.Divider(),
          ],
        ],
      ),
    );

    return document.save();
  }
}

class EmergencySheetLabels {
  const EmergencySheetLabels({
    required this.title,
    required this.category,
    required this.person,
    required this.notes,
  });

  final String title;
  final String category;
  final String person;
  final String notes;
}
