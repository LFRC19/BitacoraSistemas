-- ============================================================================
-- carnes_bacal_paso8.sql  (CORREGIDO)
-- ============================================================================
-- Tablas y datos adicionales para el Paso 8: plantillas de incidencias.
--
-- CORRECCIÓN: Se cambió INT UNSIGNED a INT para coincidir con el tipo de
-- las tablas originales del Paso 1.
-- ============================================================================

USE carnes_bacal;

-- Por si quedó parcialmente creada de un intento anterior
DROP TABLE IF EXISTS plantillas_incidencias;

-- ============================================================================
-- Tabla: plantillas_incidencias
-- ============================================================================
CREATE TABLE plantillas_incidencias (
    id              INT NOT NULL AUTO_INCREMENT,
    nombre          VARCHAR(150) NOT NULL,
    descripcion     VARCHAR(255) DEFAULT NULL COMMENT 'Para mostrar en la lista de plantillas',
    icono           VARCHAR(50) DEFAULT 'file-text' COMMENT 'Nombre del icono Lucide',
    color           VARCHAR(7) DEFAULT '#6B7280',

    -- Campos pre-rellenados al usar la plantilla
    titulo          VARCHAR(255) DEFAULT NULL,
    descripcion_inc TEXT DEFAULT NULL COMMENT 'Descripcion del problema pre-rellenada',
    area_id         INT DEFAULT NULL,
    categoria_id    INT DEFAULT NULL,
    subcategoria_id INT DEFAULT NULL,
    tipo_trabajo_id INT DEFAULT NULL,
    severidad_id    INT DEFAULT NULL,
    origen_reporte_id INT DEFAULT NULL,
    solucion_sugerida TEXT DEFAULT NULL COMMENT 'Solucion tipica para este problema',

    -- Metadatos
    usos            INT NOT NULL DEFAULT 0 COMMENT 'Veces que se ha usado esta plantilla',
    creado_por_id   INT DEFAULT NULL,
    activo          TINYINT(1) NOT NULL DEFAULT 1,
    creado_en       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    KEY idx_activo (activo),
    KEY idx_usos (usos DESC),
    CONSTRAINT fk_plantilla_area FOREIGN KEY (area_id) REFERENCES areas(id) ON DELETE SET NULL,
    CONSTRAINT fk_plantilla_categoria FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE SET NULL,
    CONSTRAINT fk_plantilla_subcategoria FOREIGN KEY (subcategoria_id) REFERENCES subcategorias(id) ON DELETE SET NULL,
    CONSTRAINT fk_plantilla_tipo FOREIGN KEY (tipo_trabajo_id) REFERENCES tipos_trabajo(id) ON DELETE SET NULL,
    CONSTRAINT fk_plantilla_severidad FOREIGN KEY (severidad_id) REFERENCES severidades(id) ON DELETE SET NULL,
    CONSTRAINT fk_plantilla_origen FOREIGN KEY (origen_reporte_id) REFERENCES origenes_reporte(id) ON DELETE SET NULL,
    CONSTRAINT fk_plantilla_creador FOREIGN KEY (creado_por_id) REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- Datos semilla: plantillas comunes
-- ============================================================================
SET @cat_hardware = (SELECT id FROM categorias WHERE nombre LIKE '%Hardware%' LIMIT 1);
SET @cat_software = (SELECT id FROM categorias WHERE nombre LIKE '%Software%' LIMIT 1);
SET @cat_red      = (SELECT id FROM categorias WHERE nombre LIKE '%Red%' OR nombre LIKE '%Internet%' LIMIT 1);
SET @cat_acceso   = (SELECT id FROM categorias WHERE nombre LIKE '%Acceso%' OR nombre LIKE '%Usuario%' LIMIT 1);
SET @cat_pos      = (SELECT id FROM categorias WHERE nombre LIKE '%Punto%' OR nombre LIKE '%POS%' LIMIT 1);

SET @area_cajas = (SELECT id FROM areas WHERE nombre LIKE '%Caja%' LIMIT 1);
SET @area_admin = (SELECT id FROM areas WHERE nombre LIKE '%Contabilidad%' OR nombre LIKE '%RH%' OR nombre LIKE '%Gerencia%' LIMIT 1);

SET @tipo_soporte    = (SELECT id FROM tipos_trabajo WHERE nombre LIKE '%Soporte%' OR nombre LIKE '%Correctivo%' LIMIT 1);
SET @tipo_preventivo = (SELECT id FROM tipos_trabajo WHERE nombre LIKE '%Preventivo%' LIMIT 1);

SET @sev_baja  = (SELECT id FROM severidades WHERE nivel = (SELECT MAX(nivel) FROM severidades) LIMIT 1);
SET @sev_media = (SELECT id FROM severidades ORDER BY nivel ASC LIMIT 1 OFFSET 1);
SET @sev_alta  = (SELECT id FROM severidades WHERE nivel = 2 LIMIT 1);
SET @sev_crit  = (SELECT id FROM severidades WHERE nivel = 1 LIMIT 1);

SET @origen_telefono = (SELECT id FROM origenes_reporte WHERE nombre LIKE '%Telef%' LIMIT 1);
SET @origen_presen   = (SELECT id FROM origenes_reporte WHERE nombre LIKE '%Presen%' LIMIT 1);

INSERT INTO plantillas_incidencias
    (nombre, descripcion, icono, color, titulo, descripcion_inc, area_id, categoria_id,
     tipo_trabajo_id, severidad_id, origen_reporte_id, solucion_sugerida)
VALUES
    ('Reset de contraseña', 'Usuario olvido su contraseña del sistema',
     'key', '#D97706',
     'Solicitud de reseteo de contraseña',
     'El usuario no puede acceder al sistema y solicita el reseteo de su contraseña.\n\nUsuario: \nMotivo: ',
     @area_admin, @cat_acceso, @tipo_soporte, @sev_baja, @origen_telefono,
     '1. Verificar identidad del usuario\n2. Resetear contraseña desde el panel admin\n3. Comunicar nueva contraseña temporal de forma segura\n4. Confirmar que el usuario pudo acceder y cambiar la contraseña'),

    ('Impresora sin tinta/toner', 'Falta consumible en impresora',
     'printer', '#7C3AED',
     'Impresora sin tinta/toner',
     'La impresora no imprime por falta de consumible.\n\nUbicacion: \nModelo: \nTipo de consumible necesario: ',
     NULL, @cat_hardware, @tipo_preventivo, @sev_media, @origen_presen,
     '1. Confirmar modelo exacto de impresora\n2. Verificar inventario de consumibles\n3. Reemplazar tinta/toner\n4. Imprimir pagina de prueba para validar'),

    ('Internet caido / lento', 'Perdida de conectividad o lentitud',
     'wifi-off', '#DC2626',
     'Sin conexion a internet',
     'Se reporta perdida total/parcial de conexion a internet.\n\nAreas afectadas: \nDispositivos afectados: \nHora aproximada del incidente: ',
     NULL, @cat_red, @tipo_soporte, @sev_alta, @origen_telefono,
     '1. Verificar luces del modem/router\n2. Reiniciar equipos de red (apagar 30 segundos)\n3. Verificar cableado fisico\n4. Contactar al proveedor si persiste\n5. Documentar tiempo de inactividad'),

    ('Falla en terminal POS', 'Terminal/caja registradora no funciona',
     'monitor-x', '#DC2626',
     'Falla en terminal de punto de venta',
     'La terminal de punto de venta presenta fallas.\n\nCaja: \nSintoma especifico: \nUltima operacion exitosa: ',
     @area_cajas, @cat_pos, @tipo_soporte, @sev_crit, @origen_telefono,
     '1. Verificar conexiones fisicas\n2. Reiniciar la terminal\n3. Validar conexion con servidor central\n4. Si persiste, habilitar caja de respaldo y escalar'),

    ('Bascula descalibrada', 'Bascula marca peso incorrecto',
     'scale', '#EA580C',
     'Bascula descalibrada o con error de pesaje',
     'La bascula presenta lecturas incorrectas o erraticas.\n\nUbicacion: \nModelo: \nMargen de error observado: ',
     NULL, @cat_hardware, @tipo_preventivo, @sev_media, @origen_presen,
     '1. Limpiar el plato y sensor\n2. Verificar nivelacion de la bascula\n3. Calibrar con pesa patron\n4. Si no calibra, agendar servicio tecnico especializado'),

    ('PC lenta o con problemas', 'Equipo de computo con bajo rendimiento',
     'cpu', '#0EA5E9',
     'Computadora con rendimiento lento',
     'La PC presenta lentitud para realizar tareas normales.\n\nUbicacion: \nUsuario: \nSintomas especificos: ',
     NULL, @cat_hardware, @tipo_soporte, @sev_baja, @origen_telefono,
     '1. Revisar uso de CPU/RAM en administrador de tareas\n2. Limpieza de archivos temporales\n3. Escaneo antivirus\n4. Verificar inicio automatico de programas\n5. Si persiste, evaluar mantenimiento preventivo'),

    ('Email no funciona', 'Problema con correo electronico corporativo',
     'mail-x', '#7C3AED',
     'Falla en correo electronico',
     'No se puede enviar/recibir correos.\n\nUsuario: \nCliente de correo: \nMensaje de error: ',
     NULL, @cat_software, @tipo_soporte, @sev_media, @origen_telefono,
     '1. Verificar conectividad a internet\n2. Probar acceso por webmail\n3. Revisar configuracion SMTP/IMAP\n4. Verificar espacio en buzon\n5. Validar credenciales'),

    ('Mantenimiento preventivo programado', 'Mantenimiento preventivo de rutina',
     'wrench', '#16A34A',
     'Mantenimiento preventivo programado',
     'Mantenimiento preventivo programado para mantener equipos en optimas condiciones.\n\nEquipo(s): \nTareas planeadas: ',
     NULL, @cat_hardware, @tipo_preventivo, @sev_baja, @origen_presen,
     '1. Limpieza interna y externa de equipos\n2. Verificacion de software actualizado\n3. Backup de informacion critica\n4. Pruebas de funcionamiento\n5. Documentar estado de cada componente');

-- ============================================================================
-- Verificacion
-- ============================================================================
SELECT COUNT(*) AS total_plantillas FROM plantillas_incidencias;
