<script setup lang="ts">
import type { ExerciseInput } from '~/composables/useCatalog'

useHead({ title: 'Editar ejercicio' })

const route = useRoute()
const id = route.params.id as string

const catalog = useCatalog()
const isAdmin = useIsAdmin()
const toast = useToast()

const draft = ref(emptyDraft())
const { data: exercise, status } = useLazyAsyncData(`exercise-edit-${id}`, () => catalog.get(id))
watch(exercise, e => {
  if (e) draft.value = draftFromExercise(e)
}, { immediate: true })

const saving = ref(false)
const error = ref('')

async function save(input: ExerciseInput) {
  saving.value = true
  error.value = ''
  try {
    await catalog.update(id, input)
    clearNuxtData(`exercise-${id}`)
    toast.ok('Guardado')
    await navigateTo(`/ejercicios/${id}`)
  }
  catch (e) {
    error.value = friendlyError(e)
  }
  finally {
    saving.value = false
  }
}
</script>

<template>
  <AppHeader title="Editar" :back="`/ejercicios/${id}`" />

  <EmptyState
    v-if="!isAdmin"
    icon="alert"
    title="Solo el admin puede editar"
    text="El catálogo es compartido: para cambiar un ejercicio, pedíselo a quien administra la app."
  />
  <AppLoading v-else-if="status === 'pending'" />
  <EmptyState v-else-if="!exercise" icon="alert" title="No encontramos este ejercicio" />
  <div v-else class="p-4">
    <ExerciseForm v-model="draft" submit-label="Guardar cambios" :loading="saving" :error="error" @submit="save" />
  </div>
</template>
