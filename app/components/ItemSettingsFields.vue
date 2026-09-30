<script setup lang="ts">
import type { ItemSettings } from '~/composables/useRoutines'

// Series, repeticiones y peso: se usa al agregar un ejercicio y al editarlo.
const settings = defineModel<ItemSettings>({ required: true })
// En la tarjeta el peso se cambia con sus propios botones; acá solo hace falta al agregar.
withDefaults(defineProps<{ withWeight?: boolean }>(), { withWeight: true })
</script>

<template>
  <div class="grid grid-cols-2 gap-3">
    <NumberStepper v-model="settings.sets" label="Series" :min="1" :max="20" />
    <NumberStepper v-model="settings.reps" label="Repeticiones" :min="1" :max="100" />
    <div v-if="withWeight" class="col-span-2">
      <NumberStepper v-model="settings.weight_kg" label="Peso" :max="999" :step="2.5" unit="kg" />
    </div>
  </div>
</template>
