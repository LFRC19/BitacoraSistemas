<?php
/**
 * ============================================================================
 * admin/equipos.php - Gestión de equipos/activos
 * ============================================================================
 */
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
require_once __DIR__ . '/../config/helpers.php';
require_once __DIR__ . '/../config/admin_helpers.php';

$accion = (string) input('accion', 'listar');
$id     = (int) input('id', 0);

$equipo_edit = null;
if (in_array($accion, ['editar', 'toggle'], true) && $id > 0) {
    $equipo_edit = db_one("SELECT * FROM equipos WHERE id = :id", ['id' => $id]);
    if (!$equipo_edit) {
        flash_set('error', 'Equipo no encontrado.');
        header('Location: ' . url('admin/equipos.php'));
        exit;
    }
}

$errores = [];

if (es_post()) {
    if (!csrf_valido(input('_csrf'))) {
        $errores[] = 'Token de seguridad inválido.';
    } else {
        $op = (string) input('op', '');
        try {
            if ($op === 'crear' || $op === 'editar') {
                $codigo = strtoupper(trim((string) input('codigo_inventario', '')));
                $nombre = trim((string) input('nombre', ''));
                $tipo   = trim((string) input('tipo', ''));
                $marca  = trim((string) input('marca', ''));
                $modelo = trim((string) input('modelo', ''));
                $serie  = trim((string) input('numero_serie', ''));
                $sid    = (int) input('sucursal_id', 0);
                $aid    = input('area_id', '') !== '' ? (int) input('area_id') : null;
                $ubic   = trim((string) input('ubicacion', ''));
                $notas  = trim((string) input('notas', ''));

                if ($codigo === '') $errores[] = 'El código de inventario es obligatorio.';
                if ($nombre === '') $errores[] = 'El nombre es obligatorio.';
                if ($sid <= 0)      $errores[] = 'La sucursal es obligatoria.';

                $check_id = $op === 'editar' ? (int) $equipo_edit['id'] : 0;
                $dup = db_one("SELECT id FROM equipos WHERE codigo_inventario = :c AND id <> :id",
                    ['c' => $codigo, 'id' => $check_id]);
                if ($dup) $errores[] = 'Ya existe un equipo con ese código de inventario.';

                if (empty($errores)) {
                    if ($op === 'crear') {
                        db_exec(
                            "INSERT INTO equipos
                             (codigo_inventario, nombre, tipo, marca, modelo, numero_serie,
                              sucursal_id, area_id, ubicacion, notas, activo)
                             VALUES (:c, :n, :t, :m, :mo, :ns, :s, :a, :u, :no, 1)",
                            ['c' => $codigo, 'n' => $nombre, 't' => $tipo ?: null, 'm' => $marca ?: null,
                             'mo' => $modelo ?: null, 'ns' => $serie ?: null,
                             's' => $sid, 'a' => $aid, 'u' => $ubic ?: null, 'no' => $notas ?: null]
                        );
                        $new_id = db_last_id();
                        registrar_auditoria('crear_equipo', 'equipos', $new_id, "Equipo $codigo");
                        flash_set('success', "Equipo \"$nombre\" creado.");
                    } else {
                        db_exec(
                            "UPDATE equipos SET
                                codigo_inventario=:c, nombre=:n, tipo=:t, marca=:m, modelo=:mo,
                                numero_serie=:ns, sucursal_id=:s, area_id=:a,
                                ubicacion=:u, notas=:no
                             WHERE id=:id",
                            ['c' => $codigo, 'n' => $nombre, 't' => $tipo ?: null, 'm' => $marca ?: null,
                             'mo' => $modelo ?: null, 'ns' => $serie ?: null,
                             's' => $sid, 'a' => $aid, 'u' => $ubic ?: null, 'no' => $notas ?: null,
                             'id' => $equipo_edit['id']]
                        );
                        registrar_auditoria('editar_equipo', 'equipos', $equipo_edit['id'], "Equipo $codigo");
                        flash_set('success', 'Equipo actualizado.');
                    }
                    header('Location: ' . url('admin/equipos.php'));
                    exit;
                }
            } elseif ($op === 'toggle' && $equipo_edit) {
                admin_toggle_activo('equipos', $equipo_edit['id'], "Equipo {$equipo_edit['codigo_inventario']}");
                header('Location: ' . url('admin/equipos.php'));
                exit;
            }
        } catch (Throwable $e) {
            $errores[] = 'Error: ' . $e->getMessage();
        }
    }
}

$sucursales = db_all("SELECT id, nombre, codigo FROM sucursales WHERE activo=1 ORDER BY nombre");
$areas      = db_all("SELECT id, nombre FROM areas WHERE activo=1 ORDER BY nombre");
$tipos_existentes = db_all("SELECT DISTINCT tipo FROM equipos WHERE tipo IS NOT NULL AND tipo <> '' ORDER BY tipo");

