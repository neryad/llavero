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

La siguiente fase no comienza hasta recibir la indicación «continue».