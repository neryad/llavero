# Progreso

## Fase 1: configuración del proyecto — completada

- Configuración de Flutter, dependencias permitidas y fuentes locales Plus Jakarta Sans y JetBrains Mono.
- Tema claro y oscuro, colores de categorías y textos en español e inglés.
- Navegación con rutas con nombre, `AppScope` y controladores base.
- Android sin permiso de internet en el manifiesto principal y con copias de seguridad desactivadas.
- Objetivo mínimo de iOS establecido en 15.0 para compilar con el Xcode disponible.

### Verificación

- `flutter analyze` sin incidencias y `flutter test` con 3 pruebas aprobadas.
- Compilación Android de depuración e iOS para dispositivo aprobadas; iOS se compiló sin firma.
- La compilación de simulador iOS sigue fallando en la comprobación de arquitecturas de Flutter con Xcode 27.2, aunque el binario muestra `arm64` y `x86_64`.

### Cómo probarlo

1. Ejecuta `flutter run` en un teléfono o emulador Android: debe aparecer la pantalla inicial de Llavero. También puedes probar en un dispositivo iOS con la firma configurada.
2. Cambia el tema del dispositivo entre claro y oscuro; la aplicación debe seguir ese tema.
3. Cambia el idioma del dispositivo entre español e inglés para comprobar los textos disponibles.
4. Ejecuta `flutter test` para verificar ambos idiomas, los temas y `AppScope`.

La fase 1 se completó tras recibir la indicación «continue».

## Fase 2: criptografía y protección de intentos — completada

- Añadidos `cryptography` y `flutter_secure_storage` para AES-256-GCM, derivación de claves y almacenamiento seguro en Keychain/Keystore.
- La DEK se genera aleatoriamente y se envuelve con PBKDF2-HMAC-SHA256 (600 000 iteraciones); solo se persisten la DEK envuelta, la sal y sus parámetros.
- Añadida validación de PIN de 4 a 8 dígitos, con rechazo de PINs repetidos y secuenciales.
- Añadido lockout persistente tras cinco fallos, con escalado de 30 s, 1 min, 5 min, 15 min y 1 h; los intentos concurrentes se serializan.
- Se configuró CocoaPods para respetar el mínimo iOS 15.0 del proyecto.

### Verificación

- `flutter analyze` sin incidencias y `flutter test` con 21 pruebas aprobadas.
- APK de release e iOS para dispositivo compilados; la compilación iOS se hizo sin firma.
- El manifiesto del APK de release no declara el permiso `INTERNET`.
- PBKDF2 con 600 000 iteraciones tardó 1 802–2 263 ms en el emulador Android 17 `sdk_gphone16k`; no hay un teléfono de gama baja disponible para medir Argon2id, por lo que se eligió PBKDF2, permitido por el requisito.

### Cómo probarlo

1. Todavía no hay pantalla de PIN ni lock screen: el alta y la interfaz llegarán en la fase 4.
2. Ejecuta `flutter test` para verificar el cifrado, la detección de alteraciones, el almacenamiento de metadata, la validación del PIN y el lockout.
3. En Android o iOS la aplicación aún muestra la pantalla inicial de la fase 1; la prueba manual de la interfaz de seguridad queda pendiente hasta conectarla en la fase 4.

La fase 2 se completó tras recibir la indicación «continue».

## Fase 3: archivo cifrado, modelos y entradas — completada

- Añadidos `VaultEntry` y `EntryField`, con tipos de campo, serialización manual, copias inmutables y soporte de papelera.
- Añadido `VaultStorage`, que guarda el vault en el directorio privado de la aplicación como un único archivo cifrado con AES-256-GCM y escritura atómica.
- En iOS, Application Support se excluye de los backups de iCloud durante el inicio; la aplicación no continúa si no puede aplicar esta protección.
- `EntriesController` ahora carga los datos al desbloquear, guarda cada cambio antes de notificar y elimina los datos descifrados de memoria al bloquear.
- Añadidas altas, edición, papelera, restauración y borrado permanente; las operaciones se serializan para evitar perder cambios simultáneos.
- Añadidas las dependencias permitidas `path_provider` y `uuid`.

### Verificación

- `flutter analyze` sin incidencias.
- `flutter test` con 35 pruebas aprobadas, incluidas pruebas de persistencia, contenido cifrado, alteraciones y operaciones del controlador.

### Cómo probarla

1. Ejecuta `flutter test` para verificar el cifrado del archivo, la restauración de entradas, el bloqueo en memoria, las operaciones de papelera y las escrituras simultáneas.
2. Ejecuta `flutter run` en Android o iOS para comprobar que la aplicación sigue iniciando; todavía mostrará el placeholder porque las pantallas de entradas llegan en fases posteriores.
3. La prueba interactiva de crear y editar entradas en el teléfono queda pendiente hasta que exista la interfaz.

## Fase 4: onboarding, PIN y pantalla bloqueada — completada

- Añadidos el onboarding de cuatro pasos, selector ES/EN persistente, alta y confirmación de PIN de seis dígitos, y aviso de que un PIN olvidado no se puede recuperar.
- `LockController` ahora crea la bóveda con el DEK protegido por PIN, desbloquea con PIN o biometría y mantiene el lockout persistente tras intentos incorrectos.
- La biometría es opcional: se guarda una copia del DEK protegida por Android Keystore/biometría o Keychain; el PIN sigue disponible como alternativa.
- La pantalla de bloqueo aparece al abrir una bóveda existente. El borrado desde esa pantalla exige la autenticación del dispositivo o el PIN de Llavero y una frase de confirmación; fallar o cancelar la biometría no borra los datos.
- Android usa `FlutterFragmentActivity` y declara `USE_BIOMETRIC`; iOS incluye el permiso de Face ID localizado en español e inglés.

### Verificación

- `flutter analyze` sin incidencias y `flutter test` con 48 pruebas aprobadas.
- `flutter build apk --debug` y `flutter build ios --no-codesign` completados.
- Las pruebas de controlador cubren alta, desbloqueo PIN/biometría, lockout, fallback, borrado del archivo cifrado y prevención de borrados concurrentes.
- La interacción biométrica del sistema no se probó manualmente en un dispositivo; aquí se validó con dobles de prueba y compilaciones nativas.

### Cómo probarla

1. Ejecuta `flutter run` en Android o iOS; el primer inicio debe mostrar cuatro pasos de bienvenida, funcionamiento offline, creación/confirmación de PIN y seguridad.
2. Crea un PIN de seis dígitos que no sea repetido ni secuencial; si el dispositivo ofrece biometría, actívala y termina. En un emulador, registra una huella o rostro primero. La pantalla inicial de entradas todavía se implementa en la fase 5.
3. Cierra y vuelve a abrir la aplicación: debe aparecer la pantalla bloqueada. Prueba el PIN, cinco intentos incorrectos para ver el lockout y, si está activada, la biometría con fallback al PIN.
4. En «¿Olvidaste tu PIN?», escribe «BORRAR TODO» y cancela o falla la biometría: la bóveda no debe borrarse; el borrado solo continúa con biometría del dispositivo o con el PIN correcto de Llavero.

La fase 5 no comienza hasta recibir la indicación «continue».