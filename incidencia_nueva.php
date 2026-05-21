<?php
/**
 * ============================================================================
 * incidencia_nueva.php - Crear nueva incidencia
 * ============================================================================
 * Formulario para registrar una incidencia con:
 *   - Selección de sucursal/área/equipo (equipos se filtran por sucursal)
 *   - Detección automática de reincidencias en tiempo real (Alpine + fetch)
 *   - Severidad con cálculo automático de SLA
 *   - Subida de múltiples adjuntos
 *   - Pre-rellenado opcional: ?duplicar_de=ID para crear basado en otra
 * ============================================================================
 */
require_once __DIR__ . '/config/db.php';
require_once __DIR__ . '/config/auth.php';
require_once __DIR__ . '/config/helpers.php';
require_once __DIR__ . '/config/incidencias_helpers.php';

requerir_login();

$u = usuario_actual();
if (!tiene_permiso('crear_solicitud')) {
    http_response_code(403);
    die('No tienes permiso para crear incidencias.');
}

$titulo_pagina = 'Nueva incidencia';
$pagina_activa = 'nueva';

// ----------------------------------------------------------------------------
// Catálogos
// ----------------------------------------------------------------------------
$sucursales  = cat_sucursales();
$areas       = cat_areas();
$categorias  = cat_categorias_con_subs();
$tipos       = cat_tipos_trabajo();
$severidades = cat_severidades();
$origenes    = cat_origenes();
$tecnicos    = cat_tecnicos();

// Estado inicial
$estado_inicial = db_one("SELECT id FROM estados WHERE es_inicial=1 AND activo=1 LIMIT 1");
$estado_inicial_id = $estado_inicial ? (int) $estado_inicial['id'] : null;

// ----------------------------------------------------------------------------
// Valores por defecto: ya sea de duplicar o vacíos
// ----------------------------------------------------------------------------
$default = [
    'titulo' => '', 'descripcion' => '',
    'sucursal_id' => $u['sucursal_id'] ?? '',
    'area_id' => $u['area_id'] ?? '',
    'categoria_id' => '', 'subcategoria_id' => '',
    'tipo_trabajo_id' => '', 'severidad_id' => '',
    'origen_reporte_id' => '', 'equipo_id' => '',
    'reportante_nombre' => '', 'reportante_puesto' => '',
    'asignado_a_id' => '',
    'es_reincidencia' => 0, 'incidencia_padre_id' => '',
    'fecha_evento' => date('Y-m-d\TH:i'),
    'causa_raiz' => '', 'solucion' => '', 'recomendaciones' => '',
];

$duplicar_de = (int) input('duplicar_de', 0);
if ($duplicar_de > 0) {
    $orig = cargar_incidencia($duplicar_de);
    if ($orig && puede_ver_incidencia($orig)) {
        $default = array_merge($default, [
            'titulo' => $orig['titulo'],
            'descripcion' => $orig['descripcion'],
            'sucursal_id' => $orig['sucursal_id'],
            'area_id' => $orig['area_id'],
            'categoria_id' => $orig['categoria_id'],
            'tipo_trabajo_id' => $orig['tipo_trabajo_id'],
            'severidad_id' => $orig['severidad_id'],
            'equipo_id' => $orig['equipo_id'],
            'es_reincidencia' => 1,
            'incidencia_padre_id' => $orig['id'],
        ]);
    }
}

$errores = [];
$valores = $default;

