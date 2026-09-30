<script setup lang="ts">
import type { WeightPoint } from '~/composables/useWeightHistory'

// Cambiar el peso en el gimnasio: botones grandes, sin confirmar, se guarda solo.
const weight = defineModel<number>({ required: true })
const props = defineProps<{ itemId: string; exerciseName: string; previous?: WeightPoint }>()
const emit = defineEmits<{ saved: [] }>()

const MAX = 999
const STEPS = [-2.5, -1, 1, 2.5]

const routines = useRoutines()
const toast = useToast()
const { status, schedule, flush } = useAutoSave((kg: number) => routines.updateItem(props.itemId, { weight_kg: kg }))

const text = ref(formatNumber(weight.value))
watch(weight, v => (text.value = formatNumber(v)))

function change(kg: number) {
  // Se guarda `next`, no `weight.value`: con defineModel, leerlo justo después de asignarlo
  // devuelve el valor anterior hasta que el padre se actualiza.
  const next = clampNumber(kg, 0, MAX)
  weight.value = next
  text.value = formatNumber(next)
  schedule(next)
}

// Escrito a mano: se guarda al salir del campo. Si no es un número, vuelve al anterior.
function commit() {
  const n = parseNumber(text.value)
  if (n === null || n === weight.value) {
    text.value = formatNumber(weight.value)
    return
  }
  change(n)
  void save()
}

async function save() {
  await flush().catch(() => {})
}

// Un solo lugar avisa del error, venga del guardado automático o de un reintento.
// "Guardado" se ve un momento y se va: con toda la rutina anotada no quedan tildes por todos lados.
const savedVisible = ref(false)
let savedTimer: ReturnType<typeof setTimeout> | undefined
watch(status, s => {
  clearTimeout(savedTimer)
  savedVisible.value = s === 'saved'
  if (s === 'saved') {
    savedTimer = setTimeout(() => (savedVisible.value = false), 3000)
    emit('saved')
  }
  if (s === 'error') toast.error(`No se guardó el peso de ${props.exerciseName}. Revisá la conexión y tocá «Reintentar».`)
})
onBeforeUnmount(() => clearTimeout(savedTimer))

// La ficha lo usa antes de pasar a peso corporal: que un guardado pendiente no pise el cambio.
defineExpose({ flush: save })

const id = useId()
const stepLabel = (s: number) => `${s > 0 ? '+' : '−'}${formatNumber(Math.abs(s))}`
</script>

<template>
  <div class="flex flex-col gap-1.5">
    <label :for="id" class="sr-only">Peso de {{ exerciseName }} en kilos</label>
    <div class="flex items-stretch gap-1.5">
      <template v-for="(s, i) in STEPS" :key="s">
        <div v-if="i === 2" class="relative flex-[1.4]">
          <input
            :id="id"
            v-model="text"
            type="text"
            inputmode="decimal"
            autocomplete="off"
            class="min-h-14 w-full rounded-xl border border-primary/40 bg-brand-soft pr-7 pl-2 text-center text-lg font-bold transition outline-none focus:border-primary focus:ring-4 focus:ring-primary/20"
            enterkeyhint="done"
            @focus="($event.target as HTMLInputElement).select()"
            @blur="commit"
            @keydown.enter.prevent="($event.target as HTMLInputElement).blur()"
          >
          <span class="pointer-events-none absolute inset-y-0 right-2 flex items-center text-xs text-muted">kg</span>
        </div>
        <button
          type="button"
          class="min-h-14 flex-1 rounded-xl border border-line bg-field text-base font-bold text-primary-strong transition active:scale-95 active:bg-primary-soft disabled:opacity-40"
          :aria-label="`${s > 0 ? 'Sumar' : 'Restar'} ${formatNumber(Math.abs(s))} kg a ${exerciseName}`"
          :disabled="(s < 0 && weight <= 0) || (s > 0 && weight >= MAX)"
          @click="change(weight + s)"
        >
          {{ stepLabel(s) }}
        </button>
      </template>
    </div>

    <div class="flex min-h-6 items-center justify-between gap-2 text-xs">
      <span class="text-muted">
        <template v-if="previous">La vez anterior: <strong class="text-ink">{{ formatKg(previous.weight_kg) }}</strong> · {{ formatShortDate(previous.logged_on) }}</template>
      </span>
      <span role="status" class="shrink-0 font-semibold">
        <span v-if="status === 'pending' || status === 'saving'" class="text-muted">Guardando…</span>
        <span v-else-if="savedVisible" class="flex items-center gap-1 text-ok"><AppIcon name="check" :size="14" />Guardado</span>
        <button v-else-if="status === 'error'" type="button" class="min-h-12 rounded-lg px-2 text-danger underline" @click="save">
          No se guardó · Reintentar
        </button>
      </span>
    </div>
  </div>
</template>
