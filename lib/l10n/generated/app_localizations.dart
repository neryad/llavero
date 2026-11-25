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
