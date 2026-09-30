<script setup lang="ts">
// Pastilla "Descargar app" para la barra de arriba. Con la app ya instalada no se muestra.
const { installed } = useInstallApp()
// Lleva la pantalla actual: "Volver" en /descargar regresa acá.
const route = useRoute()
</script>

<template>
  <NuxtLink
    v-if="!installed"
    :to="{ path: '/descargar', query: { volver: route.path } }"
    class="flex min-h-10 shrink-0 items-center gap-1.5 rounded-full border border-primary/30 bg-brand-soft px-3 text-sm font-semibold text-primary-strong active:bg-primary-soft"
  >
    <AppIcon name="download" :size="18" />
    Descargar app
  </NuxtLink>
</template>
