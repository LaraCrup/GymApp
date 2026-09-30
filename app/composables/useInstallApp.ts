/** ¿La app ya está instalada? ¿Se puede instalar con un botón o hay que explicar los pasos? */
export function useInstallApp() {
  const { $pwa } = useNuxtApp()

  const standalone = ref(false)
  const platform = ref<'ios' | 'android' | 'otro'>('otro')

  onMounted(() => {
    const nav = navigator as Navigator & { standalone?: boolean }
    standalone.value = window.matchMedia('(display-mode: standalone)').matches || nav.standalone === true
    const ua = navigator.userAgent
    // iPadOS se presenta como Mac; se reconoce por la pantalla táctil.
    if (/iphone|ipad|ipod/i.test(ua) || (/macintosh/i.test(ua) && navigator.maxTouchPoints > 1)) platform.value = 'ios'
    else if (/android/i.test(ua)) platform.value = 'android'
  })

  const installed = computed(() => standalone.value || !!$pwa?.isPWAInstalled)
  /** Chrome/Android ofrece instalar con un toque (evento beforeinstallprompt). */
  const canPrompt = computed(() => !!$pwa?.showInstallPrompt)

  async function install() {
    const choice = await $pwa?.install()
    return choice?.outcome === 'accepted'
  }

  return { installed, canPrompt, platform, install }
}
