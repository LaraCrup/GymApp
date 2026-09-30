<script setup lang="ts">
useHead({ title: 'Ejercicios' })

// Lo que se está buscando llega como nombre al crear uno nuevo.
const q = useState('catalogo-q', () => '')
const createTo = (text: string) => ({ path: '/ejercicios/nuevo', query: text ? { nombre: text } : {} })
</script>

<template>
  <AppHeader title="Ejercicios">
    <template #action>
      <NuxtLink
        :to="createTo(q)"
        class="flex min-h-10 shrink-0 items-center gap-1.5 rounded-full border border-primary/30 bg-brand-soft px-3 text-sm font-semibold text-primary-strong active:bg-primary-soft"
      >
        <AppIcon name="plus" :size="18" />
        Agregar ejercicio
      </NuxtLink>
    </template>
  </AppHeader>
  <div class="p-4">
    <ExerciseSearch
      state-key="catalogo"
      :create-to="createTo"
      @select="e => navigateTo(`/ejercicios/${e.id}`)"
    />
  </div>
</template>
