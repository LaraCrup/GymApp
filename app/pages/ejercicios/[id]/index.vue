<script setup lang="ts">
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
    <YouTubeVideo :youtube-id="exercise.youtube_id" :title="exercise.name" />

    <div>
      <h2 class="text-xl font-bold">{{ exercise.name }}</h2>
      <p class="mt-1 inline-block rounded-lg bg-primary-soft px-2 py-0.5 text-sm font-semibold text-primary-strong">
        {{ muscleGroups.nameOf(exercise.muscle_group_id) }}
      </p>
    </div>

    <section v-if="exercise.aliases.length" class="rounded-xl bg-white p-4">
      <h3 class="text-sm font-semibold text-muted">También conocido como</h3>
      <p class="mt-1">{{ exercise.aliases.join(' · ') }}</p>
    </section>

    <AppButton v-if="!fromRoutine" block @click="openPicker">
      <AppIcon name="plus" :size="20" />
      Agregar a una rutina
    </AppButton>

    <WeightProgress :exercise-id="exercise.id" />

    <div v-if="isAdmin" class="flex flex-col gap-3 border-t border-line pt-4">
      <p v-if="!exercise.youtube_id" class="text-sm text-muted">Tocá «Editar» para agregarle un video.</p>
      <AppButton variant="secondary" block :to="`/ejercicios/${exercise.id}/editar`">
        <AppIcon name="edit" :size="20" />
        Editar
      </AppButton>
      <AppButton variant="danger" block :loading="deleting" @click="remove">
        <AppIcon name="trash" :size="20" />
        Borrar del catálogo
      </AppButton>
    </div>
  </article>

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
          class="flex min-h-14 items-center gap-3 rounded-xl border-2 border-line px-4 active:bg-primary-soft"
        >
          <span class="min-w-0 flex-1 truncate font-semibold">{{ r.name }}</span>
          <AppIcon name="chevron" :size="20" class="text-muted" />
        </NuxtLink>
      </li>
    </ul>
  </AppSheet>
</template>
