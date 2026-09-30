<script setup lang="ts">
const { current, dismiss } = useToast()

const styles = {
  ok: 'bg-ok text-white',
  error: 'bg-danger text-white',
  info: 'bg-ink text-white',
} as const
</script>

<template>
  <!-- Queda arriba de la barra inferior, cerca del pulgar y sin tapar el contenido de arriba. -->
  <div
    class="pointer-events-none fixed inset-x-0 z-40 flex justify-center px-4"
    style="bottom: calc(4.5rem + env(safe-area-inset-bottom))"
    aria-live="polite"
  >
    <Transition
      mode="out-in"
      enter-from-class="translate-y-4 opacity-0"
      leave-to-class="opacity-0"
      enter-active-class="transition duration-200"
      leave-active-class="transition duration-150"
    >
      <!-- Aviso, no botón: se va solo. Tocarlo lo cierra antes, como atajo. -->
      <div
        v-if="current"
        :key="current.id"
        :role="current.kind === 'error' ? 'alert' : 'status'"
        class="pointer-events-auto flex w-full max-w-md items-center gap-3 rounded-xl px-4 py-3 text-sm font-semibold shadow-lg"
        :class="styles[current.kind]"
        @click="dismiss"
      >
        <AppIcon :name="current.kind === 'error' ? 'alert' : 'check'" :size="20" />
        <span class="flex-1">{{ current.message }}</span>
      </div>
    </Transition>
  </div>
</template>
