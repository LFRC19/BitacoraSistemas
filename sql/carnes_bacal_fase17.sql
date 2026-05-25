-- ============================================================================
-- carnes_bacal_fase17.sql
-- ============================================================================
-- Fase 17: Mapa de sucursal con drag & drop de equipos
--
-- Cambios:
--   - Columnas nuevas en sucursales: plano_url (imagen del plano)
--   - Columnas nuevas en equipos: pos_x, pos_y (posición sobre el plano, en %)
-- ============================================================================

USE carnes_bacal;

-- ============================================================================
-- Plano por sucursal
-- ============================================================================
ALTER TABLE sucursales
    ADD COLUMN plano_url VARCHAR(255) DEFAULT NULL COMMENT 'Ruta a la imagen del plano',
    ADD COLUMN plano_subido_en TIMESTAMP NULL DEFAULT NULL;

-- ============================================================================
-- Posición de cada equipo sobre el plano (en porcentajes 0-100)
-- ============================================================================
-- Usamos porcentajes para que sea independiente del tamaño de la imagen al
-- mostrarla. Si el admin sube un plano más grande/chico, las posiciones
-- siguen siendo válidas.
ALTER TABLE equipos
    ADD COLUMN pos_x DECIMAL(5,2) DEFAULT NULL COMMENT '% desde el borde izquierdo',
    ADD COLUMN pos_y DECIMAL(5,2) DEFAULT NULL COMMENT '% desde el borde superior';

ALTER TABLE equipos
    ADD INDEX idx_pos (pos_x, pos_y);

-- ============================================================================
-- Verificación
-- ============================================================================
SELECT 'Fase 17 lista' AS estado;
SELECT 'Sucursales con plano:' AS info, COUNT(*) AS total
FROM sucursales WHERE plano_url IS NOT NULL
UNION ALL
SELECT 'Equipos con posición:', COUNT(*)
FROM equipos WHERE pos_x IS NOT NULL;
