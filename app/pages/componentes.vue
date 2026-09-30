<script setup lang="ts">
// Página temporal de desarrollo para revisar los componentes base en el celular. Se borra en la etapa 6.
const toast = useToast()
const { confirm } = useConfirm()

async function tryDelete() {
  const ok = await confirm({
    title: '¿Borrar «Día 1 - Piernas»?',
    message: 'Se quitan sus 6 ejercicios. Tu historial de pesos no se pierde.',
    confirmLabel: 'Sí, borrar rutina',
    danger: true,
  })
  if (ok) toast.ok('Rutina borrada')
  else toast.info('No se borró nada')
}
</script>

<template>
  <AppHeader title="Componentes" back="/" />
  <div class="flex flex-col gap-4 p-4">
    <p>Texto base de 18px. <span class="text-muted">Texto secundario.</span></p>
    <AppButton block>Botón principal</AppButton>
    <AppButton variant="secondary" block>Botón secundario</AppButton>
    <AppButton size="lg" block loading>Guardando…</AppButton>
    <AppButton variant="danger" block @click="tryDelete">Borrar (con confirmación)</AppButton>
    <AppButton variant="ghost" block @click="toast.ok('Guardado')">Mostrar «Guardado»</AppButton>
    <AppButton variant="ghost" block @click="toast.error('No se pudo guardar. Revisá la conexión e intentá de nuevo.')">
      Mostrar un error
    </AppButton>
  </div>
</template>
