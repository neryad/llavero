import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:path_provider/path_provider.dart';

import '../core/security/vault_crypto.dart';
import 'models/entry.dart';

/// Reads and writes the single encrypted vault file in the app's private data.
class VaultStorage {
  VaultStorage({this._directory, VaultCrypto? crypto})
    : _crypto = crypto ?? VaultCrypto();

  static const String fileName = 'vault.llavero';
  static const int _formatVersion = 1;
  static final List<int> _associatedData = utf8.encode('llavero.vault.v1');

  final Directory? _directory;
  final VaultCrypto _crypto;

  Future<List<VaultEntry>> load({required SecretKey dataKey}) async {
    final file = await _vaultFile(createDirectory: true);
    if (!await file.exists()) {
      return const <VaultEntry>[];
    }

    final Map<String, Object?> envelope;
    try {
      envelope = _decodeObject(await file.readAsString());
    } on FormatException {
      throw const CorruptVaultException();
    }

    final secretBox = _decodeSecretBox(envelope);
    final cleartext = await _crypto.decryptPayload(
      secretBox,
      dataKey: dataKey,
      associatedData: _associatedData,
    );

    try {
      final payload = _decodeObject(utf8.decode(cleartext));
      if (payload['version'] != _formatVersion) {
        throw const FormatException('Invalid vault payload.');
      }
      final rawEntries = payload['entries'];
      if (rawEntries is! List<Object?>) {
        throw const FormatException('Invalid vault payload.');
      }

      return List<VaultEntry>.unmodifiable(rawEntries.map(VaultEntry.fromJson));
    } on FormatException {
      throw const CorruptVaultException();
    }
  }

  Future<void> save({
    required List<VaultEntry> entries,
    required SecretKey dataKey,
  }) async {
    final cleartext = utf8.encode(
      jsonEncode(<String, Object?>{
        'version': _formatVersion,
        'entries': entries.map((entry) => entry.toJson()).toList(),
      }),
    );
    final encrypted = await _crypto.encryptPayload(
      cleartext,
      dataKey: dataKey,
      associatedData: _associatedData,
    );
    final envelope = jsonEncode(<String, Object>{
      'version': _formatVersion,
      'nonce': base64Encode(encrypted.nonce),
      'ciphertext': base64Encode(encrypted.cipherText),
      'mac': base64Encode(encrypted.mac.bytes),
    });

    final file = await _vaultFile(createDirectory: true);
    final temporaryFile = File('${file.path}.tmp');
    try {
      await temporaryFile.writeAsString(envelope, flush: true);
      await temporaryFile.rename(file.path);
    } finally {
      if (await temporaryFile.exists()) {
        await temporaryFile.delete();
      }
    }
  }

  /// Removes the encrypted vault and any unfinished atomic-write file.
  Future<void> delete() async {
    final directory = _directory ?? await getApplicationSupportDirectory();
    final file = File('${directory.path}/$fileName');
    final temporaryFile = File('${file.path}.tmp');
    if (await file.exists()) {
      await file.delete();
    }
    if (await temporaryFile.exists()) {
      await temporaryFile.delete();
    }
  }

  Future<File> _vaultFile({required bool createDirectory}) async {
    final directory = _directory ?? await getApplicationSupportDirectory();
    if (createDirectory) {
      await directory.create(recursive: true);
    }
    return File('${directory.path}/$fileName');
  }

  SecretBox _decodeSecretBox(Map<String, Object?> envelope) {
    try {
      if (envelope['version'] != _formatVersion) {
        throw const FormatException('Invalid vault envelope.');
      }
      final nonce = _decodeBase64(envelope, 'nonce');
      final ciphertext = _decodeBase64(envelope, 'ciphertext');
      final mac = _decodeBase64(envelope, 'mac');
      if (nonce.length != VaultCrypto.nonceLength ||
          ciphertext.isEmpty ||
          mac.length != VaultCrypto.authenticationTagLength) {
        throw const FormatException('Invalid vault envelope.');
      }
      return SecretBox(ciphertext, nonce: nonce, mac: Mac(mac));
    } on FormatException {
      throw const CorruptVaultException();
    }
  }

  List<int> _decodeBase64(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is! String) {
      throw const FormatException('Invalid vault envelope.');
    }
    return base64Decode(value);
  }

  Map<String, Object?> _decodeObject(String encoded) {
    final decoded = jsonDecode(encoded);
    if (decoded is Map<String, Object?>) {
      return decoded;
    }
    throw const FormatException('Invalid vault object.');
  }
}

/// Signals invalid or unsupported vault data without exposing its contents.
class CorruptVaultException implements Exception {
  const CorruptVaultException();

  @override
  String toString() => 'Stored vault is invalid.';
}
