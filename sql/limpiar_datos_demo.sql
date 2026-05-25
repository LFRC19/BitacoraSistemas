-- ============================================================================
-- limpiar_datos_demo.sql
-- ============================================================================
-- Borra todos los datos de prueba para empezar a llenar el sistema con
-- información REAL del negocio.
--
-- QUÉ HACE:
--   ✓ Elimina TODAS las incidencias y sus dependencias (comentarios, fotos,
--     reacciones, historial, adjuntos)
--   ✓ Elimina TODOS los equipos y sus dependencias (mantenimientos, fotos,
--     transferencias)
--   ✓ Elimina importaciones, anuncios, recordatorios, sesiones, notificaciones
--   ✓ Elimina usuarios DEMO (carlos, diana, gerente1, gerente2, jefe_cajas, etc.)
--   ✓ Conserva al admin principal y a un técnico (abraham)
--   ✓ Conserva los CATÁLOGOS BASE (severidades, estados, áreas, categorías,
--     tipos de trabajo, orígenes, roles, sucursales) porque son la
--     configuración del sistema, no datos de prueba
--   ✓ Conserva proveedores reales (Abasteo, enetSystem, Metrocarrier, Sipcons)
--   ✓ Conserva plantillas de incidencias y artículos de base de conocimiento
--   ✓ Conserva palabras clave de sugerencia de categoría
--   ✓ Resetea contadores AUTO_INCREMENT
--
-- ANTES DE EJECUTAR:
--   ⚠ HAZ UN BACKUP COMPLETO de la BD por si necesitas volver atrás
--   ⚠ Revisa la sección "USUARIOS A CONSERVAR" y ajusta si necesitas
-- ============================================================================

USE carnes_bacal;

-- ============================================================================
-- Deshabilitar checks de FK temporalmente para borrar en orden libre
-- ============================================================================
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================================
-- 1. INCIDENCIAS Y DEPENDENCIAS
-- ============================================================================
TRUNCATE TABLE comentario_reacciones;
TRUNCATE TABLE incidencias_comentarios;
TRUNCATE TABLE incidencias_historial;
TRUNCATE TABLE incidencias_adjuntos;
TRUNCATE TABLE incidencias;

-- ============================================================================
-- 2. EQUIPOS Y DEPENDENCIAS
-- ============================================================================
TRUNCATE TABLE equipo_fotos;
TRUNCATE TABLE equipo_transferencias;
TRUNCATE TABLE mantenimientos;
TRUNCATE TABLE equipos;

-- ============================================================================
-- 3. MAPA Y PLANTAS (los planos también son datos de prueba)
-- ============================================================================
TRUNCATE TABLE sucursal_plantas;

-- ============================================================================
-- 4. COMUNICACIÓN
-- ============================================================================
TRUNCATE TABLE anuncios_lecturas;
TRUNCATE TABLE anuncios;
TRUNCATE TABLE recordatorios;
TRUNCATE TABLE notificaciones;

-- ============================================================================
-- 5. IMPORTACIONES Y AUDITORÍA
-- ============================================================================
TRUNCATE TABLE importaciones;
TRUNCATE TABLE auditoria;

-- ============================================================================
-- 6. SESIONES (cierra todas las activas, todos tendrán que volver a entrar)
-- ============================================================================
TRUNCATE TABLE sesiones;

-- ============================================================================
-- 7. USUARIOS DEMO
-- ============================================================================
-- USUARIOS A CONSERVAR:
--   - admin   (administrador del sistema)
--   - abraham (técnico real, puedes cambiar el login si quieres)
--
-- USUARIOS A ELIMINAR:
--   - carlos, diana, gerente1, gerente2, jefe_cajas, jefe_carn, jefe_alm
--   - Cualquier otro usuario de prueba
--
-- ⚠ Ajusta el WHERE si tu usuario principal NO se llama 'admin' o 'abraham'
-- ============================================================================
DELETE FROM usuarios
WHERE usuario NOT IN ('admin', 'abraham');