$titulo_pagina = 'Equipos';
$pagina_activa = 'admin_equipos';
require_once __DIR__ . '/../config/header.php';

if ($accion === 'nuevo' || ($accion === 'editar' && $equipo_edit)):
    $es_edicion = ($accion === 'editar');
    $eq = $equipo_edit;
?>
<div class="max-w-3xl mx-auto animate-fade-in">
    <div class="flex items-center gap-3 mb-6">
        <a href="<?= url('admin/equipos.php') ?>" class="p-2 rounded-lg hover:bg-zinc-100 text-zinc-500">
            <i data-lucide="arrow-left" class="w-5 h-5"></i>
        </a>
        <h2 class="font-display text-2xl font-extrabold text-zinc-900"><?= $es_edicion ? 'Editar equipo' : 'Nuevo equipo' ?></h2>
    </div>

    <?php if (!empty($errores)): ?>
    <div class="mb-4 px-4 py-3 rounded-lg bg-bacal-50 border border-bacal-200 text-bacal-800 text-sm">
        <ul class="list-disc list-inside text-xs"><?php foreach ($errores as $e): ?><li><?= e($e) ?></li><?php endforeach; ?></ul>
    </div>
    <?php endif; ?>

    <form method="POST" class="bg-white rounded-xl border border-zinc-200 shadow-sm p-6 space-y-4">
        <?= csrf_input() ?>
        <input type="hidden" name="op" value="<?= $es_edicion ? 'editar' : 'crear' ?>">

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
                <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Código de inventario *</label>
                <input type="text" name="codigo_inventario" required maxlength="50"
                       value="<?= e($es_edicion ? $eq['codigo_inventario'] : (string) input('codigo_inventario', '')) ?>"
                       placeholder="ej. BAC-001"
                       class="w-full px-3 py-2 rounded-lg border border-zinc-300 text-sm font-mono uppercase focus:outline-none focus:border-bacal-700"
                       style="text-transform: uppercase;">
            </div>
            <div>
                <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Nombre descriptivo *</label>
                <input type="text" name="nombre" required maxlength="150"
                       value="<?= e($es_edicion ? $eq['nombre'] : (string) input('nombre', '')) ?>"
                       placeholder="ej. PC Caja 1 Bacal"
                       class="w-full px-3 py-2 rounded-lg border border-zinc-300 text-sm focus:outline-none focus:border-bacal-700">
            </div>
            <div>
                <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Tipo</label>
                <input type="text" name="tipo" list="tipos-equipo" maxlength="50"
                       value="<?= e($es_edicion ? (string) $eq['tipo'] : (string) input('tipo', '')) ?>"
                       placeholder="ej. PC, Impresora, Cámara IP"
                       class="w-full px-3 py-2 rounded-lg border border-zinc-300 text-sm focus:outline-none focus:border-bacal-700">
                <datalist id="tipos-equipo">
                    <?php foreach ($tipos_existentes as $t): ?>
                    <option value="<?= e($t['tipo']) ?>">
                    <?php endforeach; ?>
                </datalist>
            </div>
            <div>
                <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Marca</label>
                <input type="text" name="marca" maxlength="100"
                       value="<?= e($es_edicion ? (string) $eq['marca'] : (string) input('marca', '')) ?>"
                       class="w-full px-3 py-2 rounded-lg border border-zinc-300 text-sm focus:outline-none focus:border-bacal-700">
            </div>
            <div>
                <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Modelo</label>
                <input type="text" name="modelo" maxlength="100"
                       value="<?= e($es_edicion ? (string) $eq['modelo'] : (string) input('modelo', '')) ?>"
                       class="w-full px-3 py-2 rounded-lg border border-zinc-300 text-sm focus:outline-none focus:border-bacal-700">
            </div>
            <div>
                <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Número de serie</label>
                <input type="text" name="numero_serie" maxlength="100"
                       value="<?= e($es_edicion ? (string) $eq['numero_serie'] : (string) input('numero_serie', '')) ?>"
                       class="w-full px-3 py-2 rounded-lg border border-zinc-300 text-sm font-mono focus:outline-none focus:border-bacal-700">
            </div>
            <div>
                <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Sucursal *</label>
                <select name="sucursal_id" required class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
                    <option value="">— Selecciona —</option>
                    <?php foreach ($sucursales as $s):
                        $sel = $es_edicion ? $eq['sucursal_id'] : (int) input('sucursal_id', 0);
                    ?>
                    <option value="<?= $s['id'] ?>" <?= $sel == $s['id'] ? 'selected' : '' ?>><?= e($s['nombre']) ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div>
                <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Área (opcional)</label>
                <select name="area_id" class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
                    <option value="">— Sin área —</option>
                    <?php foreach ($areas as $a):
                        $sel = $es_edicion ? $eq['area_id'] : (string) input('area_id', '');
                    ?>
                    <option value="<?= $a['id'] ?>" <?= (string) $sel === (string) $a['id'] ? 'selected' : '' ?>><?= e($a['nombre']) ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="md:col-span-2">
                <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Ubicación física</label>
                <input type="text" name="ubicacion" maxlength="255"
                       value="<?= e($es_edicion ? (string) $eq['ubicacion'] : (string) input('ubicacion', '')) ?>"
                       placeholder="ej. Planta baja, sala de cajas, posición 1"
                       class="w-full px-3 py-2 rounded-lg border border-zinc-300 text-sm focus:outline-none focus:border-bacal-700">
            </div>
            <div class="md:col-span-2">
                <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Notas</label>
                <textarea name="notas" rows="2"
                          class="w-full px-3 py-2 rounded-lg border border-zinc-300 text-sm focus:outline-none focus:border-bacal-700"><?= e($es_edicion ? (string) $eq['notas'] : (string) input('notas', '')) ?></textarea>
            </div>
        </div>

        <div class="flex justify-end gap-2 pt-3 border-t border-zinc-100">
            <a href="<?= url('admin/equipos.php') ?>" class="px-4 py-2 rounded-lg border border-zinc-300 text-zinc-700 text-sm">Cancelar</a>
            <button type="submit" class="px-5 py-2 rounded-lg bg-bacal-700 hover:bg-bacal-800 text-white text-sm font-semibold">
                <?= $es_edicion ? 'Guardar' : 'Crear equipo' ?>
            </button>
        </div>
    </form>
