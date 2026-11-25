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

La fase 3 no comienza hasta recibir la indicación «continue».