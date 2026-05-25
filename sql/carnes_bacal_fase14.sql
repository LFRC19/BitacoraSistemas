-- ============================================================================
-- carnes_bacal_fase14.sql
-- ============================================================================
-- Fase 14: Inteligencia y automatización
--
-- Tabla nueva:
--   - reglas_asignacion: reglas que asignan automáticamente un técnico
--     según condiciones simples (área, categoría, tipo, severidad, sucursal)
-- ============================================================================

USE carnes_bacal;

-- Limpieza
DROP TABLE IF EXISTS reglas_asignacion;

-- ============================================================================
-- Tabla: reglas_asignacion
-- ============================================================================
-- Las reglas se evalúan por prioridad (orden ASC).
-- Si una incidencia cumple TODAS las condiciones no nulas de una regla,
-- se asigna automáticamente al técnico especificado.
-- Solo se aplica al crear incidencias (no a las ya existentes).
-- ============================================================================
CREATE TABLE reglas_asignacion (
    id              INT NOT NULL AUTO_INCREMENT,
    nombre          VARCHAR(150) NOT NULL COMMENT 'Nombre descriptivo de la regla',
    descripcion     VARCHAR(255) DEFAULT NULL,

    -- Condiciones (todas las no-NULL deben cumplirse, AND lógico)
    sucursal_id     INT DEFAULT NULL,
    area_id         INT DEFAULT NULL,
    categoria_id    INT DEFAULT NULL,
    tipo_trabajo_id INT DEFAULT NULL,
    severidad_id    INT DEFAULT NULL,

    -- Acción: técnico al que se asigna automáticamente
    asignar_a_id    INT NOT NULL,

    -- Control
    prioridad       INT NOT NULL DEFAULT 100 COMMENT 'Menor = se evalúa antes',
    activa          TINYINT(1) NOT NULL DEFAULT 1,
    veces_aplicada  INT NOT NULL DEFAULT 0,

    -- Metadatos
    creado_por_id   INT DEFAULT NULL,
    creado_en       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    KEY idx_activa_prioridad (activa, prioridad),
    KEY idx_sucursal (sucursal_id),
    KEY idx_area (area_id),

    CONSTRAINT fk_regla_sucursal FOREIGN KEY (sucursal_id) REFERENCES sucursales(id) ON DELETE CASCADE,
    CONSTRAINT fk_regla_area FOREIGN KEY (area_id) REFERENCES areas(id) ON DELETE CASCADE,
    CONSTRAINT fk_regla_categoria FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE CASCADE,
    CONSTRAINT fk_regla_tipo FOREIGN KEY (tipo_trabajo_id) REFERENCES tipos_trabajo(id) ON DELETE CASCADE,
    CONSTRAINT fk_regla_severidad FOREIGN KEY (severidad_id) REFERENCES severidades(id) ON DELETE CASCADE,
    CONSTRAINT fk_regla_asignar FOREIGN KEY (asignar_a_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    CONSTRAINT fk_regla_creador FOREIGN KEY (creado_por_id) REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Verificación
SELECT 'reglas_asignacion creada' AS estado;
