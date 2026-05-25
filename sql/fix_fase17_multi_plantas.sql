-- ============================================================================
-- fix_fase17_multi_plantas.sql
-- ============================================================================
-- Refactoriza el mapa para soportar múltiples plantas por sucursal.
--
-- Antes: 1 sucursal = 1 plano
-- Después: 1 sucursal = N plantas (cada una con su plano y sus equipos)
-- ============================================================================

USE carnes_bacal;

-- ============================================================================
-- Nueva tabla: sucursal_plantas
-- ============================================================================
CREATE TABLE IF NOT EXISTS sucursal_plantas (
    id              INT NOT NULL AUTO_INCREMENT,
    sucursal_id     INT NOT NULL,
    nombre          VARCHAR(80) NOT NULL COMMENT 'Ej: Planta baja, Piso 1, Bodega',
    orden           INT NOT NULL DEFAULT 0 COMMENT 'Para ordenar las pestañas',
    plano_url       VARCHAR(255) DEFAULT NULL,
    plano_subido_en TIMESTAMP NULL DEFAULT NULL,
    activo          TINYINT(1) NOT NULL DEFAULT 1,
    creado_en       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    KEY idx_sucursal (sucursal_id, orden),

    CONSTRAINT fk_planta_sucursal FOREIGN KEY (sucursal_id) REFERENCES sucursales(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- Migrar planos existentes desde sucursales a sucursal_plantas
-- ============================================================================
-- Crear una planta "Planta única" para cada sucursal que tenía plano
INSERT INTO sucursal_plantas (sucursal_id, nombre, orden, plano_url, plano_subido_en)
SELECT id, 'Planta única', 1, plano_url, plano_subido_en
FROM sucursales
WHERE plano_url IS NOT NULL;


-- ============================================================================
-- Agregar planta_id a equipos (ya tienen pos_x, pos_y)
-- ============================================================================
ALTER TABLE equipos
    ADD COLUMN planta_id INT DEFAULT NULL AFTER sucursal_id,
    ADD CONSTRAINT fk_equipo_planta FOREIGN KEY (planta_id) REFERENCES sucursal_plantas(id) ON DELETE SET NULL;


-- ============================================================================
-- Migrar equipos: si tenían pos_x/pos_y, asociarlos a la planta única
-- ============================================================================
UPDATE equipos e
INNER JOIN sucursal_plantas sp ON sp.sucursal_id = e.sucursal_id
SET e.planta_id = sp.id
WHERE e.pos_x IS NOT NULL AND e.pos_y IS NOT NULL;


-- ============================================================================
-- Eliminar columnas viejas de sucursales (ya no se usan)
-- ============================================================================
ALTER TABLE sucursales DROP COLUMN plano_url;
ALTER TABLE sucursales DROP COLUMN plano_subido_en;


-- ============================================================================
-- Verificación
-- ============================================================================
SELECT 'Migración completada' AS estado;
SELECT 'Plantas creadas:' AS info, COUNT(*) AS total FROM sucursal_plantas
UNION ALL
SELECT 'Equipos vinculados a planta:', COUNT(*) FROM equipos WHERE planta_id IS NOT NULL;
