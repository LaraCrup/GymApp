<script setup lang="ts">
import type { ItemSettings } from '~/composables/useRoutines'

useHead({ title: 'Ejercicio' })

const route = useRoute()
const id = route.params.id as string
// Abierto desde una rutina: "Volver" regresa ahí y no al catálogo.
const fromRoutine = typeof route.query.rutina === 'string' ? route.query.rutina : null
const backTo = fromRoutine ? `/rutinas/${fromRoutine}` : '/ejercicios'

const catalog = useCatalog()
const muscleGroups = useMuscleGroups()
const isAdmin = useIsAdmin()
const toast = useToast()
const { confirm } = useConfirm()

const { data: exercise, status, error } = useLazyAsyncData(`exercise-${id}`, async () => {
  await muscleGroups.load()
  return catalog.get(id)
})

// ── Agregar a una rutina: se elige cuál y se sigue en su pantalla de agregar ──
const routines = useRoutines()
const pickerOpen = ref(false)
const { data: myRoutines, status: routinesStatus, error: routinesError, execute: loadRoutines } = useLazyAsyncData(
  `exercise-routines-${id}`,
  () => routines.list(),
  { immediate: false },
)

function openPicker() {
  pickerOpen.value = true
  void loadRoutines()
}

// ── Abierto desde una rutina: acá se cambian el peso, las series y las reps (o el tiempo) ──
const history = useWeightHistory()
const { data: item, status: itemStatus, error: itemError, refresh: refreshItem } = useLazyAsyncData(
  `routine-item-${fromRoutine}-${id}`,
  async () => {
    if (!fromRoutine) return null
    const found = await routines.getItem(fromRoutine, id)
    // "La vez anterior": ayuda, no es crítico; si falla, se sigue igual.
    const previous = found ? await history.previous([id]).then(m => m.get(id)).catch(() => undefined) : undefined
    return found && { ...found, previous }
  },
  { deep: true },
)

const settingsOpen = ref(false)
const settingsDraft = ref<ItemSettings>({ sets: 3, reps: 10, seconds: null, weight_kg: 0 })
const savingSettings = ref(false)

function openSettings() {
  if (!item.value) return
  settingsDraft.value = { sets: item.value.sets, reps: item.value.reps, seconds: item.value.seconds, weight_kg: item.value.weight_kg }
  settingsOpen.value = true
}

async function saveSettings() {
  if (!item.value) return
  savingSettings.value = true
  try {
    const { sets, reps, seconds } = settingsDraft.value
    await routines.updateItem(item.value.id, { sets, reps, seconds })
    Object.assign(item.value, { sets, reps, seconds })
    settingsOpen.value = false
    toast.ok('Guardado')
  }
  catch (e) {
    toast.error(friendlyError(e))
  }
  finally {
    savingSettings.value = false
  }
}

// ── Peso corporal: sin peso extra (se guarda vacío). Al apagarlo vuelve el último peso. ──
const weightControl = ref<{ flush: () => Promise<void> }>()
const lastWeight = ref(0)
const savingBodyweight = ref(false)

const bodyweight = computed({
  get: () => item.value?.weight_kg === null,
  set: on => void setBodyweight(on),
})

async function setBodyweight(on: boolean) {
  if (!item.value) return
  const current = item.value
  const before = current.weight_kg
  savingBodyweight.value = true
  try {
    // Primero termina de guardar el peso que se estaba cambiando: así no pisa el cambio.
    if (on) await weightControl.value?.flush()
    if (current.weight_kg !== null) lastWeight.value = current.weight_kg
    const next = on ? null : (lastWeight.value || current.previous?.weight_kg || 0)
    current.weight_kg = next
    await routines.updateItem(current.id, { weight_kg: next })
    if (next) onWeightSaved()
  }
  catch (e) {
    current.weight_kg = before
    toast.error(friendlyError(e))
  }
  finally {
    savingBodyweight.value = false
  }
}

// El peso nuevo queda en el historial: el gráfico de "Mi progreso" se actualiza.
function onWeightSaved() {
  void refreshNuxtData(`history-${id}`)
}

const deleting = ref(false)

async function remove() {
  if (!exercise.value) return
  const ok = await confirm({
    title: `¿Borrar «${exercise.value.name}»?`,
    message: 'Se borra del catálogo para todas las personas que usan la app.',
    confirmLabel: 'Sí, borrar ejercicio',
    danger: true,
  })
  if (!ok) return
  deleting.value = true
  try {
    await catalog.remove(id)
    toast.ok('Ejercicio borrado')
    await navigateTo('/ejercicios')
  }
  catch (e) {
    toast.error(friendlyError(e))
  }
  finally {
    deleting.value = false
  }
}
</script>

