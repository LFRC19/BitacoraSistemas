<?php
/**
 * ============================================================================
 * config/helpers.php - Funciones comunes del sistema
 * ============================================================================
 */

/**
 * Escapa texto para mostrar en HTML de forma segura.
 */
function e(?string $texto): string {
    return htmlspecialchars($texto ?? '', ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

/**
 * Genera una URL relativa al sistema.
 */
function url(string $ruta = ''): string {
    return rtrim(APP_URL, '/') . '/' . ltrim($ruta, '/');
}

/**
 * Devuelve un valor de $_POST o $_GET con valor por defecto.
 */
function input(string $clave, $default = null) {
    if (isset($_POST[$clave])) return $_POST[$clave];
    if (isset($_GET[$clave])) return $_GET[$clave];
    return $default;
}

/**
 * Verifica si la petición es POST.
 */
function es_post(): bool {
    return ($_SERVER['REQUEST_METHOD'] ?? '') === 'POST';
}

/**
 * Genera un token CSRF para formularios.
 */
function csrf_token(): string {
    if (empty($_SESSION['csrf_token'])) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['csrf_token'];
}

/**
 * Valida un token CSRF recibido.
 */
function csrf_valido(?string $token): bool {
    return !empty($_SESSION['csrf_token'])
        && !empty($token)
        && hash_equals($_SESSION['csrf_token'], $token);
}

/**
 * Devuelve un input hidden con el token CSRF para los formularios.
 */
function csrf_input(): string {
    return '<input type="hidden" name="_csrf" value="' . csrf_token() . '">';
}

/**
 * Mensaje flash (se muestra una vez y se borra).
 */
function flash_set(string $tipo, string $mensaje): void {
    $_SESSION['flash'][] = ['tipo' => $tipo, 'mensaje' => $mensaje];
}

function flash_get(): array {
    $f = $_SESSION['flash'] ?? [];
    unset($_SESSION['flash']);
    return $f;
}

/**
 * Formatea una fecha (datetime) en formato amigable.
 */
function fmt_fecha(?string $fecha, bool $con_hora = true): string {
    if (!$fecha) return '—';
    $ts = strtotime($fecha);
    if (!$ts) return '—';
    $meses = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
    $mes = $meses[(int)date('n', $ts) - 1];
    return date('d', $ts) . ' ' . $mes . ' ' . date('Y', $ts) .
           ($con_hora ? ', ' . date('H:i', $ts) : '');
}

/**
 * Tiempo relativo legible: "hace 5 minutos", "hace 2 horas", etc.
 */
function fmt_tiempo_relativo(?string $fecha): string {
    if (!$fecha) return '—';
    $diff = time() - strtotime($fecha);
    if ($diff < 60)         return 'hace un momento';
    if ($diff < 3600)       return 'hace ' . floor($diff / 60) . ' min';
    if ($diff < 86400)      return 'hace ' . floor($diff / 3600) . ' h';
    if ($diff < 2592000)    return 'hace ' . floor($diff / 86400) . ' días';
    return fmt_fecha($fecha, false);
}

/**
 * Convierte minutos a formato legible: "2h 15min", "45 min", etc.
 */
function fmt_duracion(?int $minutos): string {
    if ($minutos === null) return '—';
    if ($minutos < 60) return $minutos . ' min';
    $h = intdiv($minutos, 60);
    $m = $minutos % 60;
    return $h . 'h' . ($m > 0 ? " {$m}min" : '');
}

/**
 * Genera un badge HTML con color de fondo (estilo Notion).
 */
function badge(?string $texto, ?string $color = '#6B7280', string $clase_extra = ''): string {
    if (!$texto) return '—';
    $color = $color ?: '#6B7280';
    $texto = e($texto);
    // Fondo semi-transparente, texto del color sólido para legibilidad
    return "<span class='inline-flex items-center px-2.5 py-0.5 rounded-md text-xs font-medium {$clase_extra}'
                  style='background-color: {$color}1f; color: {$color}; border: 1px solid {$color}40;'>{$texto}</span>";
}

/**
 * Genera el siguiente folio para una incidencia.
 * Formato: INC-{CODIGO_SUCURSAL}-{AÑO}-{CONSECUTIVO}
 * Ejemplo: INC-BAC-2026-0042
 */
function generar_folio(int $sucursal_id): string {
    $sucursal = db_one("SELECT codigo FROM sucursales WHERE id = :id", ['id' => $sucursal_id]);
    $codigo = $sucursal ? $sucursal['codigo'] : 'GEN';
    $anio = date('Y');

    $row = db_one(
        "SELECT COUNT(*) AS n FROM incidencias
         WHERE sucursal_id = :sid AND YEAR(creado_en) = :anio",
        ['sid' => $sucursal_id, 'anio' => $anio]
    );
    $consecutivo = str_pad((string)((int)$row['n'] + 1), 4, '0', STR_PAD_LEFT);
    return "INC-{$codigo}-{$anio}-{$consecutivo}";
}

/**
 * Detecta posibles reincidencias.
 * Busca incidencias similares en los últimos N días con misma área/equipo/categoría.
 */
function detectar_reincidencias(int $area_id, ?int $equipo_id, ?int $categoria_id, int $dias = 30): array {
    $sql = "SELECT i.id, i.folio, i.titulo, i.fecha_evento, i.solucion,
                   e.nombre AS estado_nombre, e.color AS estado_color
            FROM incidencias i
            INNER JOIN estados e ON i.estado_id = e.id
            WHERE i.fecha_evento >= DATE_SUB(NOW(), INTERVAL :dias DAY)
              AND i.area_id = :aid";
    $params = ['dias' => $dias, 'aid' => $area_id];

    if ($equipo_id) {
        $sql .= " AND i.equipo_id = :eid";
        $params['eid'] = $equipo_id;
    }
    if ($categoria_id) {
        $sql .= " AND i.categoria_id = :cid";
        $params['cid'] = $categoria_id;
    }

    $sql .= " ORDER BY i.fecha_evento DESC LIMIT 10";
    return db_all($sql, $params);
}

/**
 * Devuelve las iniciales de un nombre completo (para avatares).
 */
function iniciales(string $nombre): string {
    $partes = preg_split('/\s+/', trim($nombre));
    $a = $partes[0][0] ?? '';
    $b = '';
    if (count($partes) > 1) {
        $b = $partes[1][0] ?? '';
    }
    return strtoupper($a . $b);
}

/**
 * Genera un color de fondo determinístico basado en un string (para avatares).
 * Garantiza siempre devolver un color válido, incluso con texto vacío o caracteres especiales.
 */
function color_avatar(?string $texto): string {
    $colores = ['#DC2626','#EA580C','#D97706','#16A34A','#0EA5E9','#2563EB','#7C3AED','#9333EA','#DB2777'];

    // Si el texto está vacío o es null, devolver un color por defecto
    $texto = trim((string) $texto);
    if ($texto === '') {
        return $colores[0];
    }

    // crc32 siempre devuelve un entero positivo de 32 bits, sin overflow
    $hash = crc32($texto);
    $indice = $hash % count($colores);
    return $colores[$indice];
}