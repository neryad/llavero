import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/core/utils/password_generator.dart';

void main() {
  test('generates a password with requested length and character classes', () {
    final password = PasswordGenerator.generate(
      length: 28,
      includeNumbers: true,
      includeSymbols: true,
    );

    expect(password, hasLength(28));
    expect(password, matches(RegExp(r'[0-9]')));
    expect(password, matches(RegExp(r'[^A-Za-z0-9]')));
  });

  test('can generate letters only when number and symbol options are off', () {
    final password = PasswordGenerator.generate(
      length: 24,
      includeNumbers: false,
      includeSymbols: false,
    );

    expect(password, matches(RegExp(r'^[A-Za-z]{24}$')));
  });

  test('generates passphrases from the local word list', () {
    final words = PasswordGenerator.generatePassphrase(wordCount: 5).split('-');

    expect(words, hasLength(5));
    expect(words.every(PasswordGenerator.passphraseWords.contains), isTrue);
  });

  test('rejects unsupported password lengths and word counts', () {
    expect(
      () => PasswordGenerator.generate(
        length: 7,
        includeNumbers: true,
        includeSymbols: true,
      ),
      throwsArgumentError,
    );
    expect(
      () => PasswordGenerator.generatePassphrase(wordCount: 3),
      throwsArgumentError,
    );
  });
}
