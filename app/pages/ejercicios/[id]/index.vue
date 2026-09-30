<script setup lang="ts">
useHead({ title: 'Ejercicio' })

const route = useRoute()
const id = route.params.id as string

const catalog = useCatalog()
const muscleGroups = useMuscleGroups()
const isAdmin = useIsAdmin()
const toast = useToast()
const { confirm } = useConfirm()

const { data: exercise, status, error } = useLazyAsyncData(`exercise-${id}`, async () => {
  await muscleGroups.load()
  return catalog.get(id)
})

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
  <AppHeader title="Ejercicio" back="/ejercicios" />

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
</template>
