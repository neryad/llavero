import 'dart:convert';

import 'secure_value_store.dart';
import 'vault_crypto.dart';

/// Persists only the salt, KDF parameters, nonce, and wrapped data key.
class KeyMaterialStore {
  KeyMaterialStore(this._secureValues);

  static const String storageKey = 'llavero.wrapped-key.v1';

  final SecureValueStore _secureValues;

  Future<void> save(WrappedKeyMaterial material) {
    return _secureValues.write(storageKey, jsonEncode(material.toJson()));
  }

  Future<WrappedKeyMaterial?> load() async {
    final encoded = await _secureValues.read(storageKey);
    if (encoded == null) {
      return null;
    }

    try {
      return WrappedKeyMaterial.fromJson(jsonDecode(encoded));
    } on FormatException {
      throw const CorruptKeyMaterialException();
    }
  }

  Future<void> delete() => _secureValues.delete(storageKey);
}

/// Signals invalid or unsupported key metadata without exposing its contents.
class CorruptKeyMaterialException implements Exception {
  const CorruptKeyMaterialException();

  @override
  String toString() => 'Stored key material is invalid.';
}
