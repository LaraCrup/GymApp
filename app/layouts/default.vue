<script setup lang="ts">
// La app ocupa justo la pantalla (100dvh) y solo se desliza el contenido del medio.
// Arriba deja libre la zona de la hora y la batería; abajo, la barra queda en su lugar
// (con `position: fixed`, el iPhone la corría al rebotar la página).
const scroller = ref<HTMLElement>()
const route = useRoute()
const router = useRouter()

// Lo que se desliza ya no es la página: el lugar de cada pantalla se guarda y se repone a mano.
// Pantalla nueva → arriba de todo; "atrás" del celular → donde estaba.
const positions = new Map<string, number>()
let goingBack = false
const markBack = () => (goingBack = true)
const stopSaving = router.beforeEach((_to, from) => {
  if (scroller.value) positions.set(from.path, scroller.value.scrollTop)
})
onMounted(() => window.addEventListener('popstate', markBack))
onBeforeUnmount(() => {
  stopSaving()
  window.removeEventListener('popstate', markBack)
})

watch(() => route.path, path => {
  const top = goingBack ? positions.get(path) ?? 0 : 0
  goingBack = false
  requestAnimationFrame(() => scroller.value?.scrollTo({ top }))
}, { flush: 'post' })
</script>

<template>
  <div class="flex h-dvh flex-col pt-[env(safe-area-inset-top)]">
    <div ref="scroller" class="app-scroll min-h-0 flex-1 overflow-y-auto overscroll-contain">
      <div class="mx-auto max-w-xl pb-6">
        <slot />
      </div>
    </div>
    <BottomNav />
  </div>
</template>
