<script setup lang="ts">
import type { IconName } from './AppIcon.vue'

const items: { to: string; label: string; icon: IconName }[] = [
  { to: '/', label: 'Mis rutinas', icon: 'list' },
  { to: '/ejercicios', label: 'Ejercicios', icon: 'search' },
  { to: '/cuenta', label: 'Mi cuenta', icon: 'user' },
]

const route = useRoute()

// "Mis rutinas" queda marcada también dentro de /rutinas/...
function isActive(to: string) {
  if (to === '/') return route.path === '/' || route.path.startsWith('/rutinas')
  return route.path.startsWith(to)
}
</script>

<template>
  <nav
    aria-label="Secciones"
    class="fixed inset-x-0 bottom-0 z-20 border-t border-line bg-white pb-[env(safe-area-inset-bottom)]"
  >
    <ul class="mx-auto grid max-w-xl grid-cols-3">
      <li v-for="item in items" :key="item.to">
        <NuxtLink
          :to="item.to"
          :aria-current="isActive(item.to) ? 'page' : undefined"
          class="flex min-h-16 flex-col items-center justify-center gap-0.5 border-t-4 text-base"
          :class="isActive(item.to) ? 'border-primary font-bold text-primary' : 'border-transparent text-muted'"
        >
          <AppIcon :name="item.icon" :size="28" />
          {{ item.label }}
        </NuxtLink>
      </li>
    </ul>
  </nav>
</template>
