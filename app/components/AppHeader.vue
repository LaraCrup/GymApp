<script setup lang="ts">
import type { RouteLocationRaw } from 'vue-router'

defineProps<{ title: string; back?: RouteLocationRaw }>()
</script>

<template>
  <header class="sticky top-0 z-10 flex min-h-14 items-center gap-2 border-b border-line bg-white px-2 pt-[env(safe-area-inset-top)]">
    <NuxtLink
      v-if="back"
      :to="back"
      class="flex min-h-12 items-center gap-1 rounded-xl pr-3 pl-1 text-base font-semibold text-primary active:bg-primary-soft"
    >
      <AppIcon name="back" :size="22" />
      Volver
    </NuxtLink>
    <h1 class="min-w-0 flex-1 truncate px-2 text-lg font-bold" :class="{ 'text-right': back }">
      {{ title }}
    </h1>
    <slot name="action" />
  </header>
</template>
