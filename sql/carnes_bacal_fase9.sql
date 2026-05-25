-- ============================================================================
-- carnes_bacal_fase9.sql
-- ============================================================================
-- Fase 9: Proveedores + Perfil de usuario + Backups
-- 
-- Cambios:
--   1. Tablas nuevas: proveedores, proveedor_contactos, proveedor_marcas,
--      proveedor_tipos_equipo, backups_realizados
--   2. Columnas nuevas en: equipos (proveedor_id, fecha_compra, costo_compra),
--      usuarios (avatar_url, pagina_inicio_preferida),
--      incidencias (proveedor_escalado_id)
--   3. Datos semilla: 4 proveedores reales de Carnes Bacal
--
-- EJECUTAR sobre la BD existente carnes_bacal
-- ============================================================================

USE carnes_bacal;

-- ============================================================================
-- LIMPIEZA por si quedó algo de un intento anterior
-- ============================================================================
DROP TABLE IF EXISTS proveedor_contactos;
DROP TABLE IF EXISTS proveedor_marcas;
DROP TABLE IF EXISTS proveedor_tipos_equipo;
DROP TABLE IF EXISTS proveedores;
DROP TABLE IF EXISTS backups_realizados;

-- ============================================================================
-- Tabla: proveedores
-- ============================================================================
CREATE TABLE proveedores (
    id              INT NOT NULL AUTO_INCREMENT,
    nombre          VARCHAR(150) NOT NULL COMMENT 'Nombre comercial',
    razon_social    VARCHAR(200) DEFAULT NULL,
    rfc             VARCHAR(20) DEFAULT NULL,
    servicio        VARCHAR(255) DEFAULT NULL COMMENT 'Descripcion corta del servicio que ofrece',

    -- Contacto principal (los demás contactos van en proveedor_contactos)
    direccion       VARCHAR(255) DEFAULT NULL,
    telefono        VARCHAR(50) DEFAULT NULL,
    email           VARCHAR(150) DEFAULT NULL,
    sitio_web       VARCHAR(200) DEFAULT NULL,
    horario_atencion VARCHAR(255) DEFAULT NULL COMMENT 'ej. Lun-Vie 9-18hr',

    -- Calificacion y notas
    calificacion    TINYINT UNSIGNED DEFAULT NULL COMMENT '1-5 estrellas',
    notas           TEXT DEFAULT NULL,

    -- Estado
    activo          TINYINT(1) NOT NULL DEFAULT 1,
    creado_por_id   INT DEFAULT NULL,
    creado_en       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    UNIQUE KEY uk_nombre (nombre),
    KEY idx_activo (activo),
    CONSTRAINT fk_proveedor_creador FOREIGN KEY (creado_por_id) REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- Tabla: proveedor_contactos
-- ============================================================================
-- Multiples contactos/telefonos/correos por proveedor.
-- Para casos como Sipcons que tiene contactos diferentes para basculas y MrTienda.
-- ============================================================================
CREATE TABLE proveedor_contactos (
    id              INT NOT NULL AUTO_INCREMENT,
    proveedor_id    INT NOT NULL,
    nombre          VARCHAR(150) NOT NULL COMMENT 'Nombre de la persona contacto',
    puesto          VARCHAR(100) DEFAULT NULL COMMENT 'ej. Asesor de basculas, Soporte',
    telefono        VARCHAR(50) DEFAULT NULL,
    email           VARCHAR(150) DEFAULT NULL,
    notas           VARCHAR(255) DEFAULT NULL COMMENT 'ej. Solo turno matutino',
    es_principal    TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Marca el contacto principal',
    orden           INT NOT NULL DEFAULT 0,
    creado_en       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    KEY idx_proveedor (proveedor_id),
    CONSTRAINT fk_contacto_proveedor FOREIGN KEY (proveedor_id) REFERENCES proveedores(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- Tabla: proveedor_marcas
-- ============================================================================
-- Marcas que comercializa o atiende el proveedor (informativo, no restrictivo)
-- ============================================================================
CREATE TABLE proveedor_marcas (
    id              INT NOT NULL AUTO_INCREMENT,
    proveedor_id    INT NOT NULL,
    marca           VARCHAR(100) NOT NULL,

    PRIMARY KEY (id),
    KEY idx_proveedor (proveedor_id),
    UNIQUE KEY uk_proveedor_marca (proveedor_id, marca),
    CONSTRAINT fk_marca_proveedor FOREIGN KEY (proveedor_id) REFERENCES proveedores(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- Tabla: proveedor_tipos_equipo
-- ============================================================================
-- Tipos de equipo que soporta el proveedor (informativo)
-- ============================================================================
CREATE TABLE proveedor_tipos_equipo (
    id              INT NOT NULL AUTO_INCREMENT,
    proveedor_id    INT NOT NULL,
    tipo            VARCHAR(100) NOT NULL,

    PRIMARY KEY (id),
    KEY idx_proveedor (proveedor_id),
    UNIQUE KEY uk_proveedor_tipo (proveedor_id, tipo),
    CONSTRAINT fk_tipo_proveedor FOREIGN KEY (proveedor_id) REFERENCES proveedores(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- Tabla: backups_realizados
-- ============================================================================
-- Auditoria de respaldos generados (automaticos o manuales)
-- ============================================================================
CREATE TABLE backups_realizados (
    id              INT NOT NULL AUTO_INCREMENT,
    nombre_archivo  VARCHAR(255) NOT NULL,
    tamano_bytes    BIGINT NOT NULL DEFAULT 0,
    tipo            ENUM('manual', 'automatico') NOT NULL DEFAULT 'manual',
    realizado_por_id INT DEFAULT NULL COMMENT 'Null si fue automatico',
    notas           VARCHAR(255) DEFAULT NULL,
    exitoso         TINYINT(1) NOT NULL DEFAULT 1,
    mensaje_error   TEXT DEFAULT NULL,
    creado_en       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    KEY idx_creado (creado_en DESC),
    CONSTRAINT fk_backup_usuario FOREIGN KEY (realizado_por_id) REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- ALTERACIONES a tablas existentes
-- ============================================================================

-- equipos: vinculo a proveedor y datos de compra
ALTER TABLE equipos
    ADD COLUMN proveedor_id INT DEFAULT NULL AFTER area_id,
    ADD COLUMN fecha_compra DATE DEFAULT NULL AFTER proveedor_id,
    ADD COLUMN costo_compra DECIMAL(12,2) DEFAULT NULL AFTER fecha_compra,
    ADD CONSTRAINT fk_equipo_proveedor FOREIGN KEY (proveedor_id) REFERENCES proveedores(id) ON DELETE SET NULL;


-- incidencias: cuando se escala al proveedor para soporte
ALTER TABLE incidencias
    ADD COLUMN proveedor_escalado_id INT DEFAULT NULL AFTER asignado_a_id,
    ADD CONSTRAINT fk_incidencia_proveedor FOREIGN KEY (proveedor_escalado_id) REFERENCES proveedores(id) ON DELETE SET NULL;


-- usuarios: avatar y preferencias
ALTER TABLE usuarios
    ADD COLUMN avatar_url VARCHAR(255) DEFAULT NULL COMMENT 'Ruta relativa de la foto de perfil' AFTER email,
    ADD COLUMN pagina_inicio_preferida VARCHAR(100) DEFAULT 'dashboard.php' AFTER avatar_url;


-- ============================================================================
-- DATOS SEMILLA: proveedores reales de Carnes Bacal
-- ============================================================================

INSERT INTO proveedores
    (nombre, servicio, telefono, email, horario_atencion, notas, activo)
VALUES
    ('Abasteo', 'Proveedor de tecnologia', NULL, 'i.lozano@abasteo.mx',
     'Lun-Vie 9:00-18:00', 'Contacto principal: Alejandro Lozano', 1),

    ('enetSystem', 'Soporte tecnico', '664 385 4983', 'aldolinares@netsistem.com.mx',
     'Lun-Vie 9:00-18:00', 'Contacto principal: Aldo Linares', 1),

    ('Metrocarrier', 'Lineas troncales', '662 555 8912', 'dsoto@metrocarrier.com.mx',
     'Lun-Vie 9:00-18:00', 'Contacto principal: Deyanira Soto', 1),

    ('Sipcons', 'Punto de cobro y basculas', NULL, 'ernesto@sipcons.com',
     'Lun-Vie 9:00-18:00', 'Maneja dos lineas de productos: basculas y MrTienda (POS)', 1);


-- Variables para insertar contactos referenciando los proveedores recien creados
SET @id_abasteo      = (SELECT id FROM proveedores WHERE nombre = 'Abasteo');
SET @id_enetsystem   = (SELECT id FROM proveedores WHERE nombre = 'enetSystem');
SET @id_metrocarrier = (SELECT id FROM proveedores WHERE nombre = 'Metrocarrier');
SET @id_sipcons      = (SELECT id FROM proveedores WHERE nombre = 'Sipcons');


-- Contactos del proveedor Abasteo
INSERT INTO proveedor_contactos (proveedor_id, nombre, puesto, email, es_principal, orden)
VALUES (@id_abasteo, 'Alejandro Lozano', 'Contacto principal', 'i.lozano@abasteo.mx', 1, 1);


-- Contactos del proveedor enetSystem
INSERT INTO proveedor_contactos (proveedor_id, nombre, puesto, telefono, email, es_principal, orden)
VALUES (@id_enetsystem, 'Aldo Linares', 'Soporte tecnico', '664 385 4983',
        'aldolinares@netsistem.com.mx', 1, 1);


-- Contactos del proveedor Metrocarrier
INSERT INTO proveedor_contactos (proveedor_id, nombre, puesto, telefono, email, es_principal, orden)
VALUES (@id_metrocarrier, 'Deyanira Soto', 'Asesora de cuenta', '662 555 8912',
        'dsoto@metrocarrier.com.mx', 1, 1);


-- Contactos del proveedor Sipcons (dos contactos, uno por linea de producto)
INSERT INTO proveedor_contactos (proveedor_id, nombre, puesto, telefono, email, es_principal, notas, orden)
VALUES
    (@id_sipcons, 'Ernesto', 'Asesor de basculas', '664 108 6038',
     'ernesto@sipcons.com', 1, 'Linea de basculas', 1),
    (@id_sipcons, 'Soporte MrTienda', 'Soporte POS MrTienda', '664 120 9235',
     NULL, 0, 'Linea de software MrTienda (puntos de cobro)', 2);


-- Marcas y tipos de equipo que maneja cada proveedor (informativo)
INSERT INTO proveedor_tipos_equipo (proveedor_id, tipo) VALUES
    (@id_abasteo, 'PC'),
    (@id_abasteo, 'Laptop'),
    (@id_abasteo, 'Perifericos'),
    (@id_enetsystem, 'PC'),
    (@id_enetsystem, 'Impresora'),
    (@id_enetsystem, 'Red'),
    (@id_metrocarrier, 'Telefonia'),
    (@id_metrocarrier, 'Red'),
    (@id_sipcons, 'Bascula'),
    (@id_sipcons, 'Terminal POS'),
    (@id_sipcons, 'Software de cobro');


-- ============================================================================
-- Verificacion
-- ============================================================================
SELECT 'Proveedores creados:' AS info, COUNT(*) AS total FROM proveedores
UNION ALL
SELECT 'Contactos creados:', COUNT(*) FROM proveedor_contactos
UNION ALL
SELECT 'Tipos de equipo asignados:', COUNT(*) FROM proveedor_tipos_equipo;
