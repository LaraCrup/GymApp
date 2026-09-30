<script setup lang="ts">
import type { RoutineItem } from '~/composables/useRoutines'

defineProps<{ item: RoutineItem; editing: boolean; first: boolean; last: boolean }>()
defineEmits<{ settings: []; up: []; down: []; remove: [] }>()
</script>

<template>
  <article class="flex flex-col gap-3 rounded-2xl bg-white p-3">
    <div class="flex items-center gap-3">
      <NuxtLink :to="`/ejercicios/${item.exercise.id}`" class="flex min-w-0 flex-1 items-center gap-3">
        <ExerciseThumb :youtube-id="item.exercise.youtube_id" />
        <span class="min-w-0 flex-1 font-semibold">{{ item.exercise.name }}</span>
      </NuxtLink>

      <!-- Modo edición: flechas en vez de arrastrar (más fácil con una mano) -->
      <div v-if="editing" class="flex shrink-0 gap-1">
        <button
          type="button"
          class="flex size-12 items-center justify-center rounded-xl border-2 border-line text-primary disabled:opacity-30"
          :aria-label="`Subir ${item.exercise.name}`"
          :disabled="first"
          @click="$emit('up')"
        >
          <AppIcon name="up" :size="20" />
        </button>
        <button
          type="button"
          class="flex size-12 items-center justify-center rounded-xl border-2 border-line text-primary disabled:opacity-30"
          :aria-label="`Bajar ${item.exercise.name}`"
          :disabled="last"
          @click="$emit('down')"
        >
          <AppIcon name="down" :size="20" />
        </button>
      </div>
    </div>

    <AppButton v-if="editing" variant="danger-ghost" block @click="$emit('remove')">
      <AppIcon name="trash" :size="20" />
      Quitar de la rutina
    </AppButton>
    <button
      v-else
      type="button"
      class="flex min-h-12 items-center justify-between gap-2 rounded-xl bg-surface px-3 text-left active:bg-primary-soft"
      @click="$emit('settings')"
    >
      <span class="text-sm">
        <strong>{{ item.sets }}</strong> series × <strong>{{ item.reps }}</strong> reps
        <span class="text-muted"> · </span>
        <strong>{{ formatKg(item.weight_kg) }}</strong>
      </span>
      <span class="text-sm font-semibold text-primary">Cambiar</span>
    </button>
  </article>
</template>
