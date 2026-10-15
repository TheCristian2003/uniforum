<!-- UniVibe Uniguajira — Perfil Gamificado -->
<!DOCTYPE html>

<html class="light" lang="es"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>UniVibe Uniguajira - Mi Perfil</title>
<!-- Material Symbols Outlined Font -->
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<!-- Google Fonts: Plus Jakarta Sans -->
<link href="https://fonts.googleapis.com" rel="preconnect"/>
<link crossorigin="" href="https://fonts.gstatic.com" rel="preconnect"/>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet"/>
<!-- Tailwind CSS CDN -->
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<script id="tailwind-config">
  tailwind.config = {
    darkMode: "class",
    theme: {
      extend: {
        "colors": {
          "on-error-container": "#93000a",
          "on-tertiary-container": "#ffffff",
          "surface-variant": "#e0e0fc",
          "outline": "#837561",
          "surface-container": "#f6f3eb",
          "on-surface": "#1e1e1e",
          "on-primary-fixed-variant": "#5f4100",
          "on-surface-variant": "#514533",
          "on-secondary-fixed-variant": "#07497d",
          "tertiary-container": "#c81d25",
          "primary-container": "#f2ae1c",
          "surface-container-lowest": "#ffffff",
          "on-primary": "#ffffff",
          "error-container": "#ffdad6",
          "inverse-primary": "#ffba30",
          "surface": "#fbf8f5",
          "primary-fixed-dim": "#ffba30",
          "primary": "#d99709",
          "on-secondary-container": "#ffffff",
          "on-error": "#ffffff",
          "outline-variant": "#e5dcce",
          "on-secondary-fixed": "#001c37",
          "secondary": "#0f4c81",
          "secondary-container": "#1565c0",
          "tertiary-fixed": "#ffdad6",
          "on-tertiary-fixed": "#410003",
          "inverse-on-surface": "#f1efff",
          "secondary-fixed-dim": "#a0c9ff",
          "on-primary-fixed": "#271900",
          "secondary-fixed": "#d2e4ff",
          "tertiary-fixed-dim": "#ffb3ad",
          "surface-bright": "#fbf8f5",
          "surface-container-highest": "#eae5d8",
          "on-background": "#1c1b18",
          "surface-container-high": "#f0ebd9",
          "surface-container-low": "#faf7f0",
          "inverse-surface": "#2d2f44",
          "on-primary-container": "#4a3500",
          "on-secondary": "#ffffff",
          "surface-tint": "#f2ae1c",
          "error": "#ba1a1a",
          "primary-fixed": "#ffdeab",
          "on-tertiary-fixed-variant": "#930011",
          "on-tertiary": "#ffffff",
          "surface-dim": "#d7d8f4",
          "background": "#fbf8f5",
          "tertiary": "#c81d25",
          "ug-yellow": "#f2ae1c",
          "ug-yellow-dark": "#d89608",
          "ug-red": "#c81d25",
          "ug-red-light": "#fde8e9",
          "ug-blue": "#0f4c81",
          "ug-blue-light": "#e8f1f9"
        },
        "borderRadius": {
          "DEFAULT": "0.25rem",
          "lg": "0.5rem",
          "xl": "0.75rem",
          "full": "9999px"
        },
        "spacing": {
          "margin": "1rem",
          "margin-desktop": "3rem",
          "space-xl": "2.5rem",
          "space-xs": "0.25rem",
          "space-sm": "0.5rem",
          "gutter": "1.25rem",
          "gutter-desktop": "1.5rem",
          "margin-tablet": "2rem",
          "space-md": "1rem",
          "space-lg": "1.5rem"
        },
        "fontFamily": {
          "title-md": ["Plus Jakarta Sans"],
          "label-sm": ["Plus Jakarta Sans"],
          "label-md": ["Plus Jakarta Sans"],
          "body-md": ["Plus Jakarta Sans"],
          "headline-lg-mobile": ["Plus Jakarta Sans"],
          "headline-lg": ["Plus Jakarta Sans"],
          "headline-sm": ["Plus Jakarta Sans"],
          "display-lg": ["Plus Jakarta Sans"],
          "body-lg": ["Plus Jakarta Sans"],
          "display-lg-mobile": ["Plus Jakarta Sans"],
          "headline-md": ["Plus Jakarta Sans"]
        },
        "fontSize": {
          "title-md": ["18px", { "lineHeight": "24px", "fontWeight": "600" }],
          "label-sm": ["11px", { "lineHeight": "16px", "letterSpacing": "0.04em", "fontWeight": "700" }],
          "label-md": ["13px", { "lineHeight": "18px", "letterSpacing": "0.01em", "fontWeight": "600" }],
          "body-md": ["14px", { "lineHeight": "22px", "fontWeight": "400" }],
          "headline-lg-mobile": ["24px", { "lineHeight": "32px", "letterSpacing": "-0.01em", "fontWeight": "700" }],
          "headline-lg": ["32px", { "lineHeight": "40px", "letterSpacing": "-0.01em", "fontWeight": "700" }],
          "headline-sm": ["20px", { "lineHeight": "28px", "fontWeight": "600" }],
          "display-lg": ["48px", { "lineHeight": "56px", "letterSpacing": "-0.02em", "fontWeight": "800" }],
          "body-lg": ["16px", { "lineHeight": "26px", "fontWeight": "400" }],
          "display-lg-mobile": ["32px", { "lineHeight": "40px", "letterSpacing": "-0.015em", "fontWeight": "800" }],
          "headline-md": ["24px", { "lineHeight": "32px", "fontWeight": "600" }]
        }
      }
    }
  }
</script>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
</head>
<body class="bg-background text-on-surface font-body-md antialiased min-h-screen pb-[104px]">
<!-- Top App Bar (Shared Anchor Blueprint) -->
<header class="fixed top-0 left-0 w-full z-40 bg-surface shadow-sm max-w-screen-md mx-auto inset-x-0 border-b border-surface-container-highest">
<div class="flex justify-between items-center px-margin py-space-sm h-16">
<!-- Title & Student Avatar -->
<div class="flex items-center gap-space-sm">
<div class="relative w-9 h-9 rounded-full ring-2 ring-ug-yellow p-0.5 bg-surface-container-lowest">
<img class="w-full h-full object-cover rounded-full" data-alt="A clean, friendly portrait of a male computer engineering university student with stylish glasses and a subtle smile, captured in soft indoor studio lighting with high clarity. The aesthetic matches modern tech campus minimalism with accents of indigo and crisp white." src="https://lh3.googleusercontent.com/aida-public/AB6AXuC_fwXEEd9RdhpOkpOKEfBT73OydcKvMSPcpcsSNkd8PdLTC4DRLJvdApPYEWzRZgc5oW4fW4RKnebZnoRX3gI5pdVQGnF2ERdPr4WOmgbmcTeDgmI4L2q76lL-W3XvGja6QfAUez3uUztnwDE8kxAa5GPwjQfBzSL31G-iXvIKDHqolz4ChV7fYfVXW0hRuL1DQJxD_3N2Sfj4oyIm3zmhw9w71FgO8uuP3bk6IeUK"/>
<span class="absolute -bottom-1 -right-1 bg-ug-yellow text-on-primary-container text-[9px] font-extrabold px-1 py-0.2 rounded-full border border-surface-container-lowest shadow-sm">N3</span>
</div>
<div>
<h1 class="text-headline-lg-mobile font-headline-lg-mobile font-extrabold text-ug-blue tracking-tight">Mi Perfil</h1>
</div>
</div>
<!-- Action Icons Cluster -->
<div class="flex items-center gap-space-xs text-on-surface-variant">
<button aria-label="Compartir perfil" class="p-2 rounded-full hover:bg-surface-container active:scale-95 transition-transform duration-150">
<span class="material-symbols-outlined text-[22px]">share</span>
</button>
<button aria-label="Código QR de estudiante" class="p-2 rounded-full hover:bg-surface-container active:scale-95 transition-transform duration-150">
<span class="material-symbols-outlined text-[22px]">qr_code_2</span>
</button>
<button aria-label="Configuración" class="p-2 rounded-full hover:bg-surface-container active:scale-95 transition-transform duration-150">
<span class="material-symbols-outlined text-[22px]">settings</span>
</button>
</div>
</div>
</header>
<!-- Main Canvas Container -->
<main class="max-w-screen-md mx-auto pt-20 px-margin space-y-space-lg">
<!-- Tarjeta Principal de Perfil (Hero Gamificado Bento - Identidad Uniguajira) -->
<section class="relative bg-surface-container-lowest rounded-xl p-space-lg border border-surface-container-highest shadow-sm overflow-hidden">
<!-- Decorative Atmospheric Glow Backdrop - Tonos Institucionales Uniguajira -->
<div class="absolute -top-16 -right-16 w-44 h-44 bg-ug-yellow/15 rounded-full blur-2xl pointer-events-none"></div>
<div class="absolute -bottom-16 -left-16 w-44 h-44 bg-ug-blue/10 rounded-full blur-2xl pointer-events-none"></div>
<div class="relative flex flex-col md:flex-row items-center md:items-start gap-space-lg">
<!-- Large Avatar with Uniguajira Gold Aura Ring -->
<div class="relative shrink-0">
<div class="w-24 h-24 rounded-full p-1 bg-gradient-to-tr from-ug-yellow via-amber-300 to-ug-red shadow-md">
<div class="w-full h-full rounded-full bg-surface-container-lowest p-0.5 overflow-hidden">
<img class="w-full h-full object-cover rounded-full" data-alt="Close-up portrait of Mateo Silva, an energetic young engineering student smiling in a modern campus makerspace lounge. The scene features ambient neon and natural library light, with modern collegiate tech elements in sharp focus, set against high-end architectural glass walls." src="https://lh3.googleusercontent.com/aida-public/AB6AXuDbMuBm2v_8aF4aWL5bmWwg5gErVgGgFvNESRsl2_BPiUhLr1zUPrAKsgEF3UxZclcKlojb6gX270AiUFgNJ_FMj5CpY2btlqfxf30nhHaWYRdO72ou8vuq5zQfQDlLylv323VWowVwGth8drFwbhPJ1mKabTXkrx4ZWavLcKgen_unawu8bE4n-qkPuBdjf7wuxiNrzn9bvMhHZaWf-Gb8ViCIvbSqcgb4PBLyntcU"/>
</div>
</div>
<!-- Level Floating Shield Badge (Amarillo institucional) -->
<div class="absolute -bottom-2 inset-x-0 mx-auto w-fit flex items-center gap-1 bg-gradient-to-r from-ug-yellow to-amber-500 text-on-primary-container text-label-sm font-label-sm px-2.5 py-0.5 rounded-full shadow font-extrabold border border-amber-200">
<span class="material-symbols-outlined text-[13px] text-amber-900" data-weight="fill" style="font-variation-settings: 'FILL' 1;">star</span>
<span class="text-amber-950 font-bold">NIVEL 3</span>
</div>
</div>
<!-- Student Identity Details -->
<div class="flex-1 text-center md:text-left space-y-space-xs">
<div class="flex flex-col md:flex-row md:items-center justify-between gap-1">
<div>
<div class="flex items-center justify-center md:justify-start gap-2">
<h2 class="text-headline-lg-mobile font-headline-lg-mobile text-on-background tracking-tight">Mateo Silva</h2>
<span class="material-symbols-outlined text-ug-blue text-[20px]" data-weight="fill" style="font-variation-settings: 'FILL' 1;" title="Estudiante Verificado Uniguajira">verified</span>
</div>
<p class="text-body-md font-body-md text-outline font-semibold">@mateo_dev</p>
</div>
<!-- Gamified State Badge (Rojo institucional alerta activa) -->
<div class="inline-flex items-center gap-1.5 px-3 py-1 bg-ug-red-light border border-ug-red/30 rounded-full w-fit mx-auto md:mx-0">
<span class="w-2 h-2 rounded-full bg-ug-red animate-pulse"></span>
<span class="text-label-sm font-label-sm text-ug-red tracking-wider uppercase font-bold">ACTIVO • TOP 5%</span>
</div>
</div>
<!-- Role / Faculty Badge - Azul Institucional Uniguajira -->
<div class="pt-1">
<span class="inline-flex items-center gap-1.5 bg-ug-blue-light text-ug-blue font-label-md text-label-md px-3 py-1 rounded-lg border border-ug-blue/20">
<span class="material-symbols-outlined text-[16px]">school</span>
              Estudiante • Ingeniería de Sistemas - Uniguajira • Semestre 6
            </span>
</div>
<!-- EXP Progress Bar Segment (Amarillo Uniguajira) -->
<div class="pt-space-sm space-y-1.5">
<div class="flex justify-between items-baseline text-label-md font-label-md">
<span class="text-on-surface font-semibold">127 / 150 EXP</span>
<span class="text-ug-blue font-bold">Nivel 4 (Referente)</span>
</div>
<!-- Kinetic Multi-gradient Bar (85% filled) con Amarillo Uniguajira -->
<div class="w-full h-3 bg-surface-container rounded-full overflow-hidden p-0.5 border border-surface-container-highest">
<div class="h-full rounded-full bg-gradient-to-r from-amber-300 via-ug-yellow to-amber-500 w-[85%] transition-all duration-500 shadow-sm"></div>
</div>
<div class="flex justify-between items-center pt-0.5">
<span class="inline-flex items-center gap-1 text-[11px] text-amber-900 font-semibold bg-amber-100 px-2.5 py-0.5 rounded-full border border-amber-200">
<span class="material-symbols-outlined text-[13px] text-ug-yellow-dark">bolt</span>
                +23 EXP restantes para subir de rango
              </span>
