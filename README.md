# Llavero

Llavero es una bóveda familiar de contraseñas y códigos para Android e iOS. Los datos se guardan cifrados en el dispositivo y no se sincronizan con un servidor. Solo salen del dispositivo mediante acciones explícitas, como exportarlos, compartirlos o copiarlos al portapapeles.

## Requisitos

- Flutter estable con Dart SDK `3.12.2` o posterior. El proyecto se verificó con Flutter `3.44.2` y Dart `3.12.2`.
- Android Studio y un emulador o dispositivo Android para ejecutar la versión Android.
- Xcode y CocoaPods para compilar iOS; el objetivo mínimo configurado es iOS `15.0`. Para instalar en un dispositivo iOS debes configurar la firma de Apple.

## Preparar y ejecutar

Desde la raíz del proyecto:

```sh
flutter pub get
flutter gen-l10n
flutter run
```

Selecciona un dispositivo conectado o un emulador cuando Flutter lo solicite. En el primer inicio completa el onboarding y crea un PIN. La interfaz usa el idioma del sistema (español o inglés); también puedes cambiar el idioma y el tema en Ajustes.

Los comandos de Flutter pueden necesitar conexión para descargar dependencias y compilar. La aplicación no necesita conexión durante el uso normal.

## Comprobaciones y compilación

```sh
flutter analyze
flutter test
flutter build apk --debug
flutter build ios --no-codesign
```

La compilación iOS anterior produce un artefacto sin firma: configúrala antes de instalarlo o distribuirlo. Las pruebas automatizadas no sustituyen las pruebas de biometría, ciclo de vida y exportación en dispositivos físicos.

## Funcionalidades

- Entradas cifradas organizadas por categoría y persona, con favoritos, búsqueda de títulos y etiquetas, formularios con plantillas y papelera.
- Campos secretos ocultos por defecto, revelado temporal, copia con borrado automático del portapapeles y generador local de contraseñas.
- Desbloqueo con PIN y biometría opcional, bloqueo por intentos fallidos y auto-bloqueo configurable.
- Copias `.llavero` cifradas, importación para combinar o reemplazar, exportación JSON/CSV en texto claro y hojas PDF de emergencia.
- Español e inglés, temas claro y oscuro, y fuentes Plus Jakarta Sans y JetBrains Mono incluidas en el paquete.

## Arquitectura

- `lib/main.dart` inicia `LlaveroApp`, definida en `lib/app.dart`. Allí se configuran el ciclo de vida, la localización, el tema y las rutas de `Navigator`.
- `lib/core/app_scope.dart` expone los controladores mediante `AppScope`. Los controladores usan `ChangeNotifier` y mantienen la lógica fuera de las pantallas.
- `lib/controllers/` contiene estado y operaciones de ajustes, bloqueo, entradas y auto-bloqueo.
- `lib/core/security/` contiene criptografía, almacenamiento seguro de credenciales, lockout, autenticación y protección del portapapeles/pantalla.
- `lib/data/` contiene modelos, el archivo cifrado de la bóveda y los servicios de backup, exportación y PDF.
- `lib/features/` contiene las pantallas; `lib/l10n/app_es.arb` y `lib/l10n/app_en.arb` son las fuentes de traducción.
- `test/` contiene pruebas unitarias y de widgets; los dobles de almacenamiento permiten probar sin guardar datos reales.

## Modelo de seguridad y datos

- La bóveda se guarda como `vault.llavero`, un único archivo en el almacenamiento privado de la aplicación. Cada guardado cifra el contenido con AES-256-GCM y reemplaza el archivo de forma atómica.
- En la primera configuración se genera una clave aleatoria de 256 bits (DEK). El PIN no se guarda: una clave derivada con PBKDF2-HMAC-SHA256 (600 000 iteraciones) protege la DEK. La aplicación persiste el material envuelto y los parámetros necesarios en el almacenamiento seguro del sistema, no el PIN ni la DEK en texto claro.
- La biometría es opcional y utiliza una copia de la clave protegida por Keychain/Keystore; el PIN sigue siendo la alternativa. Tras cinco fallos de PIN se aplican bloqueos crecientes y persistentes.
- Al bloquear la bóveda se eliminan de memoria las entradas descifradas. Android desactiva backups del sistema y su manifiesto principal no solicita `INTERNET`; iOS excluye Application Support de los backups de iCloud. No se incluyen cuentas, analítica ni servicios de sincronización.
- Esto reduce la exposición, pero no protege frente a un sistema operativo comprometido, un dispositivo desbloqueado bajo control de otra persona o la captura de datos mientras se muestran.
- Un PIN olvidado no se puede recuperar. La opción de borrado reinicia la bóveda, no recupera su contenido; una copia exportada anteriormente es la única forma de restaurarlo.

### Copias y exportaciones

- Una copia `.llavero` usa AES-256-GCM y una contraseña de backup independiente del PIN, de al menos 12 caracteres, con PBKDF2-HMAC-SHA256 (600 000 iteraciones). La contraseña no se guarda en la aplicación. Si la olvidas, esa copia no se puede abrir.
- La importación valida y descifra antes de modificar la bóveda. Combinar conserva los elementos actuales cuando hay IDs repetidos; reemplazar sustituye el contenido después de confirmación y reautenticación.
- JSON, CSV y PDF contienen secretos legibles. La app muestra advertencias y solicita reautenticación antes de generarlos; protege esos archivos como protegerías cualquier documento con contraseñas. Compartirlos puede entregarlos a otras aplicaciones según lo que elijas en la hoja del sistema.
- El recordatorio de backup se actualiza cuando una copia cifrada se guarda o comparte correctamente. No se realiza ninguna copia automática ni sincronización en la nube.

## Limitaciones conocidas y antes de distribuir

- Android e iOS todavía usan el identificador de ejemplo `com.example.llavero`; cámbialo por uno propio antes de publicar.
- La configuración Android de release todavía firma con la configuración de depuración. Configura la firma de distribución; iOS también requiere firma y perfil de aprovisionamiento propios.
- No se ha hecho una validación manual completa en teléfonos/tabletas físicos ni una auditoría de seguridad independiente. En particular, prueba en dispositivos reales biometría, portapapeles, bloqueo, compartir, guardar e imprimir antes de distribuir.
- Android puede bloquear capturas cuando la protección está activada. iOS no ofrece a esta app una API para bloquear una captura de pantalla normal: Llavero oculta el contenido en el selector de aplicaciones y durante la grabación mediante una superposición.
- No hay sincronización familiar ni recuperación remota del PIN. La pantalla de salud detecta contraseñas débiles o repetidas localmente; no comprueba filtraciones en servicios externos.
- La app excluye su bóveda de los backups automáticos del sistema. Si el dispositivo se pierde y no guardaste una copia `.llavero` recuperable, los datos pueden perderse definitivamente.