<template>
  <AppHeader title="Ejercicio" :back="backTo" />

  <AppLoading v-if="status === 'pending'" />
  <div v-else-if="error" class="p-4"><ErrorBox :message="friendlyError(error)" /></div>
  <EmptyState
    v-else-if="!exercise"
    icon="alert"
    title="No encontramos este ejercicio"
    text="Puede que lo hayan borrado del catálogo."
  >
    <AppButton variant="secondary" block to="/ejercicios">Ver todos los ejercicios</AppButton>
  </EmptyState>

  <article v-else class="flex flex-col gap-4 p-4">
    <div class="flex items-start justify-between gap-3">
      <h2 class="min-w-0 text-xl font-bold tracking-tight">{{ exercise.name }}</h2>
      <p class="mt-0.5 shrink-0 rounded-lg border border-primary/30 bg-brand-soft px-2.5 py-0.5 text-sm font-semibold text-primary-strong">
        {{ muscleGroups.nameOf(exercise.muscle_group_id) }}
      </p>
    </div>

    <YouTubeVideo :youtube-id="exercise.youtube_id" :title="exercise.name" />

    <!-- Desde una rutina: lo que se anota en el gimnasio va primero. -->
    <template v-if="fromRoutine">
      <AppLoading v-if="itemStatus === 'pending' && !item" />
      <div v-else-if="itemError" class="flex flex-col gap-2">
        <ErrorBox :message="friendlyError(itemError)" />
        <AppButton variant="secondary" block @click="refreshItem()">Probar de nuevo</AppButton>
      </div>
      <section v-else-if="item" class="card flex flex-col gap-4 rounded-2xl p-4">
        <h3 class="text-sm text-muted">En <strong class="text-ink">{{ item.routine.name }}</strong></h3>
        <button
          type="button"
          class="flex min-h-12 items-center justify-between gap-2 rounded-xl border border-line bg-field px-3 text-left active:bg-primary-soft"
          @click="openSettings"
        >
          <span class="text-sm text-muted">
            <strong class="text-ink">{{ item.sets }}</strong> series
            <template v-if="item.seconds !== null">× <strong class="text-ink">{{ formatSeconds(item.seconds) }}</strong></template>
            <template v-else-if="item.reps === null"><strong class="text-ink">al fallo</strong></template>
            <template v-else>× <strong class="text-ink">{{ item.reps }}</strong> reps</template>
          </span>
          <span class="text-sm font-semibold text-primary">Cambiar</span>
        </button>
        <div class="flex flex-col gap-2">
          <div class="-my-2 flex items-center justify-between gap-2">
            <p class="text-sm font-semibold">Peso</p>
            <AppSwitch v-model="bodyweight" label="Peso corporal" :disabled="savingBodyweight" />
          </div>
          <WeightControl
            v-if="item.weight_kg !== null"
            ref="weightControl"
            :model-value="item.weight_kg"
            :item-id="item.id"
            :exercise-name="exercise.name"
            :previous="item.previous"
            @update:model-value="v => item && (item.weight_kg = v)"
            @saved="onWeightSaved"
          />
          <p v-else class="flex min-h-14 items-center justify-center rounded-xl border border-dashed border-primary/40 bg-primary-soft px-3 text-sm font-semibold text-primary-strong">
            Sin peso extra: con tu propio cuerpo
          </p>
        </div>
      </section>
    </template>

    <section v-if="exercise.aliases.length" class="card rounded-2xl p-4">
      <h3 class="text-sm font-semibold text-muted">También conocido como</h3>
      <p class="mt-1">{{ exercise.aliases.join(' · ') }}</p>
    </section>

    <WeightProgress :exercise-id="exercise.id" />

    <div v-if="isAdmin" class="flex flex-col gap-3 border-t border-line pt-4">
      <p v-if="!exercise.youtube_id" class="text-sm text-muted">Tocá «Editar» para agregarle un video.</p>
      <!-- Lado a lado: "Borrar" pide confirmación antes de borrar del catálogo. -->
      <div class="grid grid-cols-2 gap-2">
        <AppButton variant="secondary" :to="`/ejercicios/${exercise.id}/editar`">
          <AppIcon name="edit" :size="20" />
          Editar
        </AppButton>
        <AppButton variant="danger" aria-label="Borrar del catálogo" :loading="deleting" @click="remove">
          <AppIcon name="trash" :size="20" />
          Borrar
        </AppButton>
      </div>
    </div>

    <AppButton v-if="!fromRoutine" block @click="openPicker">
      <AppIcon name="plus" :size="20" />
      Agregar a una rutina
    </AppButton>
  </article>

  <AppSheet v-model:open="settingsOpen" title="Series, reps o tiempo">
    <form class="flex flex-col gap-4" novalidate @submit.prevent="saveSettings">
      <ItemSettingsFields v-model="settingsDraft" :with-weight="false" />
      <AppButton type="submit" size="lg" block :loading="savingSettings">Guardar</AppButton>
    </form>
  </AppSheet>

  <AppSheet v-model:open="pickerOpen" title="¿A qué rutina?">
    <AppLoading v-if="routinesStatus === 'pending' && !myRoutines" />
    <ErrorBox v-else-if="routinesError" :message="friendlyError(routinesError)" />
    <template v-else-if="!myRoutines?.length">
      <p class="text-sm text-muted">Todavía no tenés rutinas. Creá una desde «Mis rutinas» y después agregale ejercicios.</p>
      <AppButton variant="secondary" block to="/">Ir a mis rutinas</AppButton>
    </template>
    <ul v-else class="flex flex-col gap-2">
      <li v-for="r in myRoutines" :key="r.id">
        <NuxtLink
          :to="`/rutinas/${r.id}/agregar?ejercicio=${id}`"
          class="card flex min-h-14 items-center gap-3 rounded-xl px-4 active:bg-primary-soft"
        >
          <span class="min-w-0 flex-1 truncate font-semibold">{{ r.name }}</span>
          <AppIcon name="chevron" :size="20" class="text-muted" />
        </NuxtLink>
      </li>
    </ul>
  </AppSheet>
</template>
