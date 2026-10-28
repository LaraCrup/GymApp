<script setup lang="ts">
import type { RoutineGroup } from '~/composables/useRoutineGroups'

// Elegir en qué grupo ("carpeta") va la rutina. Si todavía no hay grupos, se crea el primero acá mismo.
const open = defineModel<boolean>('open', { required: true })
const props = defineProps<{
  groups: RoutineGroup[]
  currentId: string | null
  loading?: boolean
  error?: string
}>()
const emit = defineEmits<{ select: [groupId: string | null]; create: [name: string] }>()

const creating = ref(false)
const name = ref('')
const nameError = ref('')

// Al abrirse, siempre empieza mostrando la lista (salvo que no haya ningún grupo).
watch(open, value => {
  if (value) {
    creating.value = props.groups.length === 0
    name.value = ''
    nameError.value = ''
  }
}, { immediate: true })

function submit() {
  nameError.value = name.value.trim() ? '' : 'Poné un nombre, por ejemplo «Gimnasio».'
  if (!nameError.value) emit('create', name.value.trim())
}
</script>

<template>
  <AppSheet v-model:open="open" title="Grupo de la rutina">
    <div class="flex flex-col gap-4">
      <p class="text-sm text-muted">
        Los grupos ordenan la lista de «Mis rutinas». Por ejemplo: «Gimnasio», «Casa».
      </p>

      <ul class="flex flex-col gap-2">
        <li v-for="g in groups" :key="g.id">
          <button
            type="button"
            class="card flex min-h-14 w-full items-center gap-3 rounded-xl px-4 text-left font-semibold transition active:scale-[0.99] active:bg-primary-soft"
            :class="{ 'border-primary/60 bg-primary-soft text-primary': g.id === currentId }"
            :aria-current="g.id === currentId || undefined"
            @click="emit('select', g.id)"
          >
            <span class="min-w-0 flex-1 truncate">{{ g.name }}</span>
            <AppIcon v-if="g.id === currentId" name="check" :size="20" />
          </button>
        </li>
        <li v-if="groups.length">
          <button
            type="button"
            class="card flex min-h-14 w-full items-center gap-3 rounded-xl px-4 text-left font-semibold transition active:scale-[0.99] active:bg-primary-soft"
            :class="{ 'border-primary/60 bg-primary-soft text-primary': currentId === null }"
            :aria-current="currentId === null || undefined"
            @click="emit('select', null)"
          >
            <span class="min-w-0 flex-1 truncate">Sin grupo</span>
            <AppIcon v-if="currentId === null" name="check" :size="20" />
          </button>
        </li>
      </ul>

      <form v-if="creating" class="flex flex-col gap-3 border-t border-line pt-4" novalidate @submit.prevent="submit">
        <AppInput
          v-model="name"
          label="Nombre del grupo nuevo"
          autocomplete="off"
          placeholder="Ej: Gimnasio"
          enterkeyhint="done"
          autofocus
          :error="nameError"
        />
        <AppButton type="submit" size="lg" block :loading="loading">Crear grupo y mover acá</AppButton>
      </form>
      <AppButton v-else variant="secondary" block @click="creating = true">
        <AppIcon name="plus" :size="20" />
        Nuevo grupo
      </AppButton>

      <ErrorBox :message="error" />
    </div>
  </AppSheet>
</template>
