<script setup lang="ts">
import type { RoutineItem } from '~/composables/useRoutines'

// Resumen del ejercicio en la rutina. Tocarlo abre su ficha, donde se cambian el peso, las series y las reps.
// `number`: su lugar en la rutina (1, 2, 3…), el orden en que se hacen.
defineProps<{ item: RoutineItem; number: number; editing: boolean; first: boolean; last: boolean }>()
defineEmits<{ up: []; down: []; remove: [] }>()

const { nameOf } = useMuscleGroups()
</script>

<template>
  <!-- Modo edición: flechas para ordenar (más fácil con una mano que arrastrar) y quitar. -->
  <article v-if="editing" class="card flex flex-col gap-3 rounded-2xl p-3">
    <div class="flex items-center gap-3">
      <span class="relative shrink-0">
        <ExerciseThumb :youtube-id="item.exercise.youtube_id" />
        <span class="absolute -top-1.5 -left-1.5 flex size-6 items-center justify-center rounded-full bg-brand text-xs font-bold ring-2 ring-elevated" aria-hidden="true">{{ number }}</span>
      </span>
      <span class="min-w-0 flex-1 leading-snug font-semibold">{{ item.exercise.name }}</span>
      <div class="flex shrink-0 gap-1">
        <button
          type="button"
          class="flex size-12 items-center justify-center rounded-xl border border-line bg-field text-primary active:bg-primary-soft disabled:opacity-30"
          :aria-label="`Subir ${item.exercise.name}`"
          :disabled="first"
          @click="$emit('up')"
        >
          <AppIcon name="up" :size="20" />
        </button>
        <button
          type="button"
          class="flex size-12 items-center justify-center rounded-xl border border-line bg-field text-primary active:bg-primary-soft disabled:opacity-30"
          :aria-label="`Bajar ${item.exercise.name}`"
          :disabled="last"
          @click="$emit('down')"
        >
          <AppIcon name="down" :size="20" />
        </button>
      </div>
    </div>
    <AppButton variant="danger-ghost" block @click="$emit('remove')">
      <AppIcon name="trash" :size="20" />
      Quitar de la rutina
    </AppButton>
  </article>

  <NuxtLink
    v-else
    :to="{ path: `/ejercicios/${item.exercise.id}`, query: { rutina: item.routine_id } }"
    class="card flex flex-col gap-3 rounded-2xl p-3 transition active:scale-[0.99] active:bg-primary-soft"
  >
    <div class="flex items-center gap-3">
      <span class="relative shrink-0">
        <ExerciseThumb :youtube-id="item.exercise.youtube_id" />
        <span class="absolute -top-1.5 -left-1.5 flex size-6 items-center justify-center rounded-full bg-brand text-xs font-bold ring-2 ring-elevated" aria-hidden="true">{{ number }}</span>
      </span>
      <span class="flex min-w-0 flex-1 flex-col items-start gap-1">
        <span class="leading-snug font-semibold">{{ item.exercise.name }}</span>
        <span class="rounded-md bg-primary-soft px-1.5 py-0.5 text-xs font-semibold text-primary-strong">
          {{ nameOf(item.exercise.muscle_group_id) }}
        </span>
      </span>
      <AppIcon name="chevron" :size="20" class="text-muted" />
    </div>
    <dl class="grid grid-cols-3 gap-2 text-center">
      <div class="rounded-xl border border-line bg-field py-2">
        <dt class="text-xs text-muted">Series</dt>
        <dd class="text-base font-bold">{{ item.sets }}</dd>
      </div>
      <div class="rounded-xl border border-line bg-field py-2">
        <dt class="text-xs text-muted">Reps</dt>
        <dd class="text-base font-bold">{{ item.reps ?? 'Al fallo' }}</dd>
      </div>
      <div class="rounded-xl border border-line bg-field py-2">
        <dt class="text-xs text-muted">Peso</dt>
        <dd class="text-base font-bold">{{ item.weight_kg === null ? 'Sin peso' : formatKg(item.weight_kg) }}</dd>
      </div>
    </dl>
  </NuxtLink>
</template>
