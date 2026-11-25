/// The reason a PIN did not satisfy the vault's creation rules.
enum PinValidationError {
  invalidConfiguration,
  invalidLength,
  invalidFormat,
  tooEasy,
}

/// Validates numeric PINs and rejects repeated or consecutive digit patterns.
abstract final class PinValidator {
  static PinValidationError? validate(String pin, {int length = 6}) {
    if (length < 4 || length > 8) {
      return PinValidationError.invalidConfiguration;
    }
    if (pin.length != length) {
      return PinValidationError.invalidLength;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(pin)) {
      return PinValidationError.invalidFormat;
    }

    final digits = pin.codeUnits;
    final repeated = digits.every((digit) => digit == digits.first);
    var ascending = true;
    var descending = true;
    for (var index = 1; index < digits.length; index++) {
      final difference = digits[index] - digits[index - 1];
      if (difference != 1) {
        ascending = false;
      }
      if (difference != -1) {
        descending = false;
      }
    }

    if (repeated || ascending || descending) {
      return PinValidationError.tooEasy;
    }
    return null;
  }
}
