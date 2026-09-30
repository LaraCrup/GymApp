<script setup lang="ts">
import type { IconName } from './AppIcon.vue'

defineProps<{ title: string; text?: string; icon?: IconName }>()
</script>

<template>
  <section class="flex flex-col items-center gap-3 px-4 py-10 text-center">
    <span class="flex size-14 items-center justify-center rounded-full bg-primary-soft text-primary">
      <AppIcon :name="icon ?? 'dumbbell'" :size="28" />
    </span>
    <h2 class="text-lg font-bold">{{ title }}</h2>
    <p v-if="text" class="max-w-sm text-sm text-muted">{{ text }}</p>
    <div class="mt-2 w-full max-w-sm">
      <slot />
    </div>
  </section>
</template>
