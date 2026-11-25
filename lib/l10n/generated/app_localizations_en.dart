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

  @override
  String get searchEntries => 'Search titles, people, or labels';

  @override
  String get filterCategories => 'Categories';

  @override
  String get filterPeople => 'People';

  @override
  String get allFilter => 'All';

  @override
  String get favoritesSection => 'Favorites';

  @override
  String get allEntriesSection => 'All entries';

  @override
  String get emptyVaultTitle => 'Your vault starts here';

  @override
  String get emptyVaultMessage =>
      'Add your first entry to keep what your family needs to remember close at hand.';

  @override
  String get noSearchResults => 'No entries found';

  @override
  String get addEntryButton => 'Add entry';

  @override
  String get trash => 'Trash';

  @override
  String get categoryWifi => 'Wi-Fi';

  @override
  String get categoryEmail => 'Email';

  @override
  String get categoryStreaming => 'Streaming';

  @override
  String get categoryBanking => 'Banking and cards';

  @override
  String get categoryPin => 'PIN and codes';

  @override
  String get categorySocial => 'Social and apps';

  @override
  String get categoryDevices => 'Devices';

  @override
  String get categoryDocuments => 'Documents and IDs';

  @override
  String get categoryOther => 'Other';

  @override
  String get personUnknown => 'No person';

  @override
  String get newEntry => 'New entry';

  @override
  String get editEntry => 'Edit entry';

  @override
  String get entryTitle => 'Title';

  @override
  String get entryTitleHint => 'For example, Home Wi-Fi';

  @override
  String get entryCategory => 'Category';

  @override
  String get entryPerson => 'Person (optional)';

  @override
  String get entryNotes => 'Notes (optional)';

  @override
  String get entryFields => 'Saved details';

  @override
  String get addField => 'Add field';

  @override
  String get removeField => 'Remove field';

  @override
  String get moveFieldUp => 'Move field up';

  @override
  String get moveFieldDown => 'Move field down';

  @override
  String get fieldLabel => 'Field name';

  @override
  String get fieldValue => 'Value';

  @override
  String get saveEntry => 'Save entry';

  @override
  String get addCustomCategory => 'Create category';

  @override
  String get customCategoryName => 'Category name';

  @override
  String get categoryNameRequired => 'Enter a unique name for this category.';

  @override
  String get fieldType => 'Data type';

  @override
  String get fieldTypeText => 'Text';

  @override
  String get fieldTypeSecret => 'Secret';

  @override
  String get fieldTypeUrl => 'Link';

  @override
  String get fieldTypeNumberPin => 'Number or PIN';

  @override
  String get fieldTypeEmail => 'Email';

  @override
  String get fieldTypePhone => 'Phone';

  @override
  String get streamingPreset => 'Service';

  @override
  String get chooseService => 'Choose a service';

  @override
  String get passwordGenerator => 'Password generator';

  @override
  String generatorLength(int length) {
    return 'Length: $length';
  }

  @override
  String get generatorNumbers => 'Include numbers';

  @override
  String get generatorSymbols => 'Include symbols';

  @override
  String get generatorPassphrase => 'Passphrase';

  @override
  String get generatorWordCount => 'Number of words';

  @override
  String get generate => 'Generate';

  @override
  String get useGenerated => 'Use password';

  @override
  String get passwordStrengthWeak => 'Weak';

  @override
  String get passwordStrengthFair => 'Fair';

  @override
  String get passwordStrengthGood => 'Good';

  @override
  String get passwordStrengthStrong => 'Strong';

  @override
  String get entryTitleRequired => 'Enter a title for this entry.';

  @override
  String get fieldLabelRequired => 'Each field needs a name.';

  @override
  String get unsavedChanges => 'Unsaved changes';

  @override
  String get discardChanges => 'Discard changes';

  @override
  String get discardDialogTitle => 'Discard changes?';

  @override
  String get discardDialogMessage => 'Your unsaved changes will be lost.';

  @override
  String get saveFailed => 'Could not save. Check the vault and try again.';

  @override
  String get details => 'Details';

  @override
  String get reveal => 'Reveal secret';

  @override
  String get hide => 'Hide secret';

  @override
  String get copy => 'Copy';

  @override
  String get copied => 'Copied to clipboard';

  @override
  String get edit => 'Edit';

  @override
  String get favorite => 'Add to favorites';

  @override
  String get removeFavorite => 'Remove from favorites';

  @override
  String get duplicate => 'Duplicate';

  @override
  String get moveToTrash => 'Move to trash';

  @override
  String get deleteEntryDialog => 'Move this entry to the trash?';

  @override
  String get confirm => 'Confirm';

  @override
  String get wifiQr => 'Wi-Fi QR code';

  @override
  String get wifiQrHint =>
      'Point your camera at this code to join the network.';

  @override
  String get qrMissingNetwork => 'Add the network name to create a QR code.';

  @override
  String get trashTitle => 'Trash';

  @override
  String get trashEmpty => 'The trash is empty';

  @override
  String get trashRestore => 'Restore';

  @override
  String get deleteForever => 'Delete forever';

  @override
  String get deleteForeverConfirm => 'This entry will be permanently deleted.';

  @override
  String get entryDeleted => 'Entry moved to trash';

  @override
  String get entryRestored => 'Entry restored';

  @override
  String get entryDeletedForever => 'Entry permanently deleted';

  @override
  String get fieldNetworkName => 'Network name';

  @override
  String get fieldPassword => 'Password';

  @override
  String get fieldSecurityType => 'Security type';

  @override
  String get fieldEmailAddress => 'Email address';

  @override
  String get fieldRecoveryEmail => 'Recovery email';

  @override
  String get fieldRecoveryPhone => 'Recovery phone';

  @override
  String get fieldService => 'Service';

  @override
  String get fieldEmailOrUsername => 'Username or email';

  @override
  String get fieldProfilePin => 'Profile PIN';

  @override
  String get fieldBank => 'Bank';

  @override
  String get fieldCardPin => 'Card PIN';

  @override
  String get fieldCodeName => 'Code name';

  @override
  String get fieldCode => 'Code';

  @override
  String get fieldDeviceName => 'Device';

  @override
  String get fieldDocumentType => 'Document type';

  @override
  String get fieldDocumentNumber => 'Document number';

  @override
  String get generatorLengthDescription =>
      'Choose between 8 and 64 characters.';

  @override
  String get categoryAlreadyExists =>
      'A category with this name already exists.';

  @override
  String get entrySaved => 'Entry saved';

  @override
  String get fieldSecretToggle => 'Show or hide secret value';

  @override
  String get fieldValueCopied =>
      'Value copied. Clipboard clearing will be added later.';

  @override
  String get trashRetentionMessage => 'Entries are deleted after 30 days.';

  @override
  String get duplicateSuffix => 'copy';

  @override
  String addEntryForCategory(String category) {
    return 'Add a $category entry';
  }

  @override
  String entryCount(int count) {
    return '$count entries';
  }

  @override
  String get reauthenticateTitle => 'Confirm your identity';

  @override
  String get reauthenticateToDelete =>
      'Enter your Llavero PIN to permanently delete this entry.';

  @override
  String get reauthenticatePin => 'Llavero PIN';

  @override
  String get reauthenticationFailed =>
      'Incorrect PIN or active lockout. Nothing was deleted.';

  @override
  String get reauthenticateWithBiometrics => 'Use biometrics';

  @override
  String get reauthenticationReason =>
      'Confirm that you want to permanently delete an entry.';
}
