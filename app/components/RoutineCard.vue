<script setup lang="ts">
import type { RoutineSummary } from '~/composables/useRoutines'

// Una rutina en la lista de «Mis rutinas». `number`: su lugar dentro del grupo (1, 2, 3…).
const props = defineProps<{ routine: RoutineSummary; number: number; editing: boolean }>()
defineEmits<{ move: [] }>()

const exercises = computed(() => {
  const n = props.routine.exercise_count
  return n === 0 ? 'Sin ejercicios todavía' : n === 1 ? '1 ejercicio' : `${n} ejercicios`
})
</script>

<template>
  <!-- Modo edición: la rutina no se abre; el botón la manda a otro grupo. -->
  <div v-if="editing" class="card flex min-h-16 items-center gap-3 rounded-2xl p-3">
    <span
      class="glow flex size-12 shrink-0 items-center justify-center rounded-xl bg-brand text-base font-extrabold"
      aria-hidden="true"
    >
      {{ String(number).padStart(2, '0') }}
    </span>
    <span class="min-w-0 flex-1">
      <span class="block font-semibold">{{ routine.name }}</span>
      <span class="block text-sm text-muted">{{ exercises }}</span>
    </span>
    <button
      type="button"
      class="flex size-12 shrink-0 items-center justify-center rounded-xl border border-line bg-field text-primary active:bg-primary-soft"
      :aria-label="`Mover ${routine.name} a otro grupo`"
      @click="$emit('move')"
    >
      <AppIcon name="folder" :size="20" />
    </button>
  </div>

  <NuxtLink
    v-else
    :to="`/rutinas/${routine.id}`"
    class="card flex min-h-16 items-center gap-3 rounded-2xl p-3 pr-4 transition active:scale-[0.99] active:bg-primary-soft"
  >
    <span
      class="glow flex size-12 shrink-0 items-center justify-center rounded-xl bg-brand text-base font-extrabold"
      aria-hidden="true"
    >
      {{ String(number).padStart(2, '0') }}
    </span>
    <span class="min-w-0 flex-1">
      <span class="block font-semibold">{{ routine.name }}</span>
      <span class="block text-sm text-muted">{{ exercises }}</span>
    </span>
    <AppIcon name="chevron" :size="20" class="text-muted" />
  </NuxtLink>
</template>
