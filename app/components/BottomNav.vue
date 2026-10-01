<script setup lang="ts">
import type { IconName } from './AppIcon.vue'

const items: { to: string; label: string; icon: IconName }[] = [
  { to: '/', label: 'Mis rutinas', icon: 'list' },
  { to: '/ejercicios', label: 'Ejercicios', icon: 'search' },
  { to: '/cuenta', label: 'Mi cuenta', icon: 'user' },
]

const route = useRoute()

// "Mis rutinas" queda marcada también dentro de /rutinas/... y en un ejercicio abierto desde una rutina.
const fromRoutine = computed(() => typeof route.query.rutina === 'string' && route.path.startsWith('/ejercicios/'))
function isActive(to: string) {
  if (to === '/') return route.path === '/' || route.path.startsWith('/rutinas') || fromRoutine.value
  return route.path.startsWith(to) && !(to === '/ejercicios' && fromRoutine.value)
}

// La línea de arriba se desliza hasta la sección activa. -1 = ninguna (por ejemplo, en /descargar).
const activeIndex = computed(() => items.findIndex(item => isActive(item.to)))
</script>

<template>
  <nav
    aria-label="Secciones"
    class="relative z-20 shrink-0 border-t border-line bg-surface/80 pb-[env(safe-area-inset-bottom)] backdrop-blur-xl"
  >
    <ul class="relative mx-auto grid max-w-xl grid-cols-3">
      <li
        class="pointer-events-none absolute top-0 left-0 flex w-1/3 justify-center transition-[translate,opacity] duration-300 ease-out"
        :class="{ 'opacity-0': activeIndex < 0 }"
        :style="{ translate: `${Math.max(activeIndex, 0) * 100}% 0` }"
        aria-hidden="true"
      >
        <span class="h-1 w-24 rounded-b-full bg-brand" />
      </li>
      <li v-for="item in items" :key="item.to">
        <NuxtLink
          :to="item.to"
          :aria-current="isActive(item.to) ? 'page' : undefined"
          class="relative flex min-h-16 flex-col items-center justify-center gap-0.5 pt-2.5 pb-1.5 text-xs transition-colors"
          :class="isActive(item.to) ? 'font-bold text-primary' : 'text-muted'"
        >
          <span class="flex h-7 items-center justify-center transition-transform duration-300" :class="{ 'scale-110': isActive(item.to) }">
            <AppIcon :name="item.icon" :size="22" />
          </span>
          {{ item.label }}
        </NuxtLink>
      </li>
    </ul>
  </nav>
</template>
