-- ============================================================================
-- fix_urls_localhost.sql
-- ============================================================================
-- Limpia las URLs en notificaciones que se guardaron con "http://localhost/..."
-- (o con cualquier host hardcodeado). Después de aplicar este parche, todas las
-- nuevas notificaciones se guardarán como rutas relativas y este problema no
-- volverá a ocurrir.
--
-- Lo que hace:
--   - Detecta y elimina el prefijo "http://localhost..." o "http://<cualquier>/"
--     de la columna enlace de notificaciones
--   - Convierte URLs absolutas en relativas, conservando el path
-- ============================================================================

USE carnes_bacal;

-- Detectar columna de enlace (puede llamarse 'enlace' o 'url')
SELECT '== Estado antes ==' AS info;
SELECT COUNT(*) AS notif_con_localhost
FROM notificaciones
WHERE enlace LIKE 'http://%' OR enlace LIKE 'https://%';

-- ============================================================================
-- Limpieza: quitar protocolo+host de cualquier URL absoluta
-- ============================================================================
-- Trick: usar SUBSTRING_INDEX para tomar la parte después del 3er slash
-- "http://localhost/UtilidadesBacal/BitacoraSistemas/incidencia_ver.php?id=5"
-- → "UtilidadesBacal/BitacoraSistemas/incidencia_ver.php?id=5"
-- → "/UtilidadesBacal/BitacoraSistemas/incidencia_ver.php?id=5"

UPDATE notificaciones
SET enlace = CONCAT('/', SUBSTRING_INDEX(SUBSTRING_INDEX(enlace, '://', -1), '/', -100))
WHERE (enlace LIKE 'http://%' OR enlace LIKE 'https://%')
  AND enlace IS NOT NULL;

-- Caso especial: si quedó solo "/" o vacío después del corte, dejarlo como NULL
UPDATE notificaciones SET enlace = NULL WHERE enlace = '/' OR enlace = '';

-- Hacer lo mismo con la tabla recordatorios (por si acaso)
UPDATE recordatorios
SET enlace = CONCAT('/', SUBSTRING_INDEX(SUBSTRING_INDEX(enlace, '://', -1), '/', -100))
WHERE (enlace LIKE 'http://%' OR enlace LIKE 'https://%')
  AND enlace IS NOT NULL;

UPDATE recordatorios SET enlace = NULL WHERE enlace = '/' OR enlace = '';

-- ============================================================================
-- Verificación
-- ============================================================================
SELECT '== Estado después ==' AS info;
SELECT COUNT(*) AS notif_con_protocolo
FROM notificaciones
WHERE enlace LIKE 'http://%' OR enlace LIKE 'https://%';
-- Debe dar 0

SELECT 'Limpieza completada' AS estado;
