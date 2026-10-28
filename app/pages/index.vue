<script setup lang="ts">
import type { RoutineSummary } from '~/composables/useRoutines'
import type { RoutineGroup } from '~/composables/useRoutineGroups'

useHead({ title: 'Mis rutinas' })

const routines = useRoutines()
const groups = useRoutineGroups()
const toast = useToast()
const { confirm } = useConfirm()

// deep: en Nuxt 4 los datos son shallowRef por defecto; acá se renombran y reordenan grupos
// en el lugar y la pantalla tiene que reaccionar a esos cambios.
const { data, status, error, refresh } = useLazyAsyncData('routines', async () => {
  const [groupList, routineList] = await Promise.all([groups.list(), routines.list()])
  return { groups: groupList, routines: routineList }
}, { deep: true })

const groupList = computed(() => data.value?.groups ?? [])
const routineList = computed(() => data.value?.routines ?? [])

/** La lista en secciones: cada grupo en su orden y, al final, lo que no está en ninguno. */
const sections = computed(() => {
  const inGroups = groupList.value.map(group => ({
    group,
    routines: routineList.value.filter(r => r.group_id === group.id),
  }))
  const loose = routineList.value.filter(r => !r.group_id)
  // Sin grupos la lista es plana, como siempre: la sección sin título es toda la lista.
  if (!groupList.value.length) return [{ group: null as RoutineGroup | null, routines: loose }]
  return loose.length ? [...inGroups, { group: null as RoutineGroup | null, routines: loose }] : inGroups
})

// ── Modo organizar: ordenar, renombrar y borrar grupos, y mover rutinas de grupo ──
const editing = ref(false)
watch(groupList, list => {
  if (!list.length) editing.value = false
})

// ── Nueva rutina (en un grupo o sin grupo) ──
const creatingIn = ref<RoutineGroup | null>(null)
const creatingRoutine = ref(false)
const savingRoutine = ref(false)
const routineError = ref('')

function openCreateRoutine(group: RoutineGroup | null) {
  creatingIn.value = group
  routineError.value = ''
  creatingRoutine.value = true
}

async function createRoutine(name: string) {
  savingRoutine.value = true
  routineError.value = ''
  try {
    const routine = await routines.create(name, creatingIn.value?.id ?? null)
    creatingRoutine.value = false
    toast.ok('Rutina creada')
    await navigateTo(`/rutinas/${routine.id}`)
  }
  catch (e) {
    routineError.value = friendlyError(e)
  }
  finally {
    savingRoutine.value = false
  }
}

// ── Grupos: crear, renombrar, borrar, ordenar ──
const creatingGroup = ref(false)
const renamingGroup = ref<RoutineGroup | null>(null)
const savingGroup = ref(false)
const groupError = ref('')

function openCreateGroup() {
  groupError.value = ''
  creatingGroup.value = true
}

async function createGroup(name: string) {
  savingGroup.value = true
  groupError.value = ''
  try {
    const group = await groups.create(name)
    data.value?.groups.push(group)
    creatingGroup.value = false
    editing.value = false
    toast.ok('Grupo creado')
  }
  catch (e) {
    groupError.value = friendlyError(e)
  }
  finally {
    savingGroup.value = false
  }
}

function openRenameGroup(group: RoutineGroup) {
  groupError.value = ''
  renamingGroup.value = group
}

async function renameGroup(name: string) {
  const group = renamingGroup.value
  if (!group) return
  savingGroup.value = true
  groupError.value = ''
  try {
    await groups.rename(group.id, name)
    group.name = name
    renamingGroup.value = null
    toast.ok('Guardado')
  }
  catch (e) {
    groupError.value = friendlyError(e)
  }
  finally {
    savingGroup.value = false
  }
}

async function removeGroup(group: RoutineGroup) {
  const n = routineList.value.filter(r => r.group_id === group.id).length
  const ok = await confirm({
    title: `¿Borrar el grupo «${group.name}»?`,
    message: n
      ? `${n === 1 ? 'Su rutina queda' : `Sus ${n} rutinas quedan`} sin grupo. No se borra ninguna rutina.`
      : 'El grupo está vacío.',
    confirmLabel: 'Sí, borrar grupo',
    danger: true,
  })
  if (!ok || !data.value) return
  try {
    await groups.remove(group.id)
    data.value.groups = data.value.groups.filter(g => g.id !== group.id)
    for (const r of data.value.routines) {
      if (r.group_id === group.id) r.group_id = null
    }
    toast.ok('Grupo borrado')
  }
  catch (e) {
    toast.error(friendlyError(e))
  }
}

