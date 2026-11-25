# Fase 5: diseño de gestión de entradas

## Intención

Reemplazar el placeholder posterior al desbloqueo por la bóveda familiar: listar y buscar entradas, filtrarlas por categoría/persona, crear y editar registros basados en plantillas, consultar secretos de forma segura y administrar la papelera. La interfaz debe funcionar en español e inglés, sin conexión y con la arquitectura Flutter nativa ya establecida.

## Objetivos y límites

- Implementar inicio, detalle, alta/edición, categorías estándar y personalizadas, generador de contraseñas, búsqueda/filtros y papelera con retención de 30 días.
- Mantener valores secretos fuera de búsquedas, títulos de ruta, argumentos de navegación y mensajes de error; los secretos se revelan solo tras una acción local y se ocultan automáticamente.
- No implementar exportación/importación, ajustes, salud de seguridad, auto-bloqueo o limpieza automática del portapapeles: pertenecen a fases posteriores.
- No añadir gestión de estado ni dependencias fuera de la lista permitida; usar `ChangeNotifier`, `AppScope`, `ListenableBuilder` y Material.

## Enfoques considerados

1. **Elegido: ampliar el payload cifrado actual.** Guardar categorías personalizadas en el mismo archivo cifrado de la bóveda, preservar el formato v1 al leer y escribir el formato v2 en los siguientes cambios. Mantiene el requisito de un solo archivo y no expone metadatos de categorías.
2. **Guardar categorías en almacenamiento seguro de preferencias.** Se descarta porque crea un segundo almacén y no protege los datos de dominio con el cifrado de la bóveda.
3. **Guardar solo el nombre de categoría en cada entrada.** Se descarta como persistencia del catálogo: no conserva una categoría creada si aún no tiene entradas.

## Decisiones

- Los IDs estándar existentes serán `wifi`, `email`, `streaming`, `banking`, `pin`, `social`, `devices`, `documents` y `other`; sus nombres visibles vendrán de ARB.
- Las categorías personalizadas guardarán ID y nombre en el payload cifrado. Los campos editables se guardan por entrada, conservando el modelo `EntryField`.
- Las rutas reciben solo IDs de entrada; las pantallas consultan el controlador en memoria. La búsqueda examina título, persona y etiquetas de campos, nunca los valores.
- La pantalla de detalle empieza con secretos ocultos y cada revelado se oculta a los 10 segundos. El generador usa `Random.secure()` y ofrece contraseñas y frases de paso.
- La papelera elimina permanentemente entradas con más de 30 días desde `deletedAt` al abrirse; se puede restaurar o borrar de forma permanente antes de entonces.
- Borrar manualmente una entrada de la papelera requiere reautenticación con PIN o biometría habilitada; un fallo no altera los datos y los intentos PIN usan el lockout persistente.
- Se usará `qr_flutter` (paquete ya permitido) para generar el QR Wi-Fi desde los campos almacenados; no se añadirá otra dependencia.

## Restricciones y validación

Mantener el tema y colores de categorías existentes, no registrar valores secretos, localizar todos los textos de interfaz en `app_es.arb` y `app_en.arb`, y seguir el estilo de los controladores y pruebas actuales. El resultado de fase debe pasar `flutter analyze` y `flutter test`; la guía `PROGRESS.md` documentará cómo probar manualmente alta, búsqueda, edición, revelado, filtros y papelera.