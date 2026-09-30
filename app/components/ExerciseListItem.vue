<script setup lang="ts">
import type { Exercise } from '~/composables/useCatalog'

defineProps<{ exercise: Pick<Exercise, 'name' | 'aliases' | 'muscle_group_id' | 'youtube_id'>; added?: boolean }>()
defineEmits<{ select: [] }>()

const { nameOf } = useMuscleGroups()
</script>

<template>
  <button
    type="button"
    class="flex w-full items-center gap-3 rounded-xl bg-white p-3 text-left active:bg-primary-soft"
    @click="$emit('select')"
  >
    <ExerciseThumb :youtube-id="exercise.youtube_id" />
    <span class="min-w-0 flex-1">
      <span class="block font-semibold">{{ exercise.name }}</span>
      <span v-if="exercise.aliases.length" class="block truncate text-sm text-muted">
        También: {{ exercise.aliases.join(', ') }}
      </span>
      <span class="block text-xs text-muted">{{ nameOf(exercise.muscle_group_id) }}</span>
    </span>
    <span v-if="added" class="flex shrink-0 items-center gap-1 rounded-lg bg-ok-soft px-2 py-1 text-xs font-semibold text-ok">
      <AppIcon name="check" :size="14" />
      En la rutina
    </span>
    <AppIcon v-else name="chevron" :size="20" class="text-muted" />
  </button>
</template>