<span class="text-body-md font-body-md text-outline">85% completado</span>
</div>
</div>
</div>
</div>
</section>
<!-- Key Gamification Statistics Pills (4 Column Asymmetric Grid) -->
<section>
<div class="grid grid-cols-2 md:grid-cols-4 gap-space-sm">
<!-- Stat Card 1 -->
<div class="bg-surface-container-lowest p-space-md rounded-xl border border-surface-container-highest shadow-sm hover:border-ug-blue/30 transition-all flex items-center gap-3">
<div class="w-10 h-10 rounded-lg bg-ug-blue-light text-ug-blue flex items-center justify-center shrink-0">
<span class="material-symbols-outlined text-[20px]">edit_note</span>
</div>
<div>
<div class="text-title-md font-title-md text-on-surface">18</div>
<div class="text-label-sm font-label-sm text-on-surface-variant">Publicaciones</div>
</div>
</div>
<!-- Stat Card 2 -->
<div class="bg-surface-container-lowest p-space-md rounded-xl border border-surface-container-highest shadow-sm hover:border-ug-blue/30 transition-all flex items-center gap-3">
<div class="w-10 h-10 rounded-lg bg-ug-blue-light text-ug-blue flex items-center justify-center shrink-0">
<span class="material-symbols-outlined text-[20px]">chat_bubble</span>
</div>
<div>
<div class="text-title-md font-title-md text-on-surface">64</div>
<div class="text-label-sm font-label-sm text-on-surface-variant">Comentarios</div>
</div>
</div>
<!-- Stat Card 3 (Featured Boost - Amarillo Institucional) -->
<div class="bg-surface-container-lowest p-space-md rounded-xl border border-surface-container-highest shadow-sm hover:border-ug-yellow/40 transition-all flex items-center gap-3 relative overflow-hidden">
<div class="w-10 h-10 rounded-lg bg-amber-100 text-amber-800 flex items-center justify-center shrink-0">
<span class="material-symbols-outlined text-[20px]" data-weight="fill" style="font-variation-settings: 'FILL' 1;">lightbulb</span>
</div>
<div>
<div class="flex items-center gap-1">
<span class="text-title-md font-title-md text-on-surface">12</span>
<span class="text-[9px] bg-ug-yellow text-amber-950 px-1 rounded font-extrabold">+15 pts</span>
</div>
<div class="text-label-sm font-label-sm text-on-surface-variant">Soluciones</div>
</div>
</div>
<!-- Stat Card 4 (Rojo Prestigio Uniguajira) -->
<div class="bg-surface-container-lowest p-space-md rounded-xl border border-surface-container-highest shadow-sm hover:border-ug-red/30 transition-all flex items-center gap-3">
<div class="w-10 h-10 rounded-lg bg-ug-red-light text-ug-red flex items-center justify-center shrink-0">
<span class="material-symbols-outlined text-[20px]" data-weight="fill" style="font-variation-settings: 'FILL' 1;">rocket_launch</span>
</div>
<div>
<div class="text-title-md font-title-md text-on-surface">248</div>
<div class="text-label-sm font-label-sm text-on-surface-variant">Votos Recibidos</div>
</div>
</div>
</div>
</section>
<!-- Vitrina de Distintivos (Gamification Showcase Uniguajira) -->
<section class="bg-surface-container-lowest rounded-xl p-space-lg border border-surface-container-highest shadow-sm space-y-space-md">
<!-- Showcase Header -->
<div class="flex flex-col sm:flex-row sm:items-center justify-between gap-1 pb-space-xs border-b border-surface-container-highest">
<div>
<div class="flex items-center gap-2">
<span class="material-symbols-outlined text-ug-yellow-dark text-[24px]" data-weight="fill" style="font-variation-settings: 'FILL' 1;">military_tech</span>
<h3 class="text-title-md font-title-md text-on-surface">VITRINA DE DISTINTIVOS</h3>
</div>
<p class="text-body-md font-body-md text-on-surface-variant">8 de 16 desbloqueados • <span class="text-ug-red font-bold">127 puntos de prestigio</span></p>
</div>
<button class="inline-flex items-center gap-1 text-label-md font-label-md text-ug-blue hover:text-secondary-container transition-colors py-1">
<span>Ver catálogo completo</span>
<span class="material-symbols-outlined text-[16px]">chevron_right</span>
</button>
</div>
<!-- Badge Grid (Bento Trophy Presentation - 8 distintivos preservados) -->
<div class="grid grid-cols-2 sm:grid-cols-4 gap-space-sm">
<!-- Distintivo 1: Primer Paso (Amarillo institucional) -->
<div class="group relative bg-surface-container-low/70 rounded-xl p-3 border-2 border-ug-yellow flex flex-col items-center text-center hover:bg-surface-container-lowest transition-all">
<div class="w-12 h-12 rounded-full bg-amber-100 flex items-center justify-center text-amber-700 mb-2 shadow-inner group-hover:scale-110 transition-transform">
<span class="material-symbols-outlined text-[26px]" data-weight="fill" style="font-variation-settings: 'FILL' 1;">star</span>
</div>
<h4 class="text-label-md font-label-md text-on-surface">Primer Paso</h4>
<p class="text-[10px] text-on-surface-variant leading-tight mt-1">Por publicar tu primer post</p>
<span class="mt-2 text-[9px] font-bold text-amber-900 bg-amber-200/70 px-2 py-0.5 rounded-full">Desbloqueado</span>
</div>
<!-- Distintivo 2: Buen Samaritano -->
<div class="group relative bg-surface-container-low/70 rounded-xl p-3 border-2 border-emerald-500 flex flex-col items-center text-center hover:bg-surface-container-lowest transition-all">
<div class="w-12 h-12 rounded-full bg-emerald-100 flex items-center justify-center text-emerald-600 mb-2 shadow-inner group-hover:scale-110 transition-transform">
<span class="material-symbols-outlined text-[26px]">handshake</span>
</div>
<h4 class="text-label-md font-label-md text-on-surface">Buen Samaritano</h4>
<p class="text-[10px] text-on-surface-variant leading-tight mt-1">Devolver objeto perdido</p>
<span class="mt-2 text-[9px] font-bold text-emerald-800 bg-emerald-200/60 px-2 py-0.5 rounded-full">Desbloqueado</span>
</div>
<!-- Distintivo 3: Resuelve-dudas (Azul Uniguajira) -->
<div class="group relative bg-surface-container-low/70 rounded-xl p-3 border-2 border-ug-blue flex flex-col items-center text-center hover:bg-surface-container-lowest transition-all">
<div class="w-12 h-12 rounded-full bg-ug-blue-light flex items-center justify-center text-ug-blue mb-2 shadow-inner group-hover:scale-110 transition-transform">
<span class="material-symbols-outlined text-[26px]">psychology</span>
</div>
<h4 class="text-label-md font-label-md text-on-surface">Resuelve-dudas</h4>
<p class="text-[10px] text-on-surface-variant leading-tight mt-1">10 respuestas solución</p>
<span class="mt-2 text-[9px] font-bold text-ug-blue bg-ug-blue-light px-2 py-0.5 rounded-full border border-ug-blue/20">Desbloqueado</span>
</div>
<!-- Distintivo 4: Vendedor Activo -->
<div class="group relative bg-surface-container-low/70 rounded-xl p-3 border-2 border-purple-500 flex flex-col items-center text-center hover:bg-surface-container-lowest transition-all">
<div class="w-12 h-12 rounded-full bg-purple-100 flex items-center justify-center text-purple-600 mb-2 shadow-inner group-hover:scale-110 transition-transform">
<span class="material-symbols-outlined text-[26px]">shopping_bag</span>
</div>
<h4 class="text-label-md font-label-md text-on-surface">Vendedor Activo</h4>
<p class="text-[10px] text-on-surface-variant leading-tight mt-1">3 ventas en campus</p>
<span class="mt-2 text-[9px] font-bold text-purple-800 bg-purple-200/60 px-2 py-0.5 rounded-full">Desbloqueado</span>
</div>
<!-- Distintivo 5: Voz del Campus (Rojo institucional) -->
<div class="group relative bg-surface-container-low/70 rounded-xl p-3 border-2 border-ug-red flex flex-col items-center text-center hover:bg-surface-container-lowest transition-all">
<div class="w-12 h-12 rounded-full bg-ug-red-light flex items-center justify-center text-ug-red mb-2 shadow-inner group-hover:scale-110 transition-transform">
<span class="material-symbols-outlined text-[26px]">campaign</span>
</div>
<h4 class="text-label-md font-label-md text-on-surface">Voz del Campus</h4>
<p class="text-[10px] text-on-surface-variant leading-tight mt-1">Post con &gt;100 votos</p>
<span class="mt-2 text-[9px] font-bold text-ug-red bg-ug-red-light px-2 py-0.5 rounded-full border border-ug-red/20">Desbloqueado</span>
</div>
<!-- Distintivo 6: Constante (Racha de fuego / Amarillo institucional) -->
<div class="group relative bg-surface-container-low/70 rounded-xl p-3 border-2 border-ug-yellow flex flex-col items-center text-center hover:bg-surface-container-lowest transition-all">
<div class="w-12 h-12 rounded-full bg-amber-100 flex items-center justify-center text-ug-yellow-dark mb-2 shadow-inner group-hover:scale-110 transition-transform">
<span class="material-symbols-outlined text-[26px]" data-weight="fill" style="font-variation-settings: 'FILL' 1;">bolt</span>
</div>
<h4 class="text-label-md font-label-md text-on-surface">Constante</h4>
<p class="text-[10px] text-on-surface-variant leading-tight mt-1">Racha 7 días activo</p>
<span class="mt-2 text-[9px] font-bold text-amber-900 bg-amber-200/70 px-2 py-0.5 rounded-full">Desbloqueado</span>
</div>
<!-- Distintivo 7: Gran Colaborador (Bloqueado 🔒) -->
<div class="relative bg-surface-container-low/40 rounded-xl p-3 border border-outline-variant/60 flex flex-col items-center text-center opacity-60">
<div class="absolute top-2 right-2 text-outline">
<span class="material-symbols-outlined text-[16px]">lock</span>
</div>
<div class="w-12 h-12 rounded-full bg-surface-container flex items-center justify-center text-outline mb-2">
<span class="material-symbols-outlined text-[24px]">workspace_premium</span>
</div>
<h4 class="text-label-md font-label-md text-on-surface-variant">Gran Colaborador</h4>
<p class="text-[10px] text-outline leading-tight mt-1">Llegar a 30 soluciones</p>
<span class="mt-2 text-[9px] font-semibold text-outline bg-surface-container px-2 py-0.5 rounded-full">Bloqueado</span>
</div>
<!-- Distintivo 8: Leyenda del Campus (Bloqueado 🔒) -->
<div class="relative bg-surface-container-low/40 rounded-xl p-3 border border-outline-variant/60 flex flex-col items-center text-center opacity-60">
<div class="absolute top-2 right-2 text-outline">
<span class="material-symbols-outlined text-[16px]">lock</span>
</div>
<div class="w-12 h-12 rounded-full bg-surface-container flex items-center justify-center text-outline mb-2">
<span class="material-symbols-outlined text-[24px]">local_fire_department</span>
</div>
<h4 class="text-label-md font-label-md text-on-surface-variant">Leyenda Campus</h4>
<p class="text-[10px] text-outline leading-tight mt-1">Nivel 4 y 400 pts</p>
<span class="mt-2 text-[9px] font-semibold text-outline bg-surface-container px-2 py-0.5 rounded-full">Bloqueado</span>
</div>
</div>
</section>
<!-- Tabs Inferiores de Contenido & Registro -->
<section class="space-y-space-md">
<!-- Content Segment Tabs Filter (Pestaña activa en Azul institucional Uniguajira #0F4C81) -->
<div class="flex items-center gap-space-xs overflow-x-auto pb-1 scrollbar-none">
<button class="bg-ug-blue text-on-secondary px-4 py-2 rounded-full text-label-md font-label-md shadow-sm shrink-0 flex items-center gap-1.5 border border-ug-blue">
<span class="material-symbols-outlined text-[16px]">history_edu</span>
<span>Historial de Puntos</span>
</button>
<button class="bg-surface-container-high text-on-surface-variant hover:bg-surface-container-highest px-4 py-2 rounded-full text-label-md font-label-md shrink-0 flex items-center gap-1.5 transition-colors">
<span class="material-symbols-outlined text-[16px]">article</span>
<span>Mis Publicaciones (18)</span>
</button>
<button class="bg-surface-container-high text-on-surface-variant hover:bg-surface-container-highest px-4 py-2 rounded-full text-label-md font-label-md shrink-0 flex items-center gap-1.5 transition-colors">
<span class="material-symbols-outlined text-[16px]">bookmark</span>
<span>Guardados (7)</span>
</button>
<button class="bg-surface-container-high text-on-surface-variant hover:bg-surface-container-highest px-4 py-2 rounded-full text-label-md font-label-md shrink-0 flex items-center gap-1.5 transition-colors">
<span class="material-symbols-outlined text-[16px]">storefront</span>
<span>Mis Ventas (2)</span>
</button>
</div>
<!-- Listado de Actividad Reciente con Puntos Ganados -->
<div class="bg-surface-container-lowest rounded-xl border border-surface-container-highest shadow-sm p-space-md space-y-3">
<div class="flex items-center justify-between pb-2 border-b border-surface-container">
<h4 class="text-label-lg font-label-lg text-on-surface font-bold">Actividad y Recompensas Recientes</h4>
<span class="text-label-sm font-label-sm text-ug-red font-bold flex items-center gap-1">
<span class="w-1.5 h-1.5 rounded-full bg-ug-red animate-ping"></span>
          Tiempo Real
        </span>
</div>
<!-- Activity Item 1 -->
<div class="flex items-start justify-between p-3 rounded-lg bg-surface-container-low hover:bg-surface-container transition-colors">
<div class="flex items-start gap-3">
<div class="w-9 h-9 rounded-full bg-emerald-100 text-emerald-700 flex items-center justify-center shrink-0 mt-0.5">
<span class="material-symbols-outlined text-[18px]" data-weight="fill" style="font-variation-settings: 'FILL' 1;">check_circle</span>
</div>
<div>
<p class="text-body-md font-body-md text-on-surface">
                Respuesta marcada como <strong class="text-ug-blue font-semibold">solución oficial</strong> en <span class="text-ug-blue font-medium">#Algoritmos</span>
</p>
<div class="flex items-center gap-2 mt-1">
<span class="text-body-sm font-body-sm text-outline">Hace 2 horas</span>
<span class="w-1 h-1 rounded-full bg-outline"></span>
<span class="text-body-sm font-body-sm text-outline">Validado por Docente Auxiliar</span>
</div>
</div>
</div>
<span class="shrink-0 bg-emerald-600 text-on-primary text-label-md font-label-md px-2.5 py-1 rounded-full font-bold ml-2">
            +15 pts
          </span>
</div>
<!-- Activity Item 2 -->
<div class="flex items-start justify-between p-3 rounded-lg bg-surface-container-low hover:bg-surface-container transition-colors">
<div class="flex items-start gap-3">
<div class="w-9 h-9 rounded-full bg-ug-blue-light text-ug-blue flex items-center justify-center shrink-0 mt-0.5">
<span class="material-symbols-outlined text-[18px]">thumb_up</span>
</div>
<div>
<p class="text-body-md font-body-md text-on-surface">
                Upvotes continuos acumulados en publicación de la <strong class="text-on-surface font-semibold">cafetería central</strong>
</p>
<div class="flex items-center gap-2 mt-1">
<span class="text-body-sm font-body-sm text-outline">Ayer</span>
<span class="w-1 h-1 rounded-full bg-outline"></span>
<span class="text-body-sm font-body-sm text-outline">Comunidad UniVibe Uniguajira</span>
</div>
</div>
</div>
<span class="shrink-0 bg-ug-blue text-on-secondary text-label-md font-label-md px-2.5 py-1 rounded-full font-bold ml-2">
            +3 pts
          </span>
</div>
<!-- Activity Item 3 (Racha de fuego - Rojo institucional Uniguajira) -->
<div class="flex items-start justify-between p-3 rounded-lg bg-surface-container-low hover:bg-surface-container transition-colors">
<div class="flex items-start gap-3">
<div class="w-9 h-9 rounded-full bg-ug-red-light text-ug-red flex items-center justify-center shrink-0 mt-0.5">
<span class="material-symbols-outlined text-[18px]" data-weight="fill" style="font-variation-settings: 'FILL' 1;">local_fire_department</span>
</div>
<div>
<p class="text-body-md font-body-md text-on-surface">
                Bonificación por <strong class="text-on-surface font-semibold">Racha Diaria Activa</strong> (Día 7)
              </p>
<div class="flex items-center gap-2 mt-1">
<span class="text-body-sm font-body-sm text-outline">Hace 2 días</span>
<span class="w-1 h-1 rounded-full bg-outline"></span>
<span class="text-body-sm font-body-sm text-outline">Logro desbloqueado: Constante</span>
</div>
</div>
</div>
<span class="shrink-0 bg-ug-yellow text-amber-950 text-label-md font-label-md px-2.5 py-1 rounded-full font-extrabold ml-2">
            +10 pts
          </span>
</div>
</div>
</section>
</main>
<!-- Bottom Navigation Bar (Shared Component Blueprint strictly executed) -->
<!-- Context Lock: Page is 'Mi Perfil' -> Tab 'Perfil' is strictly ACTIVE con Azul Institucional Uniguajira -->
<nav class="fixed bottom-0 left-0 w-full z-50 flex justify-around items-center px-margin pb-space-md pt-space-xs max-w-screen-md mx-auto inset-x-0 bg-surface-container-lowest shadow-lg backdrop-blur-md border-t border-surface-container-highest">
<!-- Tab 1: Inicio (Inactive) -->
<a class="flex flex-col items-center justify-center text-on-surface-variant px-space-md py-space-xs hover:bg-surface-container-high rounded-full active:scale-95 transition-transform duration-150" href="#">
<span class="material-symbols-outlined text-[24px]">home</span>
<span class="text-label-sm font-label-sm">Inicio</span>
</a>
<!-- Tab 2: Canales (Inactive) -->
<a class="flex flex-col items-center justify-center text-on-surface-variant px-space-md py-space-xs hover:bg-surface-container-high rounded-full active:scale-95 transition-transform duration-150" href="#">
<span class="material-symbols-outlined text-[24px]">forum</span>
<span class="text-label-sm font-label-sm">Canales</span>
</a>
<!-- Tab 3: IA (Inactive) -->
<a class="flex flex-col items-center justify-center text-on-surface-variant px-space-md py-space-xs hover:bg-surface-container-high rounded-full active:scale-95 transition-transform duration-150" href="#">
<span class="material-symbols-outlined text-[24px]">auto_awesome</span>
<span class="text-label-sm font-label-sm">IA</span>
</a>
<!-- Tab 4: Perfil (ACTIVE -> Uniguajira Azul Institucional con acento Amarillo) -->
<a class="flex flex-col items-center justify-center bg-ug-blue text-on-secondary rounded-full px-space-md py-space-xs active:scale-95 transition-transform duration-150 shadow-sm" href="#">
<span class="material-symbols-outlined text-[24px] text-ug-yellow" data-weight="fill" style="font-variation-settings: 'FILL' 1;">person</span>
<span class="text-label-sm font-label-sm">Perfil</span>
</a>
</nav>
</body></html>

<!-- UniVibe Uniguajira — Canales -->
<!DOCTYPE html>

<html class="light" lang="es"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>UniVibe Uniguajira - Canales y Comunidades</title>
<!-- Material Symbols Outlined -->
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<!-- Google Fonts -->
<link href="https://fonts.googleapis.com" rel="preconnect"/>
<link crossorigin="" href="https://fonts.gstatic.com" rel="preconnect"/>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet"/>
<!-- Tailwind CSS CDN -->
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<!-- Tailwind Configuration verbatim using Target Design Theme -->
<script id="tailwind-config">
  tailwind.config = {
    darkMode: "class",
    theme: {
      extend: {
        "colors": {
          "on-error-container": "#93000a",
          "on-tertiary-container": "#990012",
          "surface-variant": "#e0e0fc",
          "outline": "#837561",
          "surface-container": "#f8f5ee",
          "on-surface": "#181a2e",
          "on-primary-fixed-variant": "#5f4100",
          "on-surface-variant": "#514533",
          "on-secondary-fixed-variant": "#07497d",
          "tertiary-container": "#ffa199",
          "primary-container": "#f2ae1c",
          "surface-container-lowest": "#ffffff",
          "on-primary": "#ffffff",
          "error-container": "#ffdad6",
          "inverse-primary": "#ffba30",
          "surface": "#fbf8ff",
          "primary-fixed-dim": "#ffba30",
          "primary": "#7d5700",
          "on-secondary-container": "#144f84",
          "on-error": "#ffffff",
          "outline-variant": "#d5c4ad",
          "on-secondary-fixed": "#001c37",
          "secondary": "#2d6197",
          "tertiary-fixed": "#ffdad6",
          "on-tertiary-fixed": "#410003",
          "inverse-on-surface": "#f1efff",
          "secondary-fixed-dim": "#a0c9ff",
          "on-primary-fixed": "#271900",
          "secondary-fixed": "#d2e4ff",
          "tertiary-fixed-dim": "#ffb3ad",
          "surface-bright": "#fbf8ff",
          "secondary-container": "#92c1fe",
          "surface-container-highest": "#f0ede4",
          "on-background": "#181a2e",
          "surface-container-high": "#f4f0e6",
          "surface-container-low": "#faf8f2",
          "inverse-surface": "#2d2f44",
          "on-primary-container": "#4a3200",
          "on-secondary": "#ffffff",
          "surface-tint": "#7d5700",
          "error": "#ba1a1a",
          "primary-fixed": "#ffdeab",
          "on-tertiary-fixed-variant": "#930011",
          "on-tertiary": "#ffffff",
          "surface-dim": "#d7d8f4",
          "background": "#fdfbf7",
          "tertiary": "#bc111e",
          // Institutional Uniguajira specifics
          "ug-yellow": "#F2AE1C",
          "ug-yellow-dark": "#D6970A",
          "ug-red": "#C81D25",
          "ug-red-light": "#FFEBEE",
          "ug-blue": "#0F4C81",
          "ug-blue-light": "#E3F2FD"
        },
        "borderRadius": {
          "DEFAULT": "0.25rem",
          "lg": "0.5rem",
          "xl": "0.75rem",
          "full": "9999px"
        },
        "spacing": {
          "margin": "1rem",
          "margin-desktop": "3rem",
          "space-xl": "2.5rem",
          "space-xs": "0.25rem",
          "space-sm": "0.5rem",
          "gutter": "1.25rem",
          "gutter-desktop": "1.5rem",
          "margin-tablet": "2rem",
          "space-md": "1rem",
          "space-lg": "1.5rem"
        },
        "fontFamily": {
          "title-md": ["Plus Jakarta Sans"],
          "label-sm": ["Plus Jakarta Sans"],
          "label-md": ["Plus Jakarta Sans"],
          "body-md": ["Plus Jakarta Sans"],
          "headline-lg-mobile": ["Plus Jakarta Sans"],
          "headline-lg": ["Plus Jakarta Sans"],
          "headline-sm": ["Plus Jakarta Sans"],
          "display-lg": ["Plus Jakarta Sans"],
          "body-lg": ["Plus Jakarta Sans"],
          "display-lg-mobile": ["Plus Jakarta Sans"],
          "headline-md": ["Plus Jakarta Sans"]
        },
        "fontSize": {
          "title-md": ["18px", { "lineHeight": "24px", "fontWeight": "600" }],
          "label-sm": ["11px", { "lineHeight": "16px", "letterSpacing": "0.04em", "fontWeight": "700" }],
          "label-md": ["13px", { "lineHeight": "18px", "letterSpacing": "0.01em", "fontWeight": "600" }],
          "body-md": ["14px", { "lineHeight": "22px", "fontWeight": "400" }],
          "headline-lg-mobile": ["24px", { "lineHeight": "32px", "letterSpacing": "-0.01em", "fontWeight": "700" }],
          "headline-lg": ["32px", { "lineHeight": "40px", "letterSpacing": "-0.01em", "fontWeight": "700" }],
          "headline-sm": ["20px", { "lineHeight": "28px", "fontWeight": "600" }],
          "display-lg": ["48px", { "lineHeight": "56px", "letterSpacing": "-0.02em", "fontWeight": "800" }],
          "body-lg": ["16px", { "lineHeight": "26px", "fontWeight": "400" }],
          "display-lg-mobile": ["32px", { "lineHeight": "40px", "letterSpacing": "-0.015em", "fontWeight": "800" }],
          "headline-md": ["24px", { "lineHeight": "32px", "fontWeight": "600" }]
        }
      },
    },
  }
</script>
<style>
    .material-symbols-outlined {
      font-variation-settings: 'FILL' 0, 'wght' 500, 'GRAD' 0, 'opsz' 24;
      display: inline-block;
      vertical-align: middle;
      line-height: 1;
    }
    .custom-shadow-soft {
      box-shadow: 0 1px 3px 0 rgba(40, 30, 10, 0.05), 0 1px 2px -1px rgba(40, 30, 10, 0.03);
    }
    .custom-shadow-elevation {
      box-shadow: 0 10px 15px -3px rgba(242, 174, 28, 0.12), 0 4px 6px -4px rgba(40, 30, 10, 0.04);
    }
    .custom-shadow-fab {
      box-shadow: 0 12px 24px -4px rgba(242, 174, 28, 0.45);
    }
    .custom-nav-glass {
      backdrop-filter: blur(16px);
      box-shadow: 0 20px 25px -5px rgba(24, 26, 46, 0.08), 0 8px 10px -6px rgba(24, 26, 46, 0.04);
    }
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
</head>
<body class="bg-background text-on-surface min-h-screen antialiased selection:bg-primary-container selection:text-on-primary-container pb-28">
<!-- TOP APP BAR -->
<header class="fixed top-0 left-0 w-full z-40 bg-surface-container-lowest/95 backdrop-blur-md border-b border-outline-variant/30 shadow-xs transition-transform duration-150">
<div class="max-w-screen-md mx-auto px-margin py-space-sm flex justify-between items-center">
<!-- Leading: Avatar con nivel universitario Uniguajira -->
<div class="flex items-center space-x-3">
<div class="relative">
<img class="w-10 h-10 rounded-full object-cover ring-2 ring-primary-container p-0.5 bg-surface-container-lowest" data-alt="Modern high key portrait of a confident university engineering student looking directly forward in crisp collegiate lighting with subtle electric purple reflections and pristine aesthetic background, light collegiate modern styling." src="https://lh3.googleusercontent.com/aida-public/AB6AXuAEzDUhT-5oALho9_5fg3pJEAQf6tbgbsYiAAXEPE2j0V_Q6II6e5EISRKKJaFcflVsxMFi0RspWxK5OVpSKPL8FHZcqmh2owYYUxAptHTGuDJMITmGAt4n2OczLdTAcqLwUCMK8XYqYOOtHbc-8JEqgKZN2En9Mimexv2QcidUj00A3FPt4UUnNL_rRV8RwQPlMncRIAzXoZ2JGsYembrPLBy0in-STNQoD1-Q3UoO"/>
<span class="absolute -bottom-1 -right-1 bg-primary text-on-primary font-label-sm text-label-sm px-1.5 py-0.2 rounded-full border-2 border-surface-container-lowest shadow-xs">
            N4
          </span>
</div>
<div>
<div class="flex items-center space-x-1.5">
<span class="text-headline-lg-mobile font-headline-lg-mobile font-extrabold text-on-surface tracking-tight block">UniVibe</span>
<span class="bg-primary-container/25 text-primary text-[10px] font-extrabold px-1.5 py-0.5 rounded tracking-wide border border-primary-container/40">UNIGUAJIRA</span>
</div>
<span class="text-label-sm font-label-sm text-on-surface-variant block">Campus Riohacha Conectado</span>
</div>
</div>
<!-- Trailing: Notifications & Actions -->
<div class="flex items-center space-x-2">
<button aria-label="Filtros globales" class="w-10 h-10 rounded-full flex items-center justify-center text-on-surface-variant hover:bg-surface-container active:scale-95 transition-transform duration-150">
<span class="material-symbols-outlined" data-icon="tune">tune</span>
</button>
<button aria-label="Notificaciones" class="relative w-10 h-10 rounded-full flex items-center justify-center text-on-surface-variant hover:bg-surface-container active:scale-95 transition-transform duration-150">
<span class="material-symbols-outlined" data-icon="notifications">notifications</span>
<span class="absolute top-2.5 right-2.5 w-2 h-2 rounded-full bg-ug-red ring-2 ring-surface-container-lowest"></span>
</button>
</div>
</div>
</header>
<!-- MAIN WRAPPER CONTAINER -->
<main class="max-w-screen-md mx-auto px-margin pt-20">
<!-- SUBHEADER HERO SECTION -->
<section class="mt-space-md mb-space-lg">
<div class="flex justify-between items-start">
<div>
<h1 class="text-headline-lg font-headline-lg text-on-surface tracking-tight font-extrabold">Canales y Comunidades</h1>
<p class="text-body-md font-body-md text-on-surface-variant mt-1">Explora lo que pasa en tu facultad y grupos de interés institucional</p>
</div>
</div>
</section>
<!-- SEARCH & QUICK FILTER BAR -->
<section class="mb-space-lg">
<div class="relative flex items-center">
<div class="absolute left-4 flex items-center pointer-events-none text-primary">
<span class="material-symbols-outlined" data-icon="search">search</span>
</div>
<input class="w-full h-12 pl-12 pr-24 bg-surface-container-lowest rounded-xl border border-primary-container/60 text-body-md font-body-md text-on-surface placeholder:text-outline focus:outline-none focus:ring-2 focus:ring-primary-container focus:border-primary-container custom-shadow-soft transition-all" placeholder="Buscar canales, facultades, clubes..." type="text"/>
<div class="absolute right-2 flex items-center space-x-1">
<button aria-label="Búsqueda por voz" class="p-2 text-on-surface-variant hover:text-primary rounded-lg hover:bg-surface-container active:scale-95 transition-transform">
<span class="material-symbols-outlined text-headline-sm" data-icon="mic">mic</span>
</button>
<button aria-label="Filtro rápido" class="p-2 text-on-primary-container bg-primary-container rounded-lg hover:bg-primary-container/90 active:scale-95 transition-transform shadow-xs">
<span class="material-symbols-outlined text-headline-sm" data-icon="filter_list">filter_list</span>
</button>
</div>
</div>
<!-- Quick Badges Carousel -->
<div class="flex items-center space-x-2 overflow-x-auto py-space-sm no-scrollbar mt-space-xs">
<button class="px-space-md py-1.5 rounded-full bg-primary-container text-on-primary-container text-label-md font-label-md flex items-center space-x-1.5 shrink-0 active:scale-95 transition-transform font-bold shadow-xs">
<span class="material-symbols-outlined text-body-sm" data-icon="all_inclusive">all_inclusive</span>
<span>Todos</span>
</button>
<button class="px-space-md py-1.5 rounded-full bg-surface-container-lowest border border-ug-blue/30 text-ug-blue text-label-md font-label-md flex items-center space-x-1.5 shrink-0 hover:bg-ug-blue-light/50 active:scale-95 transition-transform font-medium">
<span class="material-symbols-outlined text-body-sm text-ug-blue" data-icon="verified">verified</span>
<span>Oficiales</span>
</button>
<button class="px-space-md py-1.5 rounded-full bg-surface-container-lowest border border-ug-red/30 text-ug-red text-label-md font-label-md flex items-center space-x-1.5 shrink-0 hover:bg-ug-red-light/50 active:scale-95 transition-transform font-medium">
<span class="material-symbols-outlined text-body-sm text-ug-red" data-icon="local_fire_department">local_fire_department</span>
<span>Más Activos</span>
</button>
<button class="px-space-md py-1.5 rounded-full bg-surface-container-lowest border border-outline-variant/60 text-on-surface-variant text-label-md font-label-md flex items-center space-x-1.5 shrink-0 hover:bg-surface-container active:scale-95 transition-transform font-medium">
<span class="material-symbols-outlined text-body-sm text-primary" data-icon="groups">groups</span>
<span>Mis Facultades</span>
</button>
</div>
</section>
<!-- CATEGORÍAS PRINCIPALES (Bento-Grid con Micro-acento Funcional) -->
<section class="mb-space-xl">
<div class="flex items-center justify-between mb-space-sm">
<h2 class="text-title-md font-title-md text-on-surface flex items-center space-x-2 font-bold">
<span>Categorías Principales</span>
<span class="w-2.5 h-2.5 rounded-full bg-primary-container"></span>
</h2>
<span class="text-label-md font-label-md text-ug-blue hover:underline cursor-pointer font-semibold">Ver cuadrícula</span>
</div>
<div class="grid grid-cols-2 gap-3 sm:gap-4">
<!-- Académico -->
<div class="bg-surface-container-lowest rounded-xl p-space-md border border-outline-variant/40 custom-shadow-soft hover:custom-shadow-elevation transition-all group cursor-pointer relative overflow-hidden">
<div class="flex items-start justify-between">
<div class="w-10 h-10 rounded-xl bg-ug-blue-light text-ug-blue flex items-center justify-center">
<span class="material-symbols-outlined" data-icon="school">school</span>
</div>
<span class="text-label-sm font-label-sm bg-surface-container px-2 py-0.5 rounded-full text-on-surface-variant">185 hoy</span>
</div>
<div class="mt-space-md">
<h3 class="text-label-lg font-label-lg text-on-surface group-hover:text-ug-blue transition-colors font-bold">Académico</h3>
<p class="text-body-sm font-body-sm text-on-surface-variant mt-0.5">4.2k miembros</p>
</div>
<div class="absolute bottom-0 left-0 right-0 h-1 bg-ug-blue/30 group-hover:bg-ug-blue transition-colors"></div>
</div>
<!-- Vida Universitaria & Chisme -->
<div class="bg-surface-container-lowest rounded-xl p-space-md border border-outline-variant/40 custom-shadow-soft hover:custom-shadow-elevation transition-all group cursor-pointer relative overflow-hidden">
<div class="flex items-start justify-between">
<div class="w-10 h-10 rounded-xl bg-ug-red-light text-ug-red flex items-center justify-center">
<span class="material-symbols-outlined" data-icon="local_pizza">local_pizza</span>
</div>
<span class="text-label-sm font-label-sm bg-ug-red-light text-ug-red px-2 py-0.5 rounded-full font-bold flex items-center space-x-1">
<span>Muy activo</span>
<span class="material-symbols-outlined text-[10px]" data-icon="local_fire_department">local_fire_department</span>
</span>
</div>
<div class="mt-space-md">
<h3 class="text-label-lg font-label-lg text-on-surface group-hover:text-ug-red transition-colors font-bold">Vida Universitaria</h3>
<p class="text-body-sm font-body-sm text-on-surface-variant mt-0.5">8.9k miembros</p>
</div>
<div class="absolute bottom-0 left-0 right-0 h-1 bg-ug-red/40 group-hover:bg-ug-red transition-colors"></div>
</div>
<!-- Deportes & Torneos -->
<div class="bg-surface-container-lowest rounded-xl p-space-md border border-outline-variant/40 custom-shadow-soft hover:custom-shadow-elevation transition-all group cursor-pointer relative overflow-hidden">
<div class="flex items-start justify-between">
<div class="w-10 h-10 rounded-xl bg-primary-container/20 text-primary flex items-center justify-center">
<span class="material-symbols-outlined" data-icon="sports_soccer">sports_soccer</span>
</div>
<span class="text-label-sm font-label-sm bg-primary-container/20 text-primary-container/90 px-2 py-0.5 rounded-full font-bold">Activo</span>
</div>
<div class="mt-space-md">
<h3 class="text-label-lg font-label-lg text-on-surface group-hover:text-primary transition-colors font-bold">Deportes &amp; Torneos</h3>
<p class="text-body-sm font-body-sm text-on-surface-variant mt-0.5">2.4k miembros</p>
</div>
<div class="absolute bottom-0 left-0 right-0 h-1 bg-primary-container/40 group-hover:bg-primary-container transition-colors"></div>
</div>
<!-- Marketplace Estudiantil -->
<div class="bg-surface-container-lowest rounded-xl p-space-md border border-outline-variant/40 custom-shadow-soft hover:custom-shadow-elevation transition-all group cursor-pointer relative overflow-hidden">
<div class="flex items-start justify-between">
<div class="w-10 h-10 rounded-xl bg-primary-container/25 text-on-primary-container flex items-center justify-center">
<span class="material-symbols-outlined" data-icon="shopping_bag">shopping_bag</span>
</div>
<span class="text-label-sm font-label-sm bg-primary-container/20 text-primary px-2 py-0.5 rounded-full font-bold">92 ventas hoy</span>
</div>
<div class="mt-space-md">
<h3 class="text-label-lg font-label-lg text-on-surface group-hover:text-primary transition-colors font-bold">Marketplace</h3>
<p class="text-body-sm font-body-sm text-on-surface-variant mt-0.5">5.1k miembros</p>
</div>
<div class="absolute bottom-0 left-0 right-0 h-1 bg-primary-container/50 group-hover:bg-primary-container transition-colors"></div>
</div>
<!-- Perdidos y Encontrados -->
<div class="bg-surface-container-lowest rounded-xl p-space-md border border-outline-variant/40 custom-shadow-soft hover:custom-shadow-elevation transition-all group cursor-pointer relative overflow-hidden">
<div class="flex items-start justify-between">
<div class="w-10 h-10 rounded-xl bg-surface-container text-on-surface-variant flex items-center justify-center">
<span class="material-symbols-outlined" data-icon="search_check">search_check</span>
</div>
<span class="text-label-sm font-label-sm bg-ug-red-light text-ug-red px-2 py-0.5 rounded-full font-bold">14 activos</span>
</div>
<div class="mt-space-md">
<h3 class="text-label-lg font-label-lg text-on-surface group-hover:text-ug-red transition-colors font-bold">Perdidos &amp; Hallados</h3>
<p class="text-body-sm font-body-sm text-on-surface-variant mt-0.5">3.7k miembros</p>
</div>
<div class="absolute bottom-0 left-0 right-0 h-1 bg-outline-variant/50 group-hover:bg-outline transition-colors"></div>
</div>
<!-- Tecnología & Código -->
<div class="bg-surface-container-lowest rounded-xl p-space-md border border-outline-variant/40 custom-shadow-soft hover:custom-shadow-elevation transition-all group cursor-pointer relative overflow-hidden">
<div class="flex items-start justify-between">
<div class="w-10 h-10 rounded-xl bg-ug-blue-light text-ug-blue flex items-center justify-center">
<span class="material-symbols-outlined" data-icon="terminal">terminal</span>
</div>
<span class="text-label-sm font-label-sm bg-ug-blue-light text-ug-blue px-2 py-0.5 rounded-full font-bold">Activo</span>
</div>
<div class="mt-space-md">
<h3 class="text-label-lg font-label-lg text-on-surface group-hover:text-ug-blue transition-colors font-bold">Tecnología &amp; Código</h3>
<p class="text-body-sm font-body-sm text-on-surface-variant mt-0.5">3.1k miembros</p>
</div>
<div class="absolute bottom-0 left-0 right-0 h-1 bg-ug-blue/40 group-hover:bg-ug-blue transition-colors"></div>
</div>
<!-- Arte, Cultura & Wayúu -->
<div class="bg-surface-container-lowest rounded-xl p-space-md border border-outline-variant/40 custom-shadow-soft hover:custom-shadow-elevation transition-all group cursor-pointer relative overflow-hidden">
<div class="flex items-start justify-between">
<div class="w-10 h-10 rounded-xl bg-surface-container text-on-surface-variant flex items-center justify-center">
<span class="material-symbols-outlined" data-icon="palette">palette</span>
</div>
<span class="text-label-sm font-label-sm bg-surface-container px-2 py-0.5 rounded-full text-on-surface-variant">Comunidad</span>
</div>
<div class="mt-space-md">
<h3 class="text-label-lg font-label-lg text-on-surface group-hover:text-primary transition-colors font-bold">Arte &amp; Cultura</h3>
<p class="text-body-sm font-body-sm text-on-surface-variant mt-0.5">1.8k miembros</p>
</div>
<div class="absolute bottom-0 left-0 right-0 h-1 bg-outline-variant group-hover:bg-primary-container transition-colors"></div>
</div>
<!-- Avisos Oficiales -->
<div class="bg-surface-container-lowest rounded-xl p-space-md border border-outline-variant/40 custom-shadow-soft hover:custom-shadow-elevation transition-all group cursor-pointer relative overflow-hidden">
<div class="flex items-start justify-between">
<div class="w-10 h-10 rounded-xl bg-ug-blue-light text-ug-blue flex items-center justify-center">
<span class="material-symbols-outlined" data-icon="campaign">campaign</span>
</div>
<span class="text-label-sm font-label-sm bg-ug-blue-light text-ug-blue px-2 py-0.5 rounded-full font-bold">Oficial</span>
</div>
<div class="mt-space-md">
<h3 class="text-label-lg font-label-lg text-on-surface group-hover:text-ug-blue transition-colors font-bold">Avisos Oficiales</h3>
<p class="text-body-sm font-body-sm text-on-surface-variant mt-0.5">12.4k miembros</p>
</div>
<div class="absolute bottom-0 left-0 right-0 h-1 bg-ug-blue group-hover:bg-ug-blue transition-colors"></div>
</div>
</div>
</section>
<!-- CANALES TRENDING (Chips & Micro-Feed) -->
<section class="mb-space-xl">
<div class="flex items-center justify-between mb-space-sm">
<h2 class="text-title-md font-title-md text-on-surface flex items-center space-x-2 font-bold">
<span>Canales Trending</span>
<span class="material-symbols-outlined text-ug-red text-headline-sm" data-icon="trending_up">trending_up</span>
</h2>
<span class="text-label-sm font-label-sm text-on-surface-variant">Actualizado hace 5m</span>
</div>
<div class="flex flex-col space-y-3">
<!-- Trend 1 -->
<div class="bg-surface-container-lowest p-space-md rounded-xl border border-outline-variant/40 custom-shadow-soft flex items-center justify-between hover:border-ug-red/40 transition-colors">
<div class="flex items-center space-x-3">
<div class="w-10 h-10 rounded-full bg-ug-red-light text-ug-red flex items-center justify-center font-extrabold text-label-lg">
              #
            </div>
<div>
<div class="flex items-center space-x-2">
<span class="text-label-lg font-label-lg text-on-surface font-bold">#ChismesCampusCentral</span>
<span class="bg-ug-red-light text-ug-red text-[10px] font-bold px-1.5 py-0.5 rounded border border-ug-red/20">🔥 +312 msgs/h</span>
</div>
<p class="text-body-sm font-body-sm text-on-surface-variant">Debate abierto sobre los exámenes finales y horarios</p>
</div>
</div>
<button aria-label="Explorar tendencia" class="p-2 text-on-surface-variant hover:text-ug-red transition-colors">
<span class="material-symbols-outlined" data-icon="arrow_forward_ios">arrow_forward_ios</span>
</button>
</div>
<!-- Trend 2 -->
<div class="bg-surface-container-lowest p-space-md rounded-xl border border-outline-variant/40 custom-shadow-soft flex items-center justify-between hover:border-ug-blue/40 transition-colors">
<div class="flex items-center space-x-3">
<div class="w-10 h-10 rounded-full bg-ug-blue-light text-ug-blue flex items-center justify-center font-extrabold text-label-lg">
              #
            </div>
<div>
<div class="flex items-center space-x-2">
<span class="text-label-lg font-label-lg text-on-surface font-bold">#ProyectosFinalesSistemas</span>
<span class="bg-ug-blue-light text-ug-blue text-[10px] font-bold px-1.5 py-0.5 rounded border border-ug-blue/20">💻 +84 msgs/h</span>
</div>
<p class="text-body-sm font-body-sm text-on-surface-variant">Compartiendo repositorios Git y asesorías de tesis</p>
</div>
</div>
<button aria-label="Explorar tendencia" class="p-2 text-on-surface-variant hover:text-ug-blue transition-colors">
<span class="material-symbols-outlined" data-icon="arrow_forward_ios">arrow_forward_ios</span>
</button>
</div>
<!-- Trend 3 -->
<div class="bg-surface-container-lowest p-space-md rounded-xl border border-outline-variant/40 custom-shadow-soft flex items-center justify-between hover:border-primary-container transition-colors">
<div class="flex items-center space-x-3">
<div class="w-10 h-10 rounded-full bg-primary-container/20 text-on-primary-container flex items-center justify-center font-extrabold text-label-lg">
              #
            </div>
<div>
<div class="flex items-center space-x-2">
<span class="text-label-lg font-label-lg text-on-surface font-bold">#TruequeUniversitario</span>
<span class="bg-primary-container/25 text-on-primary-container text-[10px] font-bold px-1.5 py-0.5 rounded border border-primary-container/40">📦 +49 msgs/h</span>
</div>
<p class="text-body-sm font-body-sm text-on-surface-variant">Calculadoras, batas de laboratorio y libros de cálculo</p>
</div>
</div>
<button aria-label="Explorar tendencia" class="p-2 text-on-surface-variant hover:text-primary transition-colors">
<span class="material-symbols-outlined" data-icon="arrow_forward_ios">arrow_forward_ios</span>
</button>
</div>
</div>
</section>
<!-- POR FACULTADES & CARRERAS (Tarjetas Enriquecidas con Azul Institucional) -->
<section class="mb-space-xl">
<div class="flex items-center justify-between mb-space-sm">
<h2 class="text-title-md font-title-md text-on-surface flex items-center space-x-2 font-bold">
<span>Por Facultades &amp; Carreras</span>
</h2>
<span class="text-label-md font-label-md text-ug-blue hover:underline cursor-pointer font-semibold">Ver todas (12)</span>
</div>
<div class="space-y-4">
<!-- 1. Facultad de Ingeniería & Ciencias -->
<div class="bg-surface-container-lowest p-space-md rounded-xl border border-outline-variant/40 custom-shadow-soft hover:custom-shadow-elevation transition-all">
<div class="flex items-start justify-between">
<div class="flex space-x-3">
<div class="w-12 h-12 rounded-xl bg-ug-blue-light text-ug-blue flex items-center justify-center shrink-0">
<span class="material-symbols-outlined text-headline-lg-mobile" data-icon="engineering">engineering</span>
</div>
<div>
<div class="flex flex-wrap items-center gap-2">
<h3 class="text-label-lg font-label-lg text-on-surface font-bold">Facultad de Ingeniería &amp; Ciencias</h3>
<span class="inline-flex items-center space-x-1 px-2 py-0.5 rounded-full bg-ug-red-light text-ug-red text-[11px] font-bold">
<span class="material-symbols-outlined text-[12px]" data-icon="local_fire_department">local_fire_department</span>
<span>Muy Activo</span>
</span>
</div>
<p class="text-body-sm font-body-sm text-on-surface-variant mt-1">2.8k miembros • 42 publicaciones hoy</p>
<div class="flex items-center space-x-2 mt-2">
<span class="text-label-sm font-label-sm text-on-surface-variant bg-surface-container px-2 py-0.5 rounded">Sistemas</span>
<span class="text-label-sm font-label-sm text-on-surface-variant bg-surface-container px-2 py-0.5 rounded">Industrial</span>
<span class="text-label-sm font-label-sm text-on-surface-variant bg-surface-container px-2 py-0.5 rounded">Ambiental</span>
</div>
</div>
</div>
<button class="px-space-md py-1.5 rounded-full bg-ug-blue text-on-secondary text-label-md font-label-md hover:bg-ug-blue/90 active:scale-95 transition-all shrink-0 font-semibold shadow-xs">
              + Unirme
            </button>
</div>
</div>
<!-- 2. Facultad de Medicina & Salud -->
<div class="bg-surface-container-lowest p-space-md rounded-xl border border-outline-variant/40 custom-shadow-soft hover:custom-shadow-elevation transition-all">
<div class="flex items-start justify-between">
<div class="flex space-x-3">
<div class="w-12 h-12 rounded-xl bg-ug-blue-light text-ug-blue flex items-center justify-center shrink-0">
<span class="material-symbols-outlined text-headline-lg-mobile" data-icon="stethoscope">stethoscope</span>
</div>
<div>
<div class="flex flex-wrap items-center gap-2">
<h3 class="text-label-lg font-label-lg text-on-surface font-bold">Facultad de Medicina &amp; Salud</h3>
<span class="inline-flex items-center space-x-1 px-2 py-0.5 rounded-full bg-ug-blue-light text-ug-blue text-[11px] font-bold">
<span>Guardias &amp; Rondas</span>
</span>
</div>
<p class="text-body-sm font-body-sm text-on-surface-variant mt-1">1.9k miembros • 18 publicaciones hoy</p>
<div class="flex items-center space-x-2 mt-2">
<span class="text-label-sm font-label-sm text-on-surface-variant bg-surface-container px-2 py-0.5 rounded">Medicina General</span>
<span class="text-label-sm font-label-sm text-on-surface-variant bg-surface-container px-2 py-0.5 rounded">Enfermería</span>
</div>
</div>
</div>
<button class="px-space-md py-1.5 rounded-full bg-surface-container text-ug-blue text-label-md font-label-md border border-ug-blue/30 hover:bg-ug-blue-light active:scale-95 transition-all shrink-0 flex items-center space-x-1 font-semibold">
<span class="material-symbols-outlined text-body-sm" data-icon="check">check</span>
<span>Siguiendo</span>
</button>
</div>
</div>
<!-- 3. Ciencias Económicas & Negocios -->
<div class="bg-surface-container-lowest p-space-md rounded-xl border border-outline-variant/40 custom-shadow-soft hover:custom-shadow-elevation transition-all">
<div class="flex items-start justify-between">
<div class="flex space-x-3">
<div class="w-12 h-12 rounded-xl bg-primary-container/20 text-on-primary-container flex items-center justify-center shrink-0">
<span class="material-symbols-outlined text-headline-lg-mobile" data-icon="trending_up">trending_up</span>
</div>
<div>
<div class="flex flex-wrap items-center gap-2">
<h3 class="text-label-lg font-label-lg text-on-surface font-bold">Ciencias Económicas &amp; Negocios</h3>
</div>
<p class="text-body-sm font-body-sm text-on-surface-variant mt-1">1.5k miembros • Actividad moderada</p>
<div class="flex items-center space-x-2 mt-2">
<span class="text-label-sm font-label-sm text-on-surface-variant bg-surface-container px-2 py-0.5 rounded">Finanzas</span>
<span class="text-label-sm font-label-sm text-on-surface-variant bg-surface-container px-2 py-0.5 rounded">Administración</span>
</div>
</div>
</div>
<button class="px-space-md py-1.5 rounded-full bg-ug-blue text-on-secondary text-label-md font-label-md hover:bg-ug-blue/90 active:scale-95 transition-all shrink-0 font-semibold shadow-xs">
              + Unirme
            </button>
</div>
</div>
<!-- 4. Arquitectura y Diseño -->
<div class="bg-surface-container-lowest p-space-md rounded-xl border border-outline-variant/40 custom-shadow-soft hover:custom-shadow-elevation transition-all">
<div class="flex items-start justify-between">
<div class="flex space-x-3">
<div class="w-12 h-12 rounded-xl bg-surface-container text-primary flex items-center justify-center shrink-0">
<span class="material-symbols-outlined text-headline-lg-mobile" data-icon="architecture">architecture</span>
</div>
<div>
<div class="flex flex-wrap items-center gap-2">
<h3 class="text-label-lg font-label-lg text-on-surface font-bold">Arquitectura y Diseño</h3>
</div>
<p class="text-body-sm font-body-sm text-on-surface-variant mt-1">1.2k miembros • Proyectos y maquetas</p>
<div class="flex items-center space-x-2 mt-2">
<span class="text-label-sm font-label-sm text-on-surface-variant bg-surface-container px-2 py-0.5 rounded">Diseño Gráfico</span>
<span class="text-label-sm font-label-sm text-on-surface-variant bg-surface-container px-2 py-0.5 rounded">Urbanismo</span>
</div>
</div>
</div>
<button class="px-space-md py-1.5 rounded-full bg-ug-blue text-on-secondary text-label-md font-label-md hover:bg-ug-blue/90 active:scale-95 transition-all shrink-0 font-semibold shadow-xs">
              + Unirme
            </button>
</div>
</div>
</div>
</section>
</main>
<!-- ELEVATED CENTER ACTION BUTTON (FAB Amarillo Institucional Uniguajira) -->
<div class="fixed bottom-20 left-1/2 -translate-x-1/2 z-50">
<button aria-label="Crear publicación o canal" class="w-14 h-14 rounded-full bg-primary-container text-on-primary-container flex items-center justify-center custom-shadow-fab active:scale-90 transition-transform duration-150 group ring-4 ring-surface-container-lowest">
<span class="material-symbols-outlined text-headline-lg group-hover:rotate-90 transition-transform duration-200 font-bold" data-icon="add">add</span>
</button>
</div>
<!-- BOTTOM NAVIGATION BAR (Shared Component Anchor) -->
<!-- Active Tab: Canales -->
<nav class="fixed bottom-0 left-0 w-full z-40 bg-surface-container-lowest/95 border-t border-outline-variant/30 custom-nav-glass transition-transform duration-150">
<div class="max-w-screen-md mx-auto px-margin pb-space-md pt-space-xs flex justify-around items-center">
<!-- Slot 1: Inicio (Inactive) -->
<a class="flex flex-col items-center justify-center text-on-surface-variant px-space-md py-space-xs hover:text-on-surface active:scale-95 transition-transform duration-150" href="#">
<span class="material-symbols-outlined text-headline-sm" data-icon="home">home</span>
<span class="text-label-sm font-label-sm mt-0.5">Inicio</span>
</a>
<!-- Slot 2: Canales (ACTIVE TAB Uniguajira) -->
<a class="flex flex-col items-center justify-center bg-primary-container text-on-primary-container rounded-full px-space-md py-space-xs active:scale-95 transition-transform duration-150 shadow-xs" href="#">
<span class="material-symbols-outlined text-headline-sm font-bold" data-icon="forum">forum</span>
<span class="text-label-sm font-label-sm mt-0.5 font-bold">Canales</span>
</a>
<!-- Spacer for elevated central FAB -->
<div class="w-12 h-6 pointer-events-none"></div>
<!-- Slot 3: IA (Inactive) -->
<a class="flex flex-col items-center justify-center text-on-surface-variant px-space-md py-space-xs hover:text-on-surface active:scale-95 transition-transform duration-150" href="#">
<span class="material-symbols-outlined text-headline-sm" data-icon="auto_awesome">auto_awesome</span>
<span class="text-label-sm font-label-sm mt-0.5">IA</span>
</a>
<!-- Slot 4: Perfil (Inactive) -->
<a class="flex flex-col items-center justify-center text-on-surface-variant px-space-md py-space-xs hover:text-on-surface active:scale-95 transition-transform duration-150" href="#">
<span class="material-symbols-outlined text-headline-sm" data-icon="person">person</span>
<span class="text-label-sm font-label-sm mt-0.5">Perfil</span>
</a>
</div>
</nav>
<!-- Interactive Scripts -->
<script>
    // Micro-interactions for buttons
    document.querySelectorAll('button').forEach(btn => {
      btn.addEventListener('click', function(e) {
        if (this.innerText.includes('+ Unirme')) {
          this.innerHTML = `<span class="material-symbols-outlined text-[14px]">check</span> Siguiendo`;
          this.classList.remove('bg-ug-blue', 'text-on-secondary');
          this.classList.add('bg-surface-container', 'text-ug-blue', 'border', 'border-ug-blue/30');
        } else if (this.innerText.includes('Siguiendo')) {
          this.innerHTML = `+ Unirme`;
          this.classList.remove('bg-surface-container', 'text-ug-blue', 'border', 'border-ug-blue/30');
          this.classList.add('bg-ug-blue', 'text-on-secondary');
        }
      });
    });
  </script>
</body></html>

<!-- UniVibe Uniguajira — IA del Campus -->
<!DOCTYPE html>

<html class="h-full" lang="es"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>UniVibe Uniguajira - IA del Campus</title>
<link href="https://fonts.googleapis.com" rel="preconnect"/>
<link crossorigin="" href="https://fonts.gstatic.com" rel="preconnect"/>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<script id="tailwind-config">
  tailwind.config = {
    darkMode: "class",
    theme: {
      extend: {
        "colors": {
          "on-error-container": "#93000a",
          "on-tertiary-container": "#990012",
          "surface-variant": "#e0e0fc",
          "outline": "#837561",
          "surface-container": "#edecff",
          "on-surface": "#181a2e",
          "on-primary-fixed-variant": "#5f4100",
          "on-surface-variant": "#514533",
          "on-secondary-fixed-variant": "#07497d",
          "tertiary-container": "#ffa199",
          "primary-container": "#f2ae1c",
          "surface-container-lowest": "#ffffff",
          "on-primary": "#ffffff",
          "error-container": "#ffdad6",
          "inverse-primary": "#ffba30",
          "surface": "#fbf8ff",
          "primary-fixed-dim": "#ffba30",
          "primary": "#7d5700",
          "on-secondary-container": "#144f84",
          "on-error": "#ffffff",
          "outline-variant": "#d5c4ad",
          "on-secondary-fixed": "#001c37",
          "secondary": "#2d6197",
          "tertiary-fixed": "#ffdad6",
          "on-tertiary-fixed": "#410003",
          "inverse-on-surface": "#f1efff",
          "secondary-fixed-dim": "#a0c9ff",
          "on-primary-fixed": "#271900",
          "secondary-fixed": "#d2e4ff",
          "tertiary-fixed-dim": "#ffb3ad",
          "surface-bright": "#fbf8ff",
          "secondary-container": "#92c1fe",
          "surface-container-highest": "#e0e0fc",
          "on-background": "#181a2e",
          "surface-container-high": "#e6e6ff",
          "surface-container-low": "#f4f2ff",
          "inverse-surface": "#2d2f44",
          "on-primary-container": "#644400",
          "on-secondary": "#ffffff",
          "surface-tint": "#7d5700",
          "error": "#ba1a1a",
          "primary-fixed": "#ffdeab",
          "on-tertiary-fixed-variant": "#930011",
          "on-tertiary": "#ffffff",
          "surface-dim": "#d7d8f4",
          "background": "#fbf8ff",
          "tertiary": "#bc111e",
          /* Tokens institucionales Uniguajira solicitados */
          "ug-yellow": "#F2AE1C",
          "ug-yellow-dark": "#7D5700",
          "ug-yellow-light": "#FFF3D6",
          "ug-red": "#C81D25",
          "ug-red-dark": "#930011",
          "ug-red-light": "#FFDAD6",
          "ug-blue": "#0F4C81",
          "ug-blue-dark": "#073259",
          "ug-blue-light": "#D2E4FF"
        },
        "borderRadius": {
          "DEFAULT": "0.25rem",
          "lg": "0.5rem",
          "xl": "0.75rem",
          "full": "9999px"
        },
        "spacing": {
          "margin": "1rem",
          "margin-desktop": "3rem",
          "space-xl": "2.5rem",
          "space-xs": "0.25rem",
          "space-sm": "0.5rem",
          "gutter": "1.25rem",
          "gutter-desktop": "1.5rem",
          "margin-tablet": "2rem",
          "space-md": "1rem",
          "space-lg": "1.5rem"
        },
        "fontFamily": {
          "title-md": ["Plus Jakarta Sans"],
          "label-sm": ["Plus Jakarta Sans"],
          "label-md": ["Plus Jakarta Sans"],
          "body-md": ["Plus Jakarta Sans"],
          "headline-lg-mobile": ["Plus Jakarta Sans"],
          "headline-lg": ["Plus Jakarta Sans"],
          "headline-sm": ["Plus Jakarta Sans"],
          "display-lg": ["Plus Jakarta Sans"],
          "body-lg": ["Plus Jakarta Sans"],
          "display-lg-mobile": ["Plus Jakarta Sans"],
          "headline-md": ["Plus Jakarta Sans"]
        },
        "fontSize": {
          "title-md": ["18px", {"lineHeight": "24px", "fontWeight": "600"}],
          "label-sm": ["11px", {"lineHeight": "16px", "letterSpacing": "0.04em", "fontWeight": "700"}],
          "label-md": ["13px", {"lineHeight": "18px", "letterSpacing": "0.01em", "fontWeight": "600"}],
          "body-md": ["14px", {"lineHeight": "22px", "fontWeight": "400"}],
          "headline-lg-mobile": ["24px", {"lineHeight": "32px", "letterSpacing": "-0.01em", "fontWeight": "700"}],
          "headline-lg": ["32px", {"lineHeight": "40px", "letterSpacing": "-0.01em", "fontWeight": "700"}],
          "headline-sm": ["20px", {"lineHeight": "28px", "fontWeight": "600"}],
          "display-lg": ["48px", {"lineHeight": "56px", "letterSpacing": "-0.02em", "fontWeight": "800"}],
          "body-lg": ["16px", {"lineHeight": "26px", "fontWeight": "400"}],
          "display-lg-mobile": ["32px", {"lineHeight": "40px", "letterSpacing": "-0.015em", "fontWeight": "800"}],
          "headline-md": ["24px", {"lineHeight": "32px", "fontWeight": "600"}]
        }
      }
    }
  }
</script>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
    .no-scrollbar::-webkit-scrollbar {
      display: none;
    }
    .no-scrollbar {
      -ms-overflow-style: none;
      scrollbar-width: none;
    }
  </style>
</head>
<body class="bg-[#FCFAEE] text-on-surface font-body-md antialiased min-h-full flex flex-col justify-between selection:bg-ug-yellow selection:text-ug-yellow-dark">
<!-- TopAppBar Component (Uniguajira Brand) -->
<header class="fixed top-0 left-0 w-full z-40 flex justify-between items-center px-margin py-space-sm max-w-screen-md mx-auto bg-surface-container-lowest/95 backdrop-blur-md border-b border-ug-yellow/20 shadow-sm transition-colors">
<div class="flex items-center gap-space-sm">
<div class="relative cursor-pointer active:scale-95 transition-transform duration-150">
<div class="w-10 h-10 rounded-full border-2 border-ug-yellow overflow-hidden p-0.5 bg-surface-container-lowest shadow-sm">
<img class="w-full h-full object-cover rounded-full" data-alt="A close portrait of a stylish Hispanic college student with casual tech wear and headphones smiling brightly on a sunlit university campus, surrounded by vibrant collegiate architectural lines." src="https://lh3.googleusercontent.com/aida-public/AB6AXuCXDrabhFS6AEhfIwfzAjz9ZumhHGyJtKYAKe8B-D7mh54SqXxP84AXEZJbLKRWHuKBfG4shTc1VIPp5bbuVgpn5bypyussDxi5jGVH7c7fxlSkxLmj3q1phPVolutgCS59ZZGTXVpWUJLWxl82H05TC4UDcc58AniziAvki--32Fvxg1FoQYFby5EK3SFFibKdUk876IQqddSABilHUku_3fMZ8kMFwej6OANVxedJ"/>
</div>
<span class="absolute -bottom-1 -right-1 bg-ug-red text-white font-label-sm text-[10px] px-1 rounded-full border border-surface-container-lowest shadow-sm font-bold">Lv.4</span>
</div>
<div>
<div class="flex items-center gap-1.5">
<h1 class="text-headline-lg-mobile font-headline-lg-mobile font-extrabold text-ug-yellow-dark tracking-tight leading-tight">UniVibe</h1>
<span class="text-[10px] font-bold px-1.5 py-0.2 bg-ug-yellow text-ug-yellow-dark rounded uppercase tracking-wider">Uniguajira</span>
</div>
<div class="flex items-center gap-1.5">
<span class="inline-flex items-center gap-1 bg-ug-yellow-light text-ug-yellow-dark px-1.5 py-0.5 rounded-full font-label-sm text-[11px] font-semibold border border-ug-yellow/30">
<span class="w-1.5 h-1.5 rounded-full bg-ug-yellow-dark animate-pulse"></span>
            IA Campus • En línea
          </span>
</div>
</div>
</div>
<!-- Campus Location Switcher & Actions -->
<div class="flex items-center gap-space-xs">
<button class="flex items-center gap-1 px-2.5 py-1 bg-ug-blue-light/40 hover:bg-ug-blue-light text-ug-blue rounded-full border border-ug-blue/20 transition-all active:scale-95 duration-150 shadow-sm" title="Cambiar sede">
<span class="material-symbols-outlined text-[16px] text-ug-blue" data-icon="apartment">apartment</span>
<span class="font-label-md text-label-md font-bold text-ug-blue">Riohacha (Principal)</span>
<span class="material-symbols-outlined text-[14px] text-ug-blue" data-icon="expand_more">expand_more</span>
</button>
<button aria-label="Historial" class="p-2 rounded-full text-on-surface-variant hover:bg-ug-yellow-light hover:text-ug-yellow-dark active:scale-95 transition-all duration-150">
<span class="material-symbols-outlined text-[20px]" data-icon="history">history</span>
</button>
<button aria-label="Notificaciones" class="p-2 rounded-full text-on-surface-variant hover:bg-ug-yellow-light hover:text-ug-yellow-dark active:scale-95 transition-all duration-150">
<span class="material-symbols-outlined text-[20px]" data-icon="notifications">notifications</span>
</button>
</div>
</header>
<!-- Main Canvas Container -->
<main class="w-full max-w-screen-md mx-auto px-margin pt-20 pb-36 flex-1 flex flex-col space-y-space-lg">
<!-- Intelligent Greeting & Uniguajira AI Orb Section -->
<section class="mt-2 relative overflow-hidden bg-surface-container-lowest rounded-xl p-space-lg border border-ug-yellow/30 shadow-sm">
<div class="absolute -right-8 -top-8 w-44 h-44 bg-ug-yellow/20 rounded-full blur-2xl pointer-events-none"></div>
<div class="absolute right-12 bottom-0 w-36 h-36 bg-ug-red/10 rounded-full blur-xl pointer-events-none"></div>
<div class="relative z-10 flex flex-col sm:flex-row sm:items-center gap-space-md">
<!-- Interactive AI Orb Indicator with Uniguajira Yellow Dominance -->
<div class="relative flex items-center justify-center w-16 h-16 rounded-full bg-gradient-to-tr from-ug-yellow to-ug-yellow-dark p-0.5 shadow-md flex-shrink-0 animate-pulse">
<div class="w-full h-full bg-surface-container-lowest rounded-full flex items-center justify-center">
<span class="material-symbols-outlined text-ug-yellow text-[32px]" data-icon="auto_awesome" data-weight="fill" style="font-variation-settings: 'FILL' 1;">auto_awesome</span>
</div>
<span class="absolute top-0 right-0 w-4 h-4 rounded-full bg-ug-red border-2 border-surface-container-lowest"></span>
</div>
<div class="space-y-1">
<div class="inline-flex items-center gap-1.5 px-2.5 py-0.5 bg-ug-yellow-light text-ug-yellow-dark border border-ug-yellow/40 font-label-sm text-label-sm rounded-full font-bold">
<span class="material-symbols-outlined text-[13px] text-ug-yellow-dark" data-icon="school">school</span>
            Uniguajira • Sede Principal Riohacha &amp; Sedes
          </div>
<h2 class="text-headline-xl-mobile font-headline-xl-mobile text-on-surface font-extrabold tracking-tight">
            ¿En qué te puedo ayudar hoy, Mateo?
          </h2>
<p class="text-body-md font-body-md text-on-surface-variant max-w-xl">
            Conectado en tiempo real a los canales académicos, bienestar, admisiones y sedes Riohacha, Maicao, Fonseca y Villanueva.
          </p>
</div>
</div>
<!-- Quick Action Pills with Institutional Yellow/Red Borders & Highlights -->
<div class="mt-space-md pt-space-sm border-t border-outline-variant/30">
<div class="text-label-sm font-label-sm text-outline mb-2 uppercase tracking-wider font-bold">Acciones rápidas sugeridas</div>
<div class="flex items-center gap-2 overflow-x-auto pb-1.5 no-scrollbar scroll-smooth">
<button class="whitespace-nowrap inline-flex items-center gap-1.5 px-3 py-1.5 bg-ug-yellow-light hover:bg-ug-yellow/30 text-ug-yellow-dark rounded-full border border-ug-yellow/50 text-label-md font-label-md active:scale-95 transition-all shadow-sm">
<span class="material-symbols-outlined text-[16px] text-ug-yellow-dark" data-icon="bolt">bolt</span>
            ¿Qué pasó esta semana en Uniguajira?
          </button>
<button class="whitespace-nowrap inline-flex items-center gap-1.5 px-3 py-1.5 bg-surface-container-lowest hover:bg-ug-yellow-light text-on-surface rounded-full border border-ug-yellow/40 text-label-md font-label-md active:scale-95 transition-all">
<span class="material-symbols-outlined text-[16px] text-ug-blue" data-icon="menu_book">menu_book</span>
            ¿Hay tutorías en Ingeniería?
          </button>
<button class="whitespace-nowrap inline-flex items-center gap-1.5 px-3 py-1.5 bg-surface-container-lowest hover:bg-ug-yellow-light text-on-surface rounded-full border border-ug-yellow/40 text-label-md font-label-md active:scale-95 transition-all">
<span class="material-symbols-outlined text-[16px] text-ug-red" data-icon="restaurant">restaurant</span>
            Menú y cafetería central
          </button>
<button class="whitespace-nowrap inline-flex items-center gap-1.5 px-3 py-1.5 bg-surface-container-lowest hover:bg-ug-yellow-light text-on-surface rounded-full border border-ug-yellow/40 text-label-md font-label-md active:scale-95 transition-all">
<span class="material-symbols-outlined text-[16px] text-ug-blue" data-icon="directions_bus">directions_bus</span>
            Rutas intersedes Maicao/Fonseca
          </button>
<button class="whitespace-nowrap inline-flex items-center gap-1.5 px-3 py-1.5 bg-surface-container-lowest hover:bg-ug-yellow-light text-on-surface rounded-full border border-ug-yellow/40 text-label-md font-label-md active:scale-95 transition-all">
<span class="material-symbols-outlined text-[16px] text-ug-red" data-icon="search">search</span>
            Objetos perdidos hoy
          </button>
</div>
</div>
</section>
<!-- Conversational Stream -->
<div class="space-y-space-md flex-1">
<!-- User Query Bubble with Tertiary Institutional Blue -->
<div class="flex justify-end items-end gap-2">
<div class="max-w-[85%] bg-ug-blue text-white px-space-md py-space-sm rounded-2xl rounded-br-none shadow-md">
<p class="font-body-md text-body-md text-white font-medium">
            ¿Qué pasó esta semana en el campus y qué eventos hay el fin de semana?
          </p>
<div class="flex items-center justify-end gap-1 mt-1">
<span class="text-[10px] text-white/80 font-label-sm">11:42 AM</span>
<span class="material-symbols-outlined text-[12px] text-white" data-icon="done_all">done_all</span>
</div>
</div>
<div class="w-8 h-8 rounded-full overflow-hidden flex-shrink-0 border-2 border-ug-blue bg-surface-container-lowest shadow-sm">
<img class="w-full h-full object-cover" data-alt="A portrait avatar of a collegiate student with a friendly expression in modern student lounge setting with natural bright university lighting." src="https://lh3.googleusercontent.com/aida-public/AB6AXuCf2kcYo22jtu9N8OqsNCKDxZul95Q6tLqa-DZqpVjs bias-none"/>
</div>
</div>
<!-- AI Structured Response Card with Dominant Yellow and Red/Blue Highlights -->
<div class="flex items-start gap-3">
<!-- Assistant Yellow Avatar Icon -->
<div class="w-9 h-9 rounded-full bg-gradient-to-tr from-ug-yellow to-ug-yellow-dark flex items-center justify-center flex-shrink-0 shadow-md mt-1 border border-ug-yellow/40">
<span class="material-symbols-outlined text-white text-[20px]" data-icon="auto_awesome" data-weight="fill" style="font-variation-settings: 'FILL' 1;">auto_awesome</span>
</div>
<div class="flex-1 bg-surface-container-lowest border-2 border-ug-yellow/30 rounded-xl p-space-md shadow-sm space-y-space-md">
<div class="flex items-center justify-between pb-2 border-b border-ug-yellow/20">
<div class="flex items-center gap-2">
<span class="font-headline-md text-headline-md font-bold text-ug-yellow-dark">UniVibe Campus AI</span>
<span class="bg-ug-yellow-light text-ug-yellow-dark border border-ug-yellow/30 px-2 py-0.5 rounded-full font-label-sm text-label-sm font-bold">Resumen Semanal</span>
</div>
<div class="flex items-center gap-1 text-outline">
<button class="p-1 hover:text-ug-yellow-dark transition-colors" title="Copiar"><span class="material-symbols-outlined text-[18px]" data-icon="content_copy">content_copy</span></button>
<button class="p-1 hover:text-ug-yellow-dark transition-colors" title="Guardar"><span class="material-symbols-outlined text-[18px]" data-icon="bookmark_border">bookmark_border</span></button>
</div>
</div>
<p class="font-body-md text-body-md text-on-surface">
            ¡Hola Mateo! Aquí tienes tu resumen inteligente de los últimos 3 días en <span class="font-bold text-ug-yellow-dark">Uniguajira - Sede Riohacha</span>:
          </p>
<!-- Structured Key Points Bento-style List with Institutional Accents -->
<div class="space-y-2.5">
<!-- Item 1: Institucional / Bienestar -->
<div class="flex items-start gap-3 p-2.5 rounded-lg bg-ug-yellow-light/40 border border-ug-yellow/30">
<span class="w-7 h-7 rounded-full bg-ug-yellow text-ug-yellow-dark flex items-center justify-center font-bold text-label-md flex-shrink-0 shadow-xs">📢</span>
<div class="text-body-sm font-body-sm text-on-surface">
<span class="font-bold text-ug-yellow-dark">Bienestar Uniguajira:</span> Mañana jueves hay jornada de carnetización y salud en la plazoleta de banderas (hasta las 4:00 PM).
</div>
</div>
<!-- Item 2: Deportes con Azul Institucional -->
<div class="flex items-start gap-3 p-2.5 rounded-lg bg-ug-blue-light/30 border border-ug-blue/20">
<span class="w-7 h-7 rounded-full bg-ug-blue text-white flex items-center justify-center font-bold text-label-md flex-shrink-0 shadow-xs">⚽</span>
<div class="text-body-sm font-body-sm text-on-surface">
<span class="font-bold text-ug-blue">Deportes &amp; Torneo:</span> Se abrió la inscripción para el torneo relámpago interfacultades de fútbol 8 en las canchas sintéticas (faltan 2 equipos).
</div>
</div>
<!-- Item 3: Alerta con Rojo Institucional -->
<div class="flex items-start gap-3 p-2.5 rounded-lg bg-ug-red-light/40 border border-ug-red/30">
<span class="w-7 h-7 rounded-full bg-ug-red text-white flex items-center justify-center font-bold text-label-md flex-shrink-0 shadow-xs">🔥</span>
<div class="text-body-sm font-body-sm text-on-surface">
<span class="font-bold text-ug-red">Aviso Urgente:</span> Hubo una alerta preventiva en el Bloque de Aulas C por simulacro de evacuación institucional. Circulación normalizada.
</div>
</div>
<!-- Item 4: Perdidos -->
<div class="flex items-start gap-3 p-2.5 rounded-lg bg-surface-container-low/80 border border-outline-variant/30">
<span class="w-7 h-7 rounded-full bg-ug-yellow-light text-ug-yellow-dark flex items-center justify-center font-bold text-label-md flex-shrink-0 shadow-xs">🔍</span>
<div class="text-body-sm font-body-sm text-on-surface">
<span class="font-bold text-ug-yellow-dark">Objetos Perdidos:</span> Se reportaron 4 objetos en la caseta de vigilancia 2, incluidos audífonos Bluetooth y carné estudiantil.
</div>
</div>
</div>
<!-- Citation Pills / Grounded Campus Sources (Blue & Red Verified Badges) -->
<div class="pt-2 border-t border-outline-variant/30">
<div class="text-label-sm font-label-sm text-outline-variant mb-2 font-bold tracking-wider">FUENTES VERIFICADAS UNIGUAJIRA</div>
<div class="flex flex-wrap items-center gap-2">
<a class="inline-flex items-center gap-1.5 px-3 py-1.5 bg-ug-blue-light/50 hover:bg-ug-blue-light rounded-full border border-ug-blue/30 text-label-sm font-label-sm text-ug-blue font-semibold transition-all active:scale-95" href="#">
<span class="material-symbols-outlined text-[14px] text-ug-blue" data-icon="link">link</span>
                Post: 'Torneo Interfacultades'
                <span class="bg-ug-blue text-white px-1.5 py-0.2 rounded-full text-[10px]">19 votos</span>
</a>
<a class="inline-flex items-center gap-1.5 px-3 py-1.5 bg-ug-red-light/40 hover:bg-ug-red-light rounded-full border border-ug-red/30 text-label-sm font-label-sm text-ug-red font-semibold transition-all active:scale-95" href="#">
<span class="material-symbols-outlined text-[14px] text-ug-red" data-icon="verified">verified</span>
                Aviso: 'Bienestar Universitario'
                <span class="bg-ug-red text-white px-1.5 py-0.2 rounded-full text-[10px] font-bold">Oficial Uniguajira</span>
</a>
</div>
</div>
</div>
</div>
<!-- Channel Synthesis Widget: Resumen por Canal / Facultad -->
<section class="bg-surface-container-lowest border border-ug-yellow/30 rounded-xl p-space-md shadow-sm">
<div class="flex items-center justify-between mb-2.5">
<div class="flex items-center gap-2">
<span class="material-symbols-outlined text-ug-yellow-dark text-[20px]" data-icon="topic">topic</span>
<span class="font-headline-md text-headline-md font-bold text-on-surface">Resumen por Facultad &amp; Canal</span>
</div>
<!-- Dropdown selector -->
<div class="relative inline-block">
<button class="inline-flex items-center gap-1.5 px-3 py-1 bg-ug-blue-light/40 border border-ug-blue/30 rounded-lg text-label-md font-label-md text-ug-blue font-bold shadow-sm active:scale-95 transition-all">
<span>Facultad de Ingeniería</span>
<span class="material-symbols-outlined text-[16px]" data-icon="arrow_drop_down">arrow_drop_down</span>
</button>
</div>
</div>
<!-- Mini-card Synthesis -->
<div class="bg-ug-yellow-light/30 p-3 rounded-lg border border-ug-yellow/30 flex items-center justify-between">
<div class="flex items-center gap-3">
<div class="w-8 h-8 rounded-lg bg-ug-yellow text-ug-yellow-dark flex items-center justify-center font-bold shadow-xs">
<span class="material-symbols-outlined text-[18px]" data-icon="terminal">terminal</span>
</div>
<div>
<p class="font-label-md text-label-md font-bold text-on-surface">Ingeniería de Sistemas - Río Grande</p>
<p class="font-body-sm text-body-sm text-on-surface-variant">3 posts sobre sustentaciones de grado, 1 convocatoria de monitorías académicas.</p>
</div>
</div>
<button class="p-1.5 text-ug-yellow-dark hover:bg-ug-yellow-light rounded-full active:scale-95 transition-transform" title="Abrir canal">
<span class="material-symbols-outlined" data-icon="arrow_forward">arrow_forward</span>
</button>
</div>
</section>
</div>
</main>
<!-- Sticky Bottom Conversational Input Console with Voice Dictation & Red Send Accent -->
<div class="fixed bottom-16 left-0 w-full z-40 px-margin max-w-screen-md mx-auto pointer-events-none">
<div class="pointer-events-auto bg-surface-container-lowest/95 backdrop-blur-md rounded-2xl p-2 border border-ug-yellow/40 shadow-xl flex items-center gap-2">
<button class="p-2 text-on-surface-variant hover:text-ug-yellow-dark hover:bg-ug-yellow-light rounded-full transition-all active:scale-95" title="Adjuntar documento o captura">
<span class="material-symbols-outlined text-[22px]" data-icon="attach_file">attach_file</span>
</button>
<div class="flex-1 relative">
<input class="w-full bg-[#F5F2EB] border-none rounded-xl px-3.5 py-2.5 text-body-md font-body-md text-on-surface placeholder:text-outline focus:ring-2 focus:ring-ug-yellow focus:bg-surface-container-lowest transition-all" placeholder="Pregunta sobre clases, rutas o trámites Uniguajira..." type="text"/>
</div>
<!-- Voice dictation button -->
<button class="p-2 text-on-surface-variant hover:text-ug-red hover:bg-ug-red-light/50 rounded-full transition-all active:scale-95" title="Hablar por voz">
<span class="material-symbols-outlined text-[22px]" data-icon="mic">mic</span>
</button>
<!-- Send action with Institutional Red accent -->
<button class="bg-ug-red text-white p-2.5 rounded-xl hover:bg-ug-red-dark active:scale-95 transition-all shadow-md flex items-center justify-center" title="Enviar consulta">
<span class="material-symbols-outlined text-[20px]" data-icon="send">send</span>
</button>
</div>
</div>
<!-- BottomNavBar Component (4 Tabs with Uniguajira Yellow Active Tab) -->
<nav class="fixed bottom-0 left-0 w-full z-50 flex justify-around items-center px-margin pb-space-md pt-space-xs max-w-screen-md mx-auto shadow-lg bg-surface-container-lowest border-t border-ug-yellow/20 transition-colors">
<!-- Item 1: Inicio -->
<a class="flex flex-col items-center justify-center text-on-surface-variant px-space-md py-space-xs hover:bg-ug-yellow-light hover:text-ug-yellow-dark active:scale-95 transition-transform duration-150 rounded-lg" href="#">
<span class="material-symbols-outlined" data-icon="home">home</span>
<span class="font-label-sm text-label-sm mt-0.5">Inicio</span>
</a>
<!-- Item 2: Canales -->
<a class="flex flex-col items-center justify-center text-on-surface-variant px-space-md py-space-xs hover:bg-ug-yellow-light hover:text-ug-yellow-dark active:scale-95 transition-transform duration-150 rounded-lg" href="#">
<span class="material-symbols-outlined" data-icon="forum">forum</span>
<span class="font-label-sm text-label-sm mt-0.5">Canales</span>
</a>
<!-- Item 3: IA (ACTIVE NAVIGATION - Uniguajira Golden Yellow) -->
<a class="flex flex-col items-center justify-center bg-ug-yellow text-ug-yellow-dark font-extrabold rounded-full px-space-md py-space-xs active:scale-95 transition-transform duration-150 shadow-sm border border-ug-yellow-dark/20" href="#">
<span class="material-symbols-outlined" data-icon="auto_awesome" data-weight="fill" style="font-variation-settings: 'FILL' 1;">auto_awesome</span>
<span class="font-label-sm text-label-sm mt-0.5 font-bold">IA</span>
</a>
<!-- Item 4: Perfil -->
<a class="flex flex-col items-center justify-center text-on-surface-variant px-space-md py-space-xs hover:bg-ug-yellow-light hover:text-ug-yellow-dark active:scale-95 transition-transform duration-150 rounded-lg" href="#">
<span class="material-symbols-outlined" data-icon="person">person</span>
<span class="font-label-sm text-label-sm mt-0.5">Perfil</span>
</a>
</nav>
</body></html>

<!-- UniVibe Uniguajira — Inicio (Feed) -->
<!DOCTYPE html>

<html class="light" lang="es"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>UniVibe Uniguajira - Campus Feed</title>
<!-- Fonts -->
<link href="https://fonts.googleapis.com" rel="preconnect"/>
<link crossorigin="" href="https://fonts.gstatic.com" rel="preconnect"/>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet"/>
<!-- Material Symbols -->
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<!-- Tailwind CSS -->
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<script id="tailwind-config">
  tailwind.config = {
    darkMode: "class",
    theme: {
      extend: {
        "colors": {
          "on-error-container": "#93000a",
          "on-tertiary-container": "#990012",
          "surface-variant": "#e0e0fc",
          "outline": "#837561",
          "surface-container": "#f5f3eb",
          "on-surface": "#181a2e",
          "on-primary-fixed-variant": "#5f4100",
          "on-surface-variant": "#514533",
          "on-secondary-fixed-variant": "#07497d",
          "tertiary-container": "#ffa199",
          "primary-container": "#f2ae1c",
          "surface-container-lowest": "#ffffff",
          "on-primary": "#ffffff",
          "error-container": "#ffdad6",
          "inverse-primary": "#ffba30",
          "surface": "#fbf8ff",
          "primary-fixed-dim": "#ffba30",
          "primary": "#7d5700",
          "on-secondary-container": "#144f84",
          "on-error": "#ffffff",
          "outline-variant": "#d5c4ad",
          "on-secondary-fixed": "#001c37",
          "secondary": "#2d6197",
          "tertiary-fixed": "#ffdad6",
          "on-tertiary-fixed": "#410003",
          "inverse-on-surface": "#f1efff",
          "secondary-fixed-dim": "#a0c9ff",
          "on-primary-fixed": "#271900",
          "secondary-fixed": "#d2e4ff",
          "tertiary-fixed-dim": "#ffb3ad",
          "surface-bright": "#fbf8ff",
          "secondary-container": "#92c1fe",
          "surface-container-highest": "#e8e5dc",
          "on-background": "#181a2e",
          "surface-container-high": "#eeebe1",
          "surface-container-low": "#faf8f2",
          "inverse-surface": "#2d2f44",
          "on-primary-container": "#3d2a00",
          "on-secondary": "#ffffff",
          "surface-tint": "#7d5700",
          "error": "#c81d25",
          "primary-fixed": "#ffdeab",
          "on-tertiary-fixed-variant": "#930011",
          "on-tertiary": "#ffffff",
          "surface-dim": "#d7d8f4",
          "background": "#fdfbf7",
          "tertiary": "#bc111e"
        },
        "borderRadius": {
          "DEFAULT": "0.25rem",
          "lg": "0.5rem",
          "xl": "0.75rem",
          "full": "9999px"
        },
        "spacing": {
          "margin": "1rem",
          "margin-desktop": "3rem",
          "space-xl": "2.5rem",
          "space-xs": "0.25rem",
          "space-sm": "0.5rem",
          "gutter": "1.25rem",
          "gutter-desktop": "1.5rem",
          "margin-tablet": "2rem",
          "space-md": "1rem",
          "space-lg": "1.5rem"
        },
        "fontFamily": {
          "title-md": ["Plus Jakarta Sans"],
          "label-sm": ["Plus Jakarta Sans"],
          "label-md": ["Plus Jakarta Sans"],
          "body-md": ["Plus Jakarta Sans"],
          "headline-lg-mobile": ["Plus Jakarta Sans"],
          "headline-lg": ["Plus Jakarta Sans"],
          "headline-sm": ["Plus Jakarta Sans"],
          "display-lg": ["Plus Jakarta Sans"],
          "body-lg": ["Plus Jakarta Sans"],
          "display-lg-mobile": ["Plus Jakarta Sans"],
          "headline-md": ["Plus Jakarta Sans"]
        },
        "fontSize": {
          "title-md": ["18px", { "lineHeight": "24px", "fontWeight": "600" }],
          "label-sm": ["11px", { "lineHeight": "16px", "letterSpacing": "0.04em", "fontWeight": "700" }],
          "label-md": ["13px", { "lineHeight": "18px", "letterSpacing": "0.01em", "fontWeight": "600" }],
          "body-md": ["14px", { "lineHeight": "22px", "fontWeight": "400" }],
          "headline-lg-mobile": ["24px", { "lineHeight": "32px", "letterSpacing": "-0.01em", "fontWeight": "700" }],
          "headline-lg": ["32px", { "lineHeight": "40px", "letterSpacing": "-0.01em", "fontWeight": "700" }],
          "headline-sm": ["20px", { "lineHeight": "28px", "fontWeight": "600" }],
          "display-lg": ["48px", { "lineHeight": "56px", "letterSpacing": "-0.02em", "fontWeight": "800" }],
          "body-lg": ["16px", { "lineHeight": "26px", "fontWeight": "400" }],
          "display-lg-mobile": ["32px", { "lineHeight": "40px", "letterSpacing": "-0.015em", "fontWeight": "800" }],
          "headline-md": ["24px", { "lineHeight": "32px", "fontWeight": "600" }]
        }
      }
    }
  </script>
<style>
    .no-scrollbar::-webkit-scrollbar {
      display: none;
    }
    .no-scrollbar {
      -ms-overflow-style: none;
      scrollbar-width: none;
    }
    .material-symbols-outlined {
      font-variation-settings: 'FILL' 0, 'wght' 500, 'GRAD' 0, 'opsz' 24;
    }
    .icon-fill {
      font-variation-settings: 'FILL' 1, 'wght' 600, 'GRAD' 0, 'opsz' 24;
    }
  </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
</head>
<body class="bg-background text-on-surface antialiased selection:bg-primary-container selection:text-on-primary-container pb-28">
<!-- ================= TOP APP BAR ================= -->
<header class="fixed top-0 left-0 right-0 z-40 bg-white/95 backdrop-blur-md shadow-sm border-b border-primary-container/25 transition-all">
<div class="max-w-screen-md mx-auto px-margin py-space-sm flex items-center justify-between gap-space-sm">
<!-- Leading: Avatar + User Info + Uniguajira Brand -->
<div class="flex items-center gap-space-sm">
<div class="relative cursor-pointer active:scale-95 transition-transform">
<img class="w-10 h-10 rounded-full object-cover ring-2 ring-primary-container p-0.5 bg-surface-container-lowest shadow-sm" data-alt="Portrait photograph of Mateo, a young male Latin university student with a relaxed collegiate smile, wearing modern streetwear hoodie, lit softly in natural campus library lighting with vibrant tech collegiate vibes." src="https://lh3.googleusercontent.com/aida-public/AB6AXuArc26NRRLKT8FEn7kQlJI1aVkFM5L2MHGdhsQUhzWqA3fX9uo1lTGnx_J054St9Ziqlcxp970bnwKF-lPe17mRY3ritwzQsGPjai6Wea5RQR-JuoSkOZ9qbmS-swesBNFWLRzR6BSUlSKL7vb5_kel-NbvDy-sGOd54dGcOWJm6XNLdGmEv_n2EEW42RfvPh6I2BIIzyb2c1UB0RBMRWanO0Bumsvs-OKb9EM-bFIf"/>
<span class="absolute -bottom-1 -right-1 bg-tertiary text-white font-label-sm text-[9px] font-bold px-1.5 py-0.2 rounded-full border border-surface-container-lowest shadow-sm">
            Nv. 3
          </span>
</div>
<div>
<div class="flex items-center gap-1.5">
<span class="font-headline-md text-base text-on-surface leading-tight font-bold">¡Hola, Mateo!</span>
<span class="text-base select-none">👋</span>
<span class="px-1.5 py-0.5 bg-primary-container/20 text-[#7d5700] rounded text-[10px] font-extrabold uppercase tracking-wider">Uniguajira</span>
</div>
<div class="flex items-center gap-1 text-secondary font-label-sm text-[12px] font-semibold">
<span class="material-symbols-outlined text-[13px] text-secondary" data-icon="school">school</span>
<span>Sede Riohacha • UniVibe Uniguajira</span>
</div>
</div>
</div>
<!-- Trailing: Quick Search & Notifications -->
<div class="flex items-center gap-space-xs">
<button aria-label="Buscar en campus" class="w-9 h-9 rounded-full bg-surface-container hover:bg-surface-container-high flex items-center justify-center text-on-surface-variant active:scale-95 transition-transform border border-outline-variant/30" type="button">
<span class="material-symbols-outlined text-[20px]" data-icon="search">search</span>
</button>
<button aria-label="Notificaciones" class="relative w-9 h-9 rounded-full bg-surface-container hover:bg-surface-container-high flex items-center justify-center text-on-surface active:scale-95 transition-transform border border-outline-variant/30" type="button">
<span class="material-symbols-outlined text-[20px]" data-icon="notifications">notifications</span>
<!-- Badge Rojo Institucional -->
<span class="absolute top-1 right-1 w-4 h-4 bg-tertiary text-white font-label-sm text-[9px] rounded-full flex items-center justify-center font-bold ring-2 ring-white">
            3
          </span>
</button>
</div>
</div>
</header>
<!-- Content Clearance for TopAppBar -->
<main class="max-w-screen-md mx-auto px-margin pt-20 space-y-space-lg">
<!-- ================= IA DESTACADA DEL CAMPUS (UNIGUAJIRA) ================= -->
<section class="relative overflow-hidden rounded-xl p-space-md border border-primary-container/40 bg-gradient-to-br from-surface-container-lowest via-surface-container-low to-primary-fixed/25 shadow-sm">
<!-- Glow ambient decorative orbs institucional -->
<div class="absolute -top-10 -right-10 w-32 h-32 bg-primary-container/20 rounded-full blur-2xl pointer-events-none"></div>
<div class="absolute -bottom-10 -left-10 w-28 h-28 bg-secondary-fixed/40 rounded-full blur-xl pointer-events-none"></div>
<div class="relative z-10 flex flex-col gap-space-sm">
<div class="flex items-center justify-between">
<div class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-primary-fixed text-[#5f4100] font-label-sm text-label-sm font-bold border border-primary-container/30">
<span class="material-symbols-outlined text-[14px] text-[#7d5700] icon-fill" data-icon="auto_awesome">auto_awesome</span>
<span>IA UniVibe Uniguajira activa</span>
</div>
<span class="text-on-surface-variant/80 font-label-sm text-[11px] flex items-center gap-1 font-semibold">
<span class="w-1.5 h-1.5 rounded-full bg-emerald-600 animate-pulse"></span> Sincronizado
          </span>
</div>
<div>
<h2 class="font-headline-lg-mobile text-headline-lg-mobile text-on-surface font-extrabold tracking-tight">
            ¿Qué quieres saber de tu campus hoy?
          </h2>
<p class="font-body-md text-body-md text-on-surface-variant mt-0.5">
            Horarios, cupos en biblioteca, eventos y resúmenes de asambleas al instante.
          </p>
</div>
<!-- 3 Quick Action Buttons -->
<div class="grid grid-cols-3 gap-space-xs pt-1">
<button class="group flex flex-col items-center justify-center p-2.5 rounded-lg bg-surface-container-lowest hover:bg-surface-container border border-outline-variant/30 text-center active:scale-95 transition-all shadow-sm" type="button">
<div class="w-8 h-8 rounded-full bg-tertiary-fixed text-tertiary flex items-center justify-center mb-1 group-hover:scale-105 transition-transform">
<span class="material-symbols-outlined text-[18px]" data-icon="bolt">bolt</span>
</div>
<span class="font-label-md text-[11px] text-on-surface leading-tight font-bold">¿Qué me perdí?</span>
</button>
<button class="group flex flex-col items-center justify-center p-2.5 rounded-lg bg-primary-container text-on-primary-container hover:bg-[#e5a210] active:scale-95 transition-all shadow-md shadow-primary-container/30 text-center font-bold" type="button">
<div class="w-8 h-8 rounded-full bg-black/10 text-on-primary-container flex items-center justify-center mb-1 group-hover:scale-105 transition-transform">
<span class="material-symbols-outlined text-[18px]" data-icon="chat">chat</span>
</div>
<span class="font-label-md text-[11px] text-on-primary-container leading-tight font-bold">Preguntar a IA</span>
</button>
<button class="group flex flex-col items-center justify-center p-2.5 rounded-lg bg-surface-container-lowest hover:bg-surface-container border border-outline-variant/30 text-center active:scale-95 transition-all shadow-sm" type="button">
<div class="w-8 h-8 rounded-full bg-secondary-fixed text-secondary flex items-center justify-center mb-1 group-hover:scale-105 transition-transform">
<span class="material-symbols-outlined text-[18px]" data-icon="manage_search">manage_search</span>
</div>
<span class="font-label-md text-[11px] text-on-surface leading-tight font-bold">Buscar con IA</span>
</button>
</div>
</div>
</section>
<!-- ================= HORIZONTAL FILTER CHIPS ================= -->
<section>
<div class="flex items-center gap-space-xs overflow-x-auto no-scrollbar py-1 -mx-margin px-margin">
<button class="px-4 py-1.5 rounded-full font-label-md text-label-md bg-primary-container text-on-primary-container font-extrabold shadow-sm shrink-0 active:scale-95 transition-transform border border-primary-container/40" type="button">
          Todo
        </button>
<button class="px-3.5 py-1.5 rounded-full font-label-md text-label-md bg-surface-container-high hover:bg-surface-container-highest text-on-surface shrink-0 active:scale-95 transition-transform flex items-center gap-1 font-semibold border border-outline-variant/20" type="button">
<span>🔥</span> Tendencias
        </button>
<button class="px-3.5 py-1.5 rounded-full font-label-md text-label-md bg-surface-container-high hover:bg-surface-container-highest text-on-surface shrink-0 active:scale-95 transition-transform flex items-center gap-1 font-semibold border border-outline-variant/20" type="button">
<span>📢</span> Avisos
        </button>
<button class="px-3.5 py-1.5 rounded-full font-label-md text-label-md bg-surface-container-high hover:bg-surface-container-highest text-on-surface shrink-0 active:scale-95 transition-transform flex items-center gap-1 font-semibold border border-outline-variant/20" type="button">
<span>🍔</span> Chisme &amp; Café
        </button>
<button class="px-3.5 py-1.5 rounded-full font-label-md text-label-md bg-surface-container-high hover:bg-surface-container-highest text-on-surface shrink-0 active:scale-95 transition-transform flex items-center gap-1 font-semibold border border-outline-variant/20" type="button">
<span>🛒</span> Ventas
        </button>
<button class="px-3.5 py-1.5 rounded-full font-label-md text-label-md bg-surface-container-high hover:bg-surface-container-highest text-on-surface shrink-0 active:scale-95 transition-transform flex items-center gap-1 font-semibold border border-outline-variant/20" type="button">
<span>🔍</span> Perdidos
        </button>
<button class="px-3.5 py-1.5 rounded-full font-label-md text-label-md bg-surface-container-high hover:bg-surface-container-highest text-on-surface shrink-0 active:scale-95 transition-transform flex items-center gap-1 font-semibold border border-outline-variant/20" type="button">
<span>⚽</span> Torneos
        </button>
</div>
</section>
<!-- ================= SECCIÓN 'TENDENCIAS AHORA' (ROJO INSTITUCIONAL) ================= -->
<section class="space-y-space-xs">
<div class="flex items-center justify-between px-1">
<h3 class="font-headline-sm text-headline-sm text-on-surface flex items-center gap-1.5 font-bold">
<span class="material-symbols-outlined text-tertiary text-[22px]" data-icon="local_fire_department">local_fire_department</span>
          Tendencias Ahora
        </h3>
<span class="font-label-sm text-label-sm text-secondary font-bold cursor-pointer hover:underline">Ver ranking</span>
</div>
<!-- Tarjeta destacada #1 -->
<article class="bg-surface-container-lowest rounded-xl p-space-md border border-tertiary/20 shadow-sm relative overflow-hidden transition-all hover:shadow-md">
<!-- Accent line indicator: Rojo Uniguajira -->
<div class="absolute top-0 left-0 w-1.5 h-full bg-tertiary"></div>
<div class="pl-2 space-y-space-sm">
<div class="flex items-start justify-between gap-2">
<div class="flex items-center gap-2">
<span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-tertiary-fixed text-tertiary font-label-sm text-label-sm font-extrabold tracking-wide">
                🔥 Tendencia #1
              </span>
<span class="font-body-md text-[11px] text-on-surface-variant">hace 25 min</span>
</div>
<button class="text-outline hover:text-on-surface p-1 rounded-full active:scale-90 transition-transform" type="button">
<span class="material-symbols-outlined text-[18px]" data-icon="more_horiz">more_horiz</span>
</button>
</div>
<!-- Question / Post body -->
<h4 class="font-headline-sm text-[17px] text-on-surface leading-snug cursor-pointer hover:text-secondary transition-colors font-bold">
            ¿Alguien sabe qué pasó hoy en la cafetería del Bloque C? Se llenó de seguridad y cerraron el paso 😱
          </h4>
<!-- Author info -->
<div class="flex items-center justify-between text-on-surface-variant pt-1">
<div class="flex items-center gap-2">
<img class="w-7 h-7 rounded-full object-cover ring-1 ring-primary-container" data-alt="Close-up portrait of Valeria, an architecture student wearing tortoise-shell designer glasses and an artist beret, smiling thoughtfully with modern campus design studios visible softly blurred in the background." src="https://lh3.googleusercontent.com/aida-public/AB6AXuAhIzLkWrlhRz93m1u6kvfoyIDqWsG9bmTGaN7sVBxDsXp603lqORDn2mUaODsBi1NchP-cU-KKRzhBhdG0EQzDnlreJF7OBiMxkEF_kUUP2iIR1SxYKVaOwJqsgf_fnSPUM5Bx5-qCcXvhf5s8_OBI1iUK9Qu3Z8FBaP4_GaGAMrLzAsuuGKoFIUdEPW-7ezOCLSBMeK3Dyzu014-_sHKUL_SM-8yrVdvot4ecm9Dm"/>
<div class="flex items-center gap-1.5 flex-wrap">
<span class="font-label-md text-label-md text-on-surface font-semibold">@valeria_arq</span>
<span class="text-outline text-xs">•</span>
<span class="font-body-md text-body-md text-secondary font-medium">Arquitectura</span>
<span class="px-1.5 py-0.2 bg-primary-fixed text-[#5f4100] font-label-sm text-[9px] rounded-full font-bold">Nv. 4</span>
</div>
</div>
</div>
<!-- Actions Toolbar -->
<div class="flex items-center justify-between pt-2 border-t border-surface-container">
<!-- Dual Voting -->
<div class="inline-flex items-center bg-surface-container-low rounded-full border border-outline-variant/30 px-1 py-0.5">
<button aria-label="Upvote" class="p-1 hover:text-tertiary active:scale-90 text-on-surface-variant transition-transform" type="button">
<span class="material-symbols-outlined text-[18px]" data-icon="arrow_upward">arrow_upward</span>
</button>
<span class="px-1.5 font-label-md text-label-md text-tertiary font-bold">142</span>
<button aria-label="Downvote" class="p-1 hover:text-on-surface active:scale-90 text-on-surface-variant transition-transform" type="button">
<span class="material-symbols-outlined text-[18px]" data-icon="arrow_downward">arrow_downward</span>
</button>
</div>
<div class="flex items-center gap-3">
<button class="flex items-center gap-1 text-on-surface-variant hover:text-secondary font-label-md text-label-md" type="button">
<span class="material-symbols-outlined text-[18px]" data-icon="chat_bubble">chat_bubble</span>
<span>58</span>
</button>
<button class="flex items-center gap-1 text-on-surface-variant hover:text-secondary font-label-md text-label-md" type="button">
<span class="material-symbols-outlined text-[18px]" data-icon="share">share</span>
</button>
</div>
</div>
</div>
</article>
</section>
<!-- ================= FEED PRINCIPAL DINÁMICO ================= -->
<section class="space-y-space-md">
<div class="flex items-center justify-between px-1">
<h3 class="font-headline-sm text-headline-sm text-on-surface font-bold">
          Feed del Campus Uniguajira
        </h3>
<button class="font-label-md text-label-md text-secondary flex items-center gap-1 font-semibold">
<span class="material-symbols-outlined text-[16px]" data-icon="tune">tune</span>
          Recientes
        </button>
</div>
<!-- POST 1: VENTA DE PRODUCTO -->
<article class="bg-surface-container-lowest rounded-xl p-space-md border border-outline-variant/30 shadow-sm transition-all hover:shadow-md space-y-space-sm">
<!-- Post Header -->
<div class="flex items-center justify-between">
<div class="flex items-center gap-2">
<img class="w-9 h-9 rounded-full object-cover ring-1 ring-secondary/40" data-alt="Avatar portrait of Carlos, a male engineering university student wearing a tech jacket and earphones around his neck, looking friendly and authentic inside a modern campus computing hall." src="https://lh3.googleusercontent.com/aida-public/AB6AXuC3KJPJxMUhP-alUqs0V2HOvD0o37OnmcrCa7s2Dl32vduvicumxp0PC4mc3OI6oEDBcnXb9glGd_KcHr_wKZVrFvHW0429Vkkb2g8tVBGXGkg39OTlJM2Xt4unmQ52L88Sur8z2Tmoh0-5RtmNhsx0cSOOEUpp0Xs7c4HkAPxEZyKK5UGXew_Zx-08WBiwVv9a-ipGIviqitJ_Af3JHAs38ookdwpkKkm9fBWec2sZ"/>
<div>
<div class="flex items-center gap-1.5">
<span class="font-label-md text-label-md text-on-surface font-bold">@carlos_ing</span>
<span class="px-1.5 py-0.2 rounded-full bg-secondary-fixed text-on-secondary-fixed font-label-sm text-[9px] font-semibold">Ing. Sistemas</span>
</div>
<span class="font-body-md text-[11px] text-on-surface-variant">hace 42 min</span>
</div>
</div>
<div class="flex items-center gap-2">
<span class="px-2.5 py-0.5 rounded-full bg-primary-fixed text-[#5f4100] font-label-sm text-label-sm flex items-center gap-1 font-bold border border-primary-container/20">
<span class="w-1.5 h-1.5 rounded-full bg-primary"></span> Compra/Venta
            </span>
<button class="text-outline hover:text-on-surface p-1" type="button">
<span class="material-symbols-outlined text-[18px]" data-icon="more_vert">more_vert</span>
</button>
</div>
</div>
<!-- Post Content & Preview Image -->
<div class="flex gap-space-sm">
<div class="flex-1 space-y-1">
<p class="font-body-md text-body-md text-on-surface">
              Vendo calculadora científica <strong>Casio fx-991LA CW</strong> casi nueva, la entrego en biblioteca o bloque de ingeniería.
            </p>
<div class="inline-block mt-1 px-2.5 py-1 rounded-lg bg-primary-fixed/60 text-[#3d2a00] font-headline-sm text-sm font-extrabold border border-primary-container">
              $35.000 COP
            </div>
</div>
<div class="w-20 h-20 rounded-lg overflow-hidden shrink-0 border border-outline-variant/40">
<img class="w-full h-full object-cover" data-alt="A clean product shot of a black and white Casio fx-991LA CW scientific calculator resting on a clean wooden study desk next to neatly typed lecture notes in a crisp light-filled collegiate library." src="https://lh3.googleusercontent.com/aida-public/AB6AXuDvDrmhOSFTRIIEgOu9U7wOxDL4PInSDj3aEjQ0Fppn-gnw1fALQewMn5Xs7lfcEzuKw-bvyg2vQxc5FLTX8hCDAtT1jh0KwEhlDZYgxzdlr6vjfGy55AoM-ZfLIlKTr1hpBdBMfyV5aWRCjd7x4Hs7zdAUYAk4kTfZ5mToAUFvBedkoydbO-kdcNKm7n3_E1WjkelbN-JZwp-yBUQZx6t67n-Yi70rA1Edh2U2GOMy"/>
</div>
</div>
<!-- Bottom Actions -->
<div class="flex items-center justify-between pt-2 border-t border-surface-container">
<div class="inline-flex items-center bg-surface-container-low rounded-full border border-outline-variant/30 px-1 py-0.5">
<button aria-label="Upvote" class="p-1 hover:text-secondary active:scale-90 text-on-surface-variant transition-transform" type="button">
<span class="material-symbols-outlined text-[18px]" data-icon="arrow_upward">arrow_upward</span>
</button>
<span class="px-1.5 font-label-md text-label-md text-on-surface font-bold">+24</span>
<button aria-label="Downvote" class="p-1 hover:text-on-surface active:scale-90 text-on-surface-variant transition-transform" type="button">
<span class="material-symbols-outlined text-[18px]" data-icon="arrow_downward">arrow_downward</span>
</button>
</div>
<div class="flex items-center gap-3">
<button class="flex items-center gap-1 text-on-surface-variant hover:text-secondary font-label-md text-label-md" type="button">
<span class="material-symbols-outlined text-[18px]" data-icon="chat_bubble">chat_bubble</span>
<span>8</span>
</button>
<button class="px-3.5 py-1 rounded-full bg-secondary text-white font-label-sm text-label-sm font-bold active:scale-95 transition-transform flex items-center gap-1 shadow-sm hover:bg-[#1f4b7a]" type="button">
<span class="material-symbols-outlined text-[14px]" data-icon="send">send</span>
              Contactar
            </button>
</div>
</div>
</article>
<!-- POST 2: PERDIDOS / ENCONTRADOS -->
<article class="bg-surface-container-lowest rounded-xl p-space-md border border-outline-variant/30 shadow-sm transition-all hover:shadow-md space-y-space-sm">
<!-- Header -->
<div class="flex items-center justify-between">
<div class="flex items-center gap-2">
<img class="w-9 h-9 rounded-full object-cover ring-1 ring-secondary/40" data-alt="Portrait photo of Sofia, a female Latin medical student with stethoscope pin on a white laboratory coat collar, with warm natural light in a hospital-university faculty courtyard." src="https://lh3.googleusercontent.com/aida-public/AB6AXuAyeyWHMiDgIbo3uTWirjyCZ1FL64fPETer1xWIU2yvQ834o9r_JUAONg-eKIWoPdAk8Nlhw6qU_bhIBCPbLuUZDaGMMtUaBZKU9o-iSUnhKfpFQW0XrE17O8UpydMgGSdakieyYdPfuYjLiEY-8RreyNN_nw6WBH2RCrHeJCoWL2Cb1qAPdt9XSERKX4Tq3tyz7uyH65c_SB8TwpPgYVbEnvbr3uc8FdaKx4G8nnLS"/>
<div>
<div class="flex items-center gap-1.5">
<span class="font-label-md text-label-md text-on-surface font-bold">@sofia_med</span>
<span class="px-1.5 py-0.2 rounded-full bg-secondary-fixed text-on-secondary-fixed font-label-sm text-[9px] font-semibold">Salud • Nv. 2</span>
</div>
<span class="font-body-md text-[11px] text-on-surface-variant">hace 1 hora</span>
</div>
</div>
<div class="flex items-center gap-2">
<span class="px-2.5 py-0.5 rounded-full bg-primary-fixed text-[#5f4100] font-label-sm text-label-sm flex items-center gap-1 font-bold border border-primary-container/20">
<span class="material-symbols-outlined text-[13px] text-primary" data-icon="search">search</span> Encontrado
            </span>
<button class="text-outline hover:text-on-surface p-1" type="button">
<span class="material-symbols-outlined text-[18px]" data-icon="more_vert">more_vert</span>
</button>
</div>
</div>
<p class="font-body-md text-body-md text-on-surface">
          Se encontraron unas llaves con llavero de <strong>Spiderman</strong> cerca del laboratorio 302. Las dejé con el guardia del acceso norte. 🔑🕷️
        </p>
<!-- Claim Action Card -->
<div class="flex items-center justify-between p-2.5 rounded-lg bg-surface-container-low border border-outline-variant/30">
<div class="flex items-center gap-2">
<span class="material-symbols-outlined text-secondary text-[20px]" data-icon="vpn_key">vpn_key</span>
<span class="font-body-md text-body-md text-on-surface">Llavero Spider-Man (3 llaves)</span>
</div>
<button class="px-3 py-1 rounded-full bg-primary-container text-on-primary-container font-label-sm text-label-sm font-bold active:scale-95 transition-transform hover:bg-[#e5a210] shadow-sm" type="button">
            Reclamar / Info
          </button>
</div>
<!-- Footer -->
<div class="flex items-center justify-between pt-2 border-t border-surface-container">
<div class="inline-flex items-center bg-surface-container-low rounded-full border border-outline-variant/30 px-1 py-0.5">
<button aria-label="Upvote" class="p-1 hover:text-secondary active:scale-90 text-on-surface-variant transition-transform" type="button">
<span class="material-symbols-outlined text-[18px]" data-icon="arrow_upward">arrow_upward</span>
</button>
<span class="px-1.5 font-label-md text-label-md text-on-surface font-bold">+31</span>
<button aria-label="Downvote" class="p-1 hover:text-on-surface active:scale-90 text-on-surface-variant transition-transform" type="button">
<span class="material-symbols-outlined text-[18px]" data-icon="arrow_downward">arrow_downward</span>
</button>
</div>
<div class="flex items-center gap-3">
<button class="flex items-center gap-1 text-on-surface-variant hover:text-secondary font-label-md text-label-md" type="button">
<span class="material-symbols-outlined text-[18px]" data-icon="chat_bubble">chat_bubble</span>
<span>12</span>
</button>
<button class="text-on-surface-variant hover:text-secondary p-1" type="button">
<span class="material-symbols-outlined text-[18px]" data-icon="share">share</span>
</button>
</div>
</div>
</article>
<!-- POST 3: SOCIAL / VIDA ESTUDIANTIL -->
<article class="bg-surface-container-lowest rounded-xl p-space-md border border-outline-variant/30 shadow-sm transition-all hover:shadow-md space-y-space-sm">
<!-- Header -->
<div class="flex items-center justify-between">
<div class="flex items-center gap-2">
<img class="w-9 h-9 rounded-full object-cover ring-1 ring-secondary/40" data-alt="Athletic university student Juan Diego wearing a vibrant blue college sports jersey outdoors on synthetic soccer turf under bright sunny daylight, smiling cheerfully." src="https://lh3.googleusercontent.com/aida-public/AB6AXuCG-eeCjUjJL3Ozj3yylYHyGp7vEKREsc_PuD5eBf9B6arJ-KaMHdSUf6o5ULJnNOUIsi1Gfhw5H6yMIyWhtqE02wbrVqnvcPSuleGGqPyW2mU7nRmqKogmpdFsj3LKMiC61eh5DaGchvVRPrF8CbQloEP9Dk_nCDriNoF8JyH8P8iRL4eK0kuldJJ80v2sCR-okzr4SyBKNU3U-BgPzXHQwMCXBBVqUA-z1AGSvtyF"/>
<div>
<div class="flex items-center gap-1.5">
<span class="font-label-md text-label-md text-on-surface font-bold">@juan_diego</span>
<span class="px-1.5 py-0.2 rounded-full bg-secondary-fixed text-on-secondary-fixed font-label-sm text-[9px] font-semibold">Economía</span>
</div>
<span class="font-body-md text-[11px] text-on-surface-variant">hace 2 horas</span>
</div>
</div>
<div class="flex items-center gap-2">
<span class="px-2.5 py-0.5 rounded-full bg-secondary-fixed text-on-secondary-fixed font-label-sm text-label-sm flex items-center gap-1 font-bold">
<span class="material-symbols-outlined text-[13px] text-secondary" data-icon="sports_soccer">sports_soccer</span> Deportes
            </span>
<button class="text-outline hover:text-on-surface p-1" type="button">
<span class="material-symbols-outlined text-[18px]" data-icon="more_vert">more_vert</span>
</button>
</div>
</div>
<p class="font-body-md text-body-md text-on-surface">
          ¿Quién va al torneo relámpago de fútbol 8 este viernes en las canchas de Uniguajira? ¡Falta un defensa central con ganas de salir campeones! ⚽🔥
        </p>
<!-- Mini Info Chip -->
<div class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-secondary-fixed text-secondary font-label-sm text-label-sm font-semibold">
<span class="material-symbols-outlined text-[14px]" data-icon="event">event</span>
          Viernes 4:00 PM • Cancha 2
        </div>
<!-- Footer -->
<div class="flex items-center justify-between pt-2 border-t border-surface-container">
<div class="inline-flex items-center bg-surface-container-low rounded-full border border-outline-variant/30 px-1 py-0.5">
<button aria-label="Upvote" class="p-1 hover:text-secondary active:scale-90 text-on-surface-variant transition-transform" type="button">
<span class="material-symbols-outlined text-[18px]" data-icon="arrow_upward">arrow_upward</span>
</button>
<span class="px-1.5 font-label-md text-label-md text-on-surface font-bold">+19</span>
<button aria-label="Downvote" class="p-1 hover:text-on-surface active:scale-90 text-on-surface-variant transition-transform" type="button">
<span class="material-symbols-outlined text-[18px]" data-icon="arrow_downward">arrow_downward</span>
</button>
</div>
<div class="flex items-center gap-3">
<button class="flex items-center gap-1 text-on-surface-variant hover:text-secondary font-label-md text-label-md" type="button">
<span class="material-symbols-outlined text-[18px]" data-icon="chat_bubble">chat_bubble</span>
<span>14</span>
</button>
<button class="text-on-surface-variant hover:text-secondary p-1" type="button">
<span class="material-symbols-outlined text-[18px]" data-icon="share">share</span>
</button>
</div>
</div>
</article>
<!-- POST 4: INSTITUCIONAL / AVISO (UNIGUAJIRA AZUL + AMARILLO) -->
<article class="bg-surface-container-lowest rounded-xl p-space-md border-2 border-secondary/30 shadow-sm transition-all hover:shadow-md space-y-space-sm relative overflow-hidden">
<div class="absolute -top-12 -right-12 w-24 h-24 bg-primary-container/20 rounded-full blur-xl pointer-events-none"></div>
<!-- Header -->
<div class="flex items-center justify-between">
<div class="flex items-center gap-2">
<div class="w-9 h-9 rounded-full bg-secondary flex items-center justify-center text-white shadow-sm ring-2 ring-primary-container/50">
<span class="material-symbols-outlined text-[20px]" data-icon="verified">verified</span>
</div>
<div>
<div class="flex items-center gap-1.5">
<span class="font-label-md text-label-md text-on-surface font-bold">Bienestar Uniguajira</span>
<span class="material-symbols-outlined text-[15px] text-secondary icon-fill" data-icon="check_circle">check_circle</span>
</div>
<span class="font-body-md text-[11px] text-on-surface-variant font-medium">Oficial Institucional • hace 3 horas</span>
</div>
</div>
<div class="flex items-center gap-2">
<span class="px-2.5 py-0.5 rounded-full bg-tertiary-fixed text-tertiary font-label-sm text-label-sm flex items-center gap-1 font-extrabold border border-tertiary/20">
              Oficial
            </span>
<button class="text-outline hover:text-on-surface p-1" type="button">
<span class="material-symbols-outlined text-[18px]" data-icon="more_vert">more_vert</span>
</button>
</div>
</div>
<p class="font-body-md text-body-md text-on-surface">
<strong>Confirmado:</strong> Mañana jornada institucional de carnetización y bienestar en la plazoleta principal de Uniguajira. Recuerda traer tu documento original de identidad de 8:00 AM a 4:00 PM. 🪪✨
        </p>
<!-- Bottom Actions -->
<div class="flex items-center justify-between pt-2 border-t border-surface-container">
<div class="inline-flex items-center bg-surface-container-low rounded-full border border-outline-variant/30 px-1 py-0.5">
<button aria-label="Upvote" class="p-1 hover:text-secondary active:scale-90 text-on-surface-variant transition-transform" type="button">
<span class="material-symbols-outlined text-[18px]" data-icon="arrow_upward">arrow_upward</span>
</button>
<span class="px-1.5 font-label-md text-label-md text-secondary font-bold">+88</span>
<button aria-label="Downvote" class="p-1 hover:text-on-surface active:scale-90 text-on-surface-variant transition-transform" type="button">
<span class="material-symbols-outlined text-[18px]" data-icon="arrow_downward">arrow_downward</span>
</button>
</div>
<div class="flex items-center gap-3">
<button class="flex items-center gap-1 text-on-surface-variant hover:text-secondary font-label-md text-label-md" type="button">
<span class="material-symbols-outlined text-[18px]" data-icon="chat_bubble">chat_bubble</span>
<span>22</span>
</button>
<button class="text-on-surface-variant hover:text-secondary p-1" type="button">
<span class="material-symbols-outlined text-[18px]" data-icon="bookmark">bookmark</span>
</button>
<button class="text-on-surface-variant hover:text-secondary p-1" type="button">
<span class="material-symbols-outlined text-[18px]" data-icon="share">share</span>
</button>
</div>
</div>
</article>
</section>
</main>
<!-- ================= FLOATING ACTION BUTTON (CENTRAL DOCK) ================= -->
<!-- Con color amarillo institucional Uniguajira (#f2ae1c) y alto contraste -->
<div class="fixed bottom-14 left-1/2 -translate-x-1/2 z-50">
<button aria-label="Publicar nuevo post o pregunta" class="w-14 h-14 rounded-full bg-primary-container text-on-primary-container flex items-center justify-center shadow-lg active:scale-90 transition-all duration-150 ring-4 ring-white hover:bg-[#e5a210]" style="box-shadow: 0 10px 22px -3px rgba(242, 174, 28, 0.55);" type="button">
<span class="material-symbols-outlined text-[30px] font-bold" data-icon="add">add</span>
</button>
</div>
<!-- ================= BOTTOM NAVIGATION BAR ================= -->
<!-- Con identidad UniVibe Uniguajira -->
<nav class="fixed bottom-0 left-0 w-full z-40 bg-white shadow-lg py-1 px-4 max-w-screen-md mx-auto right-0 backdrop-blur-md border-t border-primary-container/20">
<div class="flex justify-around items-center">
<!-- Slot 1: Inicio (ACTIVE con amarillo Uniguajira) -->
<a class="flex flex-col items-center justify-center bg-primary-container text-on-primary-container rounded-full px-space-md py-space-xs active:scale-95 transition-transform duration-150 shadow-sm" href="#">
<span class="material-symbols-outlined text-[20px] icon-fill text-on-primary-container" data-icon="home">home</span>
<span class="font-label-sm text-label-sm font-extrabold tracking-tight">Inicio</span>
</a>
<!-- Slot 2: Canales (INACTIVE) -->
<a class="flex flex-col items-center justify-center text-on-surface-variant hover:bg-surface-container-high hover:text-secondary rounded-full px-space-md py-space-xs active:scale-95 transition-transform duration-150" href="#">
<span class="material-symbols-outlined text-[20px]" data-icon="forum">forum</span>
<span class="font-label-sm text-label-sm font-semibold">Canales</span>
</a>
<!-- Spacing hole for FAB alignment -->
<div class="w-8"></div>
<!-- Slot 3: IA (INACTIVE) -->
<a class="flex flex-col items-center justify-center text-on-surface-variant hover:bg-surface-container-high hover:text-secondary rounded-full px-space-md py-space-xs active:scale-95 transition-transform duration-150" href="#">
<span class="material-symbols-outlined text-[20px]" data-icon="auto_awesome">auto_awesome</span>
<span class="font-label-sm text-label-sm font-semibold">IA</span>
</a>
<!-- Slot 4: Perfil (INACTIVE) -->
<a class="flex flex-col items-center justify-center text-on-surface-variant hover:bg-surface-container-high hover:text-secondary rounded-full px-space-md py-space-xs active:scale-95 transition-transform duration-150" href="#">
<span class="material-symbols-outlined text-[20px]" data-icon="person">person</span>
<span class="font-label-sm text-label-sm font-semibold">Perfil</span>
</a>
</div>
</nav>
</body></html>
---

## Sistema de tema (implementación Flutter)

Referencia de código: `lib/core/theme/`.

- `AppPalette` (`app_palette.dart`) es un `ThemeExtension` con variantes
  `light` y `dark`. Se consume en widgets con `context.colors.<token>`.
- `AppTheme.light()` / `AppTheme.dark()` (`app_theme.dart`) construyen el
  `ThemeData` (Material 3) y registran la paleta como extensión.
- `ThemeController` (`theme_controller.dart`) expone el `ThemeMode` activo.
- La preferencia se persiste con `shared_preferences` a través de
  `PreferencesService` (`lib/core/services/preferences_service.dart`).

Regla: **no usar colores literales en widgets**; usar siempre `context.colors`.

### Modos de apariencia

| Modo | Valor | Descripción |
| --- | --- | --- |
| Claro | `ThemeMode.light` | Superficies cálidas claras. |
| Oscuro | `ThemeMode.dark` | Superficies cálidas casi negras. |
| Sistema | `ThemeMode.system` | Sigue el ajuste del sistema (**por defecto**). |

Se cambia en Ajustes → *Apariencia e Identidad* → *Tema visual*. La selección
persiste entre sesiones.

### Colores de marca

| Token | Claro | Oscuro |
| --- | --- | --- |
| `ugYellow` (principal) | `#C99A2E` | `#F2F2F2` |
| `ugYellowDark` | `#A67C1F` | `#CFCFCF` |
| `ugBlue` / `ugAzulMar` | `#0F4C81` | `#7FB0E0` |
| `ugBlueLight` / `ugAzulMarLight` | `#E8F1F9` | `#1C2C3D` |
| `ugRed` | `#C81D25` | `#F08A8F` |
| `ugRedLight` | `#FDE8E9` | `#3A1E20` |
| `ugFlamenco` | `#C2415A` | `#F094A6` |
| `ugFlamencoLight` | `#FBE3E8` | `#3A2129` |
| `ugOcre` | `#F2AE1C` | `#E6E6E6` |
| `ugOcreLight` | `#FDF1D6` | `#2A2A2A` |
| `ugAguaMarina` | `#0E8F9E` | `#5FD0DD` |
| `ugAguaMarinaLight` | `#DCF1F4` | `#123238` |
| `ugAmarilloDesierto` | `#C99A2E` | `#F2F2F2` |
| `ugAmarilloDesiertoLight` | `#F7EBD2` | `#2E2E2E` |
| `ugNegro` | `#1E1E1E` | `#F2F2F2` |

En modo oscuro el acento primario (amarillo institucional) se reemplaza por
blanco/gris claro (`ugYellow`/`ugOcre`/`ugAmarilloDesierto`) con texto oscuro,
porque el amarillo desentona con el negro. Los demás acentos semánticos (azul,
rojo, flamenco, agua marina) se conservan aclarados. `ugNegro` se invierte (token
de texto).

### Neutros y superficies

| Token | Claro | Oscuro |
| --- | --- | --- |
| `background` / `surface` | `#FBF8F5` | `#141414` |
| `surfaceContainerLowest` | `#FFFFFF` | `#1C1C1C` |
| `surfaceContainerLow` | `#FAF7F0` | `#222222` |
| `surfaceContainer` | `#F6F3EB` | `#262626` |
| `surfaceContainerHigh` | `#F0EBD9` | `#303030` |
| `surfaceContainerHighest` | `#EAE5D8` | `#3A3A3A` |
| `onPrimary` | `#FFFFFF` | `#141414` |
| `onSurface` | `#1E1E1E` | `#F3F3F3` |
| `onSurfaceVariant` | `#514533` | `#BDBDBD` |
| `outline` | `#837561` | `#8A8A8A` |
| `outlineVariant` | `#E5DCCE` | `#3C3C3C` |

Las superficies oscuras son gris neutro (sin el tinte cálido anterior) para
combinar con el acento blanco.

### Tipografía

Plus Jakarta Sans (`headline`/`body`). Mientras no se empaquete la fuente se usa
la tipografía por defecto de Material. Escala de referencia: `display-lg` 48,
`headline-lg` 32, `headline-md` 24, `title-md` 18, `body-md` 14, `label-md` 13,
`label-sm` 11.

### Espaciado, bordes y componentes

- Espaciado base: 4 / 8 / 12 / 16 / 20 / 24 / 32 px.
- Bordes: tarjetas e inputs con radio **16 px**; pills y avatares `999`.
- Componentes definidos en `AppTheme`: `appBarTheme`, `inputDecorationTheme`
  (relleno `surfaceContainerLowest`, borde `outlineVariant`, foco `ugYellow`),
  `filledButtonTheme` (fondo `ugYellow`, alto 52), `textButtonTheme` (`ugBlue`),
  `cardTheme` (elevación 0, borde `outlineVariant`).

### Preferencias persistidas (`shared_preferences`)

- `tema.modo`: `light` | `dark` | `system`.
- `ajustes.resumenes_ia`, `ajustes.sugerencias_ia`,
  `ajustes.alertas_institucionales`, `ajustes.actividad_publicaciones`,
  `ajustes.radar_perdidos`, `ajustes.ranking_semanal`,
  `ajustes.publicar_anonimo` (booleanos, por defecto `true`).