async function moveGroup(index: number, delta: -1 | 1) {
  if (!data.value) return
  const list = data.value.groups
  const before = [...list]
  const [moved] = list.splice(index, 1)
  list.splice(index + delta, 0, moved!)
  try {
    await groups.reorder(list.map(g => g.id))
  }
  catch (e) {
    data.value.groups = before
    toast.error(friendlyError(e))
  }
}

// ── Mover una rutina de grupo ──
const moving = ref<RoutineSummary | null>(null)
const movingOpen = ref(false)
const savingMove = ref(false)
const moveError = ref('')

function openMove(routine: RoutineSummary) {
  moving.value = routine
  moveError.value = ''
  movingOpen.value = true
}

async function moveRoutineTo(groupId: string | null) {
  const routine = moving.value
  if (!routine) return
  savingMove.value = true
  moveError.value = ''
  try {
    await routines.setGroup(routine.id, groupId)
    routine.group_id = groupId
    movingOpen.value = false
    toast.ok(groupId ? 'Rutina movida' : 'Rutina sin grupo')
  }
  catch (e) {
    moveError.value = friendlyError(e)
  }
  finally {
    savingMove.value = false
  }
}

async function createGroupForRoutine(name: string) {
  savingMove.value = true
  moveError.value = ''
  try {
    const group = await groups.create(name)
    data.value?.groups.push(group)
    await moveRoutineTo(group.id)
  }
  catch (e) {
    moveError.value = friendlyError(e)
  }
  finally {
    savingMove.value = false
  }
}
</script>

