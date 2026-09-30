<script setup lang="ts">
import type { WeightPoint } from '~/composables/useWeightHistory'

// Línea simple de peso en el tiempo. SVG propio: para una sola serie no vale sumar una librería.
// Al tocar (o pasar el mouse) se marca el día más cercano y se muestra fecha y peso.
const props = defineProps<{ points: WeightPoint[] }>()

const W = 340
const H = 190
const M = { top: 22, right: 20, bottom: 26, left: 40 }
const plotW = W - M.left - M.right
const plotH = H - M.top - M.bottom

// Escala Y con números redondos y un poco de aire arriba y abajo.
const yScale = computed(() => {
  const values = props.points.map(p => p.weight_kg)
  const lo = Math.min(...values)
  const hi = Math.max(...values)
  const range = Math.max(hi - lo, 5)
  const step = [1, 2, 2.5, 5, 10, 20, 25, 50, 100].find(s => range / s <= 4) ?? 100
  const min = Math.max(0, Math.floor((lo - range * 0.1) / step) * step)
  const max = Math.ceil((hi + range * 0.1) / step) * step
  const ticks: number[] = []
  for (let t = min; t <= max + 1e-9; t += step) ticks.push(Math.round(t * 100) / 100)
  return { min, max, ticks }
})

const days = computed(() => props.points.map(p => isoToDay(p.logged_on)))

function x(i: number) {
  const first = days.value[0]!
  const last = days.value[days.value.length - 1]!
  if (last === first) return M.left + plotW / 2
  return M.left + ((days.value[i]! - first) / (last - first)) * plotW
}
function y(kg: number) {
  const { min, max } = yScale.value
  return M.top + plotH - ((kg - min) / (max - min)) * plotH
}

const path = computed(() => props.points.map((p, i) => `${i ? 'L' : 'M'}${x(i).toFixed(1)},${y(p.weight_kg).toFixed(1)}`).join(''))
// Área rellena bajo la línea, hasta el piso del gráfico.
const area = computed(() => `${path.value}L${x(lastIndex.value).toFixed(1)},${M.top + plotH}L${x(0).toFixed(1)},${M.top + plotH}Z`)
const gid = useId()
const lastIndex = computed(() => props.points.length - 1)

// ── Interacción ──
const svg = ref<SVGSVGElement>()
const active = ref<number | null>(null)

function nearest(clientX: number) {
  const rect = svg.value!.getBoundingClientRect()
  const px = ((clientX - rect.left) / rect.width) * W
  let best = 0
  props.points.forEach((_, i) => {
    if (Math.abs(x(i) - px) < Math.abs(x(best) - px)) best = i
  })
  active.value = best
}
function onLeave(e: PointerEvent) {
  // En el celular el dedo "sale" al soltar: dejamos el dato a la vista.
  if (e.pointerType === 'mouse') active.value = null
}
function onKey(e: KeyboardEvent) {
  if (!['ArrowLeft', 'ArrowRight'].includes(e.key)) return
  e.preventDefault()
  const i = active.value ?? lastIndex.value
  active.value = Math.min(lastIndex.value, Math.max(0, i + (e.key === 'ArrowRight' ? 1 : -1)))
}

const summary = computed(() => {
  const first = props.points[0]!
  const last = props.points[lastIndex.value]!
  return `Progreso de peso: ${formatKg(first.weight_kg)} el ${formatShortDate(first.logged_on)}, ${formatKg(last.weight_kg)} el ${formatShortDate(last.logged_on)}.`
})

const tooltip = computed(() => {
  if (active.value === null) return null
  const p = props.points[active.value]!
  const left = (x(active.value) / W) * 100
  return { p, left: Math.min(80, Math.max(20, left)) }
})
</script>

<template>
  <figure class="relative select-none">
    <svg
      ref="svg"
      :viewBox="`0 0 ${W} ${H}`"
      class="w-full touch-pan-y rounded-lg outline-none focus-visible:outline-3 focus-visible:outline-primary"
      role="img"
      :aria-label="summary"
      tabindex="0"
      @pointerdown="nearest($event.clientX)"
      @pointermove="nearest($event.clientX)"
      @pointerleave="onLeave"
      @keydown="onKey"
      @blur="active = null"
    >
      <defs>
        <!-- En coordenadas del gráfico: con todos los pesos iguales la línea es plana y no tiene alto. -->
        <linearGradient :id="`${gid}-line`" gradientUnits="userSpaceOnUse" :x1="M.left" :x2="W - M.right" y1="0" y2="0">
          <stop offset="0%" stop-color="#8b5cf6" />
          <stop offset="100%" stop-color="#38bdf8" />
        </linearGradient>
        <linearGradient :id="`${gid}-area`" x1="0" x2="0" y1="0" y2="1">
          <stop offset="0%" stop-color="#6366f1" stop-opacity="0.35" />
          <stop offset="100%" stop-color="#6366f1" stop-opacity="0" />
        </linearGradient>
      </defs>

      <!-- Grilla y eje Y (discretos) -->
      <g class="text-[11px]" fill="var(--color-muted)">
        <template v-for="t in yScale.ticks" :key="t">
          <line :x1="M.left" :x2="W - M.right" :y1="y(t)" :y2="y(t)" stroke="var(--color-line)" stroke-width="1" />
          <text :x="M.left - 6" :y="y(t)" text-anchor="end" dominant-baseline="middle">{{ formatNumber(t) }}</text>
        </template>
        <!-- Eje X: solo primera y última fecha -->
        <text :x="x(0)" :y="H - 6" :text-anchor="points.length > 1 ? 'start' : 'middle'">{{ formatShortDate(points[0]!.logged_on) }}</text>
        <text v-if="points.length > 1" :x="x(lastIndex)" :y="H - 6" text-anchor="end">{{ formatShortDate(points[lastIndex]!.logged_on) }}</text>
      </g>

      <!-- Línea vertical del día elegido -->
      <line
        v-if="active !== null"
        :x1="x(active)" :x2="x(active)" :y1="M.top - 8" :y2="M.top + plotH"
        stroke="var(--color-muted)" stroke-width="1" stroke-dasharray="3 3"
      />

      <path v-if="points.length > 1" :d="area" :fill="`url(#${gid}-area)`" />
      <path :d="path" fill="none" :stroke="`url(#${gid}-line)`" stroke-width="2.5" stroke-linejoin="round" stroke-linecap="round" />
      <circle
        v-for="(p, i) in points"
        :key="p.logged_on"
        :cx="x(i)" :cy="y(p.weight_kg)"
        :r="active === i ? 6 : 4"
        :fill="i === lastIndex ? 'var(--color-accent)' : 'var(--color-primary)'" stroke="var(--color-elevated)" stroke-width="2"
      />

      <!-- Etiqueta directa solo en el último valor -->
      <text
        v-if="active === null"
        :x="x(lastIndex)" :y="y(points[lastIndex]!.weight_kg) - 12"
        text-anchor="end" class="text-[12px] font-bold" fill="var(--color-ink)"
      >{{ formatKg(points[lastIndex]!.weight_kg) }}</text>
    </svg>

    <div
      v-if="tooltip"
      class="pointer-events-none absolute top-0 -translate-x-1/2 rounded-lg border border-line bg-elevated px-2.5 py-1.5 text-center text-xs text-ink shadow-lg"
      :style="{ left: `${tooltip.left}%` }"
    >
      <span class="block font-bold">{{ formatKg(tooltip.p.weight_kg) }}</span>
      <span class="block opacity-80">{{ formatShortDate(tooltip.p.logged_on) }}</span>
    </div>
  </figure>
</template>
