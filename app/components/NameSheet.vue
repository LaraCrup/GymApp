<script setup lang="ts">
// Poner o cambiar un nombre (una rutina, un grupo): un solo campo, no merece una pantalla aparte.
const open = defineModel<boolean>('open', { required: true })
const props = withDefaults(
  defineProps<{
    title: string
    submitLabel: string
    label?: string
    placeholder?: string
    /** Qué decir si lo dejan vacío. */
    emptyError?: string
    initialName?: string
    loading?: boolean
    error?: string
  }>(),
  {
    label: 'Nombre de la rutina',
    placeholder: 'Ej: Día 1 - Piernas',
    emptyError: 'Poné un nombre, por ejemplo «Día 1 - Piernas».',
  },
)
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
  localError.value = name.value.trim() ? '' : props.emptyError
  if (!localError.value) emit('save', name.value.trim())
}
</script>

<template>
  <AppSheet v-model:open="open" :title="title">
    <form class="flex flex-col gap-4" novalidate @submit.prevent="submit">
      <AppInput
        v-model="name"
        :label="label"
        autocomplete="off"
        :placeholder="placeholder"
        enterkeyhint="done"
        autofocus
        :error="localError"
      />
      <ErrorBox :message="error" />
      <AppButton type="submit" size="lg" block :loading="loading">{{ submitLabel }}</AppButton>
    </form>
  </AppSheet>
</template>
