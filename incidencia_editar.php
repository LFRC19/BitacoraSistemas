<?php
/**
 * ============================================================================
 * incidencia_editar.php - Editar incidencia existente
 * ============================================================================
 * Formulario completo para editar todos los campos de una incidencia.
 * Registra el historial de cambios automáticamente comparando antes/después.
 * ============================================================================
 */
require_once __DIR__ . '/config/db.php';
require_once __DIR__ . '/config/auth.php';
require_once __DIR__ . '/config/helpers.php';
require_once __DIR__ . '/config/incidencias_helpers.php';

requerir_login();

$u  = usuario_actual();
$id = (int) input('id', 0);
$incidencia = $id > 0 ? cargar_incidencia($id) : null;

if (!$incidencia) {
    flash_set('error', 'Incidencia no encontrada.');
    header('Location: ' . url('bitacora.php'));
    exit;
}

if (!puede_editar_incidencia($incidencia)) {
    http_response_code(403);
    die('No tienes permiso para editar esta incidencia.');
}

$titulo_pagina = 'Editar · ' . $incidencia['folio'];
$pagina_activa = 'bitacora';

// Catálogos
$sucursales  = cat_sucursales();
$areas       = cat_areas();
$categorias  = cat_categorias_con_subs();
$tipos       = cat_tipos_trabajo();
$severidades = cat_severidades();
$estados     = cat_estados();
$origenes    = cat_origenes();
$tecnicos    = cat_tecnicos();

$errores = [];
$valores = [
    'titulo' => $incidencia['titulo'],
    'descripcion' => $incidencia['descripcion'],
    'sucursal_id' => $incidencia['sucursal_id'],
    'area_id' => $incidencia['area_id'],
    'categoria_id' => $incidencia['categoria_id'],
    'subcategoria_id' => $incidencia['subcategoria_id'],
    'tipo_trabajo_id' => $incidencia['tipo_trabajo_id'],
    'severidad_id' => $incidencia['severidad_id'],
    'estado_id' => $incidencia['estado_id'],
    'origen_reporte_id' => $incidencia['origen_reporte_id'],
    'equipo_id' => $incidencia['equipo_id'],
    'reportante_nombre' => $incidencia['reportante_nombre'],
    'reportante_puesto' => $incidencia['reportante_puesto'],
    'asignado_a_id' => $incidencia['asignado_a_id'],
    'es_reincidencia' => (int) $incidencia['es_reincidencia'],
    'incidencia_padre_id' => $incidencia['incidencia_padre_id'],
    'fecha_evento' => $incidencia['fecha_evento'] ? date('Y-m-d\TH:i', strtotime($incidencia['fecha_evento'])) : '',
    'causa_raiz' => $incidencia['causa_raiz'],
    'solucion' => $incidencia['solucion'],
    'recomendaciones' => $incidencia['recomendaciones'],
];

