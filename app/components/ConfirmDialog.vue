<script setup lang="ts">
const { pending, answer } = useConfirm()
const dialog = ref<HTMLDialogElement>()

// Después de dibujar los botones, para que el foco caiga en "No, volver" (autofocus):
// un Enter o un toque apurado nunca confirma un borrado.
watch(pending, value => {
  if (value) dialog.value?.showModal()
  else dialog.value?.close()
}, { flush: 'post' })
</script>

<template>
  <!-- `cancel` cubre la tecla Escape y el gesto de "atrás" del sistema. -->
  <dialog
    ref="dialog"
    aria-labelledby="confirm-title"
    class="m-auto w-[calc(100%-2rem)] max-w-md rounded-2xl bg-white p-5 text-ink shadow-xl"
    @cancel.prevent="answer(false)"
  >
    <template v-if="pending">
      <h2 id="confirm-title" class="text-lg font-bold">{{ pending.title }}</h2>
      <p v-if="pending.message" class="mt-2 text-sm text-muted">{{ pending.message }}</p>
      <!-- "Cancelar" abajo, donde cae el pulgar: un toque sin querer nunca borra nada. -->
      <div class="mt-6 flex flex-col gap-3">
        <AppButton :variant="pending.danger ? 'danger' : 'primary'" block @click="answer(true)">
          {{ pending.confirmLabel ?? 'Sí, confirmar' }}
        </AppButton>
        <AppButton variant="secondary" block autofocus @click="answer(false)">
          {{ pending.cancelLabel ?? 'No, volver' }}
        </AppButton>
      </div>
    </template>
  </dialog>
</template>
