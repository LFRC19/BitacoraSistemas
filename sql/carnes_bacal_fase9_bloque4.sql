-- ============================================================================
-- carnes_bacal_fase9_bloque4.sql
-- ============================================================================
-- Asegura que la tabla `sesiones` tenga la estructura necesaria para
-- el tracking de dispositivos activos.
--
-- - La tabla ya existe desde el Paso 1, pero por seguridad la recreamos
--   con todos los campos necesarios.
-- - Si tu tabla actual ya tiene datos, NO importa: las sesiones se rehacen
--   en cada login.
-- ============================================================================

USE carnes_bacal;

DROP TABLE IF EXISTS sesiones;

CREATE TABLE sesiones (
    id              INT NOT NULL AUTO_INCREMENT,
    usuario_id      INT NOT NULL,
    session_id      VARCHAR(128) NOT NULL COMMENT 'PHP session_id()',
    ip              VARCHAR(45) DEFAULT NULL COMMENT 'IPv4 o IPv6',
    user_agent      VARCHAR(500) DEFAULT NULL,
    dispositivo     VARCHAR(100) DEFAULT NULL COMMENT 'Dispositivo detectado (Windows, Mac, Android, iPhone, etc)',
    navegador       VARCHAR(50) DEFAULT NULL COMMENT 'Navegador detectado',
    activa          TINYINT(1) NOT NULL DEFAULT 1,
    motivo_cierre   VARCHAR(100) DEFAULT NULL,
    creado_en       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultima_actividad TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    cerrada_en      TIMESTAMP NULL DEFAULT NULL,

    PRIMARY KEY (id),
    UNIQUE KEY uk_session_id (session_id),
    KEY idx_usuario_activa (usuario_id, activa),
    KEY idx_creado (creado_en DESC),
    CONSTRAINT fk_sesion_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SELECT 'Tabla sesiones lista' AS estado;