// ----------------------------------------------------------------------------
// Procesar POST
// ----------------------------------------------------------------------------
if (es_post()) {
    if (!csrf_valido(input('_csrf'))) {
        $errores[] = 'Token de seguridad inválido. Recarga la página.';
    } else {
        foreach ($valores as $k => $_v) {
            $valores[$k] = input($k, $valores[$k]);
        }
        $valores['es_reincidencia'] = (int) (input('es_reincidencia', 0) ? 1 : 0);

        // Validaciones
        if (trim((string) $valores['titulo']) === '')        $errores[] = 'El título es obligatorio.';
        if (trim((string) $valores['descripcion']) === '')   $errores[] = 'La descripción es obligatoria.';
        if (!$valores['sucursal_id'])                        $errores[] = 'La sucursal es obligatoria.';
        if (!$valores['area_id'])                            $errores[] = 'El área es obligatoria.';
        if (!$valores['severidad_id'])                       $errores[] = 'La severidad es obligatoria.';
        if (!$valores['estado_id'])                          $errores[] = 'El estado es obligatorio.';

        // No permitir mover de sucursal si el usuario no tiene permiso
        if (!tiene_permiso('ver_todas_sucursales')) {
            $valores['sucursal_id'] = $incidencia['sucursal_id'];
        }

        // Verificar equipo de la sucursal correcta
        if ($valores['equipo_id']) {
            $eq = db_one("SELECT sucursal_id FROM equipos WHERE id=:id", ['id' => $valores['equipo_id']]);
            if (!$eq || (int) $eq['sucursal_id'] !== (int) $valores['sucursal_id']) {
                $errores[] = 'El equipo seleccionado no pertenece a la sucursal elegida.';
            }
        }

        if (empty($errores)) {
            try {
                db()->beginTransaction();

                // Snapshot antes (los IDs como strings para comparar)
                $antes = [];
                foreach ($valores as $k => $_v) {
                    $antes[$k] = (string) ($incidencia[$k] ?? '');
                }

                // Recalcular SLA si cambió severidad o fecha_evento
                $nueva_sla = $incidencia['fecha_limite_sla'];
                if (
                    (int) $incidencia['severidad_id'] !== (int) $valores['severidad_id'] ||
                    $incidencia['fecha_evento'] !== date('Y-m-d H:i:s', strtotime($valores['fecha_evento']))
                ) {
                    $sev = db_one("SELECT sla_horas FROM severidades WHERE id=:id", ['id' => $valores['severidad_id']]);
                    if ($sev && $sev['sla_horas']) {
                        $ts = strtotime($valores['fecha_evento']) + ((int) $sev['sla_horas']) * 3600;
                        $nueva_sla = date('Y-m-d H:i:s', $ts);
                    } else {
                        $nueva_sla = null;
                    }
                }

                // Si se cambió el estado y el nuevo es final, registrar resolución
                $nuevo_estado = db_one("SELECT es_final FROM estados WHERE id=:id", ['id' => $valores['estado_id']]);
                $fecha_resolucion = $incidencia['fecha_resolucion'];
                $fecha_cierre     = $incidencia['fecha_cierre'];
                $resuelto_por_id  = $incidencia['resuelto_por_id'];

                if ($nuevo_estado && (int) $nuevo_estado['es_final'] === 1) {
                    if (!$fecha_resolucion) $fecha_resolucion = date('Y-m-d H:i:s');
                    if (!$fecha_cierre) $fecha_cierre = date('Y-m-d H:i:s');
                    if (!$resuelto_por_id) $resuelto_por_id = $u['id'];
                }

                // Si se asigna técnico por primera vez, registrar fecha_atencion
                $fecha_atencion = $incidencia['fecha_atencion'];
                if ($valores['asignado_a_id'] && !$fecha_atencion) {
                    $fecha_atencion = date('Y-m-d H:i:s');
                }

                db_exec(
                    "UPDATE incidencias SET
                        titulo = :tit, descripcion = :desc,
                        sucursal_id = :sid, area_id = :aid,
                        categoria_id = :cid, subcategoria_id = :scid,
                        tipo_trabajo_id = :ttid, severidad_id = :sevid, estado_id = :estid,
                        origen_reporte_id = :origen, equipo_id = :eqid,
                        reportante_nombre = :repn, reportante_puesto = :repp,
                        asignado_a_id = :asig,
                        es_reincidencia = :reinc, incidencia_padre_id = :padre,
                        fecha_evento = :fe, fecha_atencion = :fa,
                        fecha_resolucion = :fr, fecha_cierre = :fc,
                        fecha_limite_sla = :sla, resuelto_por_id = :res,
                        causa_raiz = :cr, solucion = :sol, recomendaciones = :rec,
                        actualizado_por_id = :auid
                     WHERE id = :id",
                    [
                        'tit' => trim((string) $valores['titulo']),
                        'desc' => trim((string) $valores['descripcion']),
                        'sid' => $valores['sucursal_id'],
                        'aid' => $valores['area_id'],
                        'cid' => $valores['categoria_id'] ?: null,
                        'scid' => $valores['subcategoria_id'] ?: null,
                        'ttid' => $valores['tipo_trabajo_id'] ?: null,
                        'sevid' => $valores['severidad_id'],
                        'estid' => $valores['estado_id'],
                        'origen' => $valores['origen_reporte_id'] ?: null,
                        'eqid' => $valores['equipo_id'] ?: null,
                        'repn' => trim((string) $valores['reportante_nombre']) ?: null,
                        'repp' => trim((string) $valores['reportante_puesto']) ?: null,
                        'asig' => $valores['asignado_a_id'] ?: null,
                        'reinc' => $valores['es_reincidencia'],
                        'padre' => $valores['incidencia_padre_id'] ?: null,
                        'fe' => date('Y-m-d H:i:s', strtotime($valores['fecha_evento'])),
                        'fa' => $fecha_atencion,
                        'fr' => $fecha_resolucion,
                        'fc' => $fecha_cierre,
                        'sla' => $nueva_sla,
                        'res' => $resuelto_por_id,
                        'cr' => trim((string) $valores['causa_raiz']) ?: null,
                        'sol' => trim((string) $valores['solucion']) ?: null,
                        'rec' => trim((string) $valores['recomendaciones']) ?: null,
                        'auid' => $u['id'],
                        'id' => $id,
                    ]
                );

                recalcular_tiempos_incidencia($id);

                // Snapshot después
                $despues = [];
                foreach ($valores as $k => $v) {
                    $despues[$k] = (string) ($v ?? '');
                }
                registrar_diferencias($id, $u['id'], $antes, $despues);

                // Adjuntos nuevos (si los hay)
                if (!empty($_FILES['adjuntos']['name'][0])) {
                    [$exitos, $errs] = procesar_adjuntos($id, $_FILES['adjuntos'], $u['id']);
                    if (count($exitos) > 0) {
                        registrar_historial($id, $u['id'], 'adjuntos_subidos', 'adjuntos', null,
                            count($exitos) . ' archivo(s)', count($exitos) . ' archivo(s) adjuntados');
                    }
                }

                db()->commit();
                registrar_auditoria('editar_incidencia', 'incidencias', $id, "Folio {$incidencia['folio']}");
                flash_set('success', 'Incidencia actualizada correctamente.');
                header('Location: ' . url('incidencia_ver.php?id=' . $id));
                exit;
            } catch (Throwable $e) {
                if (db()->inTransaction()) db()->rollBack();
                $errores[] = 'Error al guardar: ' . $e->getMessage();
            }
        }
    }
}

