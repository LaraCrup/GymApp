<script setup lang="ts">
// "Mi progreso" en la ficha de un ejercicio: resumen, gráfico y lista día por día.
const props = defineProps<{ exerciseId: string }>()

const history = useWeightHistory()
// La clave la usa también la ficha del ejercicio para actualizar el gráfico al cambiar el peso.
const { data: points, status, error, refresh } = useLazyAsyncData(`history-${props.exerciseId}`, () => history.forExercise(props.exerciseId))

const first = computed(() => points.value?.[0])
const last = computed(() => points.value?.[points.value.length - 1])
const diff = computed(() => (first.value && last.value ? last.value.weight_kg - first.value.weight_kg : 0))

// Lista del más nuevo al más viejo, con la diferencia contra el registro anterior.
const rows = computed(() =>
  (points.value ?? [])
    .map((p, i, all) => ({ ...p, change: i ? p.weight_kg - all[i - 1]!.weight_kg : null }))
    .reverse(),
)
const signed = (n: number) => `${n > 0 ? '+' : '−'}${formatKg(Math.abs(n))}`
</script>

<template>
  <section class="card flex flex-col gap-3 rounded-2xl p-4">
    <h3 class="text-base font-bold">Mi progreso</h3>

    <AppLoading v-if="status === 'pending' && !points" />
    <div v-else-if="error" class="flex flex-col gap-2">
      <ErrorBox :message="friendlyError(error)" />
      <AppButton variant="secondary" block @click="refresh()">Probar de nuevo</AppButton>
    </div>
    <p v-else-if="!points?.length" class="text-sm text-muted">
      Todavía no hay registros. Cuando cambies el peso de este ejercicio en una rutina, tu progreso va a aparecer acá.
    </p>

    <template v-else>
      <p class="text-sm">
        <template v-if="points.length === 1">
          Registraste <strong>{{ formatKg(last!.weight_kg) }}</strong> el {{ formatShortDate(last!.logged_on) }}.
        </template>
        <template v-else>
          De <strong>{{ formatKg(first!.weight_kg) }}</strong> a <strong>{{ formatKg(last!.weight_kg) }}</strong>{{ ' ' }}<span v-if="diff" class="font-semibold" :class="diff > 0 ? 'text-ok' : 'text-muted'">({{ signed(diff) }})</span>
          desde el {{ formatShortDate(first!.logged_on) }}.
        </template>
      </p>

      <WeightChart v-if="points.length > 1" :points="points" />

      <table class="w-full text-sm">
        <caption class="sr-only">Historial de pesos</caption>
        <thead class="sr-only">
          <tr><th scope="col">Fecha</th><th scope="col">Peso</th><th scope="col">Cambio</th></tr>
        </thead>
        <tbody>
          <tr v-for="r in rows.slice(0, 10)" :key="r.logged_on" class="border-t border-line">
            <td class="py-2 text-muted">{{ formatShortDate(r.logged_on) }}</td>
            <td class="py-2 text-right font-semibold">{{ formatKg(r.weight_kg) }}</td>
            <td class="w-20 py-2 text-right text-xs" :class="r.change && r.change > 0 ? 'text-ok' : 'text-muted'">
              {{ r.change ? signed(r.change) : '' }}
            </td>
          </tr>
        </tbody>
      </table>
      <p v-if="rows.length > 10" class="text-xs text-muted">Se muestran los últimos 10 registros.</p>
    </template>
  </section>
</template>
