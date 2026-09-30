<script setup lang="ts">
defineProps<{ message?: string }>()
</script>

<template>
  <p
    v-if="message"
    role="alert"
    class="flex items-start gap-2 rounded-xl border-2 border-danger bg-danger-soft p-3 text-sm font-semibold text-danger"
  >
    <AppIcon name="alert" :size="20" />
    <span>{{ message }}</span>
  </p>
</template>
