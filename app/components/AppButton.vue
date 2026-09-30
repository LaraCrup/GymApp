<script setup lang="ts">
import type { RouteLocationRaw } from 'vue-router'

type Variant = 'primary' | 'secondary' | 'danger' | 'ghost' | 'danger-ghost'

const props = withDefaults(
  defineProps<{
    variant?: Variant
    size?: 'md' | 'lg'
    to?: RouteLocationRaw
    type?: 'button' | 'submit'
    loading?: boolean
    disabled?: boolean
    block?: boolean
  }>(),
  { variant: 'primary', size: 'md', type: 'button' },
)

const variants: Record<Variant, string> = {
  primary: 'bg-primary text-white active:bg-primary-strong',
  secondary: 'bg-white text-primary border-2 border-primary active:bg-primary-soft',
  danger: 'bg-danger text-white active:bg-red-900',
  ghost: 'bg-transparent text-primary active:bg-primary-soft',
  'danger-ghost': 'bg-transparent text-danger active:bg-danger-soft',
}

const classes = computed(() => [
  'inline-flex items-center justify-center gap-2 rounded-xl font-semibold select-none',
  'transition-colors disabled:opacity-50 disabled:pointer-events-none',
  props.size === 'lg' ? 'min-h-14 px-6 text-base' : 'min-h-12 px-4 text-base',
  props.block && 'w-full',
  variants[props.variant],
])
</script>

<template>
  <NuxtLink v-if="to" :to="to" :class="classes">
    <slot />
  </NuxtLink>
  <button
    v-else
    :type="type"
    :disabled="disabled || loading"
    :aria-busy="loading || undefined"
    :class="classes"
  >
    <AppSpinner v-if="loading" />
    <slot />
  </button>
</template>
