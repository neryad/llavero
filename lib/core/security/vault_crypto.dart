import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

/// Cryptographic operations for the vault's data key and encrypted payloads.
class VaultCrypto {
  VaultCrypto() : _cipher = AesGcm.with256bits();

  static const int iterationCount = 600000;
  static const int keyLength = 32;
  static const int saltLength = 16;
  static const int nonceLength = 12;
  static const int authenticationTagLength = 16;
  static const int _maximumIterationCount = 2000000;
  static final List<int> _wrappedKeyAssociatedData = utf8.encode(
    'llavero.wrapped-dek.v1',
  );

  final AesGcm _cipher;

  /// Generates a random data encryption key and wraps it with a PIN-derived key.
  Future<GeneratedVaultKey> createVaultKey({required String pin}) async {
    final keyBytes = _secureRandomBytes(keyLength);
    final material = await wrapDataEncryptionKey(
      pin: pin,
      dataEncryptionKey: keyBytes,
    );

    return GeneratedVaultKey(
      dataEncryptionKey: SecretKey(keyBytes),
      keyMaterial: material,
    );
  }

  /// Encrypts a data encryption key without storing the PIN or cleartext key.
  Future<WrappedKeyMaterial> wrapDataEncryptionKey({
    required String pin,
    required List<int> dataEncryptionKey,
  }) async {
    if (dataEncryptionKey.length != keyLength) {
      throw ArgumentError.value(
        dataEncryptionKey.length,
        'dataEncryptionKey',
        'A 256-bit key must contain 32 bytes.',
      );
    }

    final salt = _secureRandomBytes(saltLength);
    final pinKey = await _derivePinKey(pin, salt);
    final nonce = _cipher.newNonce();
    final encrypted = await _cipher.encrypt(
      dataEncryptionKey,
      secretKey: pinKey,
      nonce: nonce,
      aad: _wrappedKeyAssociatedData,
    );

    return WrappedKeyMaterial(
      salt: salt,
      kdfIterations: iterationCount,
      nonce: encrypted.nonce,
      encryptedDataKey: encrypted.cipherText,
      mac: encrypted.mac.bytes,
    );
  }

  /// Opens a wrapped data key, or throws a generic error for a wrong PIN.
  Future<SecretKey> unwrapDataEncryptionKey({
    required String pin,
    required WrappedKeyMaterial keyMaterial,
  }) async {
    final pinKey = await _derivePinKey(
      pin,
      keyMaterial.salt,
      iterations: keyMaterial.kdfIterations,
    );
    final wrappedKey = SecretBox(
      keyMaterial.encryptedDataKey,
      nonce: keyMaterial.nonce,
      mac: Mac(keyMaterial.mac),
    );

    try {
      final keyBytes = await _cipher.decrypt(
        wrappedKey,
        secretKey: pinKey,
        aad: _wrappedKeyAssociatedData,
      );
      if (keyBytes.length != keyLength) {
        throw const VaultAuthenticationException();
      }
      return SecretKey(keyBytes);
    } on SecretBoxAuthenticationError {
      throw const VaultAuthenticationException();
    }
  }

  /// Encrypts bytes with AES-256-GCM and a fresh random nonce.
  Future<SecretBox> encryptPayload(
    List<int> cleartext, {
    required SecretKey dataKey,
    List<int> associatedData = const <int>[],
  }) {
    return _cipher.encrypt(
      cleartext,
      secretKey: dataKey,
      nonce: _cipher.newNonce(),
      aad: associatedData,
    );
  }

  /// Decrypts and authenticates a payload, rejecting any altered bytes.
  Future<List<int>> decryptPayload(
    SecretBox encrypted, {
    required SecretKey dataKey,
    List<int> associatedData = const <int>[],
  }) async {
    try {
      return await _cipher.decrypt(
        encrypted,
        secretKey: dataKey,
        aad: associatedData,
      );
    } on SecretBoxAuthenticationError {
      throw const VaultAuthenticationException();
    }
  }