// ----------------------------------------------------------------------------
// PROCESAR FORMULARIO (POST)
// ----------------------------------------------------------------------------
if (es_post()) {
    if (!csrf_valido(input('_csrf'))) {
        $errores[] = 'Token de seguridad inválido. Recarga la página.';
    } else {
        // Capturar valores
        foreach ($default as $k => $_v) {
            $valores[$k] = input($k, $default[$k]);
        }
        $valores['es_reincidencia'] = (int) (input('es_reincidencia', 0) ? 1 : 0);

        // Validaciones obligatorias
        if (trim((string) $valores['titulo']) === '')
            $errores[] = 'El título es obligatorio.';
        if (trim((string) $valores['descripcion']) === '')
            $errores[] = 'La descripción es obligatoria.';
        if (!$valores['sucursal_id'])
            $errores[] = 'La sucursal es obligatoria.';
        if (!$valores['area_id'])
            $errores[] = 'El área es obligatoria.';
        if (!$valores['severidad_id'])
            $errores[] = 'La severidad es obligatoria.';
        if (!$valores['fecha_evento'])
            $errores[] = 'La fecha del evento es obligatoria.';

        // Si no es admin/ingeniero, forzar su sucursal
        if (!tiene_permiso('ver_todas_sucursales') && $u['sucursal_id']) {
            $valores['sucursal_id'] = (int) $u['sucursal_id'];
        }

        // Verificar que el equipo (si se eligió) pertenezca a la sucursal
        if ($valores['equipo_id']) {
            $eq = db_one("SELECT sucursal_id FROM equipos WHERE id=:id", ['id' => $valores['equipo_id']]);
            if (!$eq || (int) $eq['sucursal_id'] !== (int) $valores['sucursal_id']) {
                $errores[] = 'El equipo seleccionado no pertenece a la sucursal elegida.';
            }
        }

        if (empty($errores)) {
            try {
                db()->beginTransaction();

                // Generar folio
                $folio = generar_folio((int) $valores['sucursal_id']);

                // Calcular fecha límite SLA
                $sev = db_one("SELECT sla_horas FROM severidades WHERE id=:id", ['id' => $valores['severidad_id']]);
                $fecha_limite_sla = null;
                if ($sev && $sev['sla_horas']) {
                    $ts = strtotime($valores['fecha_evento']) + ((int) $sev['sla_horas']) * 3600;
                    $fecha_limite_sla = date('Y-m-d H:i:s', $ts);
                }

                // Si hay técnico asignado, registrar fecha_atencion = ahora
                $fecha_atencion = null;
                if ($valores['asignado_a_id']) {
                    $fecha_atencion = date('Y-m-d H:i:s');
                }

                // Insertar
                db_exec(
                    "INSERT INTO incidencias
                     (folio, titulo, descripcion, sucursal_id, area_id, categoria_id, subcategoria_id,
                      tipo_trabajo_id, severidad_id, estado_id, origen_reporte_id, equipo_id,
                      reportado_por_id, reportante_nombre, reportante_puesto, asignado_a_id,
                      es_reincidencia, incidencia_padre_id,
                      fecha_evento, fecha_atencion, fecha_limite_sla,
                      causa_raiz, solucion, recomendaciones,
                      creado_por_id)
                     VALUES
                     (:folio, :tit, :desc, :sid, :aid, :cid, :scid,
                      :ttid, :sevid, :estid, :origen, :eqid,
                      :rep, :repn, :repp, :asig,
                      :reinc, :padre,
                      :fe, :fa, :sla,
                      :cr, :sol, :rec,
                      :crid)",
                    [
                        'folio' => $folio,
                        'tit' => trim((string) $valores['titulo']),
                        'desc' => trim((string) $valores['descripcion']),
                        'sid' => $valores['sucursal_id'],
                        'aid' => $valores['area_id'],
                        'cid' => $valores['categoria_id'] ?: null,
                        'scid' => $valores['subcategoria_id'] ?: null,
                        'ttid' => $valores['tipo_trabajo_id'] ?: null,
                        'sevid' => $valores['severidad_id'],
                        'estid' => $estado_inicial_id,
                        'origen' => $valores['origen_reporte_id'] ?: null,
                        'eqid' => $valores['equipo_id'] ?: null,
                        'rep' => $u['id'],
                        'repn' => trim((string) $valores['reportante_nombre']) ?: null,
                        'repp' => trim((string) $valores['reportante_puesto']) ?: null,
                        'asig' => $valores['asignado_a_id'] ?: null,
                        'reinc' => $valores['es_reincidencia'],
                        'padre' => $valores['incidencia_padre_id'] ?: null,
                        'fe' => date('Y-m-d H:i:s', strtotime($valores['fecha_evento'])),
                        'fa' => $fecha_atencion,
                        'sla' => $fecha_limite_sla,
                        'cr' => trim((string) $valores['causa_raiz']) ?: null,
                        'sol' => trim((string) $valores['solucion']) ?: null,
                        'rec' => trim((string) $valores['recomendaciones']) ?: null,
                        'crid' => $u['id'],
                    ]
                );
                $incidencia_id = db_last_id();

                // Registrar tiempos
                recalcular_tiempos_incidencia($incidencia_id);

                // Procesar adjuntos
                $errores_adjuntos = [];
                if (!empty($_FILES['adjuntos']['name'][0])) {
                    [$exitos, $errores_adjuntos] = procesar_adjuntos($incidencia_id, $_FILES['adjuntos'], $u['id']);
                    if (count($exitos) > 0) {
                        registrar_historial(
                            $incidencia_id, $u['id'], 'adjuntos_subidos', 'adjuntos',
                            null, count($exitos) . ' archivo(s)',
                            count($exitos) . ' archivo(s) adjuntados al crear'
                        );
                    }
                }

                // Si está marcada como reincidencia, actualizar contador en la padre
                if ($valores['es_reincidencia'] && $valores['incidencia_padre_id']) {
                    db_exec(
                        "UPDATE incidencias
                         SET veces_recurrida = veces_recurrida + 1
                         WHERE id = :id",
                        ['id' => $valores['incidencia_padre_id']]
                    );
                }

                // Historial inicial
                registrar_historial(
                    $incidencia_id, $u['id'], 'creada', null, null, $folio,
                    "Incidencia creada con folio $folio"
                );

                db()->commit();
                registrar_auditoria('crear_incidencia', 'incidencias', $incidencia_id, "Folio $folio");

                $msg = "Incidencia $folio creada correctamente.";
                if (!empty($errores_adjuntos)) {
                    $msg .= " Hubo problemas con algunos adjuntos: " . implode(' ', $errores_adjuntos);
                    flash_set('warning', $msg);
                } else {
                    flash_set('success', $msg);
                }

                header('Location: ' . url('incidencia_ver.php?id=' . $incidencia_id));
                exit;
            } catch (Throwable $e) {
                if (db()->inTransaction()) db()->rollBack();
                $errores[] = 'Error al guardar: ' . $e->getMessage();
            }
        }
    }
}

