<script setup lang="ts">
// Aviso en el inicio para instalar la app. Se muestra hasta que se instala o se toca "Ahora no".
const { installed } = useInstallApp()
const dismissed = useLocalPref('instalar-aviso-descartado', false)
const open = ref(false)
</script>

<template>
  <section
    v-if="!installed && !dismissed"
    class="mx-4 mt-4 flex flex-col gap-3 rounded-2xl border-2 border-primary bg-primary-soft p-4"
  >
    <p class="text-sm">
      <strong class="text-primary-strong">Tené la app en tu celular.</strong>
      Abrila desde la pantalla de inicio, sin buscarla en el navegador.
    </p>
    <div class="flex gap-2">
      <AppButton class="flex-1" @click="open = true">Ver cómo</AppButton>
      <AppButton variant="ghost" class="flex-1" @click="dismissed = true">Ahora no</AppButton>
    </div>
  </section>

  <AppSheet v-model:open="open" title="Tener la app en el celular">
    <InstallInstructions />
    <AppButton variant="secondary" block @click="open = false">Entendido</AppButton>
  </AppSheet>
</template>
