<script setup lang="ts">
import type { RouteLocationRaw } from 'vue-router'
import type { Exercise } from '~/composables/useCatalog'

const props = defineProps<{
  /** Clave para recordar la búsqueda al volver a la pantalla. */
  stateKey: string
  /** A dónde lleva "Crear ejercicio nuevo"; recibe lo que se buscó. */
  createTo: (q: string) => RouteLocationRaw
}>()
defineEmits<{ select: [exercise: Exercise] }>()

const catalog = useCatalog()
const muscleGroups = useMuscleGroups()

const q = useState(`${props.stateKey}-q`, () => '')
const groupId = useState<string | null>(`${props.stateKey}-group`, () => null)
const results = ref<Exercise[]>([])
const loading = ref(true)
const error = ref('')

let requestId = 0
let timer: ReturnType<typeof setTimeout> | undefined

async function run() {
  const id = ++requestId
  loading.value = true
  error.value = ''
  try {
    await muscleGroups.load()
    const data = await catalog.search(q.value, groupId.value)
    // Si mientras tanto se escribió otra cosa, esta respuesta ya no sirve.
    if (id === requestId) results.value = data
  }
  catch (e) {
    if (id === requestId) error.value = friendlyError(e)
  }
  finally {
    if (id === requestId) loading.value = false
  }
}

// Espera a que se deje de tipear un momento antes de buscar.
watch(q, () => {
  clearTimeout(timer)
  timer = setTimeout(run, 250)
})
watch(groupId, run)
onMounted(run)
onBeforeUnmount(() => clearTimeout(timer))
</script>

<template>
  <div class="flex flex-col gap-3">
    <AppInput
      v-model="q"
      label="Buscar ejercicio"
      hide-label
      type="search"
      inputmode="search"
      autocomplete="off"
      placeholder="Buscá por cualquier nombre…"
      enterkeyhint="search"
    >
      <template v-if="q" #inside>
        <button
          type="button"
          class="absolute inset-y-0 right-0 flex w-12 items-center justify-center rounded-r-xl text-muted active:text-ink"
          aria-label="Borrar búsqueda"
          @click="q = ''"
        >
          <AppIcon name="close" :size="20" />
        </button>
      </template>
    </AppInput>
    <MuscleGroupChips v-model="groupId" />

    <ErrorBox :message="error" />
    <AppLoading v-if="loading && !results.length" />

    <template v-else-if="!error">
      <p v-if="!results.length" class="py-4 text-center text-sm text-muted">
        No encontramos {{ q ? `«${q}»` : 'ejercicios' }}{{ groupId ? ` en ${muscleGroups.nameOf(groupId)}` : '' }}.
      </p>
      <ul v-else class="flex flex-col gap-2 transition-opacity" :class="{ 'opacity-60': loading }" :aria-busy="loading">
        <li v-for="exercise in results" :key="exercise.id">
          <ExerciseListItem :exercise="exercise" @select="$emit('select', exercise)" />
        </li>
      </ul>
    </template>

    <div class="mt-2 flex flex-col items-center gap-2 rounded-2xl border border-dashed border-primary/30 bg-brand-soft p-4 text-center">
      <p class="text-sm text-muted">¿No está el que buscás?</p>
      <AppButton variant="secondary" block :to="createTo(q)">
        <AppIcon name="plus" :size="20" />
        Crear ejercicio nuevo
      </AppButton>
    </div>
  </div>
</template>
