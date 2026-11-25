# Diseño: exportación e importación de la bóveda

## Intención

La fase 6 permite que una persona cree una copia cifrada recuperable de la bóveda Llavero y, si lo decide, exporte datos legibles o una hoja de emergencia. La aplicación sigue funcionando sin conexión: solo se accede a archivos locales y a las hojas nativas de compartir o imprimir cuando la persona inicia una exportación.

## Objetivos

- Crear e importar copias `.llavero` cifradas con una contraseña independiente del PIN de Llavero.
- Validar por completo la copia y mostrar su recuento antes de modificar la bóveda.
- Permitir combinar o reemplazar las entradas y categorías personalizadas.
- Proteger todas las exportaciones con reautenticación y advertir antes de generar datos legibles o imprimir secretos.
- Ofrecer CSV, JSON y una hoja PDF con entradas seleccionadas.
- Avisar en Inicio si nunca se creó una copia cifrada o la última completada supera los 30 días.
- Traducir la interfaz nueva al español e inglés.

## No objetivos

- Sincronización, envío automático por red ni almacenamiento en servidores.
- Cambios al flujo de desbloqueo, PIN o biometría ya implementado.
- Gestión general de preferencias, tema o seguridad, reservada para la fase 7.
- Recuperar una contraseña perdida de un backup.

## Restricciones

- Mantener Flutter y el estado nativo existente (`ChangeNotifier`, `AppScope`, `Navigator` con rutas nombradas); no añadir gestores de estado ni generación de código.
- Añadir solo dependencias ya permitidas: `file_picker`, `share_plus`, `pdf` y `printing`.
- No guardar PIN, contraseña de backup, DEK ni contenido descifrado en logs o mensajes de error.
- Usar AES-256-GCM y PBKDF2-HMAC-SHA256 con al menos 600 000 iteraciones para la contraseña del backup, con sal aleatoria y parámetros autenticados/validados.
- Conservar la compatibilidad con el formato de bóveda existente (contenido v2 y lectura heredada v1).
- Toda cadena visible nueva debe existir en `app_es.arb` y `app_en.arb`.

## Enfoques considerados

1. **Servicio de dominio independiente y pantalla dedicada (elegido):** concentra cifrado, parseo, serialización e importación comprobable fuera de los widgets. La pantalla coordina contraseñas, confirmaciones, selección de archivo y acciones del sistema. Esto preserva la separación de responsabilidades del proyecto y permite probar los casos de seguridad sin interfaz.
2. **Lógica de archivos dentro de Inicio:** reduce el número inicial de archivos, pero mezclaría UI, criptografía y mutaciones de la bóveda; hace más difícil probar fallos y mantener los secretos fuera de mensajes de UI. No se elige.
3. **Cifrar el backup con la DEK actual:** simplificaría el uso al exportar, pero no permitiría recuperar la bóveda con una contraseña propia y fallaría el requisito explícito de una contraseña separada. Se descarta.

## Diseño

### Copia cifrada

Un formato JSON versionado con extensión `.llavero` contiene un encabezado con versión, algoritmo/parámetros PBKDF2, sal, nonce y datos cifrados/autenticados por AES-256-GCM. El texto claro contiene versión de contenido, todas las entradas (incluidas las de papelera) y categorías personalizadas. La contraseña del backup se solicita al exportar/importar, debe tener al menos 12 caracteres y nunca se persiste; al crearla se confirma para reducir errores de escritura.

El importador rechaza datos malformados, parámetros fuera de límites, versiones no admitidas, contraseña incorrecta y alteraciones con errores genéricos que no filtran secretos. Solo después de autenticar y analizar toda la copia muestra cuántas entradas/categorías contiene y pregunta por la estrategia:

- **Combinar:** conserva entradas/categorías actuales y añade solo IDs ausentes; ante un ID ya existente, prevalece el registro actual para evitar sobrescribir cambios locales.
- **Reemplazar:** sustituye entradas y categorías actuales por el contenido validado del backup. Como es una acción destructiva equivalente a borrar datos, después de escribir la frase de confirmación también exige PIN o biometría habilitada antes de persistir.

Ninguna operación cambia el estado ni el archivo de la bóveda antes de confirmar la estrategia. Las escrituras existentes siguen pasando por `EntriesController`/`VaultStorage` y mantienen su escritura atómica. Si falla o se cancela la reautenticación para reemplazar, la bóveda actual permanece intacta.

### Exportaciones legibles y hoja de emergencia

Antes de cualquier exportación se exige reautenticación con PIN o biometría habilitada. Un fallo, cancelación o lockout cancela la acción sin compartir ni escribir contenido. CSV y JSON incluyen los datos elegidos en formato legible y muestran una advertencia roja explícita de que los valores secretos quedarán expuestos en el archivo. La hoja PDF permite seleccionar entradas, muestra campos/valores y notas, y advierte que imprimir o compartir el PDF expone secretos.

`file_picker` gestiona selección/guardado de archivos; `share_plus` abre la hoja nativa de compartir y `pdf`/`printing` generan y presentan el PDF. La pantalla dedicada es accesible desde Inicio mediante una acción visible.

### Recordatorio

Se guarda únicamente la fecha de la última exportación cifrada completada en el almacenamiento privado de preferencias ya disponible. La pantalla de Inicio muestra un recordatorio si no existe fecha o han transcurrido más de 30 días. Cancelar el selector o la hoja de compartir no cuenta como backup completado.

## Pruebas y aceptación

- Ciclo de exportación/importación cifrada conserva entradas, papelera y categorías; contraseña equivocada, alteración, JSON inválido y versión/params no soportados no producen cambios.
- Combinar respeta IDs existentes y añade IDs nuevos; reemplazar sustituye el conjunto completo; fallos de escritura no publican estado parcial.
- La reautenticación cancelada o fallida impide exportar texto claro, backup o PDF; las advertencias aparecen antes de la acción sensible.
- El recordatorio aparece sin fecha y después de 30 días, y se retira al completar una exportación cifrada.
- CSV/JSON y PDF son válidos y contienen solo los datos seleccionados según la operación.
- `flutter gen-l10n`, `flutter analyze` y `flutter test` pasan; no se añade permiso de red ni dependencia ajena a la lista permitida.