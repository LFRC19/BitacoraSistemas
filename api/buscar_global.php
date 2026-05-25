<?php
/**
 * ============================================================================
 * api/buscar_global.php
 * ============================================================================
 * Búsqueda global con resultados agrupados por tipo.
 * Busca en: incidencias (folio, título, descripción), equipos (código, nombre),
 *           usuarios, base de conocimiento.
 *
 * Respeta permisos: solo muestra incidencias/equipos de la sucursal del usuario
 * a menos que tenga permiso de ver_todas_sucursales.
 * ============================================================================
 */
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
require_once __DIR__ . '/../config/helpers.php';

requerir_login();
header('Content-Type: application/json; charset=utf-8');

$q = trim((string) input('q', ''));
if (mb_strlen($q) < 2) {
    echo json_encode(['ok' => true, 'q' => $q, 'grupos' => []]);
    exit;
}

$u = usuario_actual();
$ver_todas = tiene_permiso('ver_todas_sucursales');
$ver_kb = tiene_permiso('administrar') || (int) ($u['sucursal_id'] ?? 0) > 0; // todos los logueados

$like = '%' . $q . '%';
$resultados = ['incidencias' => [], 'equipos' => [], 'usuarios' => [], 'kb' => []];

// ============================================================================
// INCIDENCIAS
// ============================================================================
try {
    $where_suc = $ver_todas ? '' : 'AND i.sucursal_id = :sid';
    $params = ['q1' => $like, 'q2' => $like, 'q3' => $like];
    if (!$ver_todas) $params['sid'] = (int) $u['sucursal_id'];

    $resultados['incidencias'] = db_all(
        "SELECT i.id, i.folio, i.titulo, i.creado_en, i.archivada,
                est.nombre AS estado_nombre, est.color AS estado_color, est.es_final,
                s.codigo AS sucursal_codigo,
                sv.nombre AS severidad_nombre, sv.color AS severidad_color
         FROM incidencias i
         INNER JOIN estados est ON i.estado_id = est.id
         INNER JOIN sucursales s ON i.sucursal_id = s.id
         INNER JOIN severidades sv ON i.severidad_id = sv.id
         WHERE (i.folio LIKE :q1 OR i.titulo LIKE :q2 OR i.descripcion LIKE :q3)
           $where_suc
         ORDER BY i.archivada ASC, i.creado_en DESC
         LIMIT 8",
        $params
    );
} catch (Throwable $e) {
    // si falla un grupo, no rompemos toda la búsqueda
}

// ============================================================================
// EQUIPOS
// ============================================================================
try {
    $where_suc = $ver_todas ? '' : 'AND e.sucursal_id = :sid';
    $params = ['q1' => $like, 'q2' => $like, 'q3' => $like];
    if (!$ver_todas) $params['sid'] = (int) $u['sucursal_id'];

    $resultados['equipos'] = db_all(
        "SELECT e.id, e.codigo_inventario, e.nombre, e.tipo, e.estado_vida,
                s.codigo AS sucursal_codigo,
                a.nombre AS area_nombre
         FROM equipos e
         LEFT JOIN sucursales s ON e.sucursal_id = s.id
         LEFT JOIN areas a ON e.area_id = a.id
         WHERE (e.codigo_inventario LIKE :q1 OR e.nombre LIKE :q2 OR e.numero_serie LIKE :q3)
           AND e.activo = 1
           $where_suc
         ORDER BY e.nombre ASC
         LIMIT 6",
        $params
    );
} catch (Throwable $e) {}

// ============================================================================
// USUARIOS (solo admin)
// ============================================================================
if (tiene_permiso('administrar')) {
    try {
        $resultados['usuarios'] = db_all(
            "SELECT u.id, u.usuario, u.nombre_completo, u.email, u.avatar_url, u.activo,
                    r.nombre AS rol_nombre,
                    s.codigo AS sucursal_codigo
             FROM usuarios u
             LEFT JOIN roles r ON u.rol_id = r.id
             LEFT JOIN sucursales s ON u.sucursal_id = s.id
             WHERE (u.usuario LIKE :q1 OR u.nombre_completo LIKE :q2 OR u.email LIKE :q3)
             ORDER BY u.activo DESC, u.nombre_completo ASC
             LIMIT 5",
            ['q1' => $like, 'q2' => $like, 'q3' => $like]
        );
    } catch (Throwable $e) {}
}

