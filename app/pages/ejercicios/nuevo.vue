<script setup lang="ts">
import type { ExerciseInput } from '~/composables/useCatalog'

useHead({ title: 'Nuevo ejercicio' })

const route = useRoute()
const catalog = useCatalog()
const toast = useToast()

const draft = ref(emptyDraft(typeof route.query.nombre === 'string' ? route.query.nombre : ''))
const routineId = typeof route.query.rutina === 'string' ? route.query.rutina : null

// ── Parecidos: se buscan mientras se escribe, para no duplicar el catálogo compartido ──
type Similar = Awaited<ReturnType<typeof catalog.similar>>
const similar = ref<Similar>([])
let timer: ReturnType<typeof setTimeout> | undefined
let requestId = 0

watch(
  () => [draft.value.name, draft.value.aliasesText] as const,
  ([name, aliasesText]) => {
    clearTimeout(timer)
    if (name.trim().length < 3) {
      similar.value = []
      return
    }
    timer = setTimeout(async () => {
      const id = ++requestId
      try {
        const data = await catalog.similar(name.trim(), splitAliases(aliasesText))
        if (id === requestId) similar.value = data
      }
      catch {
        // Es solo una ayuda: si falla, se puede crear igual.
      }
    }, 400)
  },
  { immediate: true },
)
onBeforeUnmount(() => clearTimeout(timer))

// ── Guardar ──
const saving = ref(false)
const error = ref('')

async function save(input: ExerciseInput) {
  saving.value = true
  error.value = ''
  try {
    const created = await catalog.create(input)
    toast.ok('Ejercicio creado')
    // Si se llegó desde "Agregar ejercicio" de una rutina, se vuelve ahí con el nuevo ya elegido.
    await navigateTo(
      routineId ? `/rutinas/${routineId}/agregar?ejercicio=${created.id}` : `/ejercicios/${created.id}`,
      { replace: true },
    )
  }
  catch (e) {
    const code = (e as { code?: string }).code
    error.value = code === '23505'
      ? `Ya existe «${input.name}» en el catálogo. Buscalo en la lista de ejercicios.`
      : friendlyError(e)
  }
  finally {
    saving.value = false
  }
}
</script>

<template>
  <AppHeader title="Nuevo ejercicio" :back="routineId ? `/rutinas/${routineId}/agregar` : '/ejercicios'" />
  <div class="p-4">
    <ExerciseForm v-model="draft" submit-label="Crear ejercicio" :loading="saving" :error="error" @submit="save">
      <template #after-name>
        <section
          v-if="similar.length"
          class="flex flex-col gap-2 rounded-xl border-2 border-primary bg-primary-soft p-3"
          aria-live="polite"
        >
          <h2 class="text-sm font-semibold text-primary-strong">¿Es alguno de estos? Ya están en el catálogo:</h2>
          <ul class="flex flex-col gap-2">
            <li v-for="s in similar.slice(0, 3)" :key="s.id">
              <ExerciseListItem :exercise="s" @select="navigateTo(`/ejercicios/${s.id}`)" />
            </li>
          </ul>
          <p class="text-xs text-muted">Si no es ninguno, seguí completando y crealo.</p>
        </section>
      </template>
    </ExerciseForm>
  </div>
</template>
