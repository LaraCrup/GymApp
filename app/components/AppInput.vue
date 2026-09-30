<script setup lang="ts">
import type { InputTypeHTMLAttribute, HTMLAttributes } from 'vue'

const model = defineModel<string>({ required: true })

defineProps<{
  label: string
  type?: InputTypeHTMLAttribute
  autocomplete?: string
  inputmode?: HTMLAttributes['inputmode']
  placeholder?: string
  enterkeyhint?: HTMLAttributes['enterKeyHint']
  hint?: string
  error?: string
  /** Toma el foco al abrirse el panel que lo contiene. */
  autofocus?: boolean
  /** Oculta la etiqueta visualmente (sigue disponible para lectores de pantalla). */
  hideLabel?: boolean
}>()

const id = useId()
const slots = useSlots()
</script>

<template>
  <div class="flex flex-col gap-1.5">
    <label :for="id" class="text-sm font-semibold text-ink/90" :class="{ 'sr-only': hideLabel }">{{ label }}</label>
    <p v-if="hint" :id="`${id}-hint`" class="text-sm text-muted">{{ hint }}</p>
    <div class="flex items-stretch gap-2">
      <!-- text-base (16px) es el mínimo para que iPhone no haga zoom al tocar el campo. -->
      <div class="relative min-w-0 flex-1">
        <input
          :id="id"
          v-model="model"
          :type="type ?? 'text'"
          :autocomplete="autocomplete"
          :inputmode="inputmode"
          :placeholder="placeholder"
          :enterkeyhint="enterkeyhint"
          :autofocus="autofocus"
          :aria-invalid="error ? true : undefined"
          :aria-describedby="[hint && `${id}-hint`, error && `${id}-error`].filter(Boolean).join(' ') || undefined"
          class="min-h-12 w-full min-w-0 rounded-xl border bg-field px-4 text-base transition outline-none focus:border-primary focus:bg-primary-soft/40 focus:ring-4 focus:ring-primary/15"
          :class="[error ? 'border-danger' : 'border-line', { 'pr-14': slots.inside }]"
        >
        <!-- Botón dentro del campo, a la derecha (por ejemplo, el ojito de la contraseña). -->
        <slot name="inside" />
      </div>
      <slot name="after" />
    </div>
    <p v-if="error" :id="`${id}-error`" class="text-sm font-semibold text-danger">{{ error }}</p>
  </div>
</template>
