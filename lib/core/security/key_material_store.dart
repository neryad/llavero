import 'dart:convert';

import 'secure_value_store.dart';
import 'vault_crypto.dart';

/// Persists only the salt, KDF parameters, nonce, and wrapped data key.
class KeyMaterialStore {
  KeyMaterialStore(this._secureValues);

  static const String storageKey = 'llavero.wrapped-key.v1';
  static const int defaultPinLength = 6;
  static const int _recordVersion = 2;

  final SecureValueStore _secureValues;

  Future<void> save(WrappedKeyMaterial material, {int pinLength = 6}) {
    if (pinLength < 4 || pinLength > 8) {
      throw ArgumentError.value(pinLength, 'pinLength');
    }
    return _secureValues.write(
      storageKey,
      jsonEncode(<String, Object>{
        'recordVersion': _recordVersion,
        'pinLength': pinLength,
        'wrappedKey': material.toJson(),
      }),
    );
  }

  Future<WrappedKeyMaterial?> load() async {
    final record = await _loadRecord();
    return record?.material;
  }

  Future<int> loadPinLength() async {
    final record = await _loadRecord();
    return record?.pinLength ?? defaultPinLength;
  }

  Future<_StoredKeyRecord?> _loadRecord() async {
    final encoded = await _secureValues.read(storageKey);
    if (encoded == null) {
      return null;
    }

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid wrapped key metadata.');
      }
      if (decoded['recordVersion'] == _recordVersion) {
        final pinLength = decoded['pinLength'];
        if (pinLength is! int || pinLength < 4 || pinLength > 8) {
          throw const FormatException('Invalid PIN length metadata.');
        }
        return _StoredKeyRecord(
          material: WrappedKeyMaterial.fromJson(decoded['wrappedKey']),
          pinLength: pinLength,
        );
      }
      return _StoredKeyRecord(
        material: WrappedKeyMaterial.fromJson(decoded),
        pinLength: defaultPinLength,
      );
    } on FormatException {
      throw const CorruptKeyMaterialException();
    }
  }

  Future<void> delete() => _secureValues.delete(storageKey);
}

class _StoredKeyRecord {
  const _StoredKeyRecord({required this.material, required this.pinLength});

  final WrappedKeyMaterial material;
  final int pinLength;
}

/// Signals invalid or unsupported key metadata without exposing its contents.
class CorruptKeyMaterialException implements Exception {
  const CorruptKeyMaterialException();

  @override
  String toString() => 'Stored key material is invalid.';
}
