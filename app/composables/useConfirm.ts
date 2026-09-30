export interface ConfirmOptions {
  title: string
  message?: string
  confirmLabel?: string
  cancelLabel?: string
  danger?: boolean
}

interface PendingConfirm extends ConfirmOptions {
  resolve: (confirmed: boolean) => void
}

// Estado a nivel módulo: la app es SPA, no hay riesgo de compartirlo entre requests.
const pending = shallowRef<PendingConfirm | null>(null)

export function useConfirm() {
  /** Abre el diálogo y resuelve `true` solo si la persona confirma explícitamente. */
  function confirm(options: ConfirmOptions): Promise<boolean> {
    pending.value?.resolve(false)
    return new Promise(resolve => {
      pending.value = { ...options, resolve }
    })
  }

  function answer(confirmed: boolean) {
    pending.value?.resolve(confirmed)
    pending.value = null
  }

  return { confirm, answer, pending: readonly(pending) }
}
