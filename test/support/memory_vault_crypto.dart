import 'package:cryptography/cryptography.dart';
import 'package:llavero/core/security/vault_crypto.dart';

class MemoryVaultCrypto extends VaultCrypto {
  static const String correctPin = '582941';
  static final SecretKey dataKey = SecretKey(List<int>.filled(32, 7));

  @override
  Future<GeneratedVaultKey> createVaultKey({required String pin}) async {
    return GeneratedVaultKey(
      dataEncryptionKey: dataKey,
      keyMaterial: WrappedKeyMaterial(
        salt: List<int>.filled(VaultCrypto.saltLength, 1),
        kdfIterations: VaultCrypto.iterationCount,
        nonce: List<int>.filled(VaultCrypto.nonceLength, 2),
        encryptedDataKey: List<int>.filled(VaultCrypto.keyLength, 3),
        mac: List<int>.filled(VaultCrypto.authenticationTagLength, 4),
      ),
    );
  }

  @override
  Future<SecretKey> unwrapDataEncryptionKey({
    required String pin,
    required WrappedKeyMaterial keyMaterial,
  }) async {
    if (pin != correctPin) {
      throw const VaultAuthenticationException();
    }
    return dataKey;
  }
}
