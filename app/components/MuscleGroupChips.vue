<script setup lang="ts">
// Filtro por grupo muscular: una fila que se desliza con el dedo. null = todos.
const model = defineModel<string | null>({ required: true })
const { groups } = useMuscleGroups()
</script>

<template>
  <div class="-mx-4 flex gap-2 overflow-x-auto px-4 pb-1 [scrollbar-width:none]" role="group" aria-label="Filtrar por grupo muscular">
    <button
      v-for="option in [{ id: null, name: 'Todos' }, ...groups]"
      :key="option.id ?? 'todos'"
      type="button"
      :aria-pressed="model === option.id"
      class="min-h-12 shrink-0 rounded-full border-2 px-4 text-sm font-semibold"
      :class="model === option.id ? 'border-primary bg-primary text-white' : 'border-line bg-white text-ink'"
      @click="model = option.id"
    >
      {{ option.name }}
    </button>
  </div>
</template>
