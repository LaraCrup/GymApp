<script setup lang="ts">
// Número con botones grandes de − y +, y también editable a mano (acepta coma).
const model = defineModel<number>({ required: true })
const props = withDefaults(
  // hideLabel: la etiqueta queda solo para lectores de pantalla (cuando ya hay un título visible arriba).
  defineProps<{ label: string; min?: number; max: number; step?: number; unit?: string; hideLabel?: boolean }>(),
  { min: 0, step: 1 },
)

const id = useId()
const text = ref(formatNumber(model.value))
watch(model, v => (text.value = formatNumber(v)))

function set(n: number) {
  // `next` y no `model.value`: con defineModel, el valor nuevo llega recién cuando el padre se actualiza.
  const next = clampNumber(n, props.min, props.max)
  model.value = next
  text.value = formatNumber(next)
}

// Al salir del campo: si se escribió algo inválido, vuelve al último valor bueno.
function commit() {
  const n = parseNumber(text.value)
  set(n ?? model.value)
}
</script>

<template>
  <div class="flex flex-col gap-1.5">
    <label :for="id" class="text-sm font-semibold" :class="{ 'sr-only': hideLabel }">{{ label }}</label>
    <div class="flex items-stretch gap-2">
      <button
        type="button"
        class="flex min-h-12 w-14 shrink-0 items-center justify-center rounded-xl border border-line bg-field text-primary transition active:bg-primary-soft disabled:opacity-40"
        :aria-label="`Restar ${formatNumber(step)}${unit ? ` ${unit}` : ''}`"
        :disabled="model <= min"
        @click="set(model - step)"
      >
        <AppIcon name="minus" />
      </button>
      <div class="relative flex-1">
        <input
          :id="id"
          v-model="text"
          type="text"
          inputmode="decimal"
          autocomplete="off"
          class="min-h-12 w-full rounded-xl border border-line bg-field px-3 text-center text-base font-semibold transition outline-none focus:border-primary focus:ring-4 focus:ring-primary/15"
          :class="{ 'pr-10': unit }"
          enterkeyhint="done"
          @focus="($event.target as HTMLInputElement).select()"
          @blur="commit"
          @keydown.enter.prevent="commit"
        >
        <span v-if="unit" class="pointer-events-none absolute inset-y-0 right-3 flex items-center text-sm text-muted">{{ unit }}</span>
      </div>
      <button
        type="button"
        class="flex min-h-12 w-14 shrink-0 items-center justify-center rounded-xl border border-line bg-field text-primary transition active:bg-primary-soft disabled:opacity-40"
        :aria-label="`Sumar ${formatNumber(step)}${unit ? ` ${unit}` : ''}`"
        :disabled="model >= max"
        @click="set(model + step)"
      >
        <AppIcon name="plus" />
      </button>
    </div>
  </div>
</template>
