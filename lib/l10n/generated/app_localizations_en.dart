// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Llavero';

  @override
  String get placeholderTitle => 'Your private space';

  @override
  String get placeholderMessage => 'Offline, all yours';

  @override
  String get loading => 'Loading your private vault…';

  @override
  String get startupFailed =>
      'The vault could not be opened. Please restart the app.';

  @override
  String get welcomeTitle => 'Welcome to Llavero';

  @override
  String get welcomeMessage =>
      'A private vault for the things your family needs to remember.';

  @override
  String get welcomeTagline => 'Offline, all yours';

  @override
  String get languagePickerTitle => 'Choose a language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get stepWelcome => 'Welcome';

  @override
  String get stepHowItWorks => 'How it works';

  @override
  String get stepCreatePin => 'Create a PIN';

  @override
  String get stepSecurity => 'Your security';

  @override
  String get howTitle => 'How Llavero works';

  @override
  String get howOfflineTitle => 'Always offline';

  @override
  String get howOfflineDescription =>
      'Your vault stays on this device. Llavero does not connect to the internet.';

  @override
  String get howEncryptionTitle => 'Encrypted on this device';

  @override
  String get howEncryptionDescription =>
      'Your entries are encrypted and can only be opened with your PIN or enabled biometrics.';

  @override
  String get howExportTitle => 'You control exports';

  @override
  String get howExportDescription =>
      'Nothing is shared unless you choose to export it.';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get pinCreateTitle => 'Create a 6-digit PIN';

  @override
  String get pinCreateDescription =>
      'Choose a PIN you can remember. Avoid repeated or sequential digits.';

  @override
  String get pinConfirmTitle => 'Confirm your PIN';

  @override
  String get pinConfirmDescription => 'Enter the same six digits again.';

  @override
  String get pinStrengthHint =>
      'Use six digits that are not repeated or sequential.';

  @override
  String get pinTooEasy => 'That PIN is easy to guess. Choose another one.';

  @override
  String get pinMismatch => 'Those PINs do not match. Start again.';

  @override
  String get pinContinue => 'Continue';

  @override
  String get pinConfirmButton => 'Confirm PIN';

  @override
  String get deleteDigit => 'Delete last digit';

  @override
  String get biometricTitle => 'Enable biometrics?';

  @override
  String get biometricDescription =>
      'Use your device biometrics to unlock faster. Your Llavero PIN is always the fallback.';

  @override
  String get biometricSwitchTitle => 'Unlock with biometrics';

  @override
  String get biometricNotAvailable =>
      'Biometrics are not available on this device.';

  @override
  String get noPinRecovery => 'A forgotten PIN cannot be recovered.';

  @override
  String get forgotPinWarning =>
      'Llavero cannot reset or recover your PIN. Keep an encrypted backup.';

  @override
  String get backupRecommendation =>
      'We recommend creating your first backup when export is available.';

  @override
  String get createFirstEntry => 'Create your first entry';

  @override
  String get lockTitle => 'Llavero is locked';

  @override
  String get lockPinPrompt => 'Enter your 6-digit PIN';

  @override
  String pinDigitsEntered(int count) {
    return '$count of 6 digits entered';
  }

  @override
  String get wrongPin => 'That PIN is incorrect.';

  @override
  String lockoutCountdown(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'Try again in $seconds seconds.',
      one: 'Try again in 1 second.',
    );
    return '$_temp0';
  }

  @override
  String get unlockBiometrics => 'Unlock with biometrics';

  @override
  String get forgotPin => 'Forgot your PIN?';

  @override
  String get eraseEverything => 'Erase everything';

  @override
  String get eraseDialogTitle => 'Erase the vault?';

  @override
  String get eraseDialogMessage =>
      'This permanently removes the encrypted vault, its keys, and all entries. This cannot be undone.';

  @override
  String eraseTypePrompt(String phrase) {
    return 'Type $phrase to confirm.';
  }

  @override
  String get eraseConfirmationPhrase => 'DELETE EVERYTHING';

  @override
  String get eraseContinue => 'Continue';

  @override
  String get cancel => 'Cancel';

  @override
  String get eraseDeviceReason =>
      'Confirm that you want to erase the Llavero vault.';

  @override
  String get erasePinFallbackTitle => 'Enter your Llavero PIN';

  @override
  String get erasePinFallbackDescription =>
      'Device authentication did not complete. Use your vault PIN to continue.';

  @override
  String get erasePinIncorrect =>
      'The PIN is incorrect or a lockout is active. Nothing was erased.';

  @override
  String get biometricUnlockFailed =>
      'Biometric unlock did not complete. Use your PIN instead.';

  @override
  String get vaultCreationFailed =>
      'The vault could not be created. Try again.';
}
