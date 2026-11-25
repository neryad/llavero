// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Llavero';

  @override
  String get placeholderTitle => 'Tu espacio privado';

  @override
  String get placeholderMessage => 'Todo offline, todo tuyo';

  @override
  String get loading => 'Cargando tu bóveda privada…';

  @override
  String get startupFailed =>
      'No se pudo abrir la bóveda. Reinicia la aplicación.';

  @override
  String get welcomeTitle => 'Bienvenido a Llavero';

  @override
  String get welcomeMessage =>
      'Una bóveda privada para guardar lo que tu familia necesita recordar.';

  @override
  String get welcomeTagline => 'Todo offline, todo tuyo';

  @override
  String get languagePickerTitle => 'Elige un idioma';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get stepWelcome => 'Bienvenida';

  @override
  String get stepHowItWorks => 'Cómo funciona';

  @override
  String get stepCreatePin => 'Crea un PIN';

  @override
  String get stepSecurity => 'Tu seguridad';

  @override
  String get howTitle => 'Así funciona Llavero';

  @override
  String get howOfflineTitle => 'Siempre sin conexión';

  @override
  String get howOfflineDescription =>
      'Tu bóveda permanece en este dispositivo. Llavero no se conecta a internet.';

  @override
  String get howEncryptionTitle => 'Cifrado en este dispositivo';

  @override
  String get howEncryptionDescription =>
      'Tus entradas están cifradas y solo se abren con tu PIN o la biometría que habilites.';

  @override
  String get howExportTitle => 'Tú controlas las exportaciones';

  @override
  String get howExportDescription =>
      'Nada se comparte a menos que decidas exportarlo.';

  @override
  String get next => 'Siguiente';

  @override
  String get back => 'Atrás';

  @override
  String get pinCreateTitle => 'Crea un PIN de 6 dígitos';

  @override
  String get pinCreateDescription =>
      'Elige un PIN que recuerdes. Evita dígitos repetidos o consecutivos.';

  @override
  String get pinConfirmTitle => 'Confirma tu PIN';

  @override
  String get pinConfirmDescription =>
      'Vuelve a escribir los mismos seis dígitos.';

  @override
  String get pinStrengthHint =>
      'Usa seis dígitos que no sean repetidos ni consecutivos.';

  @override
  String get pinTooEasy => 'Ese PIN es fácil de adivinar. Elige otro.';

  @override
  String get pinMismatch => 'Los PIN no coinciden. Empieza de nuevo.';

  @override
  String get pinContinue => 'Continuar';

  @override
  String get pinConfirmButton => 'Confirmar PIN';

  @override
  String get deleteDigit => 'Borrar último dígito';

  @override
  String get biometricTitle => '¿Activar biometría?';

  @override
  String get biometricDescription =>
      'Usa la biometría de tu dispositivo para desbloquear más rápido. Tu PIN de Llavero siempre será la alternativa.';

  @override
  String get biometricSwitchTitle => 'Desbloquear con biometría';

  @override
  String get biometricNotAvailable =>
      'La biometría no está disponible en este dispositivo.';

  @override
  String get noPinRecovery => 'No se puede recuperar un PIN olvidado.';

  @override
  String get forgotPinWarning =>
      'Llavero no puede restablecer ni recuperar tu PIN. Guarda una copia cifrada.';

  @override
  String get backupRecommendation =>
      'Te recomendamos crear tu primera copia cuando la exportación esté disponible.';

  @override
  String get createFirstEntry => 'Crear mi primera entrada';

  @override
  String get lockTitle => 'Llavero está bloqueado';

  @override
  String get lockPinPrompt => 'Introduce tu PIN de 6 dígitos';

  @override
  String pinDigitsEntered(int count) {
    return '$count de 6 dígitos introducidos';
  }

  @override
  String get wrongPin => 'Ese PIN no es correcto.';

  @override
  String lockoutCountdown(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'Inténtalo de nuevo en $seconds segundos.',
      one: 'Inténtalo de nuevo en 1 segundo.',
    );
    return '$_temp0';
  }

  @override
  String get unlockBiometrics => 'Desbloquear con biometría';

  @override
  String get forgotPin => '¿Olvidaste tu PIN?';

  @override
  String get eraseEverything => 'Borrar todo';

  @override
  String get eraseDialogTitle => '¿Borrar la bóveda?';

  @override
  String get eraseDialogMessage =>
      'Se eliminarán permanentemente la bóveda cifrada, sus claves y todas las entradas. Esta acción no se puede deshacer.';

  @override
  String eraseTypePrompt(String phrase) {
    return 'Escribe $phrase para confirmar.';
  }

  @override
  String get eraseConfirmationPhrase => 'BORRAR TODO';

  @override
  String get eraseContinue => 'Continuar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get eraseDeviceReason =>
      'Confirma que quieres borrar la bóveda de Llavero.';

  @override
  String get erasePinFallbackTitle => 'Introduce tu PIN de Llavero';

  @override
  String get erasePinFallbackDescription =>
      'La autenticación del dispositivo no se completó. Usa el PIN de la bóveda para continuar.';

  @override
  String get erasePinIncorrect =>
      'El PIN no es correcto o hay un bloqueo activo. No se borró nada.';

  @override
  String get biometricUnlockFailed =>
      'No se completó el desbloqueo biométrico. Usa tu PIN.';

  @override
  String get vaultCreationFailed =>
      'No se pudo crear la bóveda. Inténtalo de nuevo.';
}
