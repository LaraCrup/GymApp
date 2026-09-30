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
    <template #inside>
      <button
        type="button"
        class="absolute inset-y-0 right-0 flex w-12 items-center justify-center rounded-r-xl text-muted transition-colors active:text-primary"
        :aria-label="visible ? 'Ocultar contraseña' : 'Mostrar contraseña'"
        :aria-pressed="visible"
        @click="visible = !visible"
      >
        <AppIcon :name="visible ? 'eye-off' : 'eye'" :size="22" />
      </button>
    </template>
  </AppInput>
</template>
