import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/core/security/pin_validator.dart';

void main() {
  group('PinValidator', () {
    test('accepts a non-trivial PIN with the configured length', () {
      expect(PinValidator.validate('582941'), isNull);
    });

    test('rejects a PIN with the wrong length or non-digit characters', () {
      expect(PinValidator.validate('58294'), PinValidationError.invalidLength);
      expect(PinValidator.validate('58a941'), PinValidationError.invalidFormat);
    });

    test('rejects repeated and sequential PINs', () {
      expect(PinValidator.validate('000000'), PinValidationError.tooEasy);
      expect(
        PinValidator.validate('1111', length: 4),
        PinValidationError.tooEasy,
      );
      expect(PinValidator.validate('123456'), PinValidationError.tooEasy);
      expect(PinValidator.validate('654321'), PinValidationError.tooEasy);
      expect(
        PinValidator.validate('0123', length: 4),
        PinValidationError.tooEasy,
      );
    });

    test('allows PIN lengths from four through eight digits', () {
      expect(PinValidator.validate('5291', length: 4), isNull);
      expect(PinValidator.validate('52918473', length: 8), isNull);
      expect(
        PinValidator.validate('5291', length: 3),
        PinValidationError.invalidConfiguration,
      );
      expect(
        PinValidator.validate('529184739', length: 9),
        PinValidationError.invalidConfiguration,
      );
    });
  });
}
