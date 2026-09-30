export type ToastKind = 'ok' | 'error' | 'info'

export interface Toast {
  id: number
  kind: ToastKind
  message: string
}

let nextId = 1

export function useToast() {
  // Un solo mensaje a la vez: el nuevo reemplaza al anterior, en el celular no hay lugar para apilar.
  const current = useState<Toast | null>('toast', () => null)

  function dismiss() {
    current.value = null
  }

  function show(message: string, kind: ToastKind) {
    const id = nextId++
    current.value = { id, kind, message }
    // Los errores quedan más tiempo para que dé tiempo a leerlos.
    setTimeout(() => {
      if (current.value?.id === id) dismiss()
    }, kind === 'error' ? 7000 : 2500)
  }

  return {
    current,
    dismiss,
    ok: (message: string) => show(message, 'ok'),
    error: (message: string) => show(message, 'error'),
    info: (message: string) => show(message, 'info'),
  }
}
