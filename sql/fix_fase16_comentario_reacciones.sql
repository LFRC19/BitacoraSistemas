-- ============================================================================
-- fix_fase16_comentario_reacciones.sql
-- ============================================================================
-- Corrige el error: la tabla de comentarios se llama `incidencias_comentarios`,
-- no `comentarios`.
--
-- IMPORTANTE: el resto del SQL de Fase 16 ya se ejecutó correctamente.
-- Este parche solo crea la tabla que faltó.
-- ============================================================================

USE carnes_bacal;

-- Por si quedó intentada
DROP TABLE IF EXISTS comentario_reacciones;

-- ============================================================================
-- Tabla: comentario_reacciones (corregida)
-- ============================================================================
CREATE TABLE comentario_reacciones (
    id              INT NOT NULL AUTO_INCREMENT,
    comentario_id   INT NOT NULL,
    usuario_id      INT NOT NULL,
    emoji           VARCHAR(10) NOT NULL COMMENT 'Emoji unicode',
    creado_en       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    UNIQUE KEY uk_react (comentario_id, usuario_id, emoji),
    KEY idx_comentario (comentario_id),

    CONSTRAINT fk_react_comentario FOREIGN KEY (comentario_id) REFERENCES incidencias_comentarios(id) ON DELETE CASCADE,
    CONSTRAINT fk_react_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SELECT 'comentario_reacciones creada' AS estado;
