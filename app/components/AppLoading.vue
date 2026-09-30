<script setup lang="ts">
defineProps<{ text?: string }>()
</script>

<template>
  <div class="flex items-center justify-center gap-3 py-10 text-muted" role="status">
    <AppSpinner />
    <span class="text-sm">{{ text ?? 'Cargando…' }}</span>
  </div>
</template>
