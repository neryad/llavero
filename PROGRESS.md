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

## Fase 5: inicio, gestión de entradas y papelera — completada

- Se reemplazó el placeholder por el inicio de la bóveda con búsqueda segura (título, persona y etiquetas, nunca valores), filtros, favoritos y estado vacío.
- Se añadieron categorías estándar con plantillas, categorías personalizadas cifradas junto con las entradas y lectura compatible de bóvedas v1 al nuevo formato de contenido v2.
- Se implementaron formularios de alta/edición, autocompletado de personas, campos dinámicos reordenables, presets de streaming y generador local de contraseñas/frases de paso.
- El detalle permite marcar favoritos, editar, duplicar, copiar y mover a papelera; los secretos aparecen ocultos y se vuelven a ocultar tras 10 segundos. Wi-Fi puede mostrar un QR generado localmente.
- La papelera permite restaurar o borrar definitivamente; el borrado definitivo exige PIN o biometría habilitada, y los intentos PIN respetan el lockout existente.
- Se añadió `qr_flutter`, dependencia ya permitida por el proyecto.

### Verificación

- `flutter gen-l10n` completado; `flutter analyze` sin incidencias.
- `flutter test`: 83 pruebas aprobadas, incluidas migración v1, búsqueda sin valores, formularios, QR, lockout en reautenticación y flujo de papelera.
- `flutter build apk --debug` y `flutter build ios --no-codesign` completados.
- No se verificó manualmente la biometría ni la interfaz en un dispositivo físico; la reautenticación se cubre con dobles de prueba y compilaciones nativas.

### Cómo probarla

1. Ejecuta `flutter run` en Android o iOS. Completa el onboarding y crea un PIN para llegar al inicio.
2. Toca «Añadir entrada», elige Wi-Fi, completa título, nombre de red y contraseña, y guarda. La tarjeta debe mostrar solo el título, categoría y persona.
3. Busca el título, persona o nombre de un campo. Los valores de campos secretos no deben dar resultados.
4. Abre la entrada: el secreto aparece oculto; tócalo para mostrarlo y comprueba que se oculta de nuevo a los 10 segundos. Copiar un valor es una acción explícita. El QR Wi-Fi se crea localmente.
5. Prueba favorito, edición y duplicado. Mueve la entrada a la papelera, restáurala y prueba el borrado definitivo con PIN (o biometría si está activada); una autenticación fallida no debe borrarla.
6. Crea una categoría personalizada y comprueba que sus campos se pueden añadir, eliminar y reordenar.

## Fase 6: copias, importación y exportaciones — completada

- Se añadió el formato versionado `.llavero`: AES-256-GCM con clave derivada de una contraseña separada mediante PBKDF2-HMAC-SHA256 (600 000 iteraciones), sal aleatoria, parámetros validados y cabecera autenticada. Se requiere una contraseña de al menos 12 caracteres y se confirma al crearla.
- La importación valida y descifra el archivo antes de mostrar el recuento. Permite combinar (conserva los datos actuales ante IDs repetidos) o reemplazar; el reemplazo exige escribir «REEMPLAZAR» y volver a autenticarse antes de guardar.
- Se añadieron exportaciones JSON/CSV en texto claro con advertencia y reautenticación; el CSV escapa celdas y neutraliza prefijos de fórmulas de hoja de cálculo.
- La hoja PDF permite seleccionar entradas, muestra sus campos/notas y usa la fuente Plus Jakarta Sans local. Se advierte antes de imprimir o compartir secretos.
- Inicio muestra un recordatorio si no existe una copia cifrada completada en los últimos 30 días. Solo se persiste la fecha de una copia cifrada guardada o compartida correctamente.
- La pantalla de copias está disponible desde Inicio; se añadieron `file_picker`, `share_plus`, `pdf` y `printing`, todos permitidos y sin flujo de red.

### Verificación

- `flutter gen-l10n` completado; `flutter analyze` sin incidencias y `flutter test` con 103 pruebas aprobadas.
- `flutter build apk --debug`, `flutter build apk --release` y `flutter build ios --no-codesign` completados.
- `aapt dump permissions` del APK release confirma que no declara `INTERNET`; el permiso se conserva solo en la variante debug.
- No se probaron manualmente el selector/hoja de compartir/impresión ni la biometría en un dispositivo físico; los flujos se probaron con dobles y compilaciones nativas.

### Cómo probarla

1. Ejecuta `flutter run`, desbloquea la bóveda y abre el icono de copias en Inicio. Si no has guardado una copia cifrada o han pasado más de 30 días, verás el recordatorio.
2. Crea una copia cifrada con una contraseña de 12 caracteres o más, confírmala y autentícate con PIN o biometría. Guarda o comparte el archivo `.llavero`; al completar la acción debe desaparecer el recordatorio.
3. Importa el `.llavero`, escribe su contraseña y revisa el recuento antes de elegir «Combinar». Para reemplazar, escribe «REEMPLAZAR» y vuelve a autenticarte; cancelar o fallar no debe cambiar la bóveda.
4. Prueba JSON y CSV: confirma la advertencia roja, autentícate y guarda/compártelo. Estos archivos contienen secretos sin cifrar.
5. Selecciona entradas para la hoja PDF, confirma la advertencia, autentícate y elige guardar, compartir o imprimir.
6. Cancela el selector al crear un backup: el recordatorio debe seguir visible. Prueba una contraseña de backup incorrecta: la bóveda no debe cambiar.

