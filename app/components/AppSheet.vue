<script setup lang="ts">
// Panel que sube desde abajo (cerca del pulgar). Usa <dialog> nativo: foco, Escape y "atrás" gratis.
// Se abre después de dibujar el contenido, así un campo con `autofocus` recibe el foco (y el teclado).
const open = defineModel<boolean>('open', { required: true })
defineProps<{ title: string }>()

const dialog = ref<HTMLDialogElement>()

watch(open, value => {
  if (value && !dialog.value?.open) dialog.value?.showModal()
  if (!value && dialog.value?.open) dialog.value.close()
}, { flush: 'post' })
onMounted(() => {
  if (open.value) dialog.value?.showModal()
})
</script>

<template>
  <dialog
    ref="dialog"
    :aria-label="title"
    class="panel mx-auto mt-auto mb-0 max-h-[90dvh] w-full max-w-xl overflow-y-auto rounded-t-3xl border-t border-line bg-elevated p-0 text-ink shadow-[0_-12px_48px_rgb(124_58_237/0.25)]"
    @close="open = false"
    @click.self="open = false"
  >
    <div v-if="open" class="flex flex-col gap-4 p-4 pt-2 pb-[calc(1rem+env(safe-area-inset-bottom))]">
      <span class="mx-auto h-1.5 w-10 rounded-full bg-white/15" aria-hidden="true" />
      <header class="flex items-center justify-between gap-2">
        <h2 class="text-lg font-bold">{{ title }}</h2>
        <button
          type="button"
          class="flex size-12 items-center justify-center rounded-full text-muted active:bg-field"
          aria-label="Cerrar"
          @click="open = false"
        >
          <AppIcon name="close" />
        </button>
      </header>
      <slot />
    </div>
  </dialog>
</template>
