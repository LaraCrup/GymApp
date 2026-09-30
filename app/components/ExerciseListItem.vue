<script setup lang="ts">
import type { Exercise } from '~/composables/useCatalog'

defineProps<{ exercise: Pick<Exercise, 'name' | 'aliases' | 'muscle_group_id' | 'youtube_id'> }>()
defineEmits<{ select: [] }>()

const { nameOf } = useMuscleGroups()
</script>

<template>
  <button
    type="button"
    class="flex w-full items-center gap-3 card rounded-2xl p-2.5 text-left transition active:scale-[0.99] active:bg-primary-soft"
    @click="$emit('select')"
  >
    <ExerciseThumb :youtube-id="exercise.youtube_id" />
    <span class="min-w-0 flex-1">
      <span class="block font-semibold">{{ exercise.name }}</span>
      <span v-if="exercise.aliases.length" class="block truncate text-sm text-muted">
        También: {{ exercise.aliases.join(', ') }}
      </span>
      <span class="mt-1 inline-block rounded-md bg-primary-soft px-1.5 py-0.5 text-xs font-semibold text-primary-strong">{{ nameOf(exercise.muscle_group_id) }}</span>
    </span>
    <AppIcon name="chevron" :size="20" class="text-muted" />
  </button>
</template>
