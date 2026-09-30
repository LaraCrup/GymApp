<script setup lang="ts">
import type { ItemSettings, RoutineItem } from '~/composables/useRoutines'

const route = useRoute()
const id = route.params.id as string

const routines = useRoutines()
const muscleGroups = useMuscleGroups()
const toast = useToast()
const { confirm } = useConfirm()

// deep: en Nuxt 4 los datos son shallowRef por defecto; acá se editan en el lugar
// (series, orden, nombre) y la pantalla tiene que reaccionar a esos cambios.
const { data: routine, status, error, refresh } = useLazyAsyncData(`routine-${id}`, async () => {
  await muscleGroups.load()
  return routines.get(id)
}, { deep: true })
useHead(() => ({ title: routine.value?.name ?? 'Rutina' }))

const items = computed(() => routine.value?.items ?? [])
const editing = ref(false)
const grouped = useLocalPref('agrupar-por-musculo', false)

// Agrupado: por grupo muscular (en el orden fijo de los grupos) y, dentro, en el orden de la rutina.
const sections = computed(() => {
  if (!grouped.value || editing.value) return [{ key: 'todos', title: '', items: items.value }]
  return muscleGroups.groups.value
    .map(g => ({ key: g.id, title: g.name, items: items.value.filter(i => i.exercise.muscle_group_id === g.id) }))
    .filter(s => s.items.length)
})

// ── Series, reps y peso ──
const settingsItem = ref<RoutineItem | null>(null)
const settingsOpen = ref(false)
const settingsDraft = ref<ItemSettings>({ sets: 3, reps: 10, weight_kg: 0 })
const savingSettings = ref(false)

function openSettings(item: RoutineItem) {
  settingsItem.value = item
  settingsDraft.value = { sets: item.sets, reps: item.reps, weight_kg: item.weight_kg }
  settingsOpen.value = true
}

