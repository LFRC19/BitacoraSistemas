-- ============================================================================
-- carnes_bacal_fase10.sql
-- ============================================================================
-- Fase 10: Equipos avanzados
--   - Mantenimientos programados (con soporte para recurrencia)
--   - Ciclo de vida del equipo (nuevo, en uso, reparación, baja)
--   - Vida útil estimada y depreciación calculada
--   - Transferencias entre sucursales
--   - Galería de fotos por equipo
-- ============================================================================

USE carnes_bacal;

-- ============================================================================
-- LIMPIEZA por si hubo un intento previo
-- ============================================================================
DROP TABLE IF EXISTS equipo_fotos;
DROP TABLE IF EXISTS equipo_transferencias;
DROP TABLE IF EXISTS mantenimientos;


-- ============================================================================
-- Tabla: mantenimientos
-- ============================================================================
-- Eventos de mantenimiento programados o realizados sobre un equipo.
-- Soporta recurrencia (al completar uno, el sistema genera el siguiente).
-- ============================================================================
CREATE TABLE mantenimientos (
    id              INT NOT NULL AUTO_INCREMENT,
    equipo_id       INT NOT NULL,
    titulo          VARCHAR(200) NOT NULL,
    descripcion     TEXT DEFAULT NULL,

    -- Programacion
    fecha_programada DATE NOT NULL,
    hora_programada  TIME DEFAULT NULL,
    asignado_a_id   INT DEFAULT NULL COMMENT 'Tecnico asignado',
    proveedor_id    INT DEFAULT NULL COMMENT 'Si lo hace un proveedor externo',

    -- Estado: programado, proximo, en_progreso, completado, cancelado, vencido
    estado          ENUM('programado','proximo','en_progreso','completado','cancelado','vencido')
                    NOT NULL DEFAULT 'programado',

    -- Recurrencia (opcional)
    es_recurrente   TINYINT(1) NOT NULL DEFAULT 0,
    recurrencia_tipo ENUM('dias','semanas','meses','anios') DEFAULT NULL,
    recurrencia_valor INT DEFAULT NULL COMMENT 'Cada cuantas unidades (ej. 3 meses)',
    mantenimiento_padre_id INT DEFAULT NULL COMMENT 'Si fue auto-generado, apunta al original',

    -- Ejecucion y resultado
    fecha_inicio_real    DATETIME DEFAULT NULL,
    fecha_completado     DATETIME DEFAULT NULL,
    realizado_por_id     INT DEFAULT NULL COMMENT 'Quien lo ejecuto realmente',
    resultado            TEXT DEFAULT NULL COMMENT 'Notas de lo que se hizo',
    costo                DECIMAL(10,2) DEFAULT NULL,
    incidencia_generada_id INT DEFAULT NULL COMMENT 'Si se convirtio en incidencia',

    -- Metadatos
    creado_por_id   INT DEFAULT NULL,
    creado_en       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    KEY idx_equipo (equipo_id),
    KEY idx_estado (estado),
    KEY idx_fecha (fecha_programada),
    KEY idx_asignado (asignado_a_id),
    KEY idx_padre (mantenimiento_padre_id),

    CONSTRAINT fk_mant_equipo FOREIGN KEY (equipo_id) REFERENCES equipos(id) ON DELETE CASCADE,
    CONSTRAINT fk_mant_asignado FOREIGN KEY (asignado_a_id) REFERENCES usuarios(id) ON DELETE SET NULL,
    CONSTRAINT fk_mant_proveedor FOREIGN KEY (proveedor_id) REFERENCES proveedores(id) ON DELETE SET NULL,
    CONSTRAINT fk_mant_realizado FOREIGN KEY (realizado_por_id) REFERENCES usuarios(id) ON DELETE SET NULL,
    CONSTRAINT fk_mant_creador FOREIGN KEY (creado_por_id) REFERENCES usuarios(id) ON DELETE SET NULL,
    CONSTRAINT fk_mant_padre FOREIGN KEY (mantenimiento_padre_id) REFERENCES mantenimientos(id) ON DELETE SET NULL,
    CONSTRAINT fk_mant_incidencia FOREIGN KEY (incidencia_generada_id) REFERENCES incidencias(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- Tabla: equipo_transferencias
-- ============================================================================
-- Historial de movimientos de equipos entre sucursales.
-- ============================================================================
CREATE TABLE equipo_transferencias (
    id                  INT NOT NULL AUTO_INCREMENT,
    equipo_id           INT NOT NULL,
    sucursal_origen_id  INT DEFAULT NULL COMMENT 'Null si era equipo nuevo recien llegado',
    sucursal_destino_id INT NOT NULL,
    area_origen_id      INT DEFAULT NULL,
    area_destino_id     INT DEFAULT NULL,
    motivo              VARCHAR(255) DEFAULT NULL,
    notas               TEXT DEFAULT NULL,
    fecha_transferencia DATE NOT NULL,
    realizado_por_id    INT DEFAULT NULL,
    creado_en           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    KEY idx_equipo (equipo_id),
    KEY idx_fecha (fecha_transferencia DESC),

    CONSTRAINT fk_trans_equipo FOREIGN KEY (equipo_id) REFERENCES equipos(id) ON DELETE CASCADE,
    CONSTRAINT fk_trans_origen FOREIGN KEY (sucursal_origen_id) REFERENCES sucursales(id) ON DELETE SET NULL,
    CONSTRAINT fk_trans_destino FOREIGN KEY (sucursal_destino_id) REFERENCES sucursales(id) ON DELETE RESTRICT,
    CONSTRAINT fk_trans_area_origen FOREIGN KEY (area_origen_id) REFERENCES areas(id) ON DELETE SET NULL,
    CONSTRAINT fk_trans_area_destino FOREIGN KEY (area_destino_id) REFERENCES areas(id) ON DELETE SET NULL,
    CONSTRAINT fk_trans_usuario FOREIGN KEY (realizado_por_id) REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- Tabla: equipo_fotos
-- ============================================================================
-- Galería de imágenes del equipo (estado físico, antes/después de mantenimientos)
-- ============================================================================
CREATE TABLE equipo_fotos (
    id              INT NOT NULL AUTO_INCREMENT,
    equipo_id       INT NOT NULL,
    ruta            VARCHAR(255) NOT NULL COMMENT 'Ruta relativa (assets/equipos/...)',
    descripcion     VARCHAR(255) DEFAULT NULL,
    es_portada      TINYINT(1) NOT NULL DEFAULT 0,
    subido_por_id   INT DEFAULT NULL,
    tamano_bytes    INT DEFAULT NULL,
    creado_en       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    KEY idx_equipo (equipo_id),

    CONSTRAINT fk_foto_equipo FOREIGN KEY (equipo_id) REFERENCES equipos(id) ON DELETE CASCADE,
    CONSTRAINT fk_foto_usuario FOREIGN KEY (subido_por_id) REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- ALTERACIONES a la tabla equipos
-- ============================================================================

-- Verificamos si ya existen las columnas antes de agregarlas (por si se ejecuta dos veces)
-- En MariaDB/MySQL no hay IF NOT EXISTS para ADD COLUMN universal, asi que dejamos los
-- ADD COLUMN directos. Si esta es la segunda ejecucion, recibiras error 1060: ignora ese.

ALTER TABLE equipos
    ADD COLUMN estado_vida ENUM('nuevo','en_uso','en_reparacion','dado_de_baja')
        NOT NULL DEFAULT 'en_uso' AFTER activo,
    ADD COLUMN vida_util_meses INT DEFAULT NULL COMMENT 'Vida util estimada en meses (60 = 5 años)' AFTER costo_compra,
    ADD COLUMN fecha_baja DATE DEFAULT NULL AFTER vida_util_meses,
    ADD COLUMN motivo_baja VARCHAR(255) DEFAULT NULL AFTER fecha_baja;


-- ============================================================================
-- Verificacion final
-- ============================================================================
SELECT 'Tablas creadas:' AS info, '' AS total
UNION ALL SELECT 'mantenimientos', CAST(COUNT(*) AS CHAR) FROM mantenimientos
UNION ALL SELECT 'equipo_transferencias', CAST(COUNT(*) AS CHAR) FROM equipo_transferencias
UNION ALL SELECT 'equipo_fotos', CAST(COUNT(*) AS CHAR) FROM equipo_fotos;
