import { onScopeDispose, ref } from 'vue'

export type SaveStatus = 'idle' | 'pending' | 'saving' | 'saved' | 'error'

/**
 * Guarda automáticamente un tiempo después del último cambio.
 * Tocar "+1" cinco veces seguidas = una sola escritura con el valor final.
 * Si falla, el valor queda pendiente para reintentar; nunca se pierde en silencio.
 * Al salir de la pantalla se guarda lo pendiente en el momento.
 */
export function useAutoSave<T>(save: (value: T) => Promise<void>, delay = 1200) {
  const status = ref<SaveStatus>('idle')
  let timer: ReturnType<typeof setTimeout> | undefined
  let pending: { value: T } | null = null
  let inFlight: Promise<void> | null = null

  function schedule(value: T) {
    pending = { value }
    status.value = 'pending'
    clearTimeout(timer)
    // El error ya queda en `status`; quien quiera reaccionar lo mira ahí.
    timer = setTimeout(() => flush().catch(() => {}), delay)
  }

  async function flush(): Promise<void> {
    clearTimeout(timer)
    // De a una escritura por vez, así el último valor siempre es el que queda.
    if (inFlight) await inFlight.catch(() => {})
    if (!pending) return

    const { value } = pending
    pending = null
    status.value = 'saving'
    inFlight = save(value)
    try {
      await inFlight
      if (!pending) status.value = 'saved'
    }
    catch (e) {
      pending ??= { value }
      status.value = 'error'
      throw e
    }
    finally {
      inFlight = null
    }
  }

  onScopeDispose(() => {
    void flush().catch(() => {})
  })

  return { status, schedule, flush }
}