<template>
  <AppHeader title="Mis rutinas">
    <template #action>
      <DownloadAppLink />
    </template>
  </AppHeader>

  <AppLoading v-if="status === 'pending' && !data" />
  <div v-else-if="error" class="flex flex-col gap-3 p-4">
    <ErrorBox :message="friendlyError(error)" />
    <AppButton variant="secondary" block @click="refresh()">Probar de nuevo</AppButton>
  </div>

  <EmptyState
    v-else-if="!routineList.length && !groupList.length"
    title="Todavía no tenés rutinas"
    text="Una rutina es la lista de ejercicios que hacés un día en el gimnasio. Por ejemplo: «Día 1 - Piernas»."
  >
    <AppButton size="lg" block @click="openCreateRoutine(null)">
      <AppIcon name="plus" :size="20" />
      Crear mi primera rutina
    </AppButton>
  </EmptyState>

  <div v-else class="flex flex-col gap-4 p-4">
    <!-- Con grupos aparece el modo para ordenarlos, renombrarlos, borrarlos y mover rutinas. -->
    <div v-if="groupList.length" class="flex justify-end">
      <button
        type="button"
        class="flex min-h-11 items-center gap-1.5 rounded-xl px-3 text-sm font-semibold text-primary active:bg-primary-soft"
        @click="editing = !editing"
      >
        <AppIcon :name="editing ? 'check' : 'edit'" :size="18" />
        {{ editing ? 'Listo' : 'Organizar' }}
      </button>
    </div>

    <section v-for="(section, si) in sections" :key="section.group?.id ?? 'sin-grupo'" class="flex flex-col gap-2">
      <!-- Modo edición: el grupo con sus flechas, el lápiz y el tacho. -->
      <div v-if="editing && section.group" class="card flex flex-col gap-3 rounded-2xl p-3">
        <p class="truncate font-semibold">{{ section.group.name }}</p>
        <div class="flex items-center gap-1">
          <button
            type="button"
            class="flex size-12 items-center justify-center rounded-xl border border-line bg-field text-primary active:bg-primary-soft disabled:opacity-30"
            :aria-label="`Subir ${section.group.name}`"
            :disabled="si === 0"
            @click="moveGroup(si, -1)"
          >
            <AppIcon name="up" :size="20" />
          </button>
          <button
            type="button"
            class="flex size-12 items-center justify-center rounded-xl border border-line bg-field text-primary active:bg-primary-soft disabled:opacity-30"
            :aria-label="`Bajar ${section.group.name}`"
            :disabled="si === groupList.length - 1"
            @click="moveGroup(si, 1)"
          >
            <AppIcon name="down" :size="20" />
          </button>
          <span class="flex-1" />
          <button
            type="button"
            class="flex size-12 items-center justify-center rounded-xl border border-line bg-field text-primary active:bg-primary-soft"
            :aria-label="`Cambiar el nombre de ${section.group.name}`"
            @click="openRenameGroup(section.group)"
          >
            <AppIcon name="edit" :size="20" />
          </button>
          <button
            type="button"
            class="flex size-12 items-center justify-center rounded-xl border border-danger/40 bg-danger-soft text-danger active:bg-danger/25"
            :aria-label="`Borrar el grupo ${section.group.name}`"
            @click="removeGroup(section.group)"
          >
            <AppIcon name="trash" :size="20" />
          </button>
        </div>
      </div>

      <!-- Título del grupo, con el "+" para crear una rutina adentro. -->
      <header v-else-if="section.group" class="flex items-center gap-2 pl-1">
        <h2 class="min-w-0 flex-1 truncate text-sm font-bold tracking-wide text-muted uppercase">
          {{ section.group.name }}
        </h2>
        <button
          type="button"
          class="flex size-11 shrink-0 items-center justify-center rounded-full border border-primary/40 bg-primary-soft text-primary active:bg-primary/25"
          :aria-label="`Nueva rutina en ${section.group.name}`"
          @click="openCreateRoutine(section.group)"
        >
          <AppIcon name="plus" :size="20" />
        </button>
      </header>
      <!-- "Sin grupo" solo tiene sentido como título cuando hay grupos. -->
      <h2
        v-else-if="groupList.length"
        class="pl-1 text-sm font-bold tracking-wide text-muted uppercase"
      >
        Sin grupo
      </h2>

      <p v-if="!section.routines.length" class="card rounded-2xl px-4 py-3 text-sm text-muted">
        Este grupo todavía no tiene rutinas.
      </p>
      <ul v-else class="flex flex-col gap-2">
        <li v-for="(r, i) in section.routines" :key="r.id">
          <RoutineCard :routine="r" :number="i + 1" :editing="editing" @move="openMove(r)" />
        </li>
      </ul>
    </section>

    <div class="flex flex-col gap-2">
      <AppButton variant="secondary" block @click="openCreateRoutine(null)">
        <AppIcon name="plus" :size="20" />
        Nueva rutina
      </AppButton>
      <AppButton variant="ghost" block @click="openCreateGroup">
        <AppIcon name="folder" :size="20" />
        Nuevo grupo
      </AppButton>
    </div>
  </div>

  <NameSheet
    v-model:open="creatingRoutine"
    :title="creatingIn ? `Nueva rutina en «${creatingIn.name}»` : 'Nueva rutina'"
    submit-label="Crear rutina"
    :loading="savingRoutine"
    :error="routineError"
    @save="createRoutine"
  />

  <NameSheet
    v-model:open="creatingGroup"
    title="Nuevo grupo"
    submit-label="Crear grupo"
    label="Nombre del grupo"
    placeholder="Ej: Gimnasio"
    empty-error="Poné un nombre, por ejemplo «Gimnasio»."
    :loading="savingGroup"
    :error="groupError"
    @save="createGroup"
  />

  <NameSheet
    :open="renamingGroup !== null"
    title="Cambiar el nombre del grupo"
    submit-label="Guardar"
    label="Nombre del grupo"
    placeholder="Ej: Gimnasio"
    empty-error="Poné un nombre, por ejemplo «Gimnasio»."
    :initial-name="renamingGroup?.name"
    :loading="savingGroup"
    :error="groupError"
    @update:open="open => { if (!open) renamingGroup = null }"
    @save="renameGroup"
  />

  <RoutineGroupSheet
    v-model:open="movingOpen"
    :groups="groupList"
    :current-id="moving?.group_id ?? null"
    :loading="savingMove"
    :error="moveError"
    @select="moveRoutineTo"
    @create="createGroupForRoutine"
  />
</template>
