<script setup lang="ts">
import type { RoutineItem } from '~/composables/useRoutines'

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
  <AppHeader :title="routine?.name ?? 'Rutina'" back="/">
    <template v-if="routine && !editing" #action>
      <button
        type="button"
        class="mr-1 flex size-11 shrink-0 items-center justify-center rounded-full border border-primary/40 bg-primary-soft text-primary active:bg-primary/25"
        aria-label="Editar rutina"
        @click="editing = true"
      >
        <AppIcon name="edit" :size="22" />
      </button>
    </template>
    <!-- Arriba también: con una lista larga no hace falta bajar hasta el final para salir. -->
    <template v-else-if="editing" #action>
      <button
        type="button"
        class="flex min-h-12 shrink-0 items-center gap-1 rounded-xl px-3 font-semibold text-primary active:bg-primary-soft"
        @click="editing = false"
      >
        <AppIcon name="check" :size="20" />
        Listo
      </button>
    </template>
  </AppHeader>

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
      <!-- Modo edición: el nombre arriba, con el lápiz para cambiarlo. -->
      <div v-if="editing" class="flex items-center gap-3">
        <div class="min-w-0 flex-1">
          <p class="text-xs text-muted">Nombre de la rutina</p>
          <p class="truncate font-semibold">{{ routine.name }}</p>
        </div>
        <button
          type="button"
          class="flex size-11 shrink-0 items-center justify-center rounded-full border border-primary/40 bg-primary-soft text-primary active:bg-primary/25"
          aria-label="Cambiar el nombre"
          @click="renameError = ''; renaming = true"
        >
          <AppIcon name="edit" :size="20" />
        </button>
      </div>
      <div class="flex flex-col gap-2">
        <RoutineExerciseCard
          v-for="(item, index) in items"
          :key="item.id"
          :item="item"
          :number="index + 1"
          :editing="editing"
          :first="index === 0"
          :last="index === items.length - 1"
          @up="move(index, -1)"
          @down="move(index, 1)"
          @remove="removeItem(item)"
        />
      </div>

      <div v-if="editing" class="flex flex-col gap-3 border-t border-line pt-4">
        <AppButton size="lg" block @click="editing = false">
          <AppIcon name="check" :size="20" />
          Listo
        </AppButton>
        <AppButton variant="danger" block :loading="deleting" @click="removeRoutine">
          <AppIcon name="trash" :size="20" />
          Borrar rutina
        </AppButton>
      </div>
      <AppButton v-else size="lg" block :to="`/rutinas/${id}/agregar`">
        <AppIcon name="plus" :size="20" />
        Agregar ejercicio
      </AppButton>
    </template>
  </div>

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