  Future<SecretKey> _derivePinKey(
    String pin,
    List<int> salt, {
    int iterations = iterationCount,
  }) {
    final derivation = Pbkdf2.hmacSha256(iterations: iterations, bits: 256);
    return derivation.deriveKeyFromPassword(password: pin, nonce: salt);
  }

  List<int> _secureRandomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(
      length,
      (_) => random.nextInt(256),
      growable: false,
    );
  }
}

/// The newly generated in-memory data key and its persisted wrapped form.
class GeneratedVaultKey {
  const GeneratedVaultKey({
    required this.dataEncryptionKey,
    required this.keyMaterial,
  });

  final SecretKey dataEncryptionKey;
  final WrappedKeyMaterial keyMaterial;
}

/// Public KDF metadata and authenticated ciphertext for one wrapped data key.
class WrappedKeyMaterial {
  WrappedKeyMaterial({
    required List<int> salt,
    required this.kdfIterations,
    required List<int> nonce,
    required List<int> encryptedDataKey,
    required List<int> mac,
    this.version = 1,
    this.kdfAlgorithm = 'pbkdf2-hmac-sha256',
  }) : salt = List<int>.unmodifiable(salt),
       nonce = List<int>.unmodifiable(nonce),
       encryptedDataKey = List<int>.unmodifiable(encryptedDataKey),
       mac = List<int>.unmodifiable(mac) {
    if (version != 1 || kdfAlgorithm != 'pbkdf2-hmac-sha256') {
      throw ArgumentError('Unsupported wrapped key format.');
    }
    if (kdfIterations < VaultCrypto.iterationCount ||
        kdfIterations > VaultCrypto._maximumIterationCount) {
      throw ArgumentError('Invalid key derivation parameters.');
    }
    if (this.salt.length != VaultCrypto.saltLength ||
        this.nonce.length != VaultCrypto.nonceLength ||
        this.encryptedDataKey.length != VaultCrypto.keyLength ||
        this.mac.length != VaultCrypto.authenticationTagLength) {
      throw ArgumentError('Invalid wrapped key data.');
    }
  }

  final int version;
  final String kdfAlgorithm;
  final int kdfIterations;
  final List<int> salt;
  final List<int> nonce;
  final List<int> encryptedDataKey;
  final List<int> mac;

  Map<String, Object> toJson() => <String, Object>{
    'version': version,
    'kdfAlgorithm': kdfAlgorithm,
    'kdfIterations': kdfIterations,
    'salt': base64Encode(salt),
    'nonce': base64Encode(nonce),
    'encryptedDataKey': base64Encode(encryptedDataKey),
    'mac': base64Encode(mac),
  };

  factory WrappedKeyMaterial.fromJson(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Invalid wrapped key metadata.');
    }

    final version = value['version'];
    final kdfAlgorithm = value['kdfAlgorithm'];
    final kdfIterations = value['kdfIterations'];
    final salt = value['salt'];
    final nonce = value['nonce'];
    final encryptedDataKey = value['encryptedDataKey'];
    final mac = value['mac'];
    if (version is! int ||
        kdfAlgorithm is! String ||
        kdfIterations is! int ||
        salt is! String ||
        nonce is! String ||
        encryptedDataKey is! String ||
        mac is! String) {
      throw const FormatException('Invalid wrapped key metadata.');
    }

    try {
      return WrappedKeyMaterial(
        version: version,
        kdfAlgorithm: kdfAlgorithm,
        kdfIterations: kdfIterations,
        salt: base64Decode(salt),
        nonce: base64Decode(nonce),
        encryptedDataKey: base64Decode(encryptedDataKey),
        mac: base64Decode(mac),
      );
    } on ArgumentError {
      throw const FormatException('Invalid wrapped key metadata.');
    }
  }
}

/// A generic authentication failure that does not reveal which check failed.
class VaultAuthenticationException implements Exception {
  const VaultAuthenticationException();

  @override
  String toString() => 'Vault authentication failed.';
}