</div>

<?php else:
    // Filtros
    $f_sucursal = (int) input('sucursal', 0);
    $f_tipo     = trim((string) input('tipo', ''));
    $f_q        = trim((string) input('q', ''));

    $where = [];
    $params = [];
    if ($f_sucursal > 0) { $where[] = "e.sucursal_id = :sid"; $params['sid'] = $f_sucursal; }
    if ($f_tipo !== '')  { $where[] = "e.tipo = :t"; $params['t'] = $f_tipo; }
    if ($f_q !== '')     {
        $where[] = "(e.codigo_inventario LIKE :q1 OR e.nombre LIKE :q2 OR e.marca LIKE :q3 OR e.modelo LIKE :q4)";
        $params['q1'] = "%$f_q%"; $params['q2'] = "%$f_q%"; $params['q3'] = "%$f_q%"; $params['q4'] = "%$f_q%";
    }
    $where_sql = !empty($where) ? 'WHERE ' . implode(' AND ', $where) : '';

    $equipos = db_all(
        "SELECT e.*, s.nombre sucursal_nombre, s.codigo sucursal_codigo, a.nombre area_nombre,
                (SELECT COUNT(*) FROM incidencias WHERE equipo_id = e.id) AS incidencias_count
         FROM equipos e
         INNER JOIN sucursales s ON e.sucursal_id = s.id
         LEFT JOIN areas a ON e.area_id = a.id
         $where_sql
         ORDER BY e.activo DESC, e.codigo_inventario ASC",
        $params
    );
?>

<?php render_admin_header('Equipos / activos', count($equipos) . ' equipo(s) en inventario', url('admin/equipos.php?accion=nuevo'), 'Nuevo equipo'); ?>

<!-- Filtros -->
<form method="GET" class="flex flex-wrap gap-2 mb-4">
    <div class="relative flex-1 min-w-[200px] max-w-md">
        <i data-lucide="search" class="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-zinc-400"></i>
        <input type="text" name="q" value="<?= e($f_q) ?>" placeholder="Código, nombre, marca, modelo..."
               class="w-full pl-9 pr-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
    </div>
    <select name="sucursal" onchange="this.form.submit()"
            class="px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
        <option value="">Todas las sucursales</option>
        <?php foreach ($sucursales as $s): ?>
        <option value="<?= $s['id'] ?>" <?= $f_sucursal == $s['id'] ? 'selected' : '' ?>><?= e($s['nombre']) ?></option>
        <?php endforeach; ?>
    </select>
    <select name="tipo" onchange="this.form.submit()"
            class="px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
        <option value="">Todos los tipos</option>
        <?php foreach ($tipos_existentes as $t): ?>
        <option value="<?= e($t['tipo']) ?>" <?= $f_tipo === $t['tipo'] ? 'selected' : '' ?>><?= e($t['tipo']) ?></option>
        <?php endforeach; ?>
    </select>
    <?php if ($f_q !== '' || $f_sucursal > 0 || $f_tipo !== ''): ?>
    <a href="<?= url('admin/equipos.php') ?>" class="px-3 py-2 rounded-lg border border-zinc-300 text-zinc-700 text-sm hover:bg-zinc-50">Limpiar</a>
    <?php endif; ?>
