<script setup lang="ts">
// Crear o renombrar una rutina: un solo campo, no merece una pantalla aparte.
const open = defineModel<boolean>('open', { required: true })
const props = defineProps<{ title: string; submitLabel: string; initialName?: string; loading?: boolean; error?: string }>()
const emit = defineEmits<{ save: [name: string] }>()

const name = ref('')
const localError = ref('')
watch(open, value => {
  if (value) {
    name.value = props.initialName ?? ''
    localError.value = ''
  }
}, { immediate: true })

function submit() {
  localError.value = name.value.trim() ? '' : 'Poné un nombre, por ejemplo «Día 1 - Piernas».'
  if (!localError.value) emit('save', name.value.trim())
}
</script>

<template>
  <AppSheet v-model:open="open" :title="title">
    <form class="flex flex-col gap-4" novalidate @submit.prevent="submit">
      <AppInput
        v-model="name"
        label="Nombre de la rutina"
        autocomplete="off"
        placeholder="Ej: Día 1 - Piernas"
        enterkeyhint="done"
        autofocus
        :error="localError"
      />
      <ErrorBox :message="error" />
      <AppButton type="submit" size="lg" block :loading="loading">{{ submitLabel }}</AppButton>
    </form>
  </AppSheet>
</template>
