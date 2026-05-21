<?php
/**
 * ============================================================================
 * admin/usuarios.php - Gestión de usuarios
 * ============================================================================
 * Listar, crear, editar, activar/desactivar usuarios. Resetear contraseñas.
 * ============================================================================
 */
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
require_once __DIR__ . '/../config/helpers.php';
require_once __DIR__ . '/../config/admin_helpers.php';

$u_actual = usuario_actual();

// ----------------------------------------------------------------------------
// Determinar acción
// ----------------------------------------------------------------------------
$accion = (string) input('accion', 'listar');
$id     = (int) input('id', 0);

// Datos del usuario que se está editando (si aplica)
$usuario_edit = null;
if (in_array($accion, ['editar', 'reset_password', 'toggle'], true) && $id > 0) {
    $usuario_edit = db_one(
        "SELECT u.*, r.nombre rol_nombre FROM usuarios u
         INNER JOIN roles r ON u.rol_id = r.id
         WHERE u.id = :id",
        ['id' => $id]
    );
    if (!$usuario_edit) {
        flash_set('error', 'Usuario no encontrado.');
        header('Location: ' . url('admin/usuarios.php'));
        exit;
    }
}

// ----------------------------------------------------------------------------
// Procesar POST
// ----------------------------------------------------------------------------
$errores = [];

