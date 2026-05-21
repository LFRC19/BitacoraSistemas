<?php
/**
 * ============================================================================
 * config/header.php - Layout superior reutilizable
 * ============================================================================
 * Incluye este archivo al inicio de cada página protegida.
 * Variables esperadas:
 *   $titulo_pagina (string) - título mostrado en <title> y en la cabecera
 *   $pagina_activa (string) - identificador de la sección activa para el sidebar
 * ============================================================================
 */
require_once __DIR__ . '/db.php';
require_once __DIR__ . '/auth.php';
require_once __DIR__ . '/helpers.php';

requerir_login();

$u = usuario_actual();
$titulo_pagina = $titulo_pagina ?? 'Inicio';
$pagina_activa = $pagina_activa ?? '';
$mensajes_flash = flash_get();

// Conteo de notificaciones no leídas
$notif_count = (int) (db_one(
    "SELECT COUNT(*) c FROM notificaciones WHERE usuario_id = :uid AND leida = 0",
    ['uid' => $u['id']]
)['c'] ?? 0);
?><!DOCTYPE html>
<html lang="es" class="h-full">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= e($titulo_pagina) ?> · <?= e(APP_NAME) ?></title>

    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>

    <!-- Fuentes: Bricolage Grotesque para títulos, Inter para UI -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wght@12..96,400;12..96,500;12..96,600;12..96,700;12..96,800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

    <!-- Alpine.js (debe cargar ANTES que lucide para que el DOM dinámico funcione) -->
    <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>

    <!-- Lucide icons -->
    <script src="https://unpkg.com/lucide@latest"></script>

    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: {
                        sans: ['Inter', 'system-ui', 'sans-serif'],
                        display: ['"Bricolage Grotesque"', 'system-ui', 'sans-serif'],
                    },
                    colors: {
                        bacal: {
                            50:  '#FEF2F2',
                            100: '#FEE2E2',
                            200: '#FECACA',
                            300: '#FCA5A5',
                            400: '#F87171',
                            500: '#EF4444',
                            600: '#DC2626',
                            700: '#C8102E',  // rojo corporativo
                            800: '#991B1B',
                            900: '#7F1D1D',
                        },
                        gold: {
                            400: '#F2C94C',
                            500: '#E8B923',
                            600: '#D4A017',
                        }
                    },
                    animation: {
                        'fade-in': 'fadeIn 0.3s ease-out',
                        'slide-up': 'slideUp 0.4s ease-out',
                    },
                    keyframes: {
                        fadeIn: {
                            '0%': { opacity: '0' },
                            '100%': { opacity: '1' }
                        },
                        slideUp: {
                            '0%': { opacity: '0', transform: 'translateY(10px)' },
                            '100%': { opacity: '1', transform: 'translateY(0)' }
                        }
                    }
                }
            }
        }
    </script>

    <style>
        body { font-family: 'Inter', sans-serif; }
        .font-display { font-family: 'Bricolage Grotesque', sans-serif; letter-spacing: -0.02em; }

        /* Oculta elementos con x-cloak hasta que Alpine los procese */
        [x-cloak] { display: none !important; }

        /* Scrollbar discreto */
        ::-webkit-scrollbar { width: 8px; height: 8px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb { background: #d4d4d8; border-radius: 4px; }
        ::-webkit-scrollbar-thumb:hover { background: #a1a1aa; }

        /* Item activo del sidebar */
        .nav-item-active {
            background: linear-gradient(90deg, rgba(200,16,46,0.08) 0%, rgba(200,16,46,0.02) 100%);
            color: #C8102E;
            border-left: 3px solid #C8102E;
        }
        .nav-item-active svg { color: #C8102E; }

        /* Transición sutil al hover */
        .nav-item {
            border-left: 3px solid transparent;
            transition: all 0.15s ease;
        }
        .nav-item:hover {
            background: rgba(0,0,0,0.03);
        }
    </style>
</head>
<body class="h-full bg-zinc-50 text-zinc-900 antialiased">

<div class="flex h-screen overflow-hidden" x-data="{ sidebarAbierto: true, menuUsuario: false }">

    <!-- ============================================================ -->
    <!-- SIDEBAR -->
    <!-- ============================================================ -->
    <aside class="bg-white border-r border-zinc-200 flex-shrink-0 transition-all duration-300 flex flex-col"
           :class="sidebarAbierto ? 'w-64' : 'w-16'">

        <!-- Logo / Marca -->
        <div class="h-16 flex items-center border-b border-zinc-200 px-4 flex-shrink-0">
            <a href="<?= url('dashboard.php') ?>" class="flex items-center gap-2.5 overflow-hidden">
                <div class="w-9 h-9 flex-shrink-0 rounded-lg bg-bacal-700 flex items-center justify-center text-white font-display font-bold text-lg shadow-sm">
                    B
                </div>
                <div x-show="sidebarAbierto" x-transition.opacity class="overflow-hidden">
                    <div class="font-display font-bold text-zinc-900 text-base leading-tight">Carnes Bacal</div>
                    <div class="text-[10px] text-zinc-500 uppercase tracking-wider font-semibold">Bitácora · Sistemas</div>
                </div>
            </a>
        </div>

        <!-- Navegación principal -->
        <nav class="flex-1 overflow-y-auto py-4">

            <div class="px-3 mb-2" x-show="sidebarAbierto" x-transition.opacity>
                <div class="text-[10px] uppercase tracking-wider font-bold text-zinc-400 px-3">Principal</div>
            </div>

            <a href="<?= url('dashboard.php') ?>"
               class="nav-item <?= $pagina_activa === 'dashboard' ? 'nav-item-active' : 'text-zinc-700' ?> flex items-center gap-3 px-4 py-2.5 text-sm font-medium">
                <i data-lucide="layout-dashboard" class="w-5 h-5 flex-shrink-0 text-zinc-500"></i>
                <span x-show="sidebarAbierto" x-transition.opacity>Dashboard</span>
            </a>

            <a href="<?= url('bitacora.php') ?>"
               class="nav-item <?= $pagina_activa === 'bitacora' ? 'nav-item-active' : 'text-zinc-700' ?> flex items-center gap-3 px-4 py-2.5 text-sm font-medium">
                <i data-lucide="book-text" class="w-5 h-5 flex-shrink-0 text-zinc-500"></i>
                <span x-show="sidebarAbierto" x-transition.opacity>Bitácora</span>
            </a>

            <?php if (tiene_permiso('crear_solicitud')): ?>
            <a href="<?= url('incidencia_nueva.php') ?>"
               class="nav-item <?= $pagina_activa === 'nueva' ? 'nav-item-active' : 'text-zinc-700' ?> flex items-center gap-3 px-4 py-2.5 text-sm font-medium">
                <i data-lucide="plus-circle" class="w-5 h-5 flex-shrink-0 text-zinc-500"></i>
                <span x-show="sidebarAbierto" x-transition.opacity>Nueva solicitud</span>
            </a>
            <?php endif; ?>

            <?php if (tiene_permiso('ver_reportes')): ?>
            <div class="px-3 mt-6 mb-2" x-show="sidebarAbierto" x-transition.opacity>
                <div class="text-[10px] uppercase tracking-wider font-bold text-zinc-400 px-3">Análisis</div>
            </div>

            <a href="<?= url('reportes/reportes.php') ?>"
               class="nav-item <?= $pagina_activa === 'reportes' ? 'nav-item-active' : 'text-zinc-700' ?> flex items-center gap-3 px-4 py-2.5 text-sm font-medium">
                <i data-lucide="bar-chart-3" class="w-5 h-5 flex-shrink-0 text-zinc-500"></i>
                <span x-show="sidebarAbierto" x-transition.opacity>Reportes</span>
            </a>
            <?php endif; ?>

            <?php if (tiene_permiso('administrar')): ?>
            <div class="px-3 mt-6 mb-2" x-show="sidebarAbierto" x-transition.opacity>
                <div class="text-[10px] uppercase tracking-wider font-bold text-zinc-400 px-3">Administración</div>
            </div>

            <a href="<?= url('admin/usuarios.php') ?>"
               class="nav-item <?= $pagina_activa === 'admin_usuarios' ? 'nav-item-active' : 'text-zinc-700' ?> flex items-center gap-3 px-4 py-2.5 text-sm font-medium">
                <i data-lucide="users" class="w-5 h-5 flex-shrink-0 text-zinc-500"></i>
                <span x-show="sidebarAbierto" x-transition.opacity>Usuarios</span>
            </a>

            <a href="<?= url('admin/sucursales.php') ?>"
               class="nav-item <?= $pagina_activa === 'admin_sucursales' ? 'nav-item-active' : 'text-zinc-700' ?> flex items-center gap-3 px-4 py-2.5 text-sm font-medium">
                <i data-lucide="store" class="w-5 h-5 flex-shrink-0 text-zinc-500"></i>
                <span x-show="sidebarAbierto" x-transition.opacity>Sucursales</span>
            </a>

            <a href="<?= url('admin/areas.php') ?>"
               class="nav-item <?= $pagina_activa === 'admin_areas' ? 'nav-item-active' : 'text-zinc-700' ?> flex items-center gap-3 px-4 py-2.5 text-sm font-medium">
                <i data-lucide="layers" class="w-5 h-5 flex-shrink-0 text-zinc-500"></i>
                <span x-show="sidebarAbierto" x-transition.opacity>Áreas</span>
            </a>

            <a href="<?= url('admin/equipos.php') ?>"
               class="nav-item <?= $pagina_activa === 'admin_equipos' ? 'nav-item-active' : 'text-zinc-700' ?> flex items-center gap-3 px-4 py-2.5 text-sm font-medium">
                <i data-lucide="monitor" class="w-5 h-5 flex-shrink-0 text-zinc-500"></i>
                <span x-show="sidebarAbierto" x-transition.opacity>Equipos</span>
            </a>

            <a href="<?= url('admin/catalogos.php') ?>"
               class="nav-item <?= $pagina_activa === 'admin_catalogos' ? 'nav-item-active' : 'text-zinc-700' ?> flex items-center gap-3 px-4 py-2.5 text-sm font-medium">
                <i data-lucide="tags" class="w-5 h-5 flex-shrink-0 text-zinc-500"></i>
                <span x-show="sidebarAbierto" x-transition.opacity>Catálogos</span>
            </a>

            <a href="<?= url('admin/auditoria.php') ?>"
               class="nav-item <?= $pagina_activa === 'admin_auditoria' ? 'nav-item-active' : 'text-zinc-700' ?> flex items-center gap-3 px-4 py-2.5 text-sm font-medium">
                <i data-lucide="shield-check" class="w-5 h-5 flex-shrink-0 text-zinc-500"></i>
                <span x-show="sidebarAbierto" x-transition.opacity>Auditoría</span>
            </a>
            <?php endif; ?>
        </nav>

        <!-- Footer del sidebar: usuario + logout + colapsar -->
        <div class="border-t border-zinc-200 flex-shrink-0">

            <!-- Tarjeta de usuario -->
            <div class="px-3 pt-3 pb-2" x-show="sidebarAbierto" x-transition.opacity>
                <div class="flex items-center gap-2.5">
                    <div class="w-9 h-9 rounded-full flex items-center justify-center text-white text-xs font-bold shadow-sm flex-shrink-0"
                         style="background-color: <?= color_avatar($u['nombre']) ?>">
                        <?= e(iniciales($u['nombre'])) ?>
                    </div>
                    <div class="flex-1 min-w-0">
                        <div class="text-sm font-semibold text-zinc-900 truncate leading-tight"><?= e(explode(' ', $u['nombre'])[0]) ?></div>
                        <div class="text-[10px] text-zinc-500 truncate"><?= e($u['rol_nombre']) ?></div>
                    </div>
                </div>
            </div>

            <!-- Avatar compacto cuando sidebar está colapsado -->
            <div class="px-2 pt-3 pb-2 flex justify-center" x-show="!sidebarAbierto" x-cloak>
                <div class="w-9 h-9 rounded-full flex items-center justify-center text-white text-xs font-bold shadow-sm"
                     style="background-color: <?= color_avatar($u['nombre']) ?>"
                     title="<?= e($u['nombre']) ?>">
                    <?= e(iniciales($u['nombre'])) ?>
                </div>
            </div>

            <!-- BOTÓN DE LOGOUT (siempre visible y prominente) -->
            <div class="px-2 pb-2">
                <a href="<?= url('logout.php') ?>"
                   title="Cerrar sesión"
                   class="flex items-center justify-center gap-2 w-full px-3 py-2.5 rounded-lg bg-bacal-50 hover:bg-bacal-100 text-bacal-700 text-sm font-semibold transition-colors border border-bacal-200">
                    <!-- SVG inline para que no dependa de Lucide -->
                    <svg class="w-4 h-4 flex-shrink-0" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/>
                    </svg>
                    <span x-show="sidebarAbierto" x-transition.opacity>Cerrar sesión</span>
                </a>
            </div>

            <!-- Botón colapsar sidebar -->
            <div class="border-t border-zinc-100 p-2">
                <button @click="sidebarAbierto = !sidebarAbierto"
                        class="w-full flex items-center justify-center gap-2 px-3 py-2 rounded-md text-zinc-500 hover:bg-zinc-100 text-sm">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" x-show="sidebarAbierto">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M11 19l-7-7 7-7M19 19l-7-7 7-7"/>
                    </svg>
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" x-show="!sidebarAbierto" x-cloak>
                        <path stroke-linecap="round" stroke-linejoin="round" d="M13 5l7 7-7 7M5 5l7 7-7 7"/>
                    </svg>
                    <span x-show="sidebarAbierto" x-transition.opacity class="text-xs">Colapsar</span>
                </button>
            </div>
        </div>
    </aside>

    <!-- ============================================================ -->
    <!-- ÁREA PRINCIPAL -->
    <!-- ============================================================ -->
    <div class="flex-1 flex flex-col overflow-hidden">

        <!-- Topbar -->
        <header class="h-16 bg-white border-b border-zinc-200 flex items-center justify-between px-6 flex-shrink-0">
            <div class="flex items-center gap-3">
                <h1 class="font-display font-bold text-xl text-zinc-900"><?= e($titulo_pagina) ?></h1>
            </div>

            <div class="flex items-center gap-2">

                <!-- Notificaciones -->
                <button class="relative p-2 rounded-md hover:bg-zinc-100 text-zinc-600">
                    <i data-lucide="bell" class="w-5 h-5"></i>
                    <?php if ($notif_count > 0): ?>
                    <span class="absolute top-1 right-1 w-4 h-4 bg-bacal-700 text-white text-[10px] font-bold rounded-full flex items-center justify-center">
                        <?= $notif_count > 9 ? '9+' : $notif_count ?>
                    </span>
                    <?php endif; ?>
                </button>

                <!-- Menú de usuario -->
                <div class="relative" @click.outside="menuUsuario = false">
                    <button @click="menuUsuario = !menuUsuario"
                            class="flex items-center gap-2.5 pl-2 pr-3 py-1.5 rounded-md hover:bg-zinc-100 transition-colors">
                        <div class="w-8 h-8 rounded-full flex items-center justify-center text-white text-xs font-bold shadow-sm"
                             style="background-color: <?= color_avatar($u['nombre']) ?>">
                            <?= e(iniciales($u['nombre'])) ?>
                        </div>
                        <div class="text-left hidden md:block">
                            <div class="text-sm font-semibold text-zinc-900 leading-tight"><?= e($u['nombre']) ?></div>
                            <div class="text-[11px] text-zinc-500"><?= e($u['rol_nombre']) ?></div>
                        </div>
                        <i data-lucide="chevron-down" class="w-4 h-4 text-zinc-400"></i>
                    </button>

                    <div x-show="menuUsuario" x-transition x-cloak
                         class="absolute right-0 mt-2 w-64 bg-white rounded-lg shadow-lg border border-zinc-200 py-2 z-50">

                        <div class="px-4 py-3 border-b border-zinc-100">
                            <div class="font-semibold text-sm text-zinc-900"><?= e($u['nombre']) ?></div>
                            <div class="text-xs text-zinc-500 mt-0.5"><?= e($u['email'] ?? '') ?></div>
                            <div class="mt-2">
                                <?= badge($u['rol_nombre'], '#C8102E') ?>
                            </div>
                        </div>

                        <a href="<?= url('cambiar_password.php') ?>"
                           @click.stop
                           class="flex items-center gap-2.5 px-4 py-2 text-sm text-zinc-700 hover:bg-zinc-50">
                            <i data-lucide="key" class="w-4 h-4 text-zinc-400"></i>
                            Cambiar contraseña
                        </a>

                        <div class="border-t border-zinc-100 my-1"></div>

                        <a href="<?= url('logout.php') ?>"
                           @click.stop
                           class="flex items-center gap-2.5 px-4 py-2 text-sm text-bacal-700 hover:bg-bacal-50 font-semibold">
                            <i data-lucide="log-out" class="w-4 h-4"></i>
                            Cerrar sesión
                        </a>
                    </div>
                </div>
            </div>
        </header>

        <!-- Contenido scrolleable -->
        <main class="flex-1 overflow-y-auto">

            <!-- Mensajes flash -->
            <?php if (!empty($mensajes_flash)): ?>
            <div class="px-6 pt-4 space-y-2">
                <?php foreach ($mensajes_flash as $f):
                    $estilos = [
                        'success' => 'bg-emerald-50 border-emerald-300 text-emerald-800',
                        'error'   => 'bg-bacal-50 border-bacal-300 text-bacal-800',
                        'warning' => 'bg-amber-50 border-amber-300 text-amber-800',
                        'info'    => 'bg-blue-50 border-blue-300 text-blue-800',
                    ];
                    $estilo = $estilos[$f['tipo']] ?? $estilos['info'];
                    $iconos = ['success' => 'check-circle', 'error' => 'alert-circle', 'warning' => 'alert-triangle', 'info' => 'info'];
                    $icono = $iconos[$f['tipo']] ?? 'info';
                ?>
                <div class="border rounded-lg px-4 py-3 flex items-start gap-3 animate-slide-up <?= $estilo ?>">
                    <i data-lucide="<?= $icono ?>" class="w-5 h-5 flex-shrink-0 mt-0.5"></i>
                    <div class="text-sm flex-1"><?= e($f['mensaje']) ?></div>
                </div>
                <?php endforeach; ?>
            </div>
            <?php endif; ?>

            <!-- Aquí va el contenido de cada página -->
            <div class="p-6">