// ----------------------------------------------------------------------------
// Renderizar
// ----------------------------------------------------------------------------
require_once __DIR__ . '/config/header.php';
?>

<div class="max-w-5xl mx-auto animate-fade-in"
     x-data="formIncidencia()">

    <!-- Header -->
    <div class="flex items-center gap-3 mb-6">
        <a href="<?= url('bitacora.php') ?>"
           class="p-2 rounded-lg hover:bg-zinc-100 text-zinc-500 hover:text-zinc-700">
            <i data-lucide="arrow-left" class="w-5 h-5"></i>
        </a>
        <div>
            <h2 class="font-display text-2xl font-extrabold text-zinc-900">Nueva incidencia</h2>
            <p class="text-xs text-zinc-500 mt-0.5">Completa los datos para registrar el evento. Los campos con * son obligatorios.</p>
        </div>
    </div>

    <?php if (!empty($errores)): ?>
    <div class="mb-5 px-4 py-3 rounded-lg bg-bacal-50 border border-bacal-200 text-bacal-800 text-sm">
        <div class="font-semibold mb-1 flex items-center gap-2">
            <i data-lucide="alert-circle" class="w-4 h-4"></i> Revisa lo siguiente:
        </div>
        <ul class="list-disc list-inside space-y-0.5 text-xs">
            <?php foreach ($errores as $e): ?>
            <li><?= e($e) ?></li>
            <?php endforeach; ?>
        </ul>
    </div>
    <?php endif; ?>

    <form method="POST" enctype="multipart/form-data" class="space-y-5" x-ref="formulario">
        <?= csrf_input() ?>
        <input type="hidden" name="incidencia_padre_id" :value="incidenciaPadreId" x-model="incidenciaPadreId">
        <input type="hidden" name="es_reincidencia" :value="esReincidencia ? 1 : 0">

        <!-- Sección 1: Información básica -->
        <div class="bg-white rounded-xl border border-zinc-200 shadow-sm p-6">
            <h3 class="font-display text-base font-bold text-zinc-900 mb-4 flex items-center gap-2">
                <i data-lucide="file-text" class="w-4 h-4 text-bacal-700"></i> Información básica
            </h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="md:col-span-2">
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Título *</label>
                    <input type="text" name="titulo" required maxlength="255"
                           value="<?= e((string) $valores['titulo']) ?>"
                           placeholder="Ej. Falla en impresora de tickets caja 2"
                           class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700 focus:ring-2 focus:ring-bacal-100">
                </div>

                <div class="md:col-span-2">
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Descripción detallada *</label>
                    <textarea name="descripcion" required rows="4"
                              placeholder="Describe qué pasó, cuándo lo notaron, qué intentaron, qué impacto está teniendo, etc."
                              class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700 focus:ring-2 focus:ring-bacal-100"><?= e((string) $valores['descripcion']) ?></textarea>
                </div>

                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Fecha y hora del evento *</label>
                    <input type="datetime-local" name="fecha_evento" required
                           value="<?= e((string) $valores['fecha_evento']) ?>"
                           class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700 focus:ring-2 focus:ring-bacal-100">
                </div>

                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Origen del reporte</label>
                    <select name="origen_reporte_id"
                            class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
                        <option value="">— Sin especificar —</option>
                        <?php foreach ($origenes as $o): ?>
                        <option value="<?= $o['id'] ?>" <?= $valores['origen_reporte_id'] == $o['id'] ? 'selected' : '' ?>>
                            <?= e($o['nombre']) ?>
                        </option>
                        <?php endforeach; ?>
                    </select>
                </div>
            </div>
        </div>

        <!-- Sección 2: Clasificación -->
        <div class="bg-white rounded-xl border border-zinc-200 shadow-sm p-6">
            <h3 class="font-display text-base font-bold text-zinc-900 mb-4 flex items-center gap-2">
                <i data-lucide="tags" class="w-4 h-4 text-bacal-700"></i> Clasificación
            </h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">

                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Sucursal *</label>
                    <?php if (tiene_permiso('ver_todas_sucursales')): ?>
                    <select name="sucursal_id" required x-model="sucursalId"
                            @change="cargarEquipos(); buscarReincidencias()"
                            class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
                        <option value="">— Selecciona —</option>
                        <?php foreach ($sucursales as $s): ?>
                        <option value="<?= $s['id'] ?>" <?= $valores['sucursal_id'] == $s['id'] ? 'selected' : '' ?>>
                            <?= e($s['nombre']) ?>
                        </option>
                        <?php endforeach; ?>
                    </select>
                    <?php else:
                        $s_actual = db_one("SELECT id, nombre FROM sucursales WHERE id=:id", ['id' => $u['sucursal_id']]);
                    ?>
                    <input type="hidden" name="sucursal_id" value="<?= $u['sucursal_id'] ?>" x-init="sucursalId = '<?= $u['sucursal_id'] ?>'; cargarEquipos()">
                    <div class="px-3 py-2 rounded-lg border border-zinc-200 bg-zinc-50 text-sm text-zinc-700">
                        <?= e($s_actual['nombre'] ?? 'Tu sucursal') ?>
                    </div>
                    <?php endif; ?>
                </div>

                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Área *</label>
                    <select name="area_id" required x-model="areaId" @change="buscarReincidencias()"
                            class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
                        <option value="">— Selecciona —</option>
                        <?php foreach ($areas as $a): ?>
                        <option value="<?= $a['id'] ?>" <?= $valores['area_id'] == $a['id'] ? 'selected' : '' ?>>
                            <?= e($a['nombre']) ?>
                        </option>
                        <?php endforeach; ?>
                    </select>
                </div>

                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Categoría</label>
                    <select name="categoria_id" x-model="categoriaId" @change="buscarReincidencias()"
                            class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
                        <option value="">— Selecciona —</option>
                        <?php foreach ($categorias as $c): ?>
                        <option value="<?= $c['id'] ?>" <?= $valores['categoria_id'] == $c['id'] ? 'selected' : '' ?>>
                            <?= e($c['nombre']) ?>
                        </option>
                        <?php endforeach; ?>
                    </select>
                </div>

                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Subcategoría</label>
                    <select name="subcategoria_id" x-model="subcategoriaId"
                            class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
                        <option value="">— Sin especificar —</option>
                        <template x-for="sub in subcategoriasFiltradas" :key="sub.id">
                            <option :value="sub.id" x-text="sub.nombre" :selected="String(sub.id) === String(subcategoriaId)"></option>
                        </template>
                    </select>
                </div>

                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Tipo de trabajo</label>
                    <select name="tipo_trabajo_id"
                            class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
                        <option value="">— Sin especificar —</option>
                        <?php foreach ($tipos as $t): ?>
                        <option value="<?= $t['id'] ?>" <?= $valores['tipo_trabajo_id'] == $t['id'] ? 'selected' : '' ?>>
                            <?= e($t['nombre']) ?>
                        </option>
                        <?php endforeach; ?>
                    </select>
                </div>

                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Severidad *</label>
                    <select name="severidad_id" required x-model="severidadId"
                            class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
                        <option value="">— Selecciona —</option>
                        <?php foreach ($severidades as $s): ?>
                        <option value="<?= $s['id'] ?>"
                                data-color="<?= e($s['color']) ?>"
                                data-sla="<?= $s['sla_horas'] ?>"
                                <?= $valores['severidad_id'] == $s['id'] ? 'selected' : '' ?>>
                            <?= e($s['nombre']) ?><?= $s['sla_horas'] ? " (SLA {$s['sla_horas']}h)" : '' ?>
                        </option>
                        <?php endforeach; ?>
                    </select>
                </div>
            </div>
        </div>

        <!-- Sección 3: Equipo y reportante -->
        <div class="bg-white rounded-xl border border-zinc-200 shadow-sm p-6">
            <h3 class="font-display text-base font-bold text-zinc-900 mb-4 flex items-center gap-2">
                <i data-lucide="monitor" class="w-4 h-4 text-bacal-700"></i> Equipo y personas involucradas
            </h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">

                <div class="md:col-span-2">
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Equipo / activo</label>
                    <select name="equipo_id" x-model="equipoId" @change="buscarReincidencias()"
                            class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700"
                            :disabled="!sucursalId">
                        <option value="">— Sin equipo específico —</option>
                        <template x-for="eq in equipos" :key="eq.id">
                            <option :value="eq.id" :selected="String(eq.id) === String(equipoId)">
                                <span x-text="eq.codigo_inventario + ' - ' + eq.nombre"></span>
                            </option>
                        </template>
                    </select>
                    <p class="text-[11px] text-zinc-500 mt-1" x-show="!sucursalId">Selecciona primero una sucursal para ver sus equipos.</p>
                </div>

                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Reportante (si aplica)</label>
                    <input type="text" name="reportante_nombre" maxlength="150"
                           value="<?= e((string) $valores['reportante_nombre']) ?>"
                           placeholder="Nombre de quien reportó (si no es usuario del sistema)"
                           class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
                </div>

                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Puesto del reportante</label>
                    <input type="text" name="reportante_puesto" maxlength="100"
                           value="<?= e((string) $valores['reportante_puesto']) ?>"
                           placeholder="Ej. Cajera, Encargado de almacén"
                           class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
                </div>

                <?php if (tiene_permiso('administrar') || tiene_permiso('resolver')): ?>
                <div class="md:col-span-2">
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Asignar a técnico</label>
                    <select name="asignado_a_id"
                            class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
                        <option value="">— Sin asignar (se asignará después) —</option>
                        <?php foreach ($tecnicos as $t): ?>
                        <option value="<?= $t['id'] ?>" <?= $valores['asignado_a_id'] == $t['id'] ? 'selected' : '' ?>>
                            <?= e($t['nombre_completo']) ?>
                        </option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <?php endif; ?>
            </div>
        </div>

        <!-- Sección 4: Reincidencias detectadas (dinámica) -->
        <div class="bg-white rounded-xl border border-zinc-200 shadow-sm p-6"
             x-show="reincidencias.length > 0 || cargandoReincidencias"
             x-cloak>
            <h3 class="font-display text-base font-bold text-zinc-900 mb-1 flex items-center gap-2">
                <i data-lucide="rotate-ccw" class="w-4 h-4 text-purple-600"></i>
                Posibles incidencias relacionadas detectadas
            </h3>
            <p class="text-xs text-zinc-500 mb-4">
                Detectamos incidencias similares en los últimos 30 días en la misma área/equipo/categoría.
                Si esto se trata del mismo problema recurrente, márcalo como reincidencia.
            </p>

            <div x-show="cargandoReincidencias" class="text-sm text-zinc-500 italic">Buscando…</div>

            <div class="space-y-2 mb-3">
                <template x-for="r in reincidencias" :key="r.id">
                    <label class="block border border-zinc-200 rounded-lg p-3 hover:bg-zinc-50 cursor-pointer transition-colors"
                           :class="String(incidenciaPadreId) === String(r.id) ? 'border-purple-400 bg-purple-50' : ''">
                        <div class="flex items-start gap-3">
                            <input type="radio" name="_reincidencia_radio" :value="r.id"
                                   :checked="String(incidenciaPadreId) === String(r.id)"
                                   @change="incidenciaPadreId = r.id; esReincidencia = true"
                                   class="mt-1 text-purple-600 focus:ring-purple-500">
                            <div class="flex-1 min-w-0">
                                <div class="flex items-center gap-2 mb-1 flex-wrap">
                                    <span class="font-mono text-[10px] font-bold text-zinc-500" x-text="r.folio"></span>
                                    <span class="inline-block px-2 py-0.5 rounded text-[10px] font-semibold"
                                          :style="`background-color: ${r.estado_color}20; color: ${r.estado_color}; border: 1px solid ${r.estado_color}40`"
                                          x-text="r.estado_nombre"></span>
                                    <span class="text-[10px] text-zinc-500" x-text="'hace ' + r.dias_atras + ' día(s)'"></span>
                                </div>
                                <div class="font-semibold text-sm text-zinc-900" x-text="r.titulo"></div>
                                <div class="text-xs text-zinc-500 mt-0.5" x-show="r.equipo_nombre">
                                    <span x-text="r.equipo_nombre"></span>
                                </div>
                            </div>
                        </div>
                    </label>
                </template>
            </div>

            <div x-show="incidenciaPadreId" class="flex items-center gap-2 text-xs">
                <button type="button" @click="incidenciaPadreId = ''; esReincidencia = false"
                        class="text-zinc-500 hover:text-bacal-700 underline">
                    Quitar marca de reincidencia
                </button>
            </div>
        </div>

        <!-- Sección 5: Resolución (opcional al crear) -->
        <div class="bg-white rounded-xl border border-zinc-200 shadow-sm p-6"
             x-data="{ abierto: <?= !empty($valores['solucion']) ? 'true' : 'false' ?> }">
            <button type="button" @click="abierto = !abierto"
                    class="w-full flex items-center justify-between text-left">
                <div>
                    <h3 class="font-display text-base font-bold text-zinc-900 flex items-center gap-2">
                        <i data-lucide="wrench" class="w-4 h-4 text-bacal-700"></i>
                        Resolución
                        <span class="text-xs font-normal text-zinc-500">(opcional, si ya se resolvió)</span>
                    </h3>
                </div>
                <i data-lucide="chevron-down" class="w-4 h-4 text-zinc-400 transition-transform"
                   :class="abierto ? 'rotate-180' : ''"></i>
            </button>

            <div x-show="abierto" x-collapse class="mt-4 space-y-4">
                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Causa raíz identificada</label>
                    <textarea name="causa_raiz" rows="2"
                              placeholder="¿Por qué ocurrió este incidente?"
                              class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700"><?= e((string) $valores['causa_raiz']) ?></textarea>
                </div>

                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Solución aplicada</label>
                    <textarea name="solucion" rows="3"
                              placeholder="¿Qué se hizo para resolverlo?"
                              class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700"><?= e((string) $valores['solucion']) ?></textarea>
                </div>

                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Recomendaciones para evitar recurrencia</label>
                    <textarea name="recomendaciones" rows="2"
                              placeholder="¿Qué se puede hacer para que no vuelva a pasar?"
                              class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700"><?= e((string) $valores['recomendaciones']) ?></textarea>
                </div>
            </div>
        </div>

        <!-- Sección 6: Adjuntos -->
        <div class="bg-white rounded-xl border border-zinc-200 shadow-sm p-6">
            <h3 class="font-display text-base font-bold text-zinc-900 mb-1 flex items-center gap-2">
                <i data-lucide="paperclip" class="w-4 h-4 text-bacal-700"></i> Adjuntos / evidencias
            </h3>
            <p class="text-xs text-zinc-500 mb-4">Máximo <?= ADJUNTOS_MAX_ARCHIVOS ?> archivos, 10 MB cada uno. Formatos permitidos: imágenes, PDF, Word, Excel, ZIP, TXT.</p>

            <input type="file" name="adjuntos[]" multiple
                   x-ref="inputFiles" @change="archivosSeleccionados = Array.from($event.target.files)"
                   class="hidden">

            <div @click="$refs.inputFiles.click()"
                 @dragover.prevent="dragActivo = true" @dragleave.prevent="dragActivo = false"
                 @drop.prevent="dragActivo = false; agregarArchivos($event.dataTransfer.files)"
                 :class="dragActivo ? 'border-bacal-700 bg-bacal-50' : 'border-zinc-300 hover:border-zinc-400'"
                 class="border-2 border-dashed rounded-lg p-6 text-center cursor-pointer transition-colors">
                <i data-lucide="upload-cloud" class="w-8 h-8 mx-auto text-zinc-400 mb-2"></i>
                <p class="text-sm font-medium text-zinc-700">Haz clic o arrastra archivos aquí</p>
                <p class="text-xs text-zinc-500 mt-1" x-show="archivosSeleccionados.length === 0">Sin archivos seleccionados</p>
                <p class="text-xs text-bacal-700 font-semibold mt-1" x-show="archivosSeleccionados.length > 0">
                    <span x-text="archivosSeleccionados.length"></span> archivo(s) seleccionado(s)
                </p>
            </div>

            <div class="mt-3 space-y-1.5" x-show="archivosSeleccionados.length > 0">
                <template x-for="(f, idx) in archivosSeleccionados" :key="idx">
                    <div class="flex items-center gap-2 px-3 py-2 bg-zinc-50 rounded-lg text-xs">
                        <i data-lucide="file" class="w-4 h-4 text-zinc-400"></i>
                        <span class="flex-1 truncate font-medium text-zinc-700" x-text="f.name"></span>
                        <span class="text-zinc-500" x-text="(f.size / 1024).toFixed(0) + ' KB'"></span>
                    </div>
                </template>
            </div>
        </div>

        <!-- Botones de acción -->
        <div class="flex items-center justify-end gap-2">
            <a href="<?= url('bitacora.php') ?>"
               class="px-4 py-2 rounded-lg border border-zinc-300 text-zinc-700 font-medium text-sm hover:bg-zinc-50">
                Cancelar
            </a>
            <button type="submit"
                    class="px-5 py-2 rounded-lg bg-bacal-700 hover:bg-bacal-800 text-white font-semibold text-sm shadow-sm flex items-center gap-2">
                <i data-lucide="check" class="w-4 h-4"></i> Registrar incidencia
            </button>
        </div>

    </form>
