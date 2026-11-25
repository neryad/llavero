# Gestión de entradas — Plan de implementación

> **Para agentes implementadores:** ejecutar las tareas de una en una con TDD; cada tarea es una entrega verificable.

**Objetivo:** construir la experiencia principal de entradas familiares, desde la búsqueda y edición hasta su papelera, preservando el almacenamiento cifrado sin conexión.

**Arquitectura:** extender el controlador y el payload cifrado para categorías personalizadas; añadir utilidades Dart puras para categorías, filtros y contraseñas; conectar pantallas pequeñas a `AppScope` con rutas por ID de entrada.

**Stack:** Flutter/Dart, `ChangeNotifier`, `AppScope`, `flutter_test`, dependencias existentes y `qr_flutter` (permitido por la especificación).

**Diseño:** `docs/superpowers/specs/2026-11-25-phase-5-entry-management-design.md`.

## Restricciones globales

- Aplicación offline; secretos nunca entran en búsquedas, argumentos de rutas ni logs.
- Sin Provider, Bloc, Riverpod, generación de código ni dependencias fuera de la lista permitida.
- La bóveda continúa en un único archivo privado cifrado; PIN/DEK no se escriben en claro.
- Cada texto visible está en los recursos ES/EN; colores e iconos se obtienen del tema Material existente.
- Solo fase 5; no empezar exportación/importación ni ajustes de fase 6/7.

## Enfoque de revisión

- Consultas con un valor secreto como término no deben revelar ni encontrar el valor; cubrir en `entry_search_test.dart`.
- Un archivo v1 debe abrirse sin categorías y guardar de nuevo como v2; cubrir en `vault_storage_test.dart`.
- El límite de 30 días debe distinguir entradas aún válidas de expiradas; cubrir en `entries_controller_test.dart`.
- Nombres de categoría vacíos o duplicados (ignorando mayúsculas/espacios) no deben guardarse; cubrir en `entries_controller_test.dart`.
- Secretos ocultos al abrir y tras 10 segundos; cubrir en widget test del detalle.

---

### Tarea 1: Persistencia de categorías y operaciones de bóveda

**Archivos:** crear `lib/data/models/vault_category.dart`; modificar `lib/data/vault_storage.dart` y `lib/controllers/entries_controller.dart`; pruebas en `test/data/vault_storage_test.dart` y `test/controllers/entries_controller_test.dart`.

**Interfaces:** `VaultCategory({required String id, required String name})`; `EntriesController.customCategories`; `Future<VaultCategory> addCustomCategory(String name)`; `Future<int> purgeExpiredTrash({DateTime? now})`; `Future<VaultEntry> duplicateEntry(String id)`.

- [x] Escribir pruebas para round-trip de categorías, lectura v1, nombres inválidos/duplicados, expiración a 30 días y duplicado independiente.
- [x] Ejecutar `flutter test test/data/vault_storage_test.dart test/controllers/entries_controller_test.dart`; confirmar fallos por el comportamiento ausente.
- [x] Implementar payload v2 con lectura v1 y preservar la API existente de `load`/`save` mientras se añade soporte a categorías.
- [x] Ejecutar de nuevo ambas pruebas; ambas deben pasar.

### Tarea 2: Catálogo, búsqueda y generación

**Archivos:** crear `lib/data/entry_categories.dart`, `lib/core/utils/entry_search.dart` y `lib/core/utils/password_generator.dart`; pruebas unitarias correspondientes bajo `test/data/` y `test/core/utils/`.

**Interfaces:** catálogo de IDs estándar y sus plantillas; `searchEntries(entries, query, {category, person})`; `PasswordGenerator.generate({length, includeNumbers, includeSymbols})` y `generatePassphrase({wordCount})`.

- [x] Probar nombres de categorías estables y campos prellenados para Wi-Fi, email, streaming, banca, PIN, social, dispositivos, documentos y otros.
- [x] Probar búsqueda por título/persona/etiqueta, exclusión estricta de valores y filtros combinados.
- [x] Probar longitud y conjunto de caracteres de la contraseña, y que una frase usa palabras del diccionario local.
- [x] Ejecutar las pruebas nuevas y luego implementar las utilidades mínimas con `Random.secure()`.

### Tarea 3: Inicio, localización y componentes

**Archivos:** reemplazar `lib/features/home/placeholder_screen.dart` por inicio real; crear widgets de tarjetas/categorías/vacío; actualizar `lib/app.dart`, `lib/core/app_routes.dart` y ambas ARB; actualizar pruebas de widgets.

**Interfaces:** rutas de detalle, formulario, papelera; listas de favoritos/todas; filtros por categoría y persona; resultados desde `searchEntries`.

- [x] Añadir primero pruebas para lista vacía, título/tarjeta sin valores secretos y búsqueda/filtro.
- [x] Verificar fallos y construir el inicio responsive (máximo aproximado 720 dp), con favoritos, todas las entradas, filtros, búsqueda y botón de añadir.
- [x] Ejecutar los tests de widgets y `flutter gen-l10n`; comprobar que español e inglés compilan.

### Tarea 4: Alta, edición y plantillas

**Archivos:** crear `lib/features/entry/entry_form_screen.dart` y componentes de formulario; registrar ruta en `lib/app.dart`; ARB ES/EN y pruebas widget.

**Interfaces:** ruta recibe solo ID opcional; alta crea y edición carga del controlador; formulario soporta categoría, título, persona, notas y campos dinámicos.

- [x] Probar desde la interfaz alta de plantilla, edición, persona sugerida, selección de preset de streaming y categoría personalizada.
- [x] Probar agregar, eliminar y reordenar campos; probar generar una contraseña para un campo secreto.
- [x] Ejecutar tests antes y después de implementar; errores de validación no mostrarán valores de campos.

### Tarea 5: Detalle y acciones de entrada

**Archivos:** crear `lib/features/entry/entry_detail_screen.dart` y `lib/features/entry/secret_value.dart`; añadir payload QR Wi-Fi en `lib/core/utils/wifi_qr.dart`; añadir `qr_flutter` a `pubspec.yaml`; pruebas unitarias/widget.

- [x] Probar que el secreto está oculto al iniciar, se muestra al tocar y se vuelve a ocultar tras 10 segundos.
- [x] Probar favorito, edición por ID, duplicado, copiar campo y mover a papelera.
- [x] Probar escapado de caracteres reservados en datos Wi-Fi y representación QR solo para entradas Wi-Fi.
- [x] Añadir textos ES/EN y validar tema/material sin colores codificados en widgets.
- [x] Exigir reautenticación PIN/biometría antes del borrado permanente y probar lockout/fallo sin pérdida de datos.

### Tarea 6: Papelera y flujo completo

**Archivos:** crear `lib/features/trash/trash_screen.dart`; registrar navegación desde inicio; añadir pruebas de widgets/integración.

- [x] Probar apertura de papelera, expiración >30 días, restaurar, confirmación y borrado permanente con reautenticación.
- [x] Probar recorrido de crear → buscar → detalle → editar → borrar → restaurar; verificar que nunca aparece un valor secreto en la búsqueda/lista.
- [x] Ejecutar pruebas específicas; corregir cualquier regresión antes de seguir.

### Tarea 7: Documentación de fase y verificación

**Archivos:** actualizar `PROGRESS.md`.

- [x] Anotar únicamente lo implementado y cómo probarlo en teléfono/emulador, en español sencillo.
- [x] Ejecutar `dart format` sobre Dart modificado, `flutter gen-l10n`, `flutter analyze` y `flutter test`.
- [x] Revisar `git diff --check` y confirmar que solo se modificaron fase 5 y documentación/planning asociada.