## Fase 7: ajustes, seguridad y privacidad — completada

- Se añadieron ajustes persistentes ES/EN para tema, idioma, auto-bloqueo, borrado del portapapeles y bloqueo de capturas.
- Se implementó el cambio autenticado de PIN de 4–8 dígitos; su longitud se guarda junto al material cifrado y los registros antiguos siguen usando seis dígitos. La biometría puede activarse con PIN y autenticación del dispositivo, o desactivarse con el PIN.
- La bóveda se bloquea al ir a segundo plano según el plazo configurado y verifica el tiempo transcurrido al volver, incluso si el temporizador del sistema quedó suspendido.
- El canal nativo activa `FLAG_SECURE` en Android. En iOS se muestra una capa borrosa en el selector de aplicaciones y durante la grabación de pantalla; iOS no ofrece una API para impedir una captura de pantalla normal.
- Los valores copiados se borran tras 30 segundos, 1 o 2 minutos, solo si siguen en el portapapeles; también se comprueba el vencimiento al reanudar la aplicación.
- La pantalla de salud analiza secretos activos solo en memoria y muestra recuentos de contraseñas débiles o reutilizadas, nunca los valores.

### Verificación

- `flutter gen-l10n`, `flutter analyze` sin incidencias y `flutter test` con 122 pruebas aprobadas.
- `flutter build apk --debug` y `flutter build ios --no-codesign` completados.
- No se verificaron manualmente capturas, grabación, biometría ni ciclo de vida en un dispositivo físico; Android usa `FLAG_SECURE`, mientras iOS solo puede cubrir el selector y la grabación con una superposición.

### Cómo probarla

1. En Ajustes cambia tema/idioma, selecciona el tiempo de auto-bloqueo y el borrado del portapapeles; cierra y vuelve a abrir para confirmar que las preferencias persisten.
2. Cambia el PIN a 4 u 8 dígitos, confirma dos veces y prueba el PIN nuevo y el anterior. La pantalla bloqueada debe pedir la longitud actual.
3. Si el dispositivo admite biometría, habilítala en Ajustes con PIN y autenticación del dispositivo; cancela la comprobación para verificar que no queda habilitada. Desactívala con PIN y comprueba que el PIN sigue funcionando.
4. Con la bóveda desbloqueada, envía la app a segundo plano: debe bloquearse inmediatamente o tras el tiempo elegido. Copia un secreto y espera el plazo; si copias otro contenido entretanto, Llavero no debe borrarlo.
5. Abre Salud de seguridad y revisa los recuentos. Los valores secretos no deben aparecer en pantalla.
6. Prueba en Android que las capturas estén bloqueadas. En iOS comprueba el desenfoque en el selector de aplicaciones y al iniciar una grabación; las capturas normales no se pueden deshabilitar mediante la API del sistema.

La fase 7 queda completada.

## Fase 8: pulido, adaptación y accesibilidad — completada

- Se añadieron transiciones discretas que respetan la preferencia del sistema para reducir movimiento, además de una ilustración local para los estados vacíos y una acción para limpiar la búsqueda y los filtros.
- Se limitó el escalado de texto a un máximo de 200 % y se centró el formulario con un ancho máximo de 720 dp para tabletas.
- Se mejoró el contraste del texto secundario, los estados de éxito/error y las etiquetas de categorías seleccionadas en ambos temas; los botones de los estados vacíos mantienen objetivos táctiles de al menos 48 dp.
- Se generaron iconos adaptativos y pantallas de inicio claras/oscuras para Android e iOS con recursos locales y herramientas de desarrollo permitidas.
- Se añadieron textos ES/EN para los resultados de búsqueda vacíos; las 283 claves de ambos ARB coinciden.

### Verificación

- `flutter gen-l10n` completado; `flutter analyze` sin incidencias y `flutter test` con 131 pruebas aprobadas.
- `flutter build apk --debug` y `flutter build ios --no-codesign` completados; la app iOS requiere firma manual antes de instalarse en un dispositivo.
- Recursos de icono/splash revisados; `Info.plist` y el proyecto Xcode pasan `plutil -lint`.
- No se hizo una revisión visual en un dispositivo físico ni en una tableta física; tamaños de 320 dp, 200 % de texto, contraste y límites de ancho se cubren con pruebas automatizadas.

### Cómo probarla

1. Ejecuta `flutter run` en Android o iOS y comprueba el icono de Llavero y la pantalla de inicio en tema claro y oscuro.
2. Deja la bóveda vacía para ver la ilustración; crea entradas, filtra por persona y busca algo inexistente. «Limpiar búsqueda y filtros» debe mostrar de nuevo todas las entradas sin buscar valores secretos.
3. Activa «Reducir movimiento» en el sistema y recorre el onboarding, la pantalla de inicio y la pantalla bloqueada; las animaciones deben desaparecer o reducirse sin retrasar el contenido.
4. Configura texto al 200 % y prueba en un teléfono estrecho; luego abre un emulador de tableta y comprueba que el formulario no supera aproximadamente 720 dp.
5. Revisa categorías seleccionadas, avisos de error y estados de éxito en los temas claro y oscuro; sus etiquetas deben seguir siendo legibles.

La fase 8 queda completada; me detengo aquí y espero tu «continue» antes de iniciar la fase final.