<script setup lang="ts">
useHead({ title: 'Descargar app' })

// Cómo tener la app en la pantalla de inicio: pasos para iPhone y para Samsung (Android).
const { installed, canPrompt, platform, install } = useInstallApp()
const toast = useToast()

// "Volver" regresa a la pantalla desde la que se abrió; solo rutas internas de la app.
const route = useRoute()
const from = route.query.volver
const backTo = typeof from === 'string' && from.startsWith('/') && !from.startsWith('//') ? from : '/'

async function onInstall() {
  if (await install()) toast.ok('¡Listo! Buscá «Mis Rutinas» en la pantalla de inicio')
}
</script>

<template>
  <AppHeader title="Descargar app" :back="backTo" />
  <div class="flex flex-col gap-4 p-4">
    <p v-if="installed" class="flex items-center gap-2 rounded-xl border border-ok/40 bg-ok-soft p-3 text-sm font-semibold text-ok">
      <AppIcon name="check" :size="20" />
      Ya estás usando la app instalada.
    </p>

    <template v-else>
      <p class="text-sm text-muted">
        Tené «Mis Rutinas» en la pantalla de inicio y abrila como cualquier otra app, sin buscarla en el navegador.
      </p>

      <!-- Chrome en Android ofrece instalarla con un toque. -->
      <section v-if="canPrompt" class="flex flex-col gap-3 rounded-2xl border border-primary/30 bg-brand-soft p-4">
        <p class="text-sm">Tu celular permite instalarla directo:</p>
        <AppButton size="lg" block @click="onInstall">
          <AppIcon name="download" :size="20" />
          Instalar app
        </AppButton>
      </section>
    </template>

    <!-- En el celular de quien mira, su sección va primero. -->
    <div class="flex gap-4" :class="platform === 'android' ? 'flex-col-reverse' : 'flex-col'">
      <section class="card flex flex-col gap-4 rounded-2xl p-4">
        <header class="flex items-center justify-between gap-2">
          <h2 class="text-base font-bold">En iPhone</h2>
          <span v-if="platform === 'ios'" class="rounded-md bg-primary-soft px-2 py-0.5 text-xs font-semibold text-primary-strong">Tu celular</span>
        </header>
        <ol class="flex flex-col gap-3 text-sm">
          <li class="flex gap-3">
            <span class="flex size-7 shrink-0 items-center justify-center rounded-full bg-brand text-xs font-bold">1</span>
            <span>Abrí la app en <strong>Safari</strong> (en otro navegador no aparece la opción).</span>
          </li>
          <li class="flex gap-3">
            <span class="flex size-7 shrink-0 items-center justify-center rounded-full bg-brand text-xs font-bold">2</span>
            <span>Tocá el botón <strong>Compartir</strong>: el cuadrado con una flecha hacia arriba, abajo en el medio.</span>
          </li>
          <li class="flex gap-3">
            <span class="flex size-7 shrink-0 items-center justify-center rounded-full bg-brand text-xs font-bold">3</span>
            <span>Bajá y tocá <strong>«Agregar a inicio»</strong>.</span>
          </li>
          <li class="flex gap-3">
            <span class="flex size-7 shrink-0 items-center justify-center rounded-full bg-brand text-xs font-bold">4</span>
            <span>Tocá <strong>«Agregar»</strong> arriba a la derecha.</span>
          </li>
        </ol>
      </section>

      <section class="card flex flex-col gap-4 rounded-2xl p-4">
        <header class="flex items-center justify-between gap-2">
          <h2 class="text-base font-bold">En Samsung</h2>
          <span v-if="platform === 'android'" class="rounded-md bg-primary-soft px-2 py-0.5 text-xs font-semibold text-primary-strong">Tu celular</span>
        </header>

        <div class="flex flex-col gap-3">
          <h3 class="text-sm font-semibold text-muted">Con Samsung Internet</h3>
          <ol class="flex flex-col gap-3 text-sm">
            <li class="flex gap-3">
              <span class="flex size-7 shrink-0 items-center justify-center rounded-full bg-brand text-xs font-bold">1</span>
              <span>Tocá el menú: las <strong>tres rayitas</strong> abajo a la derecha.</span>
            </li>
            <li class="flex gap-3">
              <span class="flex size-7 shrink-0 items-center justify-center rounded-full bg-brand text-xs font-bold">2</span>
              <span>Tocá <strong>«Agregar página a»</strong> y después <strong>«Pantalla de inicio»</strong>.</span>
            </li>
            <li class="flex gap-3">
              <span class="flex size-7 shrink-0 items-center justify-center rounded-full bg-brand text-xs font-bold">3</span>
              <span>Confirmá con <strong>«Agregar»</strong>.</span>
            </li>
          </ol>
        </div>

        <div class="flex flex-col gap-3 border-t border-line pt-4">
          <h3 class="text-sm font-semibold text-muted">Con Chrome</h3>
          <ol class="flex flex-col gap-3 text-sm">
            <li class="flex gap-3">
              <span class="flex size-7 shrink-0 items-center justify-center rounded-full bg-brand text-xs font-bold">1</span>
              <span>Tocá el menú: los <strong>tres puntitos</strong> arriba a la derecha.</span>
            </li>
            <li class="flex gap-3">
              <span class="flex size-7 shrink-0 items-center justify-center rounded-full bg-brand text-xs font-bold">2</span>
              <span>Tocá <strong>«Instalar app»</strong> o <strong>«Agregar a pantalla de inicio»</strong>.</span>
            </li>
            <li class="flex gap-3">
              <span class="flex size-7 shrink-0 items-center justify-center rounded-full bg-brand text-xs font-bold">3</span>
              <span>Confirmá con <strong>«Instalar»</strong>.</span>
            </li>
          </ol>
        </div>
      </section>
    </div>

    <p class="text-center text-sm text-muted">Después abrila desde el ícono violeta y azul «Mis Rutinas».</p>
  </div>
</template>
