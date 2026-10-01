<script setup lang="ts">
const { current, dismiss } = useToast()

const styles = {
  ok: 'border-ok/40 text-ok',
  error: 'border-danger/50 text-danger',
  info: 'border-line text-ink',
} as const
</script>

<template>
  <!-- Arriba a la derecha, debajo de la hora y la batería del celular. -->
  <div
    class="pointer-events-none fixed inset-x-0 z-40 flex justify-end px-3"
    style="top: calc(env(safe-area-inset-top) + 0.5rem)"
    aria-live="polite"
  >
    <Transition
      mode="out-in"
      enter-from-class="translate-x-6 opacity-0"
      leave-to-class="translate-x-6 opacity-0"
      enter-active-class="transition duration-200 ease-out"
      leave-active-class="transition duration-150 ease-in"
    >
      <div
        v-if="current"
        :key="current.id"
        :role="current.kind === 'error' ? 'alert' : 'status'"
        class="pointer-events-auto flex max-w-sm items-center gap-2 rounded-2xl border bg-elevated/95 py-1 pr-1 pl-3 text-sm font-semibold shadow-[0_12px_32px_rgb(0_0_0/0.5)] backdrop-blur-xl"
        :class="styles[current.kind]"
      >
        <AppIcon :name="current.kind === 'error' ? 'alert' : 'check'" :size="20" class="shrink-0" />
        <span class="min-w-0 flex-1 py-2 text-ink">{{ current.message }}</span>
        <NuxtLink
          v-if="current.action"
          :to="current.action.to"
          class="flex min-h-10 shrink-0 items-center rounded-lg px-2 text-primary active:bg-primary-soft"
          @click="dismiss"
        >
          {{ current.action.label }}
        </NuxtLink>
        <button
          type="button"
          class="flex size-10 shrink-0 items-center justify-center rounded-full text-muted active:bg-field"
          aria-label="Cerrar aviso"
          @click="dismiss"
        >
          <AppIcon name="close" :size="18" />
        </button>
      </div>
    </Transition>
  </div>
</template>
