import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

/// Keeps platform file operations small and replaceable in widget tests.
abstract interface class BackupFileGateway {
  Future<Uint8List?> pickBackupFile();

  Future<bool> saveFile({required Uint8List bytes, required String fileName});

  Future<bool> shareFile({required Uint8List bytes, required String fileName});

  Future<bool> printPdf({required Uint8List bytes});
}

class PlatformBackupFileGateway implements BackupFileGateway {
  @override
  Future<Uint8List?> pickBackupFile() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const <String>['llavero'],
    );
    if (file == null) {
      return null;
    }
    return file.readAsBytes();
  }

  @override
  Future<bool> saveFile({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final savedFile = await FilePicker.saveFile(
      fileName: fileName,
      bytes: bytes,
      mimeType: _mimeType(fileName),
    );
    return savedFile != null;
  }

  @override
  Future<bool> shareFile({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final result = await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[
          XFile.fromData(bytes, mimeType: _mimeType(fileName), name: fileName),
        ],
        fileNameOverrides: <String>[fileName],
        title: fileName,
      ),
    );
    return result.status == ShareResultStatus.success;
  }

  @override
  Future<bool> printPdf({required Uint8List bytes}) {
    return Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  String _mimeType(String fileName) {
    return switch (fileName.split('.').last.toLowerCase()) {
      'csv' => 'text/csv',
      'json' => 'application/json',
      'pdf' => 'application/pdf',
      _ => 'application/octet-stream',
    };
  }
}
