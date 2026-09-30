<script setup lang="ts">
import type { IconName } from './AppIcon.vue'

defineProps<{ title: string; text?: string; icon?: IconName }>()
</script>

<template>
  <section class="flex flex-col items-center gap-4 px-4 py-12 text-center">
    <span class="flex size-20 items-center justify-center rounded-full bg-primary-soft text-primary">
      <AppIcon :name="icon ?? 'dumbbell'" :size="40" />
    </span>
    <h2 class="text-2xl font-bold">{{ title }}</h2>
    <p v-if="text" class="max-w-sm text-muted">{{ text }}</p>
    <div class="mt-2 w-full max-w-sm">
      <slot />
    </div>
  </section>
</template>
