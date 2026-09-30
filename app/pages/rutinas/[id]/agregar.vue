<script setup lang="ts">
import type { Exercise } from '~/composables/useCatalog'
import type { ItemSettings } from '~/composables/useRoutines'

useHead({ title: 'Agregar ejercicio' })

const route = useRoute()
const routineId = route.params.id as string

const routines = useRoutines()
const catalog = useCatalog()
const muscleGroups = useMuscleGroups()
const toast = useToast()

const { data: routine } = useLazyAsyncData(`routine-add-${routineId}`, () => routines.get(routineId))

// ── Vista previa del ejercicio elegido ──
const selected = ref<Exercise | null>(null)
const sheetOpen = ref(false)
const settings = ref<ItemSettings>({ sets: 3, reps: 10, weight_kg: 0 })
const saving = ref(false)
const error = ref('')

const alreadyIn = computed(() => !!routine.value?.items.some(i => i.exercise_id === selected.value?.id))

function pick(exercise: Exercise) {
  selected.value = exercise
  settings.value = { sets: 3, reps: 10, weight_kg: 0 }
  error.value = ''
  sheetOpen.value = true
}

// Si se viene de crear un ejercicio nuevo, se abre directo su vista previa.
onMounted(async () => {
  const exerciseId = route.query.ejercicio
  if (typeof exerciseId !== 'string') return
  try {
    const exercise = await catalog.get(exerciseId)
    if (exercise) pick(exercise)
  }
  catch {
    // Sin vista previa automática: se puede buscar igual.
  }
})

async function add() {
  if (!selected.value) return
  saving.value = true
  error.value = ''
  try {
    await routines.addItem(routineId, selected.value.id, settings.value)
    sheetOpen.value = false
    toast.ok(routine.value ? `Agregado a «${routine.value.name}»` : 'Agregado a la rutina')
    await navigateTo(`/rutinas/${routineId}`, { replace: true })
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
      Elegí un ejercicio para agregar a <strong class="text-ink">{{ routine.name }}</strong>.
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

      <p v-if="alreadyIn" class="rounded-xl bg-primary-soft p-3 text-sm font-semibold text-primary-strong">
        Este ejercicio ya está en la rutina.
      </p>
      <form v-else class="flex flex-col gap-4" novalidate @submit.prevent="add">
        <ItemSettingsFields v-model="settings" />
        <ErrorBox :message="error" />
        <AppButton type="submit" size="lg" block :loading="saving">
          <AppIcon name="plus" :size="20" />
          Agregar a mi rutina
        </AppButton>
      </form>
      <AppButton variant="ghost" block @click="sheetOpen = false">Elegir otro</AppButton>
    </template>
  </AppSheet>
</template>
