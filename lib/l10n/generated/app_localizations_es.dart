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

  @override
  String get searchEntries => 'Buscar títulos, personas o etiquetas';

  @override
  String get filterCategories => 'Categorías';

  @override
  String get filterPeople => 'Personas';

  @override
  String get allFilter => 'Todas';

  @override
  String get favoritesSection => 'Favoritos';

  @override
  String get allEntriesSection => 'Todas las entradas';

  @override
  String get emptyVaultTitle => 'Tu bóveda empieza aquí';

  @override
  String get emptyVaultMessage =>
      'Añade la primera entrada para tener a mano lo que tu familia necesita recordar.';

  @override
  String get noSearchResults => 'No se encontraron entradas';

  @override
  String get addEntryButton => 'Añadir entrada';

  @override
  String get trash => 'Papelera';

  @override
  String get categoryWifi => 'Wi-Fi';

  @override
  String get categoryEmail => 'Correo';

  @override
  String get categoryStreaming => 'Streaming';

  @override
  String get categoryBanking => 'Bancos y tarjetas';

  @override
  String get categoryPin => 'PIN y códigos';

  @override
  String get categorySocial => 'Redes y aplicaciones';

  @override
  String get categoryDevices => 'Dispositivos';

  @override
  String get categoryDocuments => 'Documentos e identificaciones';

  @override
  String get categoryOther => 'Otros';

  @override
  String get personUnknown => 'Sin persona';

  @override
  String get newEntry => 'Nueva entrada';

  @override
  String get editEntry => 'Editar entrada';

  @override
  String get entryTitle => 'Título';

  @override
  String get entryTitleHint => 'Por ejemplo, Wi-Fi de casa';

  @override
  String get entryCategory => 'Categoría';

  @override
  String get entryPerson => 'Persona (opcional)';

  @override
  String get entryNotes => 'Notas (opcional)';

  @override
  String get entryFields => 'Datos guardados';

  @override
  String get addField => 'Añadir campo';

  @override
  String get removeField => 'Eliminar campo';

  @override
  String get moveFieldUp => 'Mover campo arriba';

  @override
  String get moveFieldDown => 'Mover campo abajo';

  @override
  String get fieldLabel => 'Nombre del campo';

  @override
  String get fieldValue => 'Valor';

  @override
  String get saveEntry => 'Guardar entrada';

  @override
  String get addCustomCategory => 'Crear categoría';

  @override
  String get customCategoryName => 'Nombre de la categoría';

  @override
  String get categoryNameRequired =>
      'Escribe un nombre distinto para esta categoría.';

  @override
  String get fieldType => 'Tipo de dato';

  @override
  String get fieldTypeText => 'Texto';

  @override
  String get fieldTypeSecret => 'Secreto';

  @override
  String get fieldTypeUrl => 'Enlace';

  @override
  String get fieldTypeNumberPin => 'Número o PIN';

  @override
  String get fieldTypeEmail => 'Correo electrónico';

  @override
  String get fieldTypePhone => 'Teléfono';

  @override
  String get streamingPreset => 'Servicio';

  @override
  String get chooseService => 'Elige un servicio';

  @override
  String get passwordGenerator => 'Generador de contraseñas';

  @override
  String generatorLength(int length) {
    return 'Longitud: $length';
  }

  @override
  String get generatorNumbers => 'Incluir números';

  @override
  String get generatorSymbols => 'Incluir símbolos';

  @override
  String get generatorPassphrase => 'Frase de paso';

  @override
  String get generatorWordCount => 'Cantidad de palabras';

  @override
  String get generate => 'Generar';

  @override
  String get useGenerated => 'Usar contraseña';

  @override
  String get passwordStrengthWeak => 'Débil';

  @override
  String get passwordStrengthFair => 'Aceptable';

  @override
  String get passwordStrengthGood => 'Buena';

  @override
  String get passwordStrengthStrong => 'Fuerte';

  @override
  String get entryTitleRequired => 'Escribe un título para la entrada.';

  @override
  String get fieldLabelRequired => 'Cada campo necesita un nombre.';

  @override
  String get unsavedChanges => 'Cambios sin guardar';

  @override
  String get discardChanges => 'Descartar cambios';

  @override
  String get discardDialogTitle => '¿Descartar cambios?';

  @override
  String get discardDialogMessage =>
      'Los cambios que no guardaste se perderán.';

  @override
  String get saveFailed =>
      'No se pudo guardar. Comprueba la bóveda e inténtalo de nuevo.';

  @override
  String get details => 'Detalles';

  @override
  String get reveal => 'Mostrar secreto';

  @override
  String get hide => 'Ocultar secreto';

  @override
  String get copy => 'Copiar';

  @override
  String get copied => 'Copiado al portapapeles';

  @override
  String get edit => 'Editar';

  @override
  String get favorite => 'Añadir a favoritos';

  @override
  String get removeFavorite => 'Quitar de favoritos';

  @override
  String get duplicate => 'Duplicar';

  @override
  String get moveToTrash => 'Mover a la papelera';

  @override
  String get deleteEntryDialog => '¿Mover esta entrada a la papelera?';

  @override
  String get confirm => 'Confirmar';

  @override
  String get wifiQr => 'Código QR de Wi-Fi';

  @override
  String get wifiQrHint => 'Acerca la cámara para conectarte a esta red.';

  @override
  String get qrMissingNetwork =>
      'Añade el nombre de la red para crear el código QR.';

  @override
  String get trashTitle => 'Papelera';

  @override
  String get trashEmpty => 'La papelera está vacía';

  @override
  String get trashRestore => 'Restaurar';

  @override
  String get deleteForever => 'Borrar definitivamente';

  @override
  String get deleteForeverConfirm => 'Esta entrada se eliminará para siempre.';

  @override
  String get entryDeleted => 'Entrada movida a la papelera';

  @override
  String get entryRestored => 'Entrada restaurada';

  @override
  String get entryDeletedForever => 'Entrada eliminada definitivamente';

  @override
  String get fieldNetworkName => 'Nombre de la red';

  @override
  String get fieldPassword => 'Contraseña';

  @override
  String get fieldSecurityType => 'Tipo de seguridad';

  @override
  String get fieldEmailAddress => 'Dirección de correo';

  @override
  String get fieldRecoveryEmail => 'Correo de recuperación';

  @override
  String get fieldRecoveryPhone => 'Teléfono de recuperación';

  @override
  String get fieldService => 'Servicio';

  @override
  String get fieldEmailOrUsername => 'Usuario o correo';

  @override
  String get fieldProfilePin => 'PIN del perfil';

  @override
  String get fieldBank => 'Banco o entidad';

  @override
  String get fieldCardPin => 'PIN de la tarjeta';

  @override
  String get fieldCodeName => 'Nombre del código';

  @override
  String get fieldCode => 'Código';

  @override
  String get fieldDeviceName => 'Dispositivo';

  @override
  String get fieldDocumentType => 'Tipo de documento';

  @override
  String get fieldDocumentNumber => 'Número de documento';

  @override
  String get generatorLengthDescription => 'Elige entre 8 y 64 caracteres.';

  @override
  String get categoryAlreadyExists => 'Ya existe una categoría con ese nombre.';

  @override
  String get entrySaved => 'Entrada guardada';

  @override
  String get fieldSecretToggle => 'Mostrar u ocultar el valor secreto';

  @override
  String get fieldValueCopied =>
      'Valor copiado. Se borrará del portapapeles más adelante.';

  @override
  String get trashRetentionMessage =>
      'Las entradas se eliminan después de 30 días.';

  @override
  String get duplicateSuffix => 'copia';

  @override
  String addEntryForCategory(String category) {
    return 'Añadir una entrada de $category';
  }

  @override
  String entryCount(int count) {
    return '$count entradas';
  }

  @override
  String get reauthenticateTitle => 'Confirma tu identidad';

  @override
  String get reauthenticateToDelete =>
      'Introduce tu PIN de Llavero para borrar esta entrada definitivamente.';

  @override
  String get reauthenticatePin => 'PIN de Llavero';

  @override
  String get reauthenticationFailed =>
      'PIN incorrecto o bloqueo activo. No se realizó la acción.';

  @override
  String get reauthenticateWithBiometrics => 'Usar biometría';

  @override
  String get reauthenticationReason =>
      'Confirma que quieres borrar permanentemente una entrada.';

  @override
  String get backupCenterTitle => 'Copias y exportaciones';

  @override
  String get backupReminderTitle => 'Crea una copia de seguridad';

  @override
  String get backupReminderDescription =>
      'No se ha completado una copia cifrada en los últimos 30 días.';

  @override
  String get backupEncryptedTitle => 'Copia cifrada';

  @override
  String get backupEncryptedDescription =>
      'Protege una copia completa con una contraseña independiente de tu PIN.';

  @override
  String get backupCreateEncrypted => 'Crear copia cifrada';

  @override
  String get backupImportButton => 'Importar copia';

  @override
  String get backupPlainTextTitle => 'Exportación en texto claro';

  @override
  String get backupPlainTextDescription =>
      'CSV y JSON incluyen los valores de tus secretos.';

  @override
  String get backupExportJson => 'Exportar JSON';

  @override
  String get backupExportCsv => 'Exportar CSV';

  @override
  String get backupEmergencySheetTitle => 'Hoja familiar de emergencia';

  @override
  String get backupEmergencyDescription =>
      'Selecciona qué entradas incluir en el PDF.';

  @override
  String get backupSelectEntries => 'Entradas para incluir';

  @override
  String get backupGeneratePdf => 'Preparar PDF';

  @override
  String get backupNoEntries => 'No hay entradas disponibles para incluir.';

  @override
  String get backupPasswordTitle => 'Contraseña de la copia';

  @override
  String get backupPasswordHint =>
      'Usa una contraseña distinta de tu PIN de Llavero y guárdala por separado.';

  @override
  String get backupPasswordImportTitle => 'Abrir copia cifrada';

  @override
  String get backupPasswordImportHint =>
      'Escribe la contraseña usada al crear esta copia.';

  @override
  String get backupPasswordLabel => 'Contraseña de la copia';

  @override
  String get backupPasswordConfirmLabel => 'Confirma la contraseña';

  @override
  String get backupPasswordTooShort => 'Usa al menos 12 caracteres.';

  @override
  String get backupPasswordMismatch => 'Las contraseñas no coinciden.';

  @override
  String get backupOpenBackup => 'Abrir copia';

  @override
  String get backupImportPreviewTitle => 'Contenido de la copia';

  @override
  String backupImportPreview(int entryCount, int categoryCount) {
    String _temp0 = intl.Intl.pluralLogic(
      entryCount,
      locale: localeName,
      other: '$entryCount entradas',
      one: '1 entrada',
    );
    String _temp1 = intl.Intl.pluralLogic(
      categoryCount,
      locale: localeName,
      other: '$categoryCount categorías personalizadas',
      one: '1 categoría personalizada',
    );
    return 'Esta copia contiene $_temp0 y $_temp1.';
  }

  @override
  String get backupMerge => 'Combinar';

  @override
  String get backupReplace => 'Reemplazar bóveda';

  @override
  String get backupReplaceConfirmationTitle => '¿Reemplazar la bóveda?';

  @override
  String get backupReplaceConfirmationMessage =>
      'Se sustituirán todas las entradas y categorías actuales. Esta acción no se puede deshacer.';

  @override
  String backupReplacePhraseLabel(String phrase) {
    return 'Escribe $phrase para confirmar';
  }

  @override
  String get backupReplacePhrase => 'REEMPLAZAR';

  @override
  String get backupImportInvalid =>
      'No se pudo abrir la copia. Comprueba la contraseña y el archivo.';

  @override
  String get backupImportCompleted => 'Se combinaron las entradas de la copia.';

  @override
  String get backupReplaceCompleted => 'La bóveda se reemplazó con la copia.';

  @override
  String get backupExportCompleted => 'La copia cifrada se guardó o compartió.';

  @override
  String get fileExportCompleted => 'El archivo se guardó o compartió.';

  @override
  String get plainExportWarningTitle => 'Exportar secretos sin cifrar';

  @override
  String get plainExportWarning =>
      'El archivo contendrá tus secretos en texto claro.';

  @override
  String get plainExportWarningDetails =>
      'Cualquiera que acceda al archivo podrá leerlos. Compártelo solo si confías en el destino.';

  @override
  String get pdfExportWarningTitle => 'La hoja PDF contiene secretos';

  @override
  String get pdfExportWarning =>
      'Imprimir o compartir esta hoja puede revelar todas las entradas que selecciones.';

  @override
  String get backupDestinationTitle => '¿Qué quieres hacer con el archivo?';

  @override
  String get backupSaveFile => 'Guardar archivo';

  @override
  String get backupShareFile => 'Compartir archivo';

  @override
  String get backupPrint => 'Imprimir PDF';

  @override
  String get backupExportFailed =>
      'No se pudo completar la exportación. No se compartieron datos.';

  @override
  String get backupReauthenticate =>
      'Confirma tu identidad antes de exportar datos de la bóveda.';

  @override
  String get reauthenticateToExport =>
      'Confirma tu identidad para exportar datos de la bóveda.';

  @override
  String get reauthenticationExportReason =>
      'Confirma que quieres exportar datos de Llavero.';

  @override
  String get reauthenticateToReplace =>
      'Confirma tu identidad para reemplazar la bóveda actual.';

  @override
  String get reauthenticationReplaceReason =>
      'Confirma que quieres reemplazar todos los datos de la bóveda.';
}
