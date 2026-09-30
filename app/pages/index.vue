<script setup lang="ts">
useHead({ title: 'Mis rutinas' })
</script>

<template>
  <AppHeader title="Mis rutinas" />
  <!-- Etapa 3: listado de rutinas. Por ahora, el estado vacío. -->
  <EmptyState
    title="Todavía no tenés rutinas"
    text="Una rutina es la lista de ejercicios que hacés un día en el gimnasio. Por ejemplo: «Día 1 - Piernas»."
  >
    <AppButton size="lg" block disabled>
      <AppIcon name="plus" :size="28" />
      Crear mi primera rutina
    </AppButton>
  </EmptyState>
</template>
