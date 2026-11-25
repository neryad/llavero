import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../../core/security/vault_crypto.dart';
import '../models/entry.dart';
import '../models/vault_category.dart';
import '../vault_storage.dart';

/// Encodes and validates an independently encrypted backup of vault contents.
class VaultBackupService {
  VaultBackupService({VaultCrypto? crypto}) : _crypto = crypto ?? VaultCrypto();

  static const int minimumPasswordLength = 12;
  static const int _formatVersion = 1;
  static const int _contentVersion = 1;
  static const int _iterationCount = 600000;
  static const int _maximumIterationCount = 2000000;
  static const int _saltLength = 16;
  static const int _nonceLength = 12;
  static const int _tagLength = 16;
  static const String _format = 'llavero-encrypted-backup';
  static const String _kdfAlgorithm = 'pbkdf2-hmac-sha256';
  static const String _cipherAlgorithm = 'aes-256-gcm';

  final VaultCrypto _crypto;

  Future<Uint8List> createBackup({
    required VaultContents contents,
    required String password,
  }) async {
    if (password.length < minimumPasswordLength) {
      throw ArgumentError.value(
        password.length,
        'password',
        'Backup passwords must contain at least 12 characters.',
      );
    }

    final salt = _randomBytes(_saltLength);
    final key = await _deriveKey(password, salt, _iterationCount);
    final header = _header(salt: salt, iterations: _iterationCount);
    final cleartext = utf8.encode(
      jsonEncode(<String, Object?>{
        'version': _contentVersion,
        'entries': contents.entries.map((entry) => entry.toJson()).toList(),
        'customCategories': contents.customCategories
            .map((category) => category.toJson())
            .toList(),
      }),
    );
    final encrypted = await _crypto.encryptPayload(
      cleartext,
      dataKey: key,
      associatedData: _associatedData(header),
    );

    return Uint8List.fromList(
      utf8.encode(
        jsonEncode(<String, Object?>{
          ...header,
          'nonce': base64Encode(encrypted.nonce),
          'ciphertext': base64Encode(encrypted.cipherText),
          'mac': base64Encode(encrypted.mac.bytes),
        }),
      ),
    );
  }

  Future<VaultContents> readBackup({
    required List<int> bytes,
    required String password,
  }) async {
    try {
      if (password.length < minimumPasswordLength) {
        throw const BackupFileException();
      }

      final envelope = _decodeObject(utf8.decode(bytes));
      _validateHeader(envelope);
      final salt = _decodeBase64(envelope, 'salt');
      final nonce = _decodeBase64(envelope, 'nonce');
      final ciphertext = _decodeBase64(envelope, 'ciphertext');
      final mac = _decodeBase64(envelope, 'mac');
      final iterations = envelope['kdfIterations']! as int;
      if (salt.length != _saltLength ||
          nonce.length != _nonceLength ||
          ciphertext.isEmpty ||
          mac.length != _tagLength) {
        throw const BackupFileException();
      }

      final header = _header(salt: salt, iterations: iterations);
      final key = await _deriveKey(password, salt, iterations);
      final cleartext = await _crypto.decryptPayload(
        SecretBox(ciphertext, nonce: nonce, mac: Mac(mac)),
        dataKey: key,
        associatedData: _associatedData(header),
      );
      final payload = _decodeObject(utf8.decode(cleartext));
      if (payload['version'] != _contentVersion ||
          payload['entries'] is! List<Object?> ||
          payload['customCategories'] is! List<Object?>) {
        throw const BackupFileException();
      }

      return VaultContents(
        entries: (payload['entries']! as List<Object?>)
            .map(VaultEntry.fromJson)
            .toList(growable: false),
        customCategories: (payload['customCategories']! as List<Object?>)
            .map(VaultCategory.fromJson)
            .toList(growable: false),
      );
    } on BackupFileException {
      rethrow;
    } on Object {
      throw const BackupFileException();
    }
  }

  Future<SecretKey> _deriveKey(
    String password,
    List<int> salt,
    int iterations,
  ) {
    return Pbkdf2.hmacSha256(
      iterations: iterations,
      bits: 256,
    ).deriveKeyFromPassword(password: password, nonce: salt);
  }

  Map<String, Object?> _header({
    required List<int> salt,
    required int iterations,
  }) {
    return <String, Object?>{
      'format': _format,
      'formatVersion': _formatVersion,
      'contentVersion': _contentVersion,
      'kdfAlgorithm': _kdfAlgorithm,
      'kdfIterations': iterations,
      'salt': base64Encode(salt),
      'cipherAlgorithm': _cipherAlgorithm,
    };
  }

  void _validateHeader(Map<String, Object?> envelope) {
    final iterations = envelope['kdfIterations'];
    if (envelope['format'] != _format ||
        envelope['formatVersion'] != _formatVersion ||
        envelope['contentVersion'] != _contentVersion ||
        envelope['kdfAlgorithm'] != _kdfAlgorithm ||
        envelope['cipherAlgorithm'] != _cipherAlgorithm ||
        iterations is! int ||
        iterations < VaultCrypto.iterationCount ||
        iterations > _maximumIterationCount) {
      throw const BackupFileException();
    }
  }

  List<int> _associatedData(Map<String, Object?> header) {
    return utf8.encode(jsonEncode(header));
  }

  List<int> _decodeBase64(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is! String) {
      throw const BackupFileException();
    }
    return base64Decode(value);
  }

  Map<String, Object?> _decodeObject(String encoded) {
    final decoded = jsonDecode(encoded);
    if (decoded is Map<String, Object?>) {
      return decoded;
    }
    throw const BackupFileException();
  }

  List<int> _randomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }
}

/// Generic invalid-backup error that never includes decrypted data.
class BackupFileException implements Exception {
  const BackupFileException();

  @override
  String toString() => 'The backup file is invalid or cannot be opened.';
}
