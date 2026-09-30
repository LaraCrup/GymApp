<script setup lang="ts">
useHead({ title: 'Ejercicios' })
</script>

<template>
  <AppHeader title="Ejercicios" />
  <div class="p-4">
    <ExerciseSearch
      state-key="catalogo"
      :create-to="q => ({ path: '/ejercicios/nuevo', query: q ? { nombre: q } : {} })"
      @select="e => navigateTo(`/ejercicios/${e.id}`)"
    />
  </div>
</template>
