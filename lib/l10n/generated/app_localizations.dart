import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Llavero'**
  String get appTitle;

  /// No description provided for @placeholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Your private space'**
  String get placeholderTitle;

  /// No description provided for @placeholderMessage.
  ///
  /// In en, this message translates to:
  /// **'Offline, all yours'**
  String get placeholderMessage;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading your private vault…'**
  String get loading;

  /// No description provided for @startupFailed.
  ///
  /// In en, this message translates to:
  /// **'The vault could not be opened. Please restart the app.'**
  String get startupFailed;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Llavero'**
  String get welcomeTitle;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'A private vault for the things your family needs to remember.'**
  String get welcomeMessage;

  /// No description provided for @welcomeTagline.
  ///
  /// In en, this message translates to:
  /// **'Offline, all yours'**
  String get welcomeTagline;

  /// No description provided for @languagePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a language'**
  String get languagePickerTitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @stepWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get stepWelcome;

  /// No description provided for @stepHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get stepHowItWorks;

  /// No description provided for @stepCreatePin.
  ///
  /// In en, this message translates to:
  /// **'Create a PIN'**
  String get stepCreatePin;

  /// No description provided for @stepSecurity.
  ///
  /// In en, this message translates to:
  /// **'Your security'**
  String get stepSecurity;

  /// No description provided for @howTitle.
  ///
  /// In en, this message translates to:
  /// **'How Llavero works'**
  String get howTitle;

  /// No description provided for @howOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'Always offline'**
  String get howOfflineTitle;

  /// No description provided for @howOfflineDescription.
  ///
  /// In en, this message translates to:
  /// **'Your vault stays on this device. Llavero does not connect to the internet.'**
  String get howOfflineDescription;

  /// No description provided for @howEncryptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Encrypted on this device'**
  String get howEncryptionTitle;

  /// No description provided for @howEncryptionDescription.
  ///
  /// In en, this message translates to:
  /// **'Your entries are encrypted and can only be opened with your PIN or enabled biometrics.'**
  String get howEncryptionDescription;

  /// No description provided for @howExportTitle.
  ///
  /// In en, this message translates to:
  /// **'You control exports'**
  String get howExportTitle;

  /// No description provided for @howExportDescription.
  ///
  /// In en, this message translates to:
  /// **'Nothing is shared unless you choose to export it.'**
  String get howExportDescription;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @pinCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a 6-digit PIN'**
  String get pinCreateTitle;

  /// No description provided for @pinCreateDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a PIN you can remember. Avoid repeated or sequential digits.'**
  String get pinCreateDescription;

  /// No description provided for @pinConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your PIN'**
  String get pinConfirmTitle;

  /// No description provided for @pinConfirmDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the same six digits again.'**
  String get pinConfirmDescription;

  /// No description provided for @pinStrengthHint.
  ///
  /// In en, this message translates to:
  /// **'Use six digits that are not repeated or sequential.'**
  String get pinStrengthHint;

  /// No description provided for @pinTooEasy.
  ///
  /// In en, this message translates to:
  /// **'That PIN is easy to guess. Choose another one.'**
  String get pinTooEasy;

  /// No description provided for @pinMismatch.
  ///
  /// In en, this message translates to:
  /// **'Those PINs do not match. Start again.'**
  String get pinMismatch;

  /// No description provided for @pinContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get pinContinue;

  /// No description provided for @pinConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get pinConfirmButton;

  /// No description provided for @deleteDigit.
  ///
  /// In en, this message translates to:
  /// **'Delete last digit'**
  String get deleteDigit;

  /// No description provided for @biometricTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable biometrics?'**
  String get biometricTitle;

  /// No description provided for @biometricDescription.
  ///
  /// In en, this message translates to:
  /// **'Use your device biometrics to unlock faster. Your Llavero PIN is always the fallback.'**
  String get biometricDescription;

  /// No description provided for @biometricSwitchTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock with biometrics'**
  String get biometricSwitchTitle;

  /// No description provided for @biometricNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Biometrics are not available on this device.'**
  String get biometricNotAvailable;

  /// No description provided for @noPinRecovery.
  ///
  /// In en, this message translates to:
  /// **'A forgotten PIN cannot be recovered.'**
  String get noPinRecovery;

  /// No description provided for @forgotPinWarning.
  ///
  /// In en, this message translates to:
  /// **'Llavero cannot reset or recover your PIN. Keep an encrypted backup.'**
  String get forgotPinWarning;

  /// No description provided for @backupRecommendation.
  ///
  /// In en, this message translates to:
  /// **'We recommend creating your first backup when export is available.'**
  String get backupRecommendation;

  /// No description provided for @createFirstEntry.
  ///
  /// In en, this message translates to:
  /// **'Create your first entry'**
  String get createFirstEntry;

  /// No description provided for @lockTitle.
  ///
  /// In en, this message translates to:
  /// **'Llavero is locked'**
  String get lockTitle;

  /// No description provided for @lockPinPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter your 6-digit PIN'**
  String get lockPinPrompt;

  /// No description provided for @pinDigitsEntered.
  ///
  /// In en, this message translates to:
  /// **'{count} of 6 digits entered'**
  String pinDigitsEntered(int count);

  /// No description provided for @wrongPin.
  ///
  /// In en, this message translates to:
  /// **'That PIN is incorrect.'**
  String get wrongPin;

  /// No description provided for @lockoutCountdown.
  ///
  /// In en, this message translates to:
  /// **'{seconds, plural, =1{Try again in 1 second.} other{Try again in {seconds} seconds.}}'**
  String lockoutCountdown(int seconds);

  /// No description provided for @unlockBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Unlock with biometrics'**
  String get unlockBiometrics;

  /// No description provided for @forgotPin.
  ///
  /// In en, this message translates to:
  /// **'Forgot your PIN?'**
  String get forgotPin;

  /// No description provided for @eraseEverything.
  ///
  /// In en, this message translates to:
  /// **'Erase everything'**
  String get eraseEverything;

  /// No description provided for @eraseDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Erase the vault?'**
  String get eraseDialogTitle;

  /// No description provided for @eraseDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes the encrypted vault, its keys, and all entries. This cannot be undone.'**
  String get eraseDialogMessage;

  /// No description provided for @eraseTypePrompt.
  ///
  /// In en, this message translates to:
  /// **'Type {phrase} to confirm.'**
  String eraseTypePrompt(String phrase);

  /// No description provided for @eraseConfirmationPhrase.
  ///
  /// In en, this message translates to:
  /// **'DELETE EVERYTHING'**
  String get eraseConfirmationPhrase;

  /// No description provided for @eraseContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get eraseContinue;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @eraseDeviceReason.
  ///
  /// In en, this message translates to:
  /// **'Confirm that you want to erase the Llavero vault.'**
  String get eraseDeviceReason;

  /// No description provided for @erasePinFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your Llavero PIN'**
  String get erasePinFallbackTitle;

  /// No description provided for @erasePinFallbackDescription.
  ///
  /// In en, this message translates to:
  /// **'Device authentication did not complete. Use your vault PIN to continue.'**
  String get erasePinFallbackDescription;

  /// No description provided for @erasePinIncorrect.
  ///
  /// In en, this message translates to:
  /// **'The PIN is incorrect or a lockout is active. Nothing was erased.'**
  String get erasePinIncorrect;

  /// No description provided for @biometricUnlockFailed.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock did not complete. Use your PIN instead.'**
  String get biometricUnlockFailed;

  /// No description provided for @vaultCreationFailed.
  ///
  /// In en, this message translates to:
  /// **'The vault could not be created. Try again.'**
  String get vaultCreationFailed;

  /// No description provided for @searchEntries.
  ///
  /// In en, this message translates to:
  /// **'Search titles, people, or labels'**
  String get searchEntries;

  /// No description provided for @filterCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get filterCategories;

  /// No description provided for @filterPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get filterPeople;

  /// No description provided for @allFilter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allFilter;

  /// No description provided for @favoritesSection.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesSection;

  /// No description provided for @allEntriesSection.
  ///
  /// In en, this message translates to:
  /// **'All entries'**
  String get allEntriesSection;

  /// No description provided for @emptyVaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Your vault starts here'**
  String get emptyVaultTitle;

  /// No description provided for @emptyVaultMessage.
  ///
  /// In en, this message translates to:
  /// **'Add your first entry to keep what your family needs to remember close at hand.'**
  String get emptyVaultMessage;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No entries found'**
  String get noSearchResults;

  /// No description provided for @addEntryButton.
  ///
  /// In en, this message translates to:
  /// **'Add entry'**
  String get addEntryButton;

  /// No description provided for @trash.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get trash;

  /// No description provided for @categoryWifi.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi'**
  String get categoryWifi;

  /// No description provided for @categoryEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get categoryEmail;

  /// No description provided for @categoryStreaming.
  ///
  /// In en, this message translates to:
  /// **'Streaming'**
  String get categoryStreaming;

  /// No description provided for @categoryBanking.
  ///
  /// In en, this message translates to:
  /// **'Banking and cards'**
  String get categoryBanking;

  /// No description provided for @categoryPin.
  ///
  /// In en, this message translates to:
  /// **'PIN and codes'**
  String get categoryPin;

  /// No description provided for @categorySocial.
  ///
  /// In en, this message translates to:
  /// **'Social and apps'**
  String get categorySocial;

  /// No description provided for @categoryDevices.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get categoryDevices;

  /// No description provided for @categoryDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents and IDs'**
  String get categoryDocuments;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @personUnknown.
  ///
  /// In en, this message translates to:
  /// **'No person'**
  String get personUnknown;

  /// No description provided for @newEntry.
  ///
  /// In en, this message translates to:
  /// **'New entry'**
  String get newEntry;

  /// No description provided for @editEntry.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get editEntry;

  /// No description provided for @entryTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get entryTitle;

  /// No description provided for @entryTitleHint.
  ///
  /// In en, this message translates to:
  /// **'For example, Home Wi-Fi'**
  String get entryTitleHint;

  /// No description provided for @entryCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get entryCategory;

  /// No description provided for @entryPerson.
  ///
  /// In en, this message translates to:
  /// **'Person (optional)'**
  String get entryPerson;

  /// No description provided for @entryNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get entryNotes;

  /// No description provided for @entryFields.
  ///
  /// In en, this message translates to:
  /// **'Saved details'**
  String get entryFields;

  /// No description provided for @addField.
  ///
  /// In en, this message translates to:
  /// **'Add field'**
  String get addField;

  /// No description provided for @removeField.
  ///
  /// In en, this message translates to:
  /// **'Remove field'**
  String get removeField;

  /// No description provided for @moveFieldUp.
  ///
  /// In en, this message translates to:
  /// **'Move field up'**
  String get moveFieldUp;

  /// No description provided for @moveFieldDown.
  ///
  /// In en, this message translates to:
  /// **'Move field down'**
  String get moveFieldDown;

  /// No description provided for @fieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Field name'**
  String get fieldLabel;

  /// No description provided for @fieldValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get fieldValue;

  /// No description provided for @saveEntry.
  ///
  /// In en, this message translates to:
  /// **'Save entry'**
  String get saveEntry;

  /// No description provided for @addCustomCategory.
  ///
  /// In en, this message translates to:
  /// **'Create category'**
  String get addCustomCategory;

  /// No description provided for @customCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get customCategoryName;

  /// No description provided for @categoryNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a unique name for this category.'**
  String get categoryNameRequired;

  /// No description provided for @fieldType.
  ///
  /// In en, this message translates to:
  /// **'Data type'**
  String get fieldType;

  /// No description provided for @fieldTypeText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get fieldTypeText;

  /// No description provided for @fieldTypeSecret.
  ///
  /// In en, this message translates to:
  /// **'Secret'**
  String get fieldTypeSecret;

  /// No description provided for @fieldTypeUrl.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get fieldTypeUrl;

  /// No description provided for @fieldTypeNumberPin.
  ///
  /// In en, this message translates to:
  /// **'Number or PIN'**
  String get fieldTypeNumberPin;

  /// No description provided for @fieldTypeEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get fieldTypeEmail;

  /// No description provided for @fieldTypePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get fieldTypePhone;

  /// No description provided for @streamingPreset.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get streamingPreset;

  /// No description provided for @chooseService.
  ///
  /// In en, this message translates to:
  /// **'Choose a service'**
  String get chooseService;

  /// No description provided for @passwordGenerator.
  ///
  /// In en, this message translates to:
  /// **'Password generator'**
  String get passwordGenerator;

  /// No description provided for @generatorLength.
  ///
  /// In en, this message translates to:
  /// **'Length: {length}'**
  String generatorLength(int length);

  /// No description provided for @generatorNumbers.
  ///
  /// In en, this message translates to:
  /// **'Include numbers'**
  String get generatorNumbers;

  /// No description provided for @generatorSymbols.
  ///
  /// In en, this message translates to:
  /// **'Include symbols'**
  String get generatorSymbols;

  /// No description provided for @generatorPassphrase.
  ///
  /// In en, this message translates to:
  /// **'Passphrase'**
  String get generatorPassphrase;

  /// No description provided for @generatorWordCount.
  ///
  /// In en, this message translates to:
  /// **'Number of words'**
  String get generatorWordCount;

  /// No description provided for @generate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// No description provided for @useGenerated.
  ///
  /// In en, this message translates to:
  /// **'Use password'**
  String get useGenerated;

  /// No description provided for @passwordStrengthWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get passwordStrengthWeak;

  /// No description provided for @passwordStrengthFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get passwordStrengthFair;

  /// No description provided for @passwordStrengthGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get passwordStrengthGood;

  /// No description provided for @passwordStrengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get passwordStrengthStrong;

  /// No description provided for @entryTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a title for this entry.'**
  String get entryTitleRequired;

  /// No description provided for @fieldLabelRequired.
  ///
  /// In en, this message translates to:
  /// **'Each field needs a name.'**
  String get fieldLabelRequired;

  /// No description provided for @unsavedChanges.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes'**
  String get unsavedChanges;

  /// No description provided for @discardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard changes'**
  String get discardChanges;

  /// No description provided for @discardDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardDialogTitle;

  /// No description provided for @discardDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Your unsaved changes will be lost.'**
  String get discardDialogMessage;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Check the vault and try again.'**
  String get saveFailed;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @reveal.
  ///
  /// In en, this message translates to:
  /// **'Reveal secret'**
  String get reveal;

  /// No description provided for @hide.
  ///
  /// In en, this message translates to:
  /// **'Hide secret'**
  String get hide;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copied;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get favorite;

  /// No description provided for @removeFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFavorite;

  /// No description provided for @duplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicate;

  /// No description provided for @moveToTrash.
  ///
  /// In en, this message translates to:
  /// **'Move to trash'**
  String get moveToTrash;

  /// No description provided for @deleteEntryDialog.
  ///
  /// In en, this message translates to:
  /// **'Move this entry to the trash?'**
  String get deleteEntryDialog;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @wifiQr.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi QR code'**
  String get wifiQr;

  /// No description provided for @wifiQrHint.
  ///
  /// In en, this message translates to:
  /// **'Point your camera at this code to join the network.'**
  String get wifiQrHint;

  /// No description provided for @qrMissingNetwork.
  ///
  /// In en, this message translates to:
  /// **'Add the network name to create a QR code.'**
  String get qrMissingNetwork;

  /// No description provided for @trashTitle.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get trashTitle;

  /// No description provided for @trashEmpty.
  ///
  /// In en, this message translates to:
  /// **'The trash is empty'**
  String get trashEmpty;

  /// No description provided for @trashRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get trashRestore;

  /// No description provided for @deleteForever.
  ///
  /// In en, this message translates to:
  /// **'Delete forever'**
  String get deleteForever;

  /// No description provided for @deleteForeverConfirm.
  ///
  /// In en, this message translates to:
  /// **'This entry will be permanently deleted.'**
  String get deleteForeverConfirm;

  /// No description provided for @entryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Entry moved to trash'**
  String get entryDeleted;

  /// No description provided for @entryRestored.
  ///
  /// In en, this message translates to:
  /// **'Entry restored'**
  String get entryRestored;

  /// No description provided for @entryDeletedForever.
  ///
  /// In en, this message translates to:
  /// **'Entry permanently deleted'**
  String get entryDeletedForever;

  /// No description provided for @fieldNetworkName.
  ///
  /// In en, this message translates to:
  /// **'Network name'**
  String get fieldNetworkName;

  /// No description provided for @fieldPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get fieldPassword;

  /// No description provided for @fieldSecurityType.
  ///
  /// In en, this message translates to:
  /// **'Security type'**
  String get fieldSecurityType;

  /// No description provided for @fieldEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get fieldEmailAddress;

  /// No description provided for @fieldRecoveryEmail.
  ///
  /// In en, this message translates to:
  /// **'Recovery email'**
  String get fieldRecoveryEmail;

  /// No description provided for @fieldRecoveryPhone.
  ///
  /// In en, this message translates to:
  /// **'Recovery phone'**
  String get fieldRecoveryPhone;

  /// No description provided for @fieldService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get fieldService;

  /// No description provided for @fieldEmailOrUsername.
  ///
  /// In en, this message translates to:
  /// **'Username or email'**
  String get fieldEmailOrUsername;

  /// No description provided for @fieldProfilePin.
  ///
  /// In en, this message translates to:
  /// **'Profile PIN'**
  String get fieldProfilePin;

  /// No description provided for @fieldBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get fieldBank;

  /// No description provided for @fieldCardPin.
  ///
  /// In en, this message translates to:
  /// **'Card PIN'**
  String get fieldCardPin;

  /// No description provided for @fieldCodeName.
  ///
  /// In en, this message translates to:
  /// **'Code name'**
  String get fieldCodeName;

  /// No description provided for @fieldCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get fieldCode;

  /// No description provided for @fieldDeviceName.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get fieldDeviceName;

  /// No description provided for @fieldDocumentType.
  ///
  /// In en, this message translates to:
  /// **'Document type'**
  String get fieldDocumentType;

  /// No description provided for @fieldDocumentNumber.
  ///
  /// In en, this message translates to:
  /// **'Document number'**
  String get fieldDocumentNumber;

  /// No description provided for @generatorLengthDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose between 8 and 64 characters.'**
  String get generatorLengthDescription;

  /// No description provided for @categoryAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'A category with this name already exists.'**
  String get categoryAlreadyExists;

  /// No description provided for @entrySaved.
  ///
  /// In en, this message translates to:
  /// **'Entry saved'**
  String get entrySaved;

  /// No description provided for @fieldSecretToggle.
  ///
  /// In en, this message translates to:
  /// **'Show or hide secret value'**
  String get fieldSecretToggle;

  /// No description provided for @fieldValueCopied.
  ///
  /// In en, this message translates to:
  /// **'Value copied. Clipboard clearing will be added later.'**
  String get fieldValueCopied;

  /// No description provided for @trashRetentionMessage.
  ///
  /// In en, this message translates to:
  /// **'Entries are deleted after 30 days.'**
  String get trashRetentionMessage;

  /// No description provided for @duplicateSuffix.
  ///
  /// In en, this message translates to:
  /// **'copy'**
  String get duplicateSuffix;

  /// No description provided for @addEntryForCategory.
  ///
  /// In en, this message translates to:
  /// **'Add a {category} entry'**
  String addEntryForCategory(String category);

  /// No description provided for @entryCount.
  ///
  /// In en, this message translates to:
  /// **'{count} entries'**
  String entryCount(int count);

  /// No description provided for @reauthenticateTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your identity'**
  String get reauthenticateTitle;

  /// No description provided for @reauthenticateToDelete.
  ///
  /// In en, this message translates to:
  /// **'Enter your Llavero PIN to permanently delete this entry.'**
  String get reauthenticateToDelete;

  /// No description provided for @reauthenticatePin.
  ///
  /// In en, this message translates to:
  /// **'Llavero PIN'**
  String get reauthenticatePin;

  /// No description provided for @reauthenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN or active lockout. Nothing was deleted.'**
  String get reauthenticationFailed;

  /// No description provided for @reauthenticateWithBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics'**
  String get reauthenticateWithBiometrics;

  /// No description provided for @reauthenticationReason.
  ///
  /// In en, this message translates to:
  /// **'Confirm that you want to permanently delete an entry.'**
  String get reauthenticationReason;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
