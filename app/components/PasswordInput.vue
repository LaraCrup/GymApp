<script setup lang="ts">
const model = defineModel<string>({ required: true })

defineProps<{
  label: string
  autocomplete: 'current-password' | 'new-password'
  hint?: string
  error?: string
}>()

// Poder ver lo que se escribe evita la mayoría de los errores de tipeo en el celular.
const visible = ref(false)
</script>

<template>
  <AppInput
    v-model="model"
    :label="label"
    :type="visible ? 'text' : 'password'"
    :autocomplete="autocomplete"
    :hint="hint"
    :error="error"
  >
    <template #after>
      <button
        type="button"
        class="min-h-14 shrink-0 rounded-xl border-2 border-line bg-white px-3 text-base font-semibold text-primary active:bg-primary-soft"
        :aria-pressed="visible"
        @click="visible = !visible"
      >
        {{ visible ? 'Ocultar' : 'Mostrar' }}
      </button>
    </template>
  </AppInput>
</template>
