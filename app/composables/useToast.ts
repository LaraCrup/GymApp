import type { RouteLocationRaw } from 'vue-router'

export type ToastKind = 'ok' | 'error' | 'info'

/** Botón opcional dentro del aviso, por ejemplo «Ver rutina». */
export interface ToastAction {
  label: string
  to: RouteLocationRaw
}

export interface Toast {
  id: number
  kind: ToastKind
  message: string
  action?: ToastAction
}

let nextId = 1

export function useToast() {
  // Un solo mensaje a la vez: el nuevo reemplaza al anterior, en el celular no hay lugar para apilar.
  const current = useState<Toast | null>('toast', () => null)

  function dismiss() {
    current.value = null
  }

  function show(message: string, kind: ToastKind, action?: ToastAction) {
    const id = nextId++
    current.value = { id, kind, message, action }
    // Los errores, y los avisos con botón, quedan más tiempo para que dé tiempo a leerlos (o tocarlo).
    setTimeout(() => {
      if (current.value?.id === id) dismiss()
    }, kind === 'error' ? 7000 : action ? 5000 : 3000)
  }

  return {
    current,
    dismiss,
    ok: (message: string, action?: ToastAction) => show(message, 'ok', action),
    error: (message: string) => show(message, 'error'),
    info: (message: string, action?: ToastAction) => show(message, 'info', action),
  }
}
