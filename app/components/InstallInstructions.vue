<script setup lang="ts">
// Cómo tener la app en la pantalla de inicio, según el celular.
const { installed, canPrompt, platform, install } = useInstallApp()
const toast = useToast()

async function onInstall() {
  if (await install()) toast.ok('¡Listo! Buscá «Mis Rutinas» en la pantalla de inicio')
}
</script>

<template>
  <div class="flex flex-col gap-3 text-sm">
    <p v-if="installed" class="flex items-center gap-2 font-semibold text-ok">
      <AppIcon name="check" :size="20" />
      Ya estás usando la app instalada.
    </p>

    <template v-else-if="canPrompt">
      <p>Instalala y abrila desde la pantalla de inicio, como cualquier otra app.</p>
      <AppButton block @click="onInstall">Instalar app</AppButton>
    </template>

    <template v-else-if="platform === 'ios'">
      <p>En el iPhone se agrega desde <strong>Safari</strong>:</p>
      <ol class="flex list-decimal flex-col gap-2 pl-5">
        <li>Tocá el botón <strong>Compartir</strong> (el cuadrado con una flecha hacia arriba, abajo en el medio).</li>
        <li>Bajá y tocá <strong>«Agregar a inicio»</strong>.</li>
        <li>Tocá <strong>«Agregar»</strong> arriba a la derecha.</li>
      </ol>
      <p class="text-muted">Después abrila desde el ícono azul «Mis Rutinas».</p>
    </template>

    <template v-else>
      <ol class="flex list-decimal flex-col gap-2 pl-5">
        <li>Tocá el menú del navegador (los <strong>tres puntitos</strong> arriba a la derecha).</li>
        <li>Tocá <strong>«Instalar app»</strong> o <strong>«Agregar a pantalla de inicio»</strong>.</li>
      </ol>
      <p class="text-muted">Después abrila desde el ícono azul «Mis Rutinas».</p>
    </template>
  </div>
</template>
