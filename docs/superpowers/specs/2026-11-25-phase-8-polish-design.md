# Fase 8: pulido final y accesibilidad

## Intención

Cerrar el pulido visual y de accesibilidad de Llavero sobre las pantallas y temas ya existentes. La aplicación debe seguir siendo una bóveda familiar cálida, bilingüe y completamente offline, ahora con transiciones discretas, estados vacíos comprensibles, controles accesibles, adaptación a pantallas grandes y una identidad visual propia al abrirla y en el lanzador.

## Objetivos

- Respetar la preferencia del sistema para reducir movimiento en transiciones y animaciones.
- Mejorar los estados vacíos y el estado de búsqueda sin revelar valores secretos.
- Mantener objetivos táctiles de al menos 48 dp, etiquetas accesibles y tipografía legible hasta 200 %.
- Limitar el contenido en tabletas a unos 720 dp sin alterar el diseño de teléfono.
- Sustituir icono y splash de plantilla por recursos propios, coherentes con el tema claro/oscuro.
- Revisar que la interfaz y sus mensajes nuevos estén completos en español e inglés.

## No objetivos

- No se cambia el modelo de datos, la criptografía, los flujos de autenticación ni la lógica de exportación.
- No se añade ninguna dependencia de ejecución ni se usa red en la aplicación.
- No se rediseñan las pantallas ni se sustituyen los componentes Material 3 existentes.

## Restricciones

- Solo Flutter/Dart y dependencias ya permitidas; `flutter_launcher_icons` y `flutter_native_splash` se permiten únicamente como herramientas de desarrollo de esta fase.
- Los recursos gráficos se empaquetan localmente; no se usa `google_fonts`, SVG runtime ni iconos de marca de terceros.
- Toda cadena visible debe existir en ambos archivos ARB.
- Mantener contraste legible en ambos temas, controles con al menos 48 dp y ancho de contenido cercano a 720 dp en tabletas.

## Enfoques considerados

1. Reemplazar componentes y navegación por una capa visual nueva. Se descarta porque aumenta el riesgo y repetiría componentes Material 3 que ya funcionan.
2. Conservar los componentes existentes, cerrar los huecos con utilidades pequeñas y generar recursos nativos mediante las herramientas de desarrollo permitidas. Es la opción elegida: limita el cambio, conserva el comportamiento y produce iconos/splash consistentes en Android e iOS.
3. Editar manualmente cada tamaño de icono y cada splash nativo. Se descarta porque duplica recursos y es más fácil que Android e iOS diverjan.

## Diseño

- Añadir una política de movimiento reutilizable que reduzca la duración a cero cuando `MediaQuery` indique que las animaciones están desactivadas; usarla en transiciones de onboarding, contenido de inicio y feedback visual.
- Reforzar `EmptyState` con una ilustración hecha con widgets/`CustomPaint`, semántica y acciones localizadas. El estado sin resultados permitirá limpiar búsqueda/filtros.
- Limitar los formularios y las vistas restantes a 720 dp en pantallas amplias, y limitar el escalado de texto de la aplicación a 200 % sin forzar tamaños menores.
- Crear un emblema geométrico sencillo de llave en los colores de Llavero, y generar desde ese recurso iconos nativos y splash claro/oscuro para Android e iOS.
- Generar las localizaciones desde ARB, comprobar que ambos idiomas tienen las mismas claves y revisar los textos de seguridad, accesibilidad y estados vacíos.

## Decisiones para quien implemente

- Favorecer `Semantics`, `Tooltip`, `SafeArea`, `Wrap` y scroll antes que tamaños fijos.
- Las animaciones decorativas nunca deben bloquear una acción ni retrasar la lectura de contenido.
- La fase termina con `flutter analyze`, `flutter test` y compilaciones Android/iOS; la prueba en dispositivo físico se anotará como pendiente si no está disponible.