require_once __DIR__ . '/config/header.php';
?>

<div class="max-w-5xl mx-auto animate-fade-in" x-data="formEditar()">
    <div class="flex items-center gap-3 mb-6">
        <a href="<?= url('incidencia_ver.php?id=' . $id) ?>"
           class="p-2 rounded-lg hover:bg-zinc-100 text-zinc-500 hover:text-zinc-700">
            <i data-lucide="arrow-left" class="w-5 h-5"></i>
        </a>
        <div>
            <h2 class="font-display text-2xl font-extrabold text-zinc-900">Editar incidencia</h2>
            <p class="text-xs text-zinc-500 mt-0.5">
                <span class="font-mono font-semibold"><?= e($incidencia['folio']) ?></span> ·
                Los cambios quedan registrados en el historial.
            </p>
        </div>
    </div>

    <?php if (!empty($errores)): ?>
    <div class="mb-5 px-4 py-3 rounded-lg bg-bacal-50 border border-bacal-200 text-bacal-800 text-sm">
        <div class="font-semibold mb-1 flex items-center gap-2">
            <i data-lucide="alert-circle" class="w-4 h-4"></i> Revisa lo siguiente:
        </div>
        <ul class="list-disc list-inside space-y-0.5 text-xs">
            <?php foreach ($errores as $e): ?><li><?= e($e) ?></li><?php endforeach; ?>
        </ul>
    </div>
    <?php endif; ?>

    <form method="POST" enctype="multipart/form-data" class="space-y-5">
        <?= csrf_input() ?>

        <!-- Sección: Información básica -->
        <div class="bg-white rounded-xl border border-zinc-200 shadow-sm p-6">
            <h3 class="font-display text-base font-bold text-zinc-900 mb-4 flex items-center gap-2">
                <i data-lucide="file-text" class="w-4 h-4 text-bacal-700"></i> Información básica
            </h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="md:col-span-2">
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Título *</label>
                    <input type="text" name="titulo" required maxlength="255"
                           value="<?= e((string) $valores['titulo']) ?>"
                           class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
                </div>
                <div class="md:col-span-2">
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Descripción *</label>
                    <textarea name="descripcion" required rows="4"
                              class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700"><?= e((string) $valores['descripcion']) ?></textarea>
                </div>
                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Fecha y hora del evento *</label>
                    <input type="datetime-local" name="fecha_evento" required
                           value="<?= e((string) $valores['fecha_evento']) ?>"
                           class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
                </div>
                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Origen del reporte</label>
                    <select name="origen_reporte_id" class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
                        <option value="">— Sin especificar —</option>
                        <?php foreach ($origenes as $o): ?>
                        <option value="<?= $o['id'] ?>" <?= $valores['origen_reporte_id'] == $o['id'] ? 'selected' : '' ?>><?= e($o['nombre']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
            </div>
        </div>

        <!-- Sección: Clasificación -->
        <div class="bg-white rounded-xl border border-zinc-200 shadow-sm p-6">
            <h3 class="font-display text-base font-bold text-zinc-900 mb-4 flex items-center gap-2">
                <i data-lucide="tags" class="w-4 h-4 text-bacal-700"></i> Clasificación
            </h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Sucursal *</label>
                    <?php if (tiene_permiso('ver_todas_sucursales')): ?>
                    <select name="sucursal_id" required x-model="sucursalId" @change="cargarEquipos()"
                            class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
                        <?php foreach ($sucursales as $s): ?>
                        <option value="<?= $s['id'] ?>" <?= $valores['sucursal_id'] == $s['id'] ? 'selected' : '' ?>><?= e($s['nombre']) ?></option>
                        <?php endforeach; ?>
                    </select>
                    <?php else: ?>
                    <input type="hidden" name="sucursal_id" value="<?= $valores['sucursal_id'] ?>">
                    <div class="px-3 py-2 rounded-lg border border-zinc-200 bg-zinc-50 text-sm text-zinc-700"><?= e($incidencia['sucursal_nombre']) ?></div>
                    <?php endif; ?>
                </div>
                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Área *</label>
                    <select name="area_id" required class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
                        <?php foreach ($areas as $a): ?>
                        <option value="<?= $a['id'] ?>" <?= $valores['area_id'] == $a['id'] ? 'selected' : '' ?>><?= e($a['nombre']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Categoría</label>
                    <select name="categoria_id" x-model="categoriaId" class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
                        <option value="">— Sin especificar —</option>
                        <?php foreach ($categorias as $c): ?>
                        <option value="<?= $c['id'] ?>" <?= $valores['categoria_id'] == $c['id'] ? 'selected' : '' ?>><?= e($c['nombre']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Subcategoría</label>
                    <select name="subcategoria_id" x-model="subcategoriaId" class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
                        <option value="">— Sin especificar —</option>
                        <template x-for="sub in subcategoriasFiltradas" :key="sub.id">
                            <option :value="sub.id" x-text="sub.nombre" :selected="String(sub.id) === String(subcategoriaId)"></option>
                        </template>
                    </select>
                </div>
                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Tipo de trabajo</label>
                    <select name="tipo_trabajo_id" class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
                        <option value="">— Sin especificar —</option>
                        <?php foreach ($tipos as $t): ?>
                        <option value="<?= $t['id'] ?>" <?= $valores['tipo_trabajo_id'] == $t['id'] ? 'selected' : '' ?>><?= e($t['nombre']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Severidad *</label>
                    <select name="severidad_id" required class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
                        <?php foreach ($severidades as $s): ?>
                        <option value="<?= $s['id'] ?>" <?= $valores['severidad_id'] == $s['id'] ? 'selected' : '' ?>>
                            <?= e($s['nombre']) ?><?= $s['sla_horas'] ? " (SLA {$s['sla_horas']}h)" : '' ?>
                        </option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="md:col-span-2">
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Estado *</label>
                    <select name="estado_id" required class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
                        <?php foreach ($estados as $est): ?>
                        <option value="<?= $est['id'] ?>" <?= $valores['estado_id'] == $est['id'] ? 'selected' : '' ?>><?= e($est['nombre']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
            </div>
        </div>

        <!-- Sección: Equipo y personas -->
        <div class="bg-white rounded-xl border border-zinc-200 shadow-sm p-6">
            <h3 class="font-display text-base font-bold text-zinc-900 mb-4 flex items-center gap-2">
                <i data-lucide="monitor" class="w-4 h-4 text-bacal-700"></i> Equipo y personas
            </h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="md:col-span-2">
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Equipo / activo</label>
                    <select name="equipo_id" x-model="equipoId"
                            class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
                        <option value="">— Sin equipo específico —</option>
                        <template x-for="eq in equipos" :key="eq.id">
                            <option :value="eq.id" :selected="String(eq.id) === String(equipoId)">
                                <span x-text="eq.codigo_inventario + ' - ' + eq.nombre"></span>
                            </option>
                        </template>
                    </select>
                </div>
                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Nombre del reportante</label>
                    <input type="text" name="reportante_nombre" maxlength="150"
                           value="<?= e((string) $valores['reportante_nombre']) ?>"
                           class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
                </div>
                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Puesto del reportante</label>
                    <input type="text" name="reportante_puesto" maxlength="100"
                           value="<?= e((string) $valores['reportante_puesto']) ?>"
                           class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
                </div>
                <div class="md:col-span-2">
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Asignar a técnico</label>
                    <select name="asignado_a_id" class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
                        <option value="">— Sin asignar —</option>
                        <?php foreach ($tecnicos as $t): ?>
                        <option value="<?= $t['id'] ?>" <?= $valores['asignado_a_id'] == $t['id'] ? 'selected' : '' ?>><?= e($t['nombre_completo']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
            </div>
        </div>

        <!-- Sección: Reincidencia -->
        <div class="bg-white rounded-xl border border-zinc-200 shadow-sm p-6">
            <h3 class="font-display text-base font-bold text-zinc-900 mb-3 flex items-center gap-2">
                <i data-lucide="rotate-ccw" class="w-4 h-4 text-purple-600"></i> Reincidencia
            </h3>
            <label class="flex items-center gap-2 text-sm cursor-pointer mb-3">
                <input type="checkbox" name="es_reincidencia" value="1" <?= $valores['es_reincidencia'] ? 'checked' : '' ?>
                       class="rounded border-zinc-300 text-purple-600 focus:ring-purple-500">
                <span class="text-zinc-700">Esta incidencia es una reincidencia</span>
            </label>
            <div>
                <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Folio o ID de la incidencia original (opcional)</label>
                <input type="text" name="incidencia_padre_id"
                       value="<?= e((string) $valores['incidencia_padre_id']) ?>"
                       placeholder="ID numérico"
                       class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
            </div>
        </div>

        <!-- Sección: Resolución -->
        <div class="bg-white rounded-xl border border-zinc-200 shadow-sm p-6">
            <h3 class="font-display text-base font-bold text-zinc-900 mb-4 flex items-center gap-2">
                <i data-lucide="wrench" class="w-4 h-4 text-bacal-700"></i> Resolución
            </h3>
            <div class="space-y-4">
                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Causa raíz</label>
                    <textarea name="causa_raiz" rows="2" class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700"><?= e((string) $valores['causa_raiz']) ?></textarea>
                </div>
                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Solución aplicada</label>
                    <textarea name="solucion" rows="3" class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700"><?= e((string) $valores['solucion']) ?></textarea>
                </div>
                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Recomendaciones</label>
                    <textarea name="recomendaciones" rows="2" class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700"><?= e((string) $valores['recomendaciones']) ?></textarea>
                </div>
            </div>
        </div>

        <!-- Sección: Adjuntos nuevos -->
        <div class="bg-white rounded-xl border border-zinc-200 shadow-sm p-6">
            <h3 class="font-display text-base font-bold text-zinc-900 mb-3 flex items-center gap-2">
                <i data-lucide="paperclip" class="w-4 h-4 text-bacal-700"></i> Agregar adjuntos
            </h3>
            <p class="text-xs text-zinc-500 mb-3">Los adjuntos existentes se mantienen. Para eliminar, ve al detalle de la incidencia.</p>
            <input type="file" name="adjuntos[]" multiple
                   class="block w-full text-sm text-zinc-700 file:mr-3 file:py-1.5 file:px-3 file:rounded-lg file:border-0 file:bg-bacal-50 file:text-bacal-700 file:text-xs file:font-semibold hover:file:bg-bacal-100">
        </div>

        <div class="flex items-center justify-end gap-2">
            <a href="<?= url('incidencia_ver.php?id=' . $id) ?>"
               class="px-4 py-2 rounded-lg border border-zinc-300 text-zinc-700 font-medium text-sm hover:bg-zinc-50">Cancelar</a>
            <button type="submit"
                    class="px-5 py-2 rounded-lg bg-bacal-700 hover:bg-bacal-800 text-white font-semibold text-sm shadow-sm flex items-center gap-2">
                <i data-lucide="check" class="w-4 h-4"></i> Guardar cambios
            </button>
        </div>
    </form>
</div>

<script>
function formEditar() {
    return {
        sucursalId: '<?= e((string) $valores['sucursal_id']) ?>',
        categoriaId: '<?= e((string) $valores['categoria_id']) ?>',
        subcategoriaId: '<?= e((string) $valores['subcategoria_id']) ?>',
        equipoId: '<?= e((string) $valores['equipo_id']) ?>',
        equipos: [],
        categorias: <?= json_encode($categorias, JSON_UNESCAPED_UNICODE) ?>,

        get subcategoriasFiltradas() {
            if (!this.categoriaId) return [];
            const c = this.categorias.find(x => String(x.id) === String(this.categoriaId));
            return c ? c.subcategorias : [];
        },

        async cargarEquipos() {
            this.equipos = [];
            if (!this.sucursalId) return;
            try {
                const resp = await fetch('<?= url('api/equipos_de_sucursal.php') ?>?sucursal=' + this.sucursalId, { credentials: 'same-origin' });
                if (resp.ok) this.equipos = await resp.json();
            } catch (e) { console.error(e); }
        },

        init() { if (this.sucursalId) this.cargarEquipos(); }
    }
}
</script>

<?php require_once __DIR__ . '/config/footer.php'; ?>