</div>

<script>
function formIncidencia() {
    return {
        sucursalId: '<?= e((string) $valores['sucursal_id']) ?>',
        areaId: '<?= e((string) $valores['area_id']) ?>',
        categoriaId: '<?= e((string) $valores['categoria_id']) ?>',
        subcategoriaId: '<?= e((string) $valores['subcategoria_id']) ?>',
        equipoId: '<?= e((string) $valores['equipo_id']) ?>',
        severidadId: '<?= e((string) $valores['severidad_id']) ?>',
        esReincidencia: <?= $valores['es_reincidencia'] ? 'true' : 'false' ?>,
        incidenciaPadreId: '<?= e((string) $valores['incidencia_padre_id']) ?>',

        equipos: [],
        cargandoEquipos: false,

        reincidencias: [],
        cargandoReincidencias: false,
        timerReincidencias: null,

        archivosSeleccionados: [],
        dragActivo: false,

        categorias: <?= json_encode($categorias, JSON_UNESCAPED_UNICODE) ?>,

        get subcategoriasFiltradas() {
            if (!this.categoriaId) return [];
            const c = this.categorias.find(x => String(x.id) === String(this.categoriaId));
            return c ? c.subcategorias : [];
        },

        async cargarEquipos() {
            this.equipos = [];
            if (!this.sucursalId) return;
            this.cargandoEquipos = true;
            try {
                const resp = await fetch('<?= url('api/equipos_de_sucursal.php') ?>?sucursal=' + this.sucursalId, {
                    credentials: 'same-origin'
                });
                if (resp.ok) {
                    this.equipos = await resp.json();
                }
            } catch (e) { console.error(e); }
            this.cargandoEquipos = false;
        },

        buscarReincidencias() {
            clearTimeout(this.timerReincidencias);
            this.timerReincidencias = setTimeout(() => this._buscarReincidenciasNow(), 400);
        },

        async _buscarReincidenciasNow() {
            if (!this.areaId) {
                this.reincidencias = [];
                return;
            }
            this.cargandoReincidencias = true;
            try {
                const params = new URLSearchParams({
                    area: this.areaId,
                    equipo: this.equipoId || '',
                    categoria: this.categoriaId || '',
                });
                const resp = await fetch('<?= url('api/buscar_reincidencias.php') ?>?' + params.toString(), {
                    credentials: 'same-origin'
                });
                if (resp.ok) {
                    this.reincidencias = await resp.json();
                }
            } catch (e) { console.error(e); }
            this.cargandoReincidencias = false;
        },

        agregarArchivos(fileList) {
            const dt = new DataTransfer();
            // Mantener los previos
            this.archivosSeleccionados.forEach(f => dt.items.add(f));
            // Sumar nuevos
            Array.from(fileList).forEach(f => dt.items.add(f));
            this.$refs.inputFiles.files = dt.files;
            this.archivosSeleccionados = Array.from(dt.files);
        },

        init() {
            // Cargar equipos al iniciar si ya hay sucursal
            if (this.sucursalId) this.cargarEquipos();
            // Buscar reincidencias si ya hay datos
            if (this.areaId) this.buscarReincidencias();
        }
    }
}
</script>

<?php require_once __DIR__ . '/config/footer.php'; ?>