-- ============================================================================
-- 8. RESETEAR AUTO_INCREMENT (para empezar IDs desde 1)
-- ============================================================================
ALTER TABLE incidencias AUTO_INCREMENT = 1;
ALTER TABLE incidencias_comentarios AUTO_INCREMENT = 1;
ALTER TABLE incidencias_historial AUTO_INCREMENT = 1;
ALTER TABLE incidencias_adjuntos AUTO_INCREMENT = 1;
ALTER TABLE comentario_reacciones AUTO_INCREMENT = 1;
ALTER TABLE equipos AUTO_INCREMENT = 1;
ALTER TABLE equipo_fotos AUTO_INCREMENT = 1;
ALTER TABLE equipo_transferencias AUTO_INCREMENT = 1;
ALTER TABLE mantenimientos AUTO_INCREMENT = 1;
ALTER TABLE sucursal_plantas AUTO_INCREMENT = 1;
ALTER TABLE anuncios AUTO_INCREMENT = 1;
ALTER TABLE anuncios_lecturas AUTO_INCREMENT = 1;
ALTER TABLE recordatorios AUTO_INCREMENT = 1;
ALTER TABLE notificaciones AUTO_INCREMENT = 1;
ALTER TABLE importaciones AUTO_INCREMENT = 1;
ALTER TABLE auditoria AUTO_INCREMENT = 1;
ALTER TABLE sesiones AUTO_INCREMENT = 1;

-- ============================================================================
-- Rehabilitar checks de FK
-- ============================================================================
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================================
-- VERIFICACIÓN
-- ============================================================================
SELECT 'Limpieza completada' AS estado;

SELECT '== Conteos finales ==' AS info;
SELECT 'Usuarios:' AS tabla, COUNT(*) AS total FROM usuarios
UNION ALL SELECT 'Sucursales:', COUNT(*) FROM sucursales
UNION ALL SELECT 'Áreas:', COUNT(*) FROM areas
UNION ALL SELECT 'Categorías:', COUNT(*) FROM categorias
UNION ALL SELECT 'Tipos de trabajo:', COUNT(*) FROM tipos_trabajo
UNION ALL SELECT 'Severidades:', COUNT(*) FROM severidades
UNION ALL SELECT 'Estados:', COUNT(*) FROM estados
UNION ALL SELECT 'Proveedores:', COUNT(*) FROM proveedores
UNION ALL SELECT 'Plantillas:', COUNT(*) FROM plantillas
UNION ALL SELECT 'Artículos KB:', COUNT(*) FROM kb_articulos
UNION ALL SELECT 'Palabras clave:', COUNT(*) FROM categorias_palabras_clave
UNION ALL SELECT '-- Vacíos:' AS sep, 0
UNION ALL SELECT 'Incidencias:', COUNT(*) FROM incidencias
UNION ALL SELECT 'Equipos:', COUNT(*) FROM equipos
UNION ALL SELECT 'Mantenimientos:', COUNT(*) FROM mantenimientos
UNION ALL SELECT 'Notificaciones:', COUNT(*) FROM notificaciones
UNION ALL SELECT 'Auditoría:', COUNT(*) FROM auditoria;

-- ============================================================================
-- IMPORTANTE: Después de ejecutar este script:
-- ============================================================================
-- 1. La contraseña de 'admin' sigue siendo la que tenías. Si no la recuerdas,
--    puedes resetearla con:
--      UPDATE usuarios SET password_hash = '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'
--      WHERE usuario = 'admin';
--    (esto la deja en 'admin123' que es la por defecto del setup)
--
-- 2. Cierra sesión y vuelve a entrar (las sesiones fueron eliminadas).
--
-- 3. Borra los archivos físicos de uploads que ya no tienen registro en BD:
--      C:\xampp\htdocs\UtilidadesBacal\BitacoraSistemas\uploads\adjuntos\*
--      C:\xampp\htdocs\UtilidadesBacal\BitacoraSistemas\uploads\equipo_fotos\*
--      C:\xampp\htdocs\UtilidadesBacal\BitacoraSistemas\uploads\planos\*
--    (NO borres uploads/avatares si quieres conservar los avatares de admin/abraham)
-- ============================================================================