async function saveSettings() {
  const item = settingsItem.value
  if (!item) return
  savingSettings.value = true
  try {
    await routines.updateItem(item.id, settingsDraft.value)
    Object.assign(item, settingsDraft.value)
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

// ── Orden ──
async function move(index: number, delta: -1 | 1) {
  if (!routine.value) return
  const list = routine.value.items
  const before = [...list]
  const [moved] = list.splice(index, 1)
  list.splice(index + delta, 0, moved!)
  try {
    await routines.reorder(id, list.map(i => i.id))
  }
  catch (e) {
    routine.value.items = before
    toast.error(friendlyError(e))
  }
}

// ── Quitar ejercicio ──
async function removeItem(item: RoutineItem) {
  const ok = await confirm({
    title: `¿Quitar «${item.exercise.name}» de la rutina?`,
    message: 'El ejercicio sigue en el catálogo y podés volver a agregarlo cuando quieras.',
    confirmLabel: 'Sí, quitar',
    danger: true,
  })
  if (!ok || !routine.value) return
  try {
    await routines.removeItem(item.id)
    routine.value.items = routine.value.items.filter(i => i.id !== item.id)
    toast.ok('Quitado de la rutina')
  }
  catch (e) {
    toast.error(friendlyError(e))
  }
}

// ── Nombre ──
const renaming = ref(false)
const savingName = ref(false)
const renameError = ref('')

async function rename(name: string) {
  if (!routine.value) return
  savingName.value = true
  renameError.value = ''
  try {
    await routines.rename(id, name)
    routine.value.name = name
    renaming.value = false
    toast.ok('Guardado')
  }
  catch (e) {
    renameError.value = friendlyError(e)
  }
  finally {
    savingName.value = false
  }
}

// ── Borrar rutina ──
const deleting = ref(false)

async function removeRoutine() {
  if (!routine.value) return
  const n = routine.value.items.length
  const ok = await confirm({
    title: `¿Borrar «${routine.value.name}»?`,
    message: n
      ? `Se borra la rutina con sus ${n === 1 ? 'un ejercicio' : `${n} ejercicios`}. Los ejercicios siguen en el catálogo.`
      : 'La rutina está vacía.',
    confirmLabel: 'Sí, borrar rutina',
    danger: true,
  })
  if (!ok) return
  deleting.value = true
  try {
    await routines.remove(id)
    toast.ok('Rutina borrada')
    await navigateTo('/')
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
  <AppHeader :title="routine?.name ?? 'Rutina'" back="/" />

  <AppLoading v-if="status === 'pending' && !routine" />
  <div v-else-if="error" class="flex flex-col gap-3 p-4">
    <ErrorBox :message="friendlyError(error)" />
    <AppButton variant="secondary" block @click="refresh()">Probar de nuevo</AppButton>
  </div>
  <EmptyState v-else-if="!routine" icon="alert" title="No encontramos esta rutina" text="Puede que la hayas borrado.">
    <AppButton variant="secondary" block to="/">Ver mis rutinas</AppButton>
  </EmptyState>

  <div v-else class="flex flex-col gap-4 p-4">
    <EmptyState
      v-if="!items.length && !editing"
      title="Esta rutina está vacía"
      text="Agregá los ejercicios que hacés este día."
    >
      <AppButton size="lg" block :to="`/rutinas/${id}/agregar`">
        <AppIcon name="plus" :size="20" />
        Agregar ejercicio
      </AppButton>
    </EmptyState>

    <template v-else>
      <p v-if="editing" class="rounded-xl bg-primary-soft p-3 text-sm text-primary-strong">
        Usá las flechas para cambiar el orden. Cuando termines, tocá <strong>Listo</strong>.
      </p>
      <label v-else class="flex min-h-12 cursor-pointer items-center justify-between gap-3 rounded-xl bg-white px-4">
        <span class="text-sm font-semibold">Agrupar por músculo</span>
        <input v-model="grouped" type="checkbox" role="switch" class="peer sr-only">
        <span
          class="relative h-7 w-12 shrink-0 rounded-full bg-line transition-colors peer-checked:bg-primary peer-focus-visible:outline-3 peer-focus-visible:outline-primary after:absolute after:top-0.5 after:left-0.5 after:size-6 after:rounded-full after:bg-white after:shadow after:transition-transform peer-checked:after:translate-x-5"
          aria-hidden="true"
        />
      </label>

      <section v-for="section in sections" :key="section.key" class="flex flex-col gap-2">
        <h2 v-if="section.title" class="mt-2 text-sm font-bold tracking-wide text-muted uppercase">{{ section.title }}</h2>
        <RoutineExerciseCard
          v-for="item in section.items"
          :key="item.id"
          :item="item"
          :editing="editing"
          :first="items.indexOf(item) === 0"
          :last="items.indexOf(item) === items.length - 1"
          @settings="openSettings(item)"
          @up="move(items.indexOf(item), -1)"
          @down="move(items.indexOf(item), 1)"
          @remove="removeItem(item)"
        />
      </section>

      <div v-if="editing" class="flex flex-col gap-3 border-t border-line pt-4">
        <AppButton variant="secondary" block @click="renameError = ''; renaming = true">
          <AppIcon name="edit" :size="20" />
          Cambiar el nombre
        </AppButton>
        <AppButton variant="danger" block :loading="deleting" @click="removeRoutine">
          <AppIcon name="trash" :size="20" />
          Borrar rutina
        </AppButton>
        <AppButton size="lg" block @click="editing = false">
          <AppIcon name="check" :size="20" />
          Listo
        </AppButton>
      </div>
      <div v-else class="flex flex-col gap-3">
        <AppButton size="lg" block :to="`/rutinas/${id}/agregar`">
          <AppIcon name="plus" :size="20" />
          Agregar ejercicio
        </AppButton>
        <AppButton variant="secondary" block @click="editing = true">
          <AppIcon name="edit" :size="20" />
          Editar rutina
        </AppButton>
      </div>
    </template>

    <!-- Rutina vacía: igual se puede renombrar o borrar -->
    <div v-if="!items.length && !editing" class="flex flex-col gap-3">
      <AppButton variant="secondary" block @click="editing = true">
        <AppIcon name="edit" :size="20" />
        Editar rutina
      </AppButton>
    </div>
  </div>

  <AppSheet v-model:open="settingsOpen" :title="settingsItem?.exercise.name ?? ''">
    <form class="flex flex-col gap-4" novalidate @submit.prevent="saveSettings">
      <ItemSettingsFields v-model="settingsDraft" />
      <AppButton type="submit" size="lg" block :loading="savingSettings">Guardar</AppButton>
    </form>
  </AppSheet>

  <RoutineNameSheet
    v-model:open="renaming"
    title="Cambiar el nombre"
    submit-label="Guardar"
    :initial-name="routine?.name"
    :loading="savingName"
    :error="renameError"
    @save="rename"
  />
</template>
