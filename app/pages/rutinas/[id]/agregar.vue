<script setup lang="ts">
import type { Exercise } from '~/composables/useCatalog'
import type { ItemSettings } from '~/composables/useRoutines'

useHead({ title: 'Agregar ejercicio' })

const route = useRoute()
const router = useRouter()
const routineId = route.params.id as string

const routines = useRoutines()
const catalog = useCatalog()
const muscleGroups = useMuscleGroups()
const history = useWeightHistory()

const { data: routine } = useLazyAsyncData(`routine-add-${routineId}`, () => routines.get(routineId))
const addedIds = computed(() => routine.value?.items.map(i => i.exercise_id) ?? [])

// ── Vista previa del ejercicio elegido ──
const selected = ref<Exercise | null>(null)
const sheetOpen = ref(false)
const settings = ref<ItemSettings>({ sets: 3, reps: 10, seconds: null, weight_kg: 0 })
const saving = ref(false)
const error = ref('')
const toast = useToast()

const alreadyIn = computed(() => !!selected.value && addedIds.value.includes(selected.value.id))

function pick(exercise: Exercise) {
  selected.value = exercise
  settings.value = { sets: 3, reps: 10, seconds: null, weight_kg: 0 }
  error.value = ''
  sheetOpen.value = true
  void prefillWeight(exercise.id)
}

// Si ya lo hizo en otra rutina, arranca con el último peso que usó en vez de 0.
async function prefillWeight(exerciseId: string) {
  try {
    const last = (await history.previous([exerciseId])).get(exerciseId)
    if (last && selected.value?.id === exerciseId && settings.value.weight_kg === 0) settings.value.weight_kg = last.weight_kg
  }
  catch {
    // Es solo una ayuda: se puede poner el peso a mano.
  }
}

// Si se viene de crear un ejercicio nuevo, se abre directo su vista previa.
onMounted(async () => {
  const exerciseId = route.query.ejercicio
  if (typeof exerciseId !== 'string') return
  // Se saca de la dirección: al recargar o volver no se tiene que abrir otra vez.
  void router.replace({ query: {} })
  try {
    const exercise = await catalog.get(exerciseId)
    if (exercise) pick(exercise)
  }
  catch {
    // Sin vista previa automática: se puede buscar igual.
  }
})

// Se queda en esta pantalla: armar una rutina es agregar varios ejercicios seguidos.
async function add() {
  if (!selected.value) return
  saving.value = true
  error.value = ''
  try {
    const item = await routines.addItem(routineId, selected.value.id, settings.value)
    if (routine.value) routine.value = { ...routine.value, items: [...routine.value.items, item] }
    toast.ok(`«${selected.value.name}» agregado`, { label: 'Ver rutina', to: `/rutinas/${routineId}` })
    sheetOpen.value = false
  }
  catch (e) {
    error.value = (e as { code?: string }).code === '23505' ? 'Este ejercicio ya está en la rutina.' : friendlyError(e)
  }
  finally {
    saving.value = false
  }
}
</script>

<template>
  <AppHeader title="Agregar ejercicio" :back="`/rutinas/${routineId}`" />
  <div class="p-4">
    <p v-if="routine" class="mb-3 text-sm text-muted">
      Elegí los ejercicios para <strong class="text-ink">{{ routine.name }}</strong>. Podés agregar varios seguidos.
    </p>
    <ExerciseSearch
      state-key="agregar"
      :create-to="q => ({ path: '/ejercicios/nuevo', query: { ...(q ? { nombre: q } : {}), rutina: routineId } })"
      @select="pick"
    />
  </div>

  <AppSheet v-model:open="sheetOpen" :title="selected?.name ?? ''">
    <template v-if="selected">
      <YouTubeVideo :youtube-id="selected.youtube_id" :title="selected.name" />
      <div class="text-sm">
        <p class="font-semibold text-primary-strong">{{ muscleGroups.nameOf(selected.muscle_group_id) }}</p>
        <p v-if="selected.aliases.length" class="text-muted">También conocido como: {{ selected.aliases.join(', ') }}</p>
      </div>

      <p v-if="alreadyIn" class="rounded-xl bg-ok-soft p-3 text-sm font-semibold text-ok">
        Este ejercicio ya está en la rutina.
      </p>
      <form v-else class="flex flex-col gap-4" novalidate @submit.prevent="add">
        <ItemSettingsFields v-model="settings" />
        <ErrorBox :message="error" />
        <AppButton type="submit" size="lg" block :loading="saving">
          <AppIcon name="plus" :size="20" />
          Agregar a la rutina
        </AppButton>
      </form>
      <AppButton variant="ghost" block @click="sheetOpen = false">Elegir otro</AppButton>
    </template>
  </AppSheet>
</template>
