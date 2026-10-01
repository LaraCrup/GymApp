<script setup lang="ts">
import type { ItemSettings } from '~/composables/useRoutines'

// Series, repeticiones (o tiempo) y peso: se usa al agregar un ejercicio y al editarlo.
// Repeticiones vacías = al fallo; segundos con número = por tiempo; peso vacío = peso corporal.
const settings = defineModel<ItemSettings>({ required: true })
// En la ficha el peso se cambia con sus propios botones; acá solo hace falta al agregar.
withDefaults(defineProps<{ withWeight?: boolean }>(), { withWeight: true })

// Al apagar "Al fallo" o "Peso corporal", o al cambiar entre reps y tiempo, vuelve el último número que había.
const lastReps = ref(settings.value.reps ?? 10)
const lastSeconds = ref(settings.value.seconds ?? 30)
const lastWeight = ref(settings.value.weight_kg ?? 0)

const modes = [
  { value: 'reps', label: 'Repeticiones' },
  { value: 'time', label: 'Tiempo' },
] as const

const mode = computed({
  get: () => (settings.value.seconds === null ? 'reps' : 'time'),
  set: m => {
    settings.value.seconds = m === 'time' ? lastSeconds.value : null
    settings.value.reps = m === 'time' ? null : lastReps.value
  },
})

const toFailure = computed({
  get: () => settings.value.reps === null,
  set: on => (settings.value.reps = on ? null : lastReps.value),
})
const bodyweight = computed({
  get: () => settings.value.weight_kg === null,
  set: on => (settings.value.weight_kg = on ? null : lastWeight.value),
})

const reps = computed({
  get: () => settings.value.reps ?? lastReps.value,
  set: n => (settings.value.reps = lastReps.value = n),
})
const seconds = computed({
  get: () => settings.value.seconds ?? lastSeconds.value,
  set: n => (settings.value.seconds = lastSeconds.value = n),
})
const weight = computed({
  get: () => settings.value.weight_kg ?? lastWeight.value,
  set: n => (settings.value.weight_kg = lastWeight.value = n),
})

// El peso sugerido (el de la última vez) puede llegar después de abrir el panel.
watch(() => settings.value.weight_kg, v => {
  if (v !== null) lastWeight.value = v
})
</script>

<template>
  <div class="flex flex-col gap-4">
    <NumberStepper v-model="settings.sets" label="Series" :min="1" :max="20" />

    <div class="flex flex-col gap-2">
      <!-- Cómo se mide cada serie: casi todos por repeticiones; algunos (plancha) por tiempo. -->
      <div role="radiogroup" aria-label="Cada serie se mide en" class="grid grid-cols-2 gap-1 rounded-xl border border-line bg-field p-1">
        <button
          v-for="m in modes"
          :key="m.value"
          type="button"
          role="radio"
          :aria-checked="mode === m.value"
          class="min-h-10 rounded-lg text-sm font-semibold transition-colors"
          :class="mode === m.value ? 'bg-brand' : 'text-muted active:bg-primary-soft'"
          @click="mode = m.value"
        >
          {{ m.label }}
        </button>
      </div>

      <template v-if="mode === 'reps'">
        <div class="-my-2 flex items-center justify-between gap-2">
          <span class="text-sm font-semibold">Repeticiones</span>
          <AppSwitch v-model="toFailure" label="Al fallo" />
        </div>
        <NumberStepper v-if="!toFailure" v-model="reps" label="Repeticiones" hide-label :min="1" :max="100" />
        <p v-else class="flex min-h-12 items-center justify-center rounded-xl border border-dashed border-primary/40 bg-primary-soft px-3 text-sm font-semibold text-primary-strong">
          Al fallo: hasta no poder hacer una más
        </p>
      </template>
      <NumberStepper v-else v-model="seconds" label="Segundos por serie" :min="5" :max="600" :step="5" unit="seg" />
    </div>

    <div v-if="withWeight" class="flex flex-col gap-1.5">
      <div class="-my-2 flex items-center justify-between gap-2">
        <span class="text-sm font-semibold">Peso</span>
        <AppSwitch v-model="bodyweight" label="Peso corporal" />
      </div>
      <NumberStepper v-if="!bodyweight" v-model="weight" label="Peso" hide-label :max="999" :step="2.5" unit="kg" />
      <p v-else class="flex min-h-12 items-center justify-center rounded-xl border border-dashed border-primary/40 bg-primary-soft px-3 text-sm font-semibold text-primary-strong">
        Sin peso extra: con tu propio cuerpo
      </p>
    </div>
  </div>
</template>
