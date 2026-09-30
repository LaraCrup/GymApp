<script setup lang="ts">
import type { InputTypeHTMLAttribute, HTMLAttributes } from 'vue'

const model = defineModel<string>({ required: true })

defineProps<{
  label: string
  type?: InputTypeHTMLAttribute
  autocomplete?: string
  inputmode?: HTMLAttributes['inputmode']
  hint?: string
  error?: string
}>()

const id = useId()
</script>

<template>
  <div class="flex flex-col gap-1.5">
    <label :for="id" class="text-sm font-semibold">{{ label }}</label>
    <p v-if="hint" :id="`${id}-hint`" class="text-sm text-muted">{{ hint }}</p>
    <div class="flex items-stretch gap-2">
      <!-- text-base (16px) es el mínimo para que iPhone no haga zoom al tocar el campo. -->
      <input
        :id="id"
        v-model="model"
        :type="type ?? 'text'"
        :autocomplete="autocomplete"
        :inputmode="inputmode"
        :aria-invalid="error ? true : undefined"
        :aria-describedby="[hint && `${id}-hint`, error && `${id}-error`].filter(Boolean).join(' ') || undefined"
        class="min-h-12 w-full min-w-0 rounded-xl border-2 bg-white px-4 text-base outline-none focus:border-primary"
        :class="error ? 'border-danger' : 'border-line'"
      >
      <slot name="after" />
    </div>
    <p v-if="error" :id="`${id}-error`" class="text-sm font-semibold text-danger">{{ error }}</p>
  </div>
</template>