if (es_post()) {
    if (!csrf_valido(input('_csrf'))) {
        $errores[] = 'Token de seguridad inválido.';
    } else {
        $op = (string) input('op', '');

        try {
            if ($op === 'crear') {
                $usuario  = trim((string) input('usuario', ''));
                $nombre   = trim((string) input('nombre_completo', ''));
                $email    = trim((string) input('email', ''));
                $rol_id   = (int) input('rol_id', 0);
                $suc_id   = input('sucursal_id', '') !== '' ? (int) input('sucursal_id') : null;
                $area_id  = input('area_id', '') !== '' ? (int) input('area_id') : null;
                $puesto   = trim((string) input('puesto', ''));
                $tel      = trim((string) input('telefono', ''));
                $pass     = (string) input('password', '');

                if ($usuario === '')        $errores[] = 'El nombre de usuario es obligatorio.';
                if (!preg_match('/^[a-z0-9_\.]+$/i', $usuario)) $errores[] = 'El usuario solo puede tener letras, números, guion bajo y punto.';
                if ($nombre === '')         $errores[] = 'El nombre completo es obligatorio.';
                if ($rol_id <= 0)           $errores[] = 'Debes asignar un rol.';
                if (strlen($pass) < 8)      $errores[] = 'La contraseña inicial debe tener al menos 8 caracteres.';

                $existe = db_one("SELECT id FROM usuarios WHERE usuario = :u", ['u' => $usuario]);
                if ($existe) $errores[] = 'Ya existe un usuario con ese nombre.';

                if (empty($errores)) {
                    $hash = password_hash($pass, PASSWORD_DEFAULT);
                    db_exec(
                        "INSERT INTO usuarios
                         (usuario, password_hash, nombre_completo, email, telefono,
                          rol_id, sucursal_id, area_id, puesto, debe_cambiar_password, activo)
                         VALUES (:u, :p, :n, :e, :t, :r, :s, :a, :pu, 1, 1)",
                        ['u' => $usuario, 'p' => $hash, 'n' => $nombre, 'e' => $email ?: null,
                         't' => $tel ?: null, 'r' => $rol_id, 's' => $suc_id, 'a' => $area_id,
                         'pu' => $puesto ?: null]
                    );
                    $nuevo_id = db_last_id();
                    registrar_auditoria('crear_usuario', 'usuarios', $nuevo_id, "Usuario $usuario creado");
                    flash_set('success', "Usuario \"$usuario\" creado. Contraseña inicial: $pass (deberá cambiarla al entrar).");
                    header('Location: ' . url('admin/usuarios.php'));
                    exit;
                }
            } elseif ($op === 'editar' && $usuario_edit) {
                $nombre   = trim((string) input('nombre_completo', ''));
                $email    = trim((string) input('email', ''));
                $rol_id   = (int) input('rol_id', 0);
                $suc_id   = input('sucursal_id', '') !== '' ? (int) input('sucursal_id') : null;
                $area_id  = input('area_id', '') !== '' ? (int) input('area_id') : null;
                $puesto   = trim((string) input('puesto', ''));
                $tel      = trim((string) input('telefono', ''));

                if ($nombre === '') $errores[] = 'El nombre completo es obligatorio.';
                if ($rol_id <= 0)   $errores[] = 'Debes asignar un rol.';

                // No permitir que el admin se quite a sí mismo el rol de admin
                if ((int) $usuario_edit['id'] === (int) $u_actual['id']) {
                    $rol_admin = db_one("SELECT id FROM roles WHERE nombre='Administrador'")['id'];
                    if ($rol_id !== (int) $rol_admin) {
                        $errores[] = 'No puedes quitarte el rol de Administrador a ti mismo.';
                    }
                }

                if (empty($errores)) {
                    db_exec(
                        "UPDATE usuarios SET
                            nombre_completo = :n, email = :e, telefono = :t,
                            rol_id = :r, sucursal_id = :s, area_id = :a, puesto = :pu
                         WHERE id = :id",
                        ['n' => $nombre, 'e' => $email ?: null, 't' => $tel ?: null,
                         'r' => $rol_id, 's' => $suc_id, 'a' => $area_id,
                         'pu' => $puesto ?: null, 'id' => $usuario_edit['id']]
                    );
                    registrar_auditoria('editar_usuario', 'usuarios', $usuario_edit['id'], "Usuario {$usuario_edit['usuario']} editado");
                    flash_set('success', 'Usuario actualizado.');
                    header('Location: ' . url('admin/usuarios.php'));
                    exit;
                }
            } elseif ($op === 'reset_password' && $usuario_edit) {
                $pass = (string) input('password_nuevo', '');
                if (strlen($pass) < 8) {
                    $errores[] = 'La nueva contraseña debe tener al menos 8 caracteres.';
                } else {
                    $hash = password_hash($pass, PASSWORD_DEFAULT);
                    db_exec(
                        "UPDATE usuarios SET password_hash = :h, debe_cambiar_password = 1,
                                              intentos_fallidos = 0, bloqueado_hasta = NULL
                         WHERE id = :id",
                        ['h' => $hash, 'id' => $usuario_edit['id']]
                    );
                    registrar_auditoria('reset_password', 'usuarios', $usuario_edit['id'], "Contraseña reseteada para {$usuario_edit['usuario']}");
                    flash_set('success', "Contraseña reseteada. El usuario deberá cambiarla al entrar. Pass: $pass");
                    header('Location: ' . url('admin/usuarios.php'));
                    exit;
                }
            } elseif ($op === 'toggle' && $usuario_edit) {
                // No permitir desactivarse a sí mismo
                if ((int) $usuario_edit['id'] === (int) $u_actual['id']) {
                    flash_set('error', 'No puedes desactivarte a ti mismo.');
                } else {
                    admin_toggle_activo('usuarios', $usuario_edit['id'], "Usuario {$usuario_edit['usuario']}");
                }
                header('Location: ' . url('admin/usuarios.php'));
                exit;
            }
        } catch (Throwable $e) {
            $errores[] = 'Error: ' . $e->getMessage();
        }
    }
}

// ----------------------------------------------------------------------------
// Datos para vistas
// ----------------------------------------------------------------------------
$roles      = db_all("SELECT id, nombre, descripcion FROM roles WHERE activo=1 ORDER BY id");
$sucursales = db_all("SELECT id, nombre FROM sucursales WHERE activo=1 ORDER BY nombre");
$areas      = db_all("SELECT id, nombre FROM areas WHERE activo=1 ORDER BY nombre");

$titulo_pagina = 'Usuarios';
$pagina_activa = 'admin_usuarios';
require_once __DIR__ . '/../config/header.php';

// ============================================================================
// VISTA: FORMULARIO (crear o editar)
// ============================================================================
if ($accion === 'nuevo' || ($accion === 'editar' && $usuario_edit)):
    $es_edicion = ($accion === 'editar');
    $u = $usuario_edit;
