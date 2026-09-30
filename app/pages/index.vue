<script setup lang="ts">
useHead({ title: 'Mis rutinas' })

const routines = useRoutines()
const toast = useToast()

const { data: list, status, error, refresh } = useLazyAsyncData('routines', () => routines.list())

const creating = ref(false)
const saving = ref(false)
const createError = ref('')

function openCreate() {
  createError.value = ''
  creating.value = true
}

async function create(name: string) {
  saving.value = true
  createError.value = ''
  try {
    const routine = await routines.create(name)
    creating.value = false
    toast.ok('Rutina creada')
    await navigateTo(`/rutinas/${routine.id}`)
  }
  catch (e) {
    createError.value = friendlyError(e)
  }
  finally {
    saving.value = false
  }
}
</script>

<template>
  <AppHeader title="Mis rutinas" />

  <AppLoading v-if="status === 'pending' && !list" />
  <div v-else-if="error" class="flex flex-col gap-3 p-4">
    <ErrorBox :message="friendlyError(error)" />
    <AppButton variant="secondary" block @click="refresh()">Probar de nuevo</AppButton>
  </div>

  <EmptyState
    v-else-if="!list?.length"
    title="Todavía no tenés rutinas"
    text="Una rutina es la lista de ejercicios que hacés un día en el gimnasio. Por ejemplo: «Día 1 - Piernas»."
  >
    <AppButton size="lg" block @click="openCreate">
      <AppIcon name="plus" :size="20" />
      Crear mi primera rutina
    </AppButton>
  </EmptyState>

  <div v-else class="flex flex-col gap-3 p-4">
    <ul class="flex flex-col gap-2">
      <li v-for="r in list" :key="r.id">
        <NuxtLink :to="`/rutinas/${r.id}`" class="flex min-h-16 items-center gap-3 rounded-2xl bg-white p-4 active:bg-primary-soft">
          <span class="min-w-0 flex-1">
            <span class="block font-semibold">{{ r.name }}</span>
            <span class="block text-sm text-muted">
              {{ r.exercise_count === 0 ? 'Sin ejercicios todavía' : r.exercise_count === 1 ? '1 ejercicio' : `${r.exercise_count} ejercicios` }}
            </span>
          </span>
          <AppIcon name="chevron" :size="20" class="text-muted" />
        </NuxtLink>
      </li>
    </ul>
    <AppButton variant="secondary" block @click="openCreate">
      <AppIcon name="plus" :size="20" />
      Nueva rutina
    </AppButton>
  </div>

  <RoutineNameSheet
    v-model:open="creating"
    title="Nueva rutina"
    submit-label="Crear rutina"
    :loading="saving"
    :error="createError"
    @save="create"
  />
</template>