</form>

<div class="bg-white rounded-xl border border-zinc-200 shadow-sm overflow-hidden">
    <div class="overflow-x-auto">
        <table class="w-full text-sm">
            <thead class="bg-zinc-50 border-b border-zinc-200">
                <tr>
                    <th class="px-4 py-2.5 text-left text-[10px] font-bold text-zinc-500 uppercase tracking-wider">Código</th>
                    <th class="px-4 py-2.5 text-left text-[10px] font-bold text-zinc-500 uppercase tracking-wider">Equipo</th>
                    <th class="px-4 py-2.5 text-left text-[10px] font-bold text-zinc-500 uppercase tracking-wider">Tipo</th>
                    <th class="px-4 py-2.5 text-left text-[10px] font-bold text-zinc-500 uppercase tracking-wider">Sucursal</th>
                    <th class="px-4 py-2.5 text-left text-[10px] font-bold text-zinc-500 uppercase tracking-wider">Área</th>
                    <th class="px-4 py-2.5 text-center text-[10px] font-bold text-zinc-500 uppercase tracking-wider">Fallas</th>
                    <th class="px-4 py-2.5"></th>
                </tr>
            </thead>
            <tbody class="divide-y divide-zinc-100">
                <?php foreach ($equipos as $eq): ?>
                <tr class="hover:bg-zinc-50 group <?= !$eq['activo'] ? 'opacity-50' : '' ?>">
                    <td class="px-4 py-2.5 font-mono text-xs font-bold text-zinc-700"><?= e($eq['codigo_inventario']) ?></td>
                    <td class="px-4 py-2.5">
                        <div class="font-semibold text-sm text-zinc-900"><?= e($eq['nombre']) ?></div>
                        <?php if ($eq['marca'] || $eq['modelo']): ?>
                        <div class="text-[10px] text-zinc-500"><?= e(trim(($eq['marca'] ?? '') . ' ' . ($eq['modelo'] ?? ''))) ?></div>
                        <?php endif; ?>
                    </td>
                    <td class="px-4 py-2.5 text-xs text-zinc-700"><?= e((string) $eq['tipo']) ?: '—' ?></td>
                    <td class="px-4 py-2.5">
                        <span class="font-mono text-[10px] bg-zinc-100 text-zinc-600 px-1.5 py-0.5 rounded font-bold"><?= e($eq['sucursal_codigo']) ?></span>
                    </td>
                    <td class="px-4 py-2.5 text-xs text-zinc-700"><?= e($eq['area_nombre'] ?? '—') ?></td>
                    <td class="px-4 py-2.5 text-center">
                        <?php if ((int) $eq['incidencias_count'] > 0): ?>
                        <a href="<?= url('bitacora.php?equipo=' . $eq['id']) ?>"
                           class="inline-flex items-center gap-1 text-xs font-bold text-bacal-700 hover:underline">
                            <?= $eq['incidencias_count'] ?>
                            <i data-lucide="arrow-up-right" class="w-3 h-3"></i>
                        </a>
                        <?php else: ?>
                        <span class="text-zinc-400 text-xs">0</span>
                        <?php endif; ?>
                    </td>
                    <td class="px-4 py-2.5 text-right">
                        <div class="flex items-center justify-end gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                            <a href="<?= url('admin/equipos.php?accion=editar&id=' . $eq['id']) ?>"
                               class="p-1.5 rounded text-zinc-500 hover:bg-zinc-100 hover:text-zinc-700">
                                <i data-lucide="edit-3" class="w-4 h-4"></i>
                            </a>
                            <form method="POST" action="<?= url('admin/equipos.php?accion=toggle&id=' . $eq['id']) ?>"
                                  onsubmit="return confirm('¿<?= $eq['activo'] ? 'Desactivar' : 'Activar' ?> este equipo?');">
                                <?= csrf_input() ?>
                                <input type="hidden" name="op" value="toggle">
                                <button type="submit" class="p-1.5 rounded text-zinc-500 hover:bg-bacal-50 hover:text-bacal-700">
                                    <i data-lucide="<?= $eq['activo'] ? 'power' : 'power-off' ?>" class="w-4 h-4"></i>
                                </button>
                            </form>
                        </div>
                    </td>
                </tr>
                <?php endforeach; ?>
                <?php if (empty($equipos)): ?>
                <tr><td colspan="7" class="px-4 py-12 text-center text-sm text-zinc-500 italic">Sin equipos que coincidan.</td></tr>
                <?php endif; ?>
            </tbody>
        </table>
    </div>
</div>

<?php endif; ?>

<?php require_once __DIR__ . '/../config/footer.php'; ?>