// ============================================================================
// BASE DE CONOCIMIENTO
// ============================================================================
if ($ver_kb) {
    try {
        // Verificar que la tabla exista (puede no estar en algunas instalaciones)
        $tabla = db_one("SHOW TABLES LIKE 'kb_articulos'");
        if ($tabla) {
            $resultados['kb'] = db_all(
                "SELECT id, titulo, resumen, slug
                 FROM kb_articulos
                 WHERE activo = 1 AND (titulo LIKE :q1 OR resumen LIKE :q2 OR contenido LIKE :q3)
                 ORDER BY actualizado_en DESC
                 LIMIT 5",
                ['q1' => $like, 'q2' => $like, 'q3' => $like]
            );
        }
    } catch (Throwable $e) {}
}

// ============================================================================
// Construir respuesta agrupada
// ============================================================================
$grupos = [];

if (!empty($resultados['incidencias'])) {
    $items = [];
    foreach ($resultados['incidencias'] as $r) {
        $items[] = [
            'tipo' => 'incidencia',
            'titulo' => $r['folio'] . ' · ' . $r['titulo'],
            'subtitulo' => $r['estado_nombre'] . ' · ' . $r['sucursal_codigo'] . ' · ' . fmt_tiempo_relativo($r['creado_en']) .
                          ((int) $r['archivada'] === 1 ? ' · 📦 Archivada' : ''),
            'badge' => $r['severidad_nombre'],
            'badge_color' => $r['severidad_color'],
            'url' => url_relativa('incidencia_ver.php?id=' . $r['id']),
            'icono' => 'alert-circle',
        ];
    }
    $grupos[] = ['nombre' => 'Incidencias', 'icono' => 'clipboard-list', 'items' => $items];
}

if (!empty($resultados['equipos'])) {
    $items = [];
    foreach ($resultados['equipos'] as $r) {
        $color_estado = match ($r['estado_vida']) {
            'en_uso' => '#16A34A',
            'en_mantenimiento' => '#F59E0B',
            'baja' => '#71717a',
            default => '#0EA5E9',
        };
        $items[] = [
            'tipo' => 'equipo',
            'titulo' => $r['codigo_inventario'] . ' · ' . $r['nombre'],
            'subtitulo' => ($r['tipo'] ?: 'Equipo') . ' · ' . ($r['sucursal_codigo'] ?? '?') .
                          ($r['area_nombre'] ? ' · ' . $r['area_nombre'] : ''),
            'badge' => $r['estado_vida'],
            'badge_color' => $color_estado,
            'url' => url_relativa('equipo_ver.php?id=' . $r['id']),
            'icono' => 'monitor',
        ];
    }
    $grupos[] = ['nombre' => 'Equipos', 'icono' => 'monitor', 'items' => $items];
}

if (!empty($resultados['usuarios'])) {
    $items = [];
    foreach ($resultados['usuarios'] as $r) {
        $items[] = [
            'tipo' => 'usuario',
            'titulo' => $r['nombre_completo'],
            'subtitulo' => '@' . $r['usuario'] . ' · ' . ($r['rol_nombre'] ?? '?') .
                          ($r['sucursal_codigo'] ? ' · ' . $r['sucursal_codigo'] : ''),
            'badge' => (int) $r['activo'] === 1 ? null : 'INACTIVO',
            'badge_color' => '#71717a',
            'url' => url_relativa('admin/usuarios.php?accion=editar&id=' . $r['id']),
            'icono' => 'user',
        ];
    }
    $grupos[] = ['nombre' => 'Usuarios', 'icono' => 'users', 'items' => $items];
}

if (!empty($resultados['kb'])) {
    $items = [];
    foreach ($resultados['kb'] as $r) {
        $items[] = [
            'tipo' => 'kb',
            'titulo' => $r['titulo'],
            'subtitulo' => $r['resumen'] ?: 'Artículo de base de conocimiento',
            'badge' => null,
            'badge_color' => null,
            'url' => url_relativa('kb_articulo.php?slug=' . urlencode($r['slug'])),
            'icono' => 'book-open',
        ];
    }
    $grupos[] = ['nombre' => 'Base de conocimiento', 'icono' => 'book-open', 'items' => $items];
}

echo json_encode([
    'ok' => true,
    'q' => $q,
    'grupos' => $grupos,
    'total' => array_sum(array_map(fn($g) => count($g['items']), $grupos)),
], JSON_UNESCAPED_UNICODE);
