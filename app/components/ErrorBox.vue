<script setup lang="ts">
defineProps<{ message?: string }>()
</script>

<template>
  <p
    v-if="message"
    role="alert"
    class="flex items-start gap-3 rounded-xl border-2 border-danger bg-danger-soft p-4 font-semibold text-danger"
  >
    <AppIcon name="alert" :size="28" />
    <span>{{ message }}</span>
  </p>
</template>
