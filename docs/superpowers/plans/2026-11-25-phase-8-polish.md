# Fase 8: pulido final y accesibilidad — plan de implementación

> **Para agentes implementadores:** ejecutar las tareas en orden y usar TDD: escribir la prueba, verla fallar por el comportamiento ausente y solo entonces implementar el cambio mínimo.

**Objetivo:** completar la accesibilidad, el pulido visual, la adaptabilidad y la identidad nativa de Llavero sin cambiar su comportamiento de bóveda.

**Arquitectura:** pequeñas mejoras sobre widgets Material 3 existentes, con una política común para movimiento reducido, contenido adaptable y recursos de marca generados para las plataformas. No se añade dependencia de ejecución.

**Tecnologías:** Flutter/Dart, `flutter_test`, ARB/gen-l10n y las herramientas dev permitidas `flutter_launcher_icons` y `flutter_native_splash`.

**Spec:** `docs/superpowers/specs/2026-11-25-phase-8-polish-design.md`.

## Restricciones globales

- No añadir dependencias de ejecución; la app sigue funcionando offline y con recursos locales.
- Mantener localizaciones ES/EN, Material 3 y los temas claro/oscuro existentes.
- Objetivos táctiles de al menos 48 dp, escalado de texto hasta 200 % y ancho máximo de contenido cercano a 720 dp.
- Respetar `MediaQuery` cuando el usuario solicita reducir movimiento.
- No cambiar modelos, cifrado, autenticación ni formatos de exportación.

## Áreas de revisión

- Texto ampliado al 200 % en una pantalla estrecha: no debe producir desbordamientos ni ocultar acciones.
- Preferencia de reducir movimiento activa: la interfaz debe seguir completa y las transiciones deben desaparecer o reducirse sin bloquear contenido.
- Tablet de ancho superior a 720 dp: el formulario no debe estirarse a todo el ancho.
- Cambio de español a inglés: los estados vacíos, acciones y textos de seguridad deben mantenerse localizados.
- Iconos y splash generados: los recursos deben existir para las plataformas seleccionadas y mostrar colores legibles en ambos temas.

---

### Tarea 1: movimiento reducido y transición de estados

**Archivos:**
- Crear: `lib/core/utils/app_motion.dart`
- Modificar: `lib/features/onboarding/onboarding_screen.dart`, `lib/features/home/home_screen.dart`, `lib/core/widgets/empty_state.dart`
- Prueba: `test/core/utils/app_motion_test.dart`, `test/features/home_test.dart`

**Interfaces:**
- Produce: `AppMotion.duration(BuildContext context, Duration preferred)` devuelve `Duration.zero` cuando `MediaQuery.disableAnimations` es verdadero y `preferred` en caso contrario.

- [x] Escribir pruebas para movimiento habilitado/deshabilitado y para cambiar el contenido de inicio sin perder el estado vacío/listado.
- [x] Ejecutar las pruebas nuevas y comprobar el fallo esperado antes de implementar.
- [x] Aplicar `AppMotion.duration` a la transición de onboarding y a la transición del estado de inicio; evitar animaciones no esenciales al reducir movimiento.
- [x] Añadir ilustración local accesible a `EmptyState` y acción localizada para restablecer búsqueda/filtros cuando no hay resultados.
- [x] Ejecutar `flutter test test/core/utils/app_motion_test.dart test/features/home_test.dart` y confirmar los casos de ambos estados.

### Tarea 2: accesibilidad, tipografía y ancho adaptable

**Archivos:**
- Modificar: `lib/app.dart`, `lib/features/entry/entry_form_screen.dart`, `lib/core/widgets/empty_state.dart`
- Prueba: `test/widget_test.dart`, `test/features/entry_form_test.dart`, `test/core/theme/app_theme_test.dart`

**Interfaces:**
- Consume: `AppMotion` de la tarea 1.
- Produce: la app limita el escalado de texto a un máximo de 2.0 sin reducir la escala preferida por debajo del valor del sistema; el contenido de formularios queda centrado y limitado a 720 dp.

- [x] Añadir pruebas que reproduzcan formulario ancho en tablet, render a escala de texto 200 % en ancho de teléfono y contraste mínimo 4.5:1 para texto normal de tema.
- [x] Ejecutar los casos nuevos y comprobar que fallan por ausencia del comportamiento adaptable/contraste.
- [x] Aplicar el límite de ancho y escala, revisar controles con tooltip/semántica y corregir los fallos de accesibilidad detectados.
- [x] Ejecutar las pruebas de widgets y tema y verificar que no hay errores de layout.

### Tarea 3: identidad visual y splash de plataforma

**Archivos:**
- Modificar: `pubspec.yaml`, `pubspec.lock`, recursos de `android/app/src/main/res/` e `ios/Runner/Assets.xcassets/`
- Crear: recurso maestro local en `assets/brand/` y configuración de generación en `pubspec.yaml`
- Verificación: generación de iconos y splash, compilación Android e iOS

**Interfaces:**
- Consume: paleta de tema y decisión de marca geométrica de llave de la especificación.
- Produce: icono de lanzador y splash personalizados para Android/iOS, en claro y oscuro, generados con herramientas dev permitidas.

- [x] Crear los recursos de marca como activos locales y añadir únicamente las herramientas dev aprobadas para generar los tamaños nativos.
- [x] Generar recursos Android/iOS, comprobar que los archivos y referencias nativas se actualizaron y que no se alteraron permisos ni configuración de privacidad.
- [x] Compilar Android e iOS para detectar errores en los recursos generados.

### Tarea 4: revisión ES/EN y cierre de fase

**Archivos:**
- Modificar: `lib/l10n/app_es.arb`, `lib/l10n/app_en.arb`, `PROGRESS.md` y pruebas de localización/widgets si hacen falta
- Verificación: `flutter gen-l10n`, prueba de paridad de claves ARB, `flutter analyze`, `flutter test`, `flutter build apk --debug`, `flutter build ios --no-codesign`, `git diff --check`

- [x] Añadir o corregir traducciones visibles identificadas durante la revisión en ambos ARB y regenerar localizaciones.
- [x] Verificar paridad ES/EN y comprobar ambos idiomas en los estados vacíos.
- [x] Actualizar `PROGRESS.md` con el alcance, validación y pasos manuales para teléfono/tableta y movimiento reducido.
- [x] Ejecutar las verificaciones completas de fase y registrar resultados; no crear commit/push para fase 8 salvo que el usuario lo solicite.