?>
<div class="max-w-3xl mx-auto animate-fade-in">
    <div class="flex items-center gap-3 mb-6">
        <a href="<?= url('admin/usuarios.php') ?>" class="p-2 rounded-lg hover:bg-zinc-100 text-zinc-500">
            <i data-lucide="arrow-left" class="w-5 h-5"></i>
        </a>
        <div>
            <h2 class="font-display text-2xl font-extrabold text-zinc-900">
                <?= $es_edicion ? 'Editar usuario' : 'Nuevo usuario' ?>
            </h2>
            <p class="text-xs text-zinc-500"><?= $es_edicion ? e($u['usuario']) : 'Crea una cuenta para un ingeniero, gerente o jefe de área' ?></p>
        </div>
    </div>

    <?php if (!empty($errores)): ?>
    <div class="mb-5 px-4 py-3 rounded-lg bg-bacal-50 border border-bacal-200 text-bacal-800 text-sm">
        <ul class="list-disc list-inside text-xs"><?php foreach ($errores as $e): ?><li><?= e($e) ?></li><?php endforeach; ?></ul>
    </div>
    <?php endif; ?>

    <form method="POST" class="space-y-5">
        <?= csrf_input() ?>
        <input type="hidden" name="op" value="<?= $es_edicion ? 'editar' : 'crear' ?>">

        <div class="bg-white rounded-xl border border-zinc-200 shadow-sm p-6">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Nombre de usuario *</label>
                    <?php if ($es_edicion): ?>
                    <div class="px-3 py-2 rounded-lg border border-zinc-200 bg-zinc-50 text-sm text-zinc-700 font-mono"><?= e($u['usuario']) ?></div>
                    <p class="text-[10px] text-zinc-500 mt-1">El usuario no se puede cambiar.</p>
                    <?php else: ?>
                    <input type="text" name="usuario" required maxlength="50" pattern="[a-zA-Z0-9_.]+"
                           value="<?= e((string) input('usuario', '')) ?>"
                           placeholder="ej. juan.perez"
                           class="w-full px-3 py-2 rounded-lg border border-zinc-300 text-sm focus:outline-none focus:border-bacal-700">
                    <p class="text-[10px] text-zinc-500 mt-1">Solo letras, números, guion bajo y punto.</p>
                    <?php endif; ?>
                </div>

                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Nombre completo *</label>
                    <input type="text" name="nombre_completo" required maxlength="150"
                           value="<?= e($es_edicion ? $u['nombre_completo'] : (string) input('nombre_completo', '')) ?>"
                           class="w-full px-3 py-2 rounded-lg border border-zinc-300 text-sm focus:outline-none focus:border-bacal-700">
                </div>

                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Email</label>
                    <input type="email" name="email" maxlength="150"
                           value="<?= e($es_edicion ? (string) $u['email'] : (string) input('email', '')) ?>"
                           class="w-full px-3 py-2 rounded-lg border border-zinc-300 text-sm focus:outline-none focus:border-bacal-700">
                </div>

                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Teléfono</label>
                    <input type="text" name="telefono" maxlength="50"
                           value="<?= e($es_edicion ? (string) $u['telefono'] : (string) input('telefono', '')) ?>"
                           class="w-full px-3 py-2 rounded-lg border border-zinc-300 text-sm focus:outline-none focus:border-bacal-700">
                </div>

                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Rol *</label>
                    <select name="rol_id" required class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
                        <option value="">— Selecciona —</option>
                        <?php foreach ($roles as $r):
                            $sel = $es_edicion ? $u['rol_id'] : (int) input('rol_id', 0);
                        ?>
                        <option value="<?= $r['id'] ?>" <?= $sel == $r['id'] ? 'selected' : '' ?>><?= e($r['nombre']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>

                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Puesto</label>
                    <input type="text" name="puesto" maxlength="100"
                           value="<?= e($es_edicion ? (string) $u['puesto'] : (string) input('puesto', '')) ?>"
                           placeholder="ej. Gerente de sucursal"
                           class="w-full px-3 py-2 rounded-lg border border-zinc-300 text-sm focus:outline-none focus:border-bacal-700">
                </div>

                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Sucursal asignada</label>
                    <select name="sucursal_id" class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
                        <option value="">— Todas (ingeniero/admin) —</option>
                        <?php foreach ($sucursales as $s):
                            $sel = $es_edicion ? $u['sucursal_id'] : (string) input('sucursal_id', '');
                        ?>
                        <option value="<?= $s['id'] ?>" <?= (string) $sel === (string) $s['id'] ? 'selected' : '' ?>><?= e($s['nombre']) ?></option>
                        <?php endforeach; ?>
                    </select>
                    <p class="text-[10px] text-zinc-500 mt-1">Deja en "Todas" para ingenieros y admin.</p>
                </div>

                <div>
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Área (para jefes de área)</label>
                    <select name="area_id" class="w-full px-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
                        <option value="">— Ninguna —</option>
                        <?php foreach ($areas as $a):
                            $sel = $es_edicion ? $u['area_id'] : (string) input('area_id', '');
                        ?>
                        <option value="<?= $a['id'] ?>" <?= (string) $sel === (string) $a['id'] ? 'selected' : '' ?>><?= e($a['nombre']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>

                <?php if (!$es_edicion): ?>
                <div class="md:col-span-2">
                    <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Contraseña inicial *</label>
                    <input type="text" name="password" required minlength="8"
                           value="<?= e((string) input('password', '')) ?>"
                           class="w-full px-3 py-2 rounded-lg border border-zinc-300 text-sm font-mono focus:outline-none focus:border-bacal-700">
                    <p class="text-[10px] text-zinc-500 mt-1">El usuario deberá cambiarla en su primer login. Mínimo 8 caracteres.</p>
                </div>
                <?php endif; ?>
            </div>
        </div>

        <div class="flex justify-end gap-2">
            <a href="<?= url('admin/usuarios.php') ?>" class="px-4 py-2 rounded-lg border border-zinc-300 text-zinc-700 text-sm font-medium hover:bg-zinc-50">Cancelar</a>
            <button type="submit" class="px-5 py-2 rounded-lg bg-bacal-700 hover:bg-bacal-800 text-white text-sm font-semibold flex items-center gap-2">
                <i data-lucide="check" class="w-4 h-4"></i> <?= $es_edicion ? 'Guardar cambios' : 'Crear usuario' ?>
            </button>
        </div>
    </form>
</div>

<?php
// ============================================================================
// VISTA: RESETEAR PASSWORD
// ============================================================================
elseif ($accion === 'reset_password' && $usuario_edit):
    $u = $usuario_edit;
?>
<div class="max-w-md mx-auto animate-fade-in">
    <div class="flex items-center gap-3 mb-6">
        <a href="<?= url('admin/usuarios.php') ?>" class="p-2 rounded-lg hover:bg-zinc-100 text-zinc-500">
            <i data-lucide="arrow-left" class="w-5 h-5"></i>
        </a>
        <div>
            <h2 class="font-display text-2xl font-extrabold text-zinc-900">Resetear contraseña</h2>
            <p class="text-xs text-zinc-500"><?= e($u['nombre_completo']) ?> · <span class="font-mono"><?= e($u['usuario']) ?></span></p>
        </div>
    </div>

    <?php if (!empty($errores)): ?>
    <div class="mb-5 px-4 py-3 rounded-lg bg-bacal-50 border border-bacal-200 text-bacal-800 text-sm">
        <ul class="list-disc list-inside text-xs"><?php foreach ($errores as $e): ?><li><?= e($e) ?></li><?php endforeach; ?></ul>
    </div>
    <?php endif; ?>

    <form method="POST" class="bg-white rounded-xl border border-zinc-200 shadow-sm p-6 space-y-4">
        <?= csrf_input() ?>
        <input type="hidden" name="op" value="reset_password">

        <div class="bg-amber-50 border border-amber-200 rounded-lg p-3 text-xs text-amber-800 flex items-start gap-2">
            <i data-lucide="alert-triangle" class="w-4 h-4 flex-shrink-0 mt-0.5"></i>
            <div>
                Vas a establecer una nueva contraseña para <strong><?= e($u['nombre_completo']) ?></strong>.
                El usuario será obligado a cambiarla en su próximo inicio de sesión.
            </div>
        </div>

        <div>
            <label class="block text-xs font-bold text-zinc-700 mb-1 uppercase tracking-wide">Nueva contraseña</label>
            <input type="text" name="password_nuevo" required minlength="8"
                   class="w-full px-3 py-2 rounded-lg border border-zinc-300 text-sm font-mono focus:outline-none focus:border-bacal-700">
            <p class="text-[10px] text-zinc-500 mt-1">Mínimo 8 caracteres. Cópiala antes de enviarla.</p>
        </div>

        <div class="flex justify-end gap-2 pt-2">
            <a href="<?= url('admin/usuarios.php') ?>" class="px-4 py-2 rounded-lg border border-zinc-300 text-zinc-700 text-sm">Cancelar</a>
            <button type="submit" class="px-5 py-2 rounded-lg bg-bacal-700 text-white text-sm font-semibold">Resetear</button>
        </div>
    </form>
</div>

<?php
// ============================================================================
// VISTA: LISTADO
// ============================================================================
else:
    $q = trim((string) input('q', ''));
    $where = [];
    $params = [];
    if ($q !== '') {
        $where[] = "(u.usuario LIKE :q1 OR u.nombre_completo LIKE :q2 OR u.email LIKE :q3)";
        $params['q1'] = "%$q%"; $params['q2'] = "%$q%"; $params['q3'] = "%$q%";
    }
    $where_sql = !empty($where) ? 'WHERE ' . implode(' AND ', $where) : '';

    $usuarios = db_all(
        "SELECT u.*, r.nombre rol_nombre, s.nombre sucursal_nombre, a.nombre area_nombre
         FROM usuarios u
         INNER JOIN roles r ON u.rol_id = r.id
         LEFT JOIN sucursales s ON u.sucursal_id = s.id
         LEFT JOIN areas a ON u.area_id = a.id
         $where_sql
         ORDER BY u.activo DESC, u.nombre_completo ASC",
        $params
    );
?>

<?php render_admin_header('Usuarios', 'Ingenieros, gerentes y jefes de área. ' . count($usuarios) . ' registro(s).', url('admin/usuarios.php?accion=nuevo'), 'Nuevo usuario'); ?>

<!-- Buscador -->
<form method="GET" class="mb-4">
    <div class="relative max-w-sm">
        <i data-lucide="search" class="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-zinc-400"></i>
        <input type="text" name="q" value="<?= e($q) ?>"
               placeholder="Buscar por usuario, nombre o email..."
               class="w-full pl-9 pr-3 py-2 rounded-lg border border-zinc-300 bg-white text-sm focus:outline-none focus:border-bacal-700">
    </div>
</form>

<div class="bg-white rounded-xl border border-zinc-200 shadow-sm overflow-hidden">
    <div class="overflow-x-auto">
        <table class="w-full text-sm">
            <thead class="bg-zinc-50 border-b border-zinc-200">
                <tr>
                    <th class="px-4 py-2.5 text-left text-[10px] font-bold text-zinc-500 uppercase tracking-wider">Usuario</th>
                    <th class="px-4 py-2.5 text-left text-[10px] font-bold text-zinc-500 uppercase tracking-wider">Rol</th>
                    <th class="px-4 py-2.5 text-left text-[10px] font-bold text-zinc-500 uppercase tracking-wider">Sucursal</th>
                    <th class="px-4 py-2.5 text-left text-[10px] font-bold text-zinc-500 uppercase tracking-wider">Área</th>
                    <th class="px-4 py-2.5 text-left text-[10px] font-bold text-zinc-500 uppercase tracking-wider">Último login</th>
                    <th class="px-4 py-2.5 text-center text-[10px] font-bold text-zinc-500 uppercase tracking-wider">Estado</th>
                    <th class="px-4 py-2.5"></th>
                </tr>
            </thead>
            <tbody class="divide-y divide-zinc-100">
                <?php foreach ($usuarios as $usr): ?>
                <tr class="hover:bg-zinc-50 group <?= !$usr['activo'] ? 'opacity-50' : '' ?>">
                    <td class="px-4 py-3">
                        <div class="flex items-center gap-2.5">
                            <div class="w-8 h-8 rounded-full flex items-center justify-center text-white text-xs font-bold shadow-sm flex-shrink-0"
                                 style="background-color: <?= color_avatar($usr['nombre_completo']) ?>">
                                <?= e(iniciales($usr['nombre_completo'])) ?>
                            </div>
                            <div class="min-w-0">
                                <div class="font-semibold text-sm text-zinc-900 truncate"><?= e($usr['nombre_completo']) ?></div>
                                <div class="text-[11px] text-zinc-500 font-mono"><?= e($usr['usuario']) ?></div>
                            </div>
                        </div>
                    </td>
                    <td class="px-4 py-3"><?= badge($usr['rol_nombre'], '#C8102E') ?></td>
                    <td class="px-4 py-3 text-xs text-zinc-700"><?= e($usr['sucursal_nombre'] ?? 'Todas') ?></td>
                    <td class="px-4 py-3 text-xs text-zinc-700"><?= e($usr['area_nombre'] ?? '—') ?></td>
                    <td class="px-4 py-3 text-xs text-zinc-500">
                        <?= $usr['ultimo_login'] ? e(fmt_tiempo_relativo($usr['ultimo_login'])) : 'Nunca' ?>
                    </td>
                    <td class="px-4 py-3 text-center">
                        <?php if ($usr['activo']): ?>
                        <span class="inline-flex items-center gap-1 text-[10px] font-semibold text-emerald-700 bg-emerald-50 border border-emerald-200 px-1.5 py-0.5 rounded-md">
                            <span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span> Activo
                        </span>
                        <?php else: ?>
                        <span class="inline-flex items-center gap-1 text-[10px] font-semibold text-zinc-500 bg-zinc-100 border border-zinc-200 px-1.5 py-0.5 rounded-md">
                            <span class="w-1.5 h-1.5 rounded-full bg-zinc-400"></span> Inactivo
                        </span>
                        <?php endif; ?>
                    </td>
                    <td class="px-4 py-3 text-right">
                        <div class="flex items-center justify-end gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                            <a href="<?= url('admin/usuarios.php?accion=editar&id=' . $usr['id']) ?>"
                               class="p-1.5 rounded-md text-zinc-500 hover:bg-zinc-100 hover:text-zinc-700" title="Editar">
                                <i data-lucide="edit-3" class="w-4 h-4"></i>
                            </a>
                            <a href="<?= url('admin/usuarios.php?accion=reset_password&id=' . $usr['id']) ?>"
                               class="p-1.5 rounded-md text-zinc-500 hover:bg-amber-50 hover:text-amber-700" title="Resetear contraseña">
                                <i data-lucide="key" class="w-4 h-4"></i>
                            </a>
                            <?php if ((int) $usr['id'] !== (int) $u_actual['id']): ?>
                            <form method="POST" action="<?= url('admin/usuarios.php?accion=toggle&id=' . $usr['id']) ?>"
                                  onsubmit="return confirm('¿<?= $usr['activo'] ? 'Desactivar' : 'Activar' ?> a <?= e(addslashes($usr['nombre_completo'])) ?>?');">
                                <?= csrf_input() ?>
                                <input type="hidden" name="op" value="toggle">
                                <button type="submit" class="p-1.5 rounded-md text-zinc-500 hover:bg-bacal-50 hover:text-bacal-700"
                                        title="<?= $usr['activo'] ? 'Desactivar' : 'Activar' ?>">
                                    <i data-lucide="<?= $usr['activo'] ? 'user-x' : 'user-check' ?>" class="w-4 h-4"></i>
                                </button>
                            </form>
                            <?php endif; ?>
                        </div>
                    </td>
                </tr>
                <?php endforeach; ?>
                <?php if (empty($usuarios)): ?>
                <tr><td colspan="7" class="px-4 py-12 text-center text-sm text-zinc-500 italic">Sin usuarios que coincidan.</td></tr>
                <?php endif; ?>
            </tbody>
        </table>
    </div>
</div>

<?php endif; ?>

<?php require_once __DIR__ . '/../config/footer.php'; ?>
