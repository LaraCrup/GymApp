<script setup lang="ts">
import type { ItemSettings } from '~/composables/useRoutines'

// Series, repeticiones y peso: se usa al agregar un ejercicio y al editarlo.
const settings = defineModel<ItemSettings>({ required: true })
</script>

<template>
  <div class="grid grid-cols-2 gap-3">
    <NumberStepper v-model="settings.sets" label="Series" :min="1" :max="20" />
    <NumberStepper v-model="settings.reps" label="Repeticiones" :min="1" :max="100" />
    <div class="col-span-2">
      <NumberStepper v-model="settings.weight_kg" label="Peso" :max="999" :step="2.5" unit="kg" />
    </div>
  </div>
</template>
