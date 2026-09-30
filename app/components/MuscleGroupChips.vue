<script setup lang="ts">
// Filtro por grupo muscular: una fila que se desliza con el dedo. null = todos.
// Tocar el grupo elegido otra vez lo destilda y vuelve a mostrar todos.
const model = defineModel<string | null>({ required: true })
const { groups } = useMuscleGroups()
</script>

<template>
  <div class="-mx-4 flex gap-2 overflow-x-auto px-4 pb-1 [scrollbar-width:none]" role="group" aria-label="Filtrar por grupo muscular">
    <button
      v-for="option in groups"
      :key="option.id"
      type="button"
      :aria-pressed="model === option.id"
      class="flex min-h-11 shrink-0 items-center gap-1.5 rounded-full border px-4 text-sm font-semibold transition"
      :class="model === option.id ? 'border-transparent bg-brand' : 'border-line bg-field text-muted active:text-ink'"
      @click="model = model === option.id ? null : option.id"
    >
      {{ option.name }}
      <AppIcon v-if="model === option.id" name="close" :size="16" />
    </button>
  </div>
</template>
