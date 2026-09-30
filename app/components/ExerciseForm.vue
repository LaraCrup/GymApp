<script setup lang="ts">
import type { DraftErrors, ExerciseDraft } from '~/utils/exerciseDraft'
import type { ExerciseInput } from '~/composables/useCatalog'

const draft = defineModel<ExerciseDraft>({ required: true })
defineProps<{ submitLabel: string; loading?: boolean; error?: string }>()
const emit = defineEmits<{ submit: [input: ExerciseInput] }>()

const { groups, load } = useMuscleGroups()
onMounted(load)

// Los errores aparecen recién al intentar guardar; desde ahí se validan en vivo,
// así cada mensaje desaparece apenas se corrige el campo.
const attempted = ref(false)
const errors = computed<DraftErrors>(() => (attempted.value ? validateDraft(draft.value) : {}))
const previewId = computed(() => parseYouTubeId(draft.value.youtubeUrl))

function submit() {
  attempted.value = true
  if (Object.keys(errors.value).length) return
  emit('submit', draftToInput(draft.value))
}
</script>

<template>
  <form class="flex flex-col gap-5" novalidate @submit.prevent="submit">
    <AppInput
      v-model="draft.name"
      label="Nombre"
      autocomplete="off"
      placeholder="Ej: Remo con barra"
      :error="errors.name"
    />
    <slot name="after-name" />
    <AppInput
      v-model="draft.aliasesText"
      label="Otros nombres (opcional)"
      autocomplete="off"
      hint="Cómo más le dicen en el gimnasio. Separalos con comas."
      placeholder="Ej: Remo inclinado, Bent over row"
    />

    <fieldset class="flex flex-col gap-2">
      <legend class="mb-1.5 text-sm font-semibold">¿Qué músculo trabaja?</legend>
      <div class="grid grid-cols-2 gap-2">
        <label
          v-for="g in groups"
          :key="g.id"
          class="flex min-h-12 cursor-pointer items-center justify-center rounded-xl border px-3 transition text-center text-sm font-semibold has-focus-visible:outline-3 has-focus-visible:outline-primary"
          :class="draft.muscleGroupId === g.id ? 'glow border-transparent bg-brand' : 'border-line bg-field active:bg-primary-soft'"
        >
          <input v-model="draft.muscleGroupId" type="radio" name="muscle-group" :value="g.id" class="sr-only">
          {{ g.name }}
        </label>
      </div>
      <p v-if="errors.muscleGroupId" class="text-sm font-semibold text-danger">{{ errors.muscleGroupId }}</p>
    </fieldset>

    <div class="flex flex-col gap-3">
      <AppInput
        v-model="draft.youtubeUrl"
        label="Video de YouTube (opcional)"
        type="url"
        inputmode="url"
        autocomplete="off"
        hint="Pegá el link del video. Sirve para confirmar que es el ejercicio correcto."
        placeholder="https://youtu.be/…"
        :error="errors.youtubeUrl"
      />
      <YouTubeVideo v-if="previewId" :youtube-id="previewId" :title="draft.name || 'ejercicio'" />
    </div>

    <slot name="before-submit" />

    <ErrorBox :message="error" />
    <AppButton type="submit" size="lg" block :loading="loading">{{ submitLabel }}</AppButton>
  </form>
</template>
