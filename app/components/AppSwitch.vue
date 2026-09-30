<script setup lang="ts">
// Interruptor de sí/no con su texto al lado. Toda la fila se puede tocar.
const model = defineModel<boolean>({ required: true })
defineProps<{ label: string; disabled?: boolean }>()
</script>

<template>
  <label class="flex min-h-11 cursor-pointer items-center gap-2 text-sm font-semibold" :class="{ 'pointer-events-none opacity-50': disabled }">
    <span :class="model ? 'text-primary-strong' : 'text-muted'">{{ label }}</span>
    <input v-model="model" type="checkbox" role="switch" class="peer sr-only" :disabled="disabled">
    <span
      class="relative h-6 w-10 shrink-0 rounded-full bg-white/15 transition-colors peer-checked:bg-brand peer-focus-visible:outline-3 peer-focus-visible:outline-primary after:absolute after:top-0.5 after:left-0.5 after:size-5 after:rounded-full after:bg-white after:shadow after:transition-transform peer-checked:after:translate-x-4"
      aria-hidden="true"
    />
  </label>
